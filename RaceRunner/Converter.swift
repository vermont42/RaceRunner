//
//  Converter.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/17/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import AVFoundation

class Converter {
    private static let metersInKilometer: Double = 1000.0
    static let metersInMile: Double = 1609.344
    private static let feetInMeter: Double = 3.281
    private static let fahrenheitMultiplier: Float = 9.0 / 5.0
    private static let celsiusFraction: Float = 5.0 / 9.0
    private static let fahrenheitAmountToAdd: Float = 32.0
    private static let celsiusMultiplier: Float = 1.0
    private static let celsiusAmountToAdd: Float = 0.0
    private static let altitudeFudge: Double = 5.0
    private static let secondsPerMinute: Int = 60
    private static let minutesPerHour: Int = 60
    private static let secondsPerHour: Int = 3600
    private static let fahrenheitUnitName: String = "F"
    private static let celsiusUnitName: String = "C"
    private static let imperialLongUnitName: String = "mi"
    private static let metricLongUnitName: String = "km"
    private static let imperialShortUnitName: String = "ft"
    private static let metricShortUnitName: String = "m"
    private static let imperialShortUnitUnabbreviatedName: String = "feet"
    private static let metricShortUnitUnabbreviatedName: String = "meters"
    
    private static let synth = AVSpeechSynthesizer()
    
