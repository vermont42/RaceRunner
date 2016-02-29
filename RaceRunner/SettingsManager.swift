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
  
  private var logSortField: LogSortField
  private static let logSortFieldKey = "logSortField"

  private var shoesSortField: ShoesSortField
  private static let shoesSortFieldKey = "shoeSortField"
  
  private var sortType: SortType
  private static let sortTypeKey = "sortType"
  
  private var iconType: RunnerIcons.IconType
  private static let iconTypeKey = "iconType"
  
  private var accent: Accent
  private static let accentKey = "accent"
  
  private var overlay: Overlay
  private static let overlayKey = "overlay"
  
  private var broadcastRun: Bool
  private static let broadcastRunKey = "broadcastRun"
  private static let broadcastRunDefault = false

  private var allowStop: Bool
  private static let allowStopKey = "allowStop"
  private static let allowStopDefault = false

  private var broadcastAvailability: Bool
  private static let broadcastAvailabilityKey = "broadcastAvailability"
  private static let broadcastAvailabilityDefault = false

  private var broadcastName: String
  private static let broadcastNameKey = "broadcastName"
  private static let broadcastNameDefault = ""
  
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
  
  private var weight: Double
  static let weightDefault: Double = HumanWeight.defaultWeight
  private static let weightKey = "weight"
  
  private var showWeight: Bool
  private static let showWeightKey = "showWeight"
  private static let showWeightDefault = true
  
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
    
    if let storedSortTypeString = userDefaults.stringForKey(SettingsManager.sortTypeKey) {
      sortType = SortType(rawValue: storedSortTypeString)!
    }
    else {
      sortType = SortType()
      userDefaults.setObject(sortType.rawValue, forKey: SettingsManager.sortTypeKey)
      userDefaults.synchronize()
    }
    
    if let storedIconTypeString = userDefaults.stringForKey(SettingsManager.iconTypeKey) {
      iconType = RunnerIcons.IconType(rawValue: storedIconTypeString)!
    }
    else {
      iconType = RunnerIcons.IconType()
      userDefaults.setObject(iconType.rawValue, forKey: SettingsManager.iconTypeKey)
      userDefaults.synchronize()
    }
    
    if let storedLogSortFieldString = userDefaults.stringForKey(SettingsManager.logSortFieldKey) {
      logSortField = LogSortField(rawValue: storedLogSortFieldString)!
    }
    else {
      logSortField = LogSortField()
      userDefaults.setObject(logSortField.rawValue, forKey: SettingsManager.logSortFieldKey)
      userDefaults.synchronize()
    }
    
    if let storedShoesSortFieldString = userDefaults.stringForKey(SettingsManager.shoesSortFieldKey) {
      shoesSortField = ShoesSortField(rawValue: storedShoesSortFieldString)!
    }
    else {
      shoesSortField = ShoesSortField()
      userDefaults.setObject(shoesSortField.rawValue, forKey: SettingsManager.shoesSortFieldKey)
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

    if let storedOverlayString = userDefaults.stringForKey(SettingsManager.overlayKey) {
      overlay = Overlay(rawValue: storedOverlayString)!
    }
    else {
      overlay = Overlay()
      userDefaults.setObject(overlay.rawValue, forKey: SettingsManager.overlayKey)
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
    
    if let storedBroadcastRunString = userDefaults.stringForKey(SettingsManager.broadcastRunKey) {
      broadcastRun = (storedBroadcastRunString as NSString).boolValue
    }
    else {
      broadcastRun = SettingsManager.broadcastRunDefault
      userDefaults.setObject("\(broadcastRun)", forKey: SettingsManager.broadcastRunKey)
      userDefaults.synchronize()
    }

    if let storedAllowStopString = userDefaults.stringForKey(SettingsManager.allowStopKey) {
      allowStop = (storedAllowStopString as NSString).boolValue
    }
    else {
      allowStop = SettingsManager.allowStopDefault
      userDefaults.setObject("\(allowStop)", forKey: SettingsManager.allowStopKey)
      userDefaults.synchronize()
    }

    if let storedBroadcastAvailabilityString = userDefaults.stringForKey(SettingsManager.broadcastAvailabilityKey) {
      broadcastAvailability = (storedBroadcastAvailabilityString as NSString).boolValue
    }
    else {
      broadcastAvailability = SettingsManager.broadcastAvailabilityDefault
      userDefaults.setObject("\(broadcastAvailability)", forKey: SettingsManager.broadcastAvailabilityKey)
      userDefaults.synchronize()
    }

    if let storedBroadcastNameString = userDefaults.stringForKey(SettingsManager.broadcastNameKey) {
      broadcastName = storedBroadcastNameString
    }
    else {
      broadcastName = SettingsManager.broadcastNameDefault
      userDefaults.setObject(broadcastName, forKey: SettingsManager.broadcastNameKey)
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
    
    if let storedShowWeightString = userDefaults.stringForKey(SettingsManager.showWeightKey) {
      showWeight = (storedShowWeightString as NSString).boolValue
    }
    else {
      showWeight = SettingsManager.showWeightDefault
      userDefaults.setObject("\(showWeight)", forKey: SettingsManager.showWeightKey)
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
  
  class func getSortType() -> SortType {
    return settingsManager.sortType
  }
  
  class func setSortType(sortType: SortType) {
    if sortType != settingsManager.sortType {
      settingsManager.sortType = sortType
      settingsManager.userDefaults.setObject(sortType.rawValue, forKey: SettingsManager.sortTypeKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getIconType() -> RunnerIcons.IconType {
    return settingsManager.iconType
  }
  
  class func setIconType(iconType: RunnerIcons.IconType) {
    if iconType != settingsManager.iconType {
      settingsManager.iconType = iconType
      settingsManager.userDefaults.setObject(iconType.rawValue, forKey: SettingsManager.iconTypeKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getLogSortField() -> LogSortField {
    return settingsManager.logSortField
  }
  
  class func setLogSortField(logSortField: LogSortField) {
    if logSortField != settingsManager.logSortField {
      settingsManager.logSortField = logSortField
      settingsManager.userDefaults.setObject(logSortField.rawValue, forKey: SettingsManager.logSortFieldKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getShoesSortField() -> ShoesSortField {
    return settingsManager.shoesSortField
  }
  
  class func setShoesSortField(shoesSortField: ShoesSortField) {
    if shoesSortField != settingsManager.shoesSortField {
      settingsManager.shoesSortField = shoesSortField
      settingsManager.userDefaults.setObject(shoesSortField.rawValue, forKey: SettingsManager.shoesSortFieldKey)
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
  
  class func getOverlay() -> Overlay {
    return settingsManager.overlay
  }
  
  class func setOverlay(overlay: Overlay) {
    if overlay != settingsManager.overlay {
      settingsManager.overlay = overlay
      settingsManager.userDefaults.setObject(overlay.rawValue, forKey: SettingsManager.overlayKey)
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

  class func getBroadcastRun() -> Bool {
    return settingsManager.broadcastRun
  }
  
  class func setBroadcastRun(broadcastRun: Bool) {
    if broadcastRun != settingsManager.broadcastRun {
      settingsManager.broadcastRun = broadcastRun
      settingsManager.userDefaults.setObject("\(broadcastRun)", forKey: SettingsManager.broadcastRunKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getAllowStop() -> Bool {
    return settingsManager.allowStop
  }
  
  class func setAllowStop(allowStop: Bool) {
    if allowStop != settingsManager.allowStop {
      settingsManager.allowStop = allowStop
      settingsManager.userDefaults.setObject("\(allowStop)", forKey: SettingsManager.allowStopKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getBroadcastAvailability() -> Bool {
    return settingsManager.broadcastAvailability
  }
  
  class func setBroadcastAvailability(broadcastAvailability: Bool) {
    if broadcastAvailability != settingsManager.broadcastAvailability {
      settingsManager.broadcastAvailability = broadcastAvailability
      settingsManager.userDefaults.setObject("\(broadcastAvailability)", forKey: SettingsManager.broadcastAvailabilityKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getBroadcastName() -> String {
    return settingsManager.broadcastName
  }
  
  class func setBroadcastName(broadcastName: String) {
    if broadcastName != settingsManager.broadcastName {
      settingsManager.broadcastName = broadcastName
      settingsManager.userDefaults.setObject(broadcastName, forKey: SettingsManager.broadcastNameKey)
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
  
  class func getShowWeight() -> Bool {
    return settingsManager.showWeight
  }
  
  class func setShowWeight(showWeight: Bool) {
    if showWeight != settingsManager.showWeight {
      settingsManager.showWeight = showWeight
      settingsManager.userDefaults.setObject("\(showWeight)", forKey: SettingsManager.showWeightKey)
      settingsManager.userDefaults.synchronize()
    }
  }
}