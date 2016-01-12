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
    let name: String
    let locations: [CLLocation]
    let weather: String
    let temperature: Float
    
    init(name: String, locations: [CLLocation], weather: String, temperature: Float) {
        self.name = name
        self.locations = locations
        self.weather = weather
        self.temperature = temperature
    }
}

class GpxParser: NSObject, NSXMLParserDelegate {
    private var parser: NSXMLParser?
    private var name: String = ""
    private var weather = DarkSky.weatherError
    private var temperature = DarkSky.temperatureError
    private var locations: [CLLocation] = []
    private var buffer: String = ""
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
        case Name = "name"
        case Ele = "ele"
        case Time = "time"
        case Temperature = "temperature"
        case Weather = "weather"
        case Other = "other"
        init() {
            self = .Name
        }
    }
    private var alreadySetName = false
    private var parsingState: ParsingState = .Name
    private static let runtastic = "runtastic"
    private static let runtasticGarbage = ".000"
    private static let runtasticRunName = "Runtastic Run"
    
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
        return ParseResult(name: name, locations: locations, weather: weather, temperature: temperature)
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case ParsingState.Trkpt.rawValue:
            curLatString = attributeDict["lat"]!
            curLonString = attributeDict["lon"]!
            parsingState = .Trkpt
            startedTrackPoints = true
        case ParsingState.Name.rawValue:
            if !alreadySetName {
                buffer = ""
                parsingState = .Name
            }
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
        if (startedTrackPoints || (parsingState == .Name && !alreadySetName) || (parsingState == .Temperature) || (parsingState == .Weather)) && string != "\n" {
            buffer = buffer + string
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case ParsingState.Trkpt.rawValue:
            locations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: curLatString.doubleValue, longitude: curLonString.doubleValue), altitude: curEleString.doubleValue, horizontalAccuracy: GpxParser.accuracy, verticalAccuracy: GpxParser.accuracy, timestamp: dateFormatter.dateFromString(curTimeString)!))
        case ParsingState.Name.rawValue:
            name = buffer
            alreadySetName = true
        case ParsingState.Ele.rawValue:
            curEleString = buffer
        case ParsingState.Temperature.rawValue:
            temperature = Float(buffer) ?? temperature
        case ParsingState.Weather.rawValue:
            weather = buffer
        case ParsingState.Time.rawValue:
            if startedTrackPoints {
                curTimeString = buffer
                if isRuntastic {
                    curTimeString = curTimeString.stringByReplacingOccurrencesOfString(GpxParser.runtasticGarbage, withString: "")
                    name = GpxParser.runtasticRunName
                }
            }
        default:
            break
        }
    }
}