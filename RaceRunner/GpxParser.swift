//
//  GpxParser.swift
//  GpxLocationManager
//
//  Created by Josh Adams on 5/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import CoreLocation
import Foundation

struct ParseResult {
  let autoName: String
  let customName: String
  let locations: [CLLocation]
  let weather: String
  let temperature: Double
  let weight: Double
}

class GpxParser: NSObject, XMLParserDelegate {
  static let parseError = "An error occurred during GPX parsing."

  private static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
  private static let accuracy: CLLocationAccuracy = 5.0
  private static let runtastic = "runtastic"
  private static let runtasticGarbage = ".000"
  private static let runtasticRunName = "Runtastic Run"

  private var parser: XMLParser?
  private var autoName = Run.noAutoName
  private var customName = Run.noCustomName
  private var weather = Run.noWeather
  private var temperature = Run.noTemperature
  private var weight = Run.noWeight
  private var locations: [CLLocation] = []
  private var buffer = ""
  private let dateFormatter = DateFormatter()
  private var curLatString: NSString = ""
  private var curLonString: NSString = ""
  private var curEleString: NSString = ""
  private var curTimeString: String = ""
  private var startedTrackPoints = false
  private var isRuntastic = false
  private var alreadySetName = false
  private var parsingState: ParsingState = .autoName

  private enum ParsingState: String {
    case trkpt = "trkpt"
    case autoName = "name"
    case customName = "customName"
    case weight = "weight"
    case ele = "ele"
    case time = "time"
    case temperature = "temperature"
    case weather = "weather"
    case other = "other"
    init() {
      self = .autoName
    }
  }

  convenience init?(file: String) {
    if let url = Bundle.main.url(forResource: file, withExtension: "gpx") {
      self.init(url: url)
    } else {
      return nil
    }
  }

  init?(url: URL) {
    super.init()
    parser = XMLParser(contentsOf: url)
    if parser == nil {
      return nil
    }
    parser?.delegate = self
    dateFormatter.dateFormat = GpxParser.dateFormat
  }

  func parse() -> ParseResult {
    parser?.parse()
    return ParseResult(autoName: autoName, customName: customName, locations: locations, weather: weather, temperature: temperature, weight: weight)
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    switch elementName {
    case ParsingState.trkpt.rawValue:
      curLatString = attributeDict["lat"]! as NSString
      curLonString = attributeDict["lon"]! as NSString
      parsingState = .trkpt
      startedTrackPoints = true
    case ParsingState.autoName.rawValue:
      if !alreadySetName {
        buffer = ""
        parsingState = .autoName
      }
    case ParsingState.customName.rawValue:
      buffer = ""
      parsingState = .customName
    case ParsingState.ele.rawValue:
      buffer = ""
      parsingState = .ele
    case ParsingState.temperature.rawValue:
      buffer = ""
      parsingState = .temperature
    case ParsingState.weather.rawValue:
      buffer = ""
      parsingState = .weather
    case ParsingState.time.rawValue:
      if startedTrackPoints {
        buffer = ""
        parsingState = .time
      }
    case ParsingState.weight.rawValue:
      buffer = ""
      parsingState = .weight
    default:
      parsingState = .other
    }
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if !startedTrackPoints {
      if string == GpxParser.runtastic {
        isRuntastic = true
      }
    }
    if (startedTrackPoints || (parsingState == .autoName && !alreadySetName) || (parsingState == .customName) || (parsingState == .weight) || (parsingState == .temperature) || (parsingState == .weather)) && string != "\n" {
      buffer = buffer + string
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case ParsingState.trkpt.rawValue:
      locations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: curLatString.doubleValue, longitude: curLonString.doubleValue), altitude: curEleString.doubleValue, horizontalAccuracy: GpxParser.accuracy, verticalAccuracy: GpxParser.accuracy, timestamp: dateFormatter.date(from: curTimeString)!))
    case ParsingState.autoName.rawValue:
      if !alreadySetName {
        autoName = buffer
        alreadySetName = true
      }
    case ParsingState.customName.rawValue:
      customName = buffer
    case ParsingState.ele.rawValue:
      curEleString = buffer as NSString
    case ParsingState.temperature.rawValue:
      temperature = Double(buffer) ?? temperature
    case ParsingState.weather.rawValue:
      weather = buffer
    case ParsingState.weight.rawValue:
      weight = Double(buffer) ?? weight
    case ParsingState.time.rawValue:
      if startedTrackPoints {
        curTimeString = buffer
        if isRuntastic {
          curTimeString = curTimeString.replacingOccurrences(of: GpxParser.runtasticGarbage, with: "")
          autoName = GpxParser.runtasticRunName
        }
      }
    default:
      break
    }
  }
}
