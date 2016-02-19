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

class GpxParser: NSObject, NSXMLParserDelegate {
  private var parser: NSXMLParser?
  private var autoName = Run.noAutoName
  private var customName = Run.noCustomName
  private var weather = Run.noWeather
  private var temperature = Run.noTemperature
  private var weight = Run.noWeight
  private var locations: [CLLocation] = []
  private var buffer = ""
  private let dateFormatter = NSDateFormatter()
  private var curLatString: NSString = ""
  private var curLonString: NSString = ""
  private var curEleString: NSString = ""
  private var curTimeString: String = ""
  private var startedTrackPoints = false
  private var isRuntastic = false
  private static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
  private static let accuracy: CLLocationAccuracy = 5.0
  private enum ParsingState: String {
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
  private var alreadySetName = false
  private var parsingState: ParsingState = .AutoName
  private static let runtastic = "runtastic"
  private static let runtasticGarbage = ".000"
  private static let runtasticRunName = "Runtastic Run"
  static let parseError = "An error occurred during GPX parsing."
  
  convenience init?(file: String) {
    if let url = NSBundle.mainBundle().URLForResource(file, withExtension: "gpx") {
      self.init(url: url)
    }
    else {
      return nil
    }
  }
  
  init?(url: NSURL) {
    super.init()
    parser = NSXMLParser(contentsOfURL: url)
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
  
  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    switch elementName {
    case ParsingState.Trkpt.rawValue:
      curLatString = attributeDict["lat"]!
      curLonString = attributeDict["lon"]!
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
  
  func parser(parser: NSXMLParser, foundCharacters string: String) {
    if !startedTrackPoints {
      if string == GpxParser.runtastic {
        isRuntastic = true
      }
    }
    if (startedTrackPoints || (parsingState == .AutoName && !alreadySetName) || (parsingState == .CustomName) || (parsingState == .Weight) || (parsingState == .Temperature) || (parsingState == .Weather)) && string != "\n" {
      buffer = buffer + string
    }
  }
  
  func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case ParsingState.Trkpt.rawValue:
      print("lat: \(curLatString.doubleValue) lon: \(curLonString.doubleValue) alt: \(curEleString.doubleValue) time: \(dateFormatter.dateFromString(curTimeString))")
      locations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: curLatString.doubleValue, longitude: curLonString.doubleValue), altitude: curEleString.doubleValue, horizontalAccuracy: GpxParser.accuracy, verticalAccuracy: GpxParser.accuracy, timestamp: dateFormatter.dateFromString(curTimeString)!))
    case ParsingState.AutoName.rawValue:
      autoName = buffer
      alreadySetName = true
    case ParsingState.CustomName.rawValue:
      customName = buffer
    case ParsingState.Ele.rawValue:
      curEleString = buffer
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
          curTimeString = curTimeString.stringByReplacingOccurrencesOfString(GpxParser.runtasticGarbage, withString: "")
          autoName = GpxParser.runtasticRunName
        }
      }
    default:
      break
    }
  }
}