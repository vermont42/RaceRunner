//
//  SettingsManager.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/26/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation

class SettingsManager {
    private static let settingsManager = SettingsManager()
    private var userDefaults: NSUserDefaults
    
    private var unitType: UnitType
    private static let unitTypeKey = "unitType"
    
    private var accent: Accent
    private static let accentKey = "accent"
    
    private var publishRun: Bool
    private static let publishRunKey = "publishRun"
    private static let publishRunDefault = false

    private var audibleSplits: Bool
    private static let audibleSplitsKey = "audibleSplits"
    private static let audibleSplitsDefault = true
    
    private var multiplier: Double
    private static let multiplierKey = "multiplier"
    private static let multiplierDefault = 5.0
  
    private var stopAfter: Double
    static let never: Double = 0.0
    static let minStopAfter: Double = 0.1
    static let maxStopAfter: Double = 500
    private static let stopAfterKey = "stopAfter"
    private static let stopAfterDefault = SettingsManager.never

    private var reportEvery: Double
    private static let reportEveryKey = "reportEvery"
    private static let reportEveryDefault = Converter.metersInMile
    
    private var alreadyMadeSampleRun: Bool
    private static let alreadyMadeSampleRunKey = "alreadyMadeSampleRun"
    private static let alreadyMadeSampleRunDefault = false
    
    private var calorieType: CalorieType
    private static let calorieTypeKey = "calorieType"
    
    private var weight: Double
    static let weightDefault: Double = HumanWeight.defaultWeight
    private static let weightKey = "weight"
    
    private init() {
        userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let storedUnitTypeString = userDefaults.stringForKey(SettingsManager.unitTypeKey) {
            unitType = UnitType(rawValue: storedUnitTypeString)!
        }
        else {
            unitType = UnitType()
            userDefaults.setObject(unitType.rawValue, forKey: SettingsManager.unitTypeKey)
            userDefaults.synchronize()
        }
        
        if let storedAccentString = userDefaults.stringForKey(SettingsManager.accentKey) {
            accent = Accent(rawValue: storedAccentString)!
        }
        else {
            accent = Accent()
            userDefaults.setObject(accent.rawValue, forKey: SettingsManager.accentKey)
            userDefaults.synchronize()
        }

        if let storedCalorieTypeString = userDefaults.stringForKey(SettingsManager.calorieTypeKey) {
            calorieType = CalorieType(rawValue: storedCalorieTypeString)!
        }
        else {
            calorieType = CalorieType()
            userDefaults.setObject(calorieType.rawValue, forKey: SettingsManager.calorieTypeKey)
            userDefaults.synchronize()
        }
        
        if let storedWeightString = userDefaults.stringForKey(SettingsManager.weightKey) {
            weight = (storedWeightString as NSString).doubleValue
        }
        else {
            weight = SettingsManager.weightDefault
            userDefaults.setObject(String(format:"%f", weight), forKey: SettingsManager.weightKey)
            userDefaults.synchronize()
        }
        
        if let storedPublishRunString = userDefaults.stringForKey(SettingsManager.publishRunKey) {
            publishRun = (storedPublishRunString as NSString).boolValue
        }
        else {
            publishRun = SettingsManager.publishRunDefault
            userDefaults.setObject("\(publishRun)", forKey: SettingsManager.publishRunKey)
            userDefaults.synchronize()
        }

        if let storedAudibleSplitsString = userDefaults.stringForKey(SettingsManager.audibleSplitsKey) {
            audibleSplits = (storedAudibleSplitsString as NSString).boolValue
        }
        else {
            audibleSplits = SettingsManager.audibleSplitsDefault
            userDefaults.setObject("\(audibleSplits)", forKey: SettingsManager.audibleSplitsKey)
            userDefaults.synchronize()
        }
        
        if let storedAlreadyMadeSampleRunString = userDefaults.stringForKey(SettingsManager.alreadyMadeSampleRunKey) {
            alreadyMadeSampleRun = (storedAlreadyMadeSampleRunString as NSString).boolValue
        }
        else {
            alreadyMadeSampleRun = SettingsManager.alreadyMadeSampleRunDefault
            userDefaults.setObject("\(alreadyMadeSampleRun)", forKey: SettingsManager.alreadyMadeSampleRunKey)
            userDefaults.synchronize()
        }
        
        if let storedMultiplierString = userDefaults.stringForKey(SettingsManager.multiplierKey) {
            multiplier = (storedMultiplierString as NSString).doubleValue
        }
        else {
            multiplier = SettingsManager.multiplierDefault
            userDefaults.setObject(String(format:"%f", multiplier), forKey: SettingsManager.multiplierKey)
            userDefaults.synchronize()
        }
        
        if let storedStopAfterString = userDefaults.stringForKey(SettingsManager.stopAfterKey) {
            stopAfter = (storedStopAfterString as NSString).doubleValue
        }
        else {
            stopAfter = SettingsManager.stopAfterDefault
            userDefaults.setObject(String(format:"%f", stopAfter), forKey: SettingsManager.stopAfterKey)
            userDefaults.synchronize()
        }
        
        if let storedReportEveryString = userDefaults.stringForKey(SettingsManager.reportEveryKey) {
            reportEvery = (storedReportEveryString as NSString).doubleValue
        }
        else {
            reportEvery = SettingsManager.reportEveryDefault
            userDefaults.setObject(String(format:"%f", reportEvery), forKey: SettingsManager.reportEveryKey)
            userDefaults.synchronize()
        }
    }
    