    class func announceProgress(totalSeconds: Int, lastSeconds: Int, totalDistance: Double, lastDistance: Double, newAltitude: Double, oldAltitude: Double) {
        let totalLongDistance = convertMetersToLongDistance(totalDistance)
        let roundedDistance = NSString(format: "%.1f", totalLongDistance) as String
        var progressString = "total distance \(roundedDistance) \(pluralizedCurrentLongUnit(totalLongDistance)), total time \(stringifySecondCount(totalSeconds, useLongFormat: true)), split pace"
        let distanceDelta = totalDistance - lastDistance
        let secondsDelta = totalSeconds - lastSeconds
        progressString += stringifyPace(distanceDelta, seconds: secondsDelta, forSpeaking: true)
        let altitudeDelta = newAltitude - oldAltitude
        if altitudeDelta > 0.0 + altitudeFudge {
            progressString += ", gained \(stringifyAltitude(altitudeDelta, unabbreviated: true))"
        }
        else if altitudeDelta < 0.0 - altitudeFudge {
            progressString += ", lost \(stringifyAltitude(-altitudeDelta, unabbreviated: true)))"
        }
        else {
            progressString += ", no altitude change"
        }
        let utterance = AVSpeechUtterance(string: progressString)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "en-\(SettingsManager.getAccent().languageCode())")        
        utterance.pitchMultiplier = 0.8
        synth.speakUtterance(utterance)
    }
    
    class func pluralizedCurrentLongUnit(value: Double) -> String {
        switch SettingsManager.getUnitType() {
        case .Imperial:
            if value <= 1.0 {
                return "mile"
            }
            else {
                return "miles"
            }
        case .Metric:
            if value <= 1.0 {
                return "kilometer"
            }
            else {
                return "kilometers"
            }
        }
    }

    class func convertLongDistanceToMeters(longDistance: Double) -> Double {
        switch SettingsManager.getUnitType() {
        case .Imperial:
            return longDistance * metersInMile
        case .Metric:
            return longDistance * metersInKilometer
        }
    }

    class func convertMetersToLongDistance(meters: Double) -> Double {
        switch SettingsManager.getUnitType() {
        case .Imperial:
            return meters / metersInMile
        case .Metric:
            return meters / metersInKilometer
        }
    }
    
    class func getCurrentLongUnitName() -> String {
        return SettingsManager.getUnitType() == .Imperial ? "mile" : "kilometer"
    }

    class func getCurrentAbbreviatedLongUnitName() -> String {
        return SettingsManager.getUnitType() == .Imperial ? "mile" : "km"
    }
    
    class func getCurrentPluralLongUnitName() -> String {
        return SettingsManager.getUnitType() == .Imperial ? "miles" : "kms"
    }
    
    class func convertFahrenheitToCelsius(temperature: Float) -> Float {
        return celsiusFraction * (temperature - fahrenheitAmountToAdd)
    }
    
    class func stringifyDistance(meters: Double) -> String {
        var unitDivider: Double
        var unitName: String
        if SettingsManager.getUnitType() == .Metric {
            unitName = metricLongUnitName
            unitDivider = metersInKilometer
        }
        else {
            unitName = imperialLongUnitName
            unitDivider = metersInMile
        }
        return NSString(format: "%.2f %@", meters / unitDivider, unitName) as String
    }
    
    class func stringifySecondCount(seconds: Int, useLongFormat: Bool, useLongUnits: Bool = false) -> String {
        var remainingSeconds = seconds
        let hours = remainingSeconds / secondsPerHour
        remainingSeconds -= hours * secondsPerHour
        let minutes = remainingSeconds / secondsPerMinute
        remainingSeconds -= minutes * secondsPerMinute
        if useLongFormat {
            if useLongUnits {
                if hours > 0 {
                    return NSString(format: "%d hour %d minutes %d seconds", hours, minutes, remainingSeconds) as String
                } else if minutes > 0 {
                    return NSString(format: "%d minutes %d seconds", minutes, remainingSeconds) as String
                } else {
                    return NSString(format: "%d seconds", remainingSeconds) as String
                }
            }
            else {
                if hours > 0 {
                    return NSString(format: "%d hr %d min %d sec", hours, minutes, remainingSeconds) as String
                } else if minutes > 0 {
                    return NSString(format: "%d min %d sec", minutes, remainingSeconds) as String
                } else {
                    return NSString(format: "%d sec", remainingSeconds) as String
                }
            }
        }
        else {
            if hours > 0 {
                return NSString(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds) as String
            } else if minutes > 0 {
                return NSString(format: "%02d:%02d", minutes, remainingSeconds) as String
            } else {
                return NSString(format: "%02d", remainingSeconds) as String
            }
        }
    }
    
    class func stringifyPace(meters: Double, seconds:Int, forSpeaking:Bool = false) -> String {
        if seconds == 0 || meters == 0.0 {
            return "0"
        }
        
        let avgPaceSecMeters = Double(seconds) / meters
        var unitMultiplier: Double
        var unitName: String
        if forSpeaking {
            if SettingsManager.getUnitType() == .Metric {
                unitName = getCurrentLongUnitName()
                unitMultiplier = metersInKilometer
            }
            else {
                unitName = getCurrentLongUnitName()
                unitMultiplier = metersInMile
            }
        }
        else {
            if SettingsManager.getUnitType() == .Metric {
                unitName = "min/" + metricLongUnitName
                unitMultiplier = metersInKilometer
            }
            else {
                unitName = "min/" + imperialLongUnitName
                unitMultiplier = metersInMile
            }
        }
        let paceMin = Int((avgPaceSecMeters * unitMultiplier) / Double(secondsPerMinute))
        let paceSec = Int(avgPaceSecMeters * unitMultiplier - Double((paceMin * secondsPerMinute)))
        if forSpeaking {
            return NSString(format: "%d minutes %02d seconds per %@", paceMin, paceSec, unitName) as String
        }
        else {
            return NSString(format: "%d:%02d %@", paceMin, paceSec, unitName) as String
        }
    }

    class func stringifyAltitude(meters: Double, unabbreviated: Bool = false) -> String {
        var unitMultiplier: Double
        var unitName: String
        if SettingsManager.getUnitType() == .Metric {
            unitMultiplier = 1.0
            if !unabbreviated {
                unitName = metricShortUnitName
            }
            else {
                unitName = metricShortUnitUnabbreviatedName
            }
        }
        else {
            unitMultiplier = feetInMeter
            if !unabbreviated {
                unitName = imperialShortUnitName
            }
            else {
                unitName = imperialShortUnitUnabbreviatedName
            }
        }
        return NSString(format: "%.0f %@", meters * unitMultiplier, unitName) as String
    }
    
    class func stringifyTemperature(temperature: Float) -> String {
        var unitName: String
        var multiplier: Float
        var amountToAdd: Float
        if SettingsManager.getUnitType() == .Metric {
            unitName = celsiusUnitName
            multiplier = celsiusMultiplier
            amountToAdd = celsiusAmountToAdd
        }
        else {
            unitName = fahrenheitUnitName
            multiplier = fahrenheitMultiplier
            amountToAdd = fahrenheitAmountToAdd
        }
        return NSString(format: "%.0f° %@", temperature * multiplier + amountToAdd, unitName) as String
    }
}