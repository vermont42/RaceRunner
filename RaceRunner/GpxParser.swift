//
//  GpxParser.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 5/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreLocation

struct ParseResult {
  let autoName: String
  let customName: String
  let locations: [CLLocation]
  let weather: String
  let temperature: Float
  let weight: Double
  
  init(autoName: String, customName: String, locations: [CLLocation], weather: String, temperature: Float, weight: Double) {
    self.autoName = autoName
    self.customName = customName
    self.locations = locations
    self.weather = weather
    self.temperature = temperature
    self.weight = weight
  }
}

class GpxParser: NSObject, XMLParserDelegate {
  fileprivate var parser: XMLParser?
  fileprivate var autoName = Run.noAutoName
  fileprivate var customName = Run.noCustomName
  fileprivate var weather = Run.noWeather
  fileprivate var temperature = Run.noTemperature
  fileprivate var weight = Run.noWeight
  fileprivate var locations: [CLLocation] = []
  fileprivate var buffer = ""
  fileprivate let dateFormatter = DateFormatter()
  fileprivate var curLatString: NSString = ""
  fileprivate var curLonString: NSString = ""
  fileprivate var curEleString: NSString = ""
  fileprivate var curTimeString: String = ""
  fileprivate var startedTrackPoints = false
  fileprivate var isRuntastic = false
  fileprivate static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
  fileprivate static let accuracy: CLLocationAccuracy = 5.0
  fileprivate enum ParsingState: String {
    case Trkpt = "trkpt"
    case AutoName = "name"
    case CustomName = "customName"
    case Weight = "weight"
    case Ele = "ele"
    case Time = "time"
    case Temperature = "temperature"
    case Weather = "weather"
    case Other = "other"
    init() {
      self = .AutoName
    }
  }
  fileprivate var alreadySetName = false
  fileprivate var parsingState: ParsingState = .AutoName
  fileprivate static let runtastic = "runtastic"
  fileprivate static let runtasticGarbage = ".000"
  fileprivate static let runtasticRunName = "Runtastic Run"
  static let parseError = "An error occurred during GPX parsing."
  
  convenience init?(file: String) {
    if let url = Bundle.main.url(forResource: file, withExtension: "gpx") {
      self.init(url: url)
    }
    else {
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
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    switch elementName {
    case ParsingState.Trkpt.rawValue:
      curLatString = attributeDict["lat"]! as NSString
      curLonString = attributeDict["lon"]! as NSString
      parsingState = .Trkpt
      startedTrackPoints = true
    case ParsingState.AutoName.rawValue:
      if !alreadySetName {
        buffer = ""
        parsingState = .AutoName
      }
    case ParsingState.CustomName.rawValue:
      buffer = ""
      parsingState = .CustomName
    case ParsingState.Ele.rawValue:
      buffer = ""
      parsingState = .Ele
    case ParsingState.Temperature.rawValue:
      buffer = ""
      parsingState = .Temperature
    case ParsingState.Weather.rawValue:
      buffer = ""
      parsingState = .Weather
    case ParsingState.Time.rawValue:
      if startedTrackPoints {
        buffer = ""
        parsingState = .Time
      }
    case ParsingState.Weight.rawValue:
      buffer = ""
      parsingState = .Weight
    default:
      parsingState = .Other
      break
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if !startedTrackPoints {
      if string == GpxParser.runtastic {
        isRuntastic = true
      }
    }
    if (startedTrackPoints || (parsingState == .AutoName && !alreadySetName) || (parsingState == .CustomName) || (parsingState == .Weight) || (parsingState == .Temperature) || (parsingState == .Weather)) && string != "\n" {
      buffer = buffer + string
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case ParsingState.Trkpt.rawValue:
      locations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: curLatString.doubleValue, longitude: curLonString.doubleValue), altitude: curEleString.doubleValue, horizontalAccuracy: GpxParser.accuracy, verticalAccuracy: GpxParser.accuracy, timestamp: dateFormatter.date(from: curTimeString)!))
    case ParsingState.AutoName.rawValue:
      if !alreadySetName {
        autoName = buffer
        alreadySetName = true
      }
    case ParsingState.CustomName.rawValue:
      customName = buffer
    case ParsingState.Ele.rawValue:
      curEleString = buffer as NSString
    case ParsingState.Temperature.rawValue:
      temperature = Float(buffer) ?? temperature
    case ParsingState.Weather.rawValue:
      weather = buffer
    case ParsingState.Weight.rawValue:
      weight = Double(buffer) ?? weight
    case ParsingState.Time.rawValue:
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