    class func getUnitType() -> UnitType {
        return settingsManager.unitType
    }

    class func setUnitType(unitType: UnitType) {
        if unitType != settingsManager.unitType {
            settingsManager.unitType = unitType
            settingsManager.userDefaults.setObject(unitType.rawValue, forKey: SettingsManager.unitTypeKey)
            settingsManager.userDefaults.synchronize()
        }
    }

    class func getCalorieType() -> CalorieType {
        return settingsManager.calorieType
    }
    
    class func setCalorieType(calorieType: CalorieType) {
        if calorieType != settingsManager.calorieType {
            settingsManager.calorieType = calorieType
            settingsManager.userDefaults.setObject(calorieType.rawValue, forKey: SettingsManager.calorieTypeKey)
            settingsManager.userDefaults.synchronize()
        }
    }
    
    class func getWeight() -> Double {
        return settingsManager.weight
    }
    
    class func setWeight(weight: Double) {
        if weight != settingsManager.weight {
            settingsManager.weight = weight
            settingsManager.userDefaults.setObject(String(format:"%f", weight), forKey: SettingsManager.weightKey)
            settingsManager.userDefaults.synchronize()
        }
    }
    
    class func getAccent() -> Accent {
        return settingsManager.accent
    }
    
    class func setAccent(accent: Accent) {
        if accent != settingsManager.accent {
            settingsManager.accent = accent
            settingsManager.userDefaults.setObject(accent.rawValue, forKey: SettingsManager.accentKey)
            settingsManager.userDefaults.synchronize()
        }
    }
    
    class func setAccent(accent: String) {
        SettingsManager.setAccent(Accent.stringToAccent(accent))
    }
    
    class func getAlreadyMadeSampleRun() -> Bool {
        return settingsManager.alreadyMadeSampleRun
    }
    
    class func setAlreadyMadeSampleRun(alreadyMadeSampleRun: Bool) {
        if alreadyMadeSampleRun != settingsManager.alreadyMadeSampleRun {
            settingsManager.alreadyMadeSampleRun = alreadyMadeSampleRun
            settingsManager.userDefaults.setObject("\(alreadyMadeSampleRun)", forKey: SettingsManager.alreadyMadeSampleRunKey)
            settingsManager.userDefaults.synchronize()
        }
    }

    class func getPublishRun() -> Bool {
        return settingsManager.publishRun
    }
    
    class func setPublishRun(publishRun: Bool) {
        if publishRun != settingsManager.publishRun {
            settingsManager.publishRun = publishRun
            settingsManager.userDefaults.setObject("\(publishRun)", forKey: SettingsManager.publishRunKey)
            settingsManager.userDefaults.synchronize()
        }
    }

    class func getAudibleSplits() -> Bool {
        return settingsManager.audibleSplits
    }
    
    class func setAudibleSplits(audibleSplits: Bool) {
        if audibleSplits != settingsManager.audibleSplits {
            settingsManager.audibleSplits = audibleSplits
            settingsManager.userDefaults.setObject("\(audibleSplits)", forKey: SettingsManager.audibleSplitsKey)
            settingsManager.userDefaults.synchronize()
        }
    }
    
    class func getMultiplier() -> Double {
        return settingsManager.multiplier
    }
    
    class func setMultiplier(multiplier: Double) {
        if multiplier != settingsManager.multiplier {
            settingsManager.multiplier = multiplier
            settingsManager.userDefaults.setObject(String(format:"%f", multiplier), forKey: SettingsManager.multiplierKey)
            settingsManager.userDefaults.synchronize()
        }
    }

    class func getReportEvery() -> Double {
        return settingsManager.reportEvery
    }
    
    class func setReportEvery(reportEvery: Double) {
        if reportEvery != settingsManager.reportEvery {
            settingsManager.reportEvery = reportEvery
            settingsManager.userDefaults.setObject(String(format:"%f", reportEvery), forKey: SettingsManager.reportEveryKey)
            settingsManager.userDefaults.synchronize()
        }
    }

    class func getStopAfter() -> Double {
        return settingsManager.stopAfter
    }
    
    class func setStopAfter(stopAfter: Double) {
        if stopAfter != settingsManager.stopAfter {
            settingsManager.stopAfter = stopAfter
            settingsManager.userDefaults.setObject(String(format:"%f", stopAfter), forKey: SettingsManager.stopAfterKey)
            settingsManager.userDefaults.synchronize()
        }
    }
}