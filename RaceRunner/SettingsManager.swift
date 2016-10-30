//
//  SettingsManager.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/26/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation

class SettingsManager {
  fileprivate static let settingsManager = SettingsManager()
  fileprivate var userDefaults: UserDefaults
  
  fileprivate var unitType: UnitType
  fileprivate static let unitTypeKey = "unitType"
  
  fileprivate var logSortField: LogSortField
  fileprivate static let logSortFieldKey = "logSortField"

  fileprivate var shoesSortField: ShoesSortField
  fileprivate static let shoesSortFieldKey = "shoeSortField"
  
  fileprivate var sortType: SortType
  fileprivate static let sortTypeKey = "sortType"
  
  fileprivate var iconType: RunnerIcons.IconType
  fileprivate static let iconTypeKey = "iconType"
  
  fileprivate var accent: Accent
  fileprivate static let accentKey = "accent"
  
  fileprivate var overlay: Overlay
  fileprivate static let overlayKey = "overlay"
  
  fileprivate var broadcastNextRun: Bool
  fileprivate static let broadcastNextRunKey = "broadcastNextRun"
  fileprivate static let broadcastNextRunDefault = false

  fileprivate var showedForecastCredit: Bool
  fileprivate static let showedForecastCreditKey = "showedForecastCredit"
  fileprivate static let showedForecastCreditDefault = false
  
  fileprivate var allowStop: Bool
  fileprivate static let allowStopKey = "allowStop"
  fileprivate static let allowStopDefault = false

  fileprivate var broadcastName: String
  fileprivate static let broadcastNameKey = "broadcastName"
  fileprivate static let broadcastNameDefault = ""
  
  fileprivate var audibleSplits: Bool
  fileprivate static let audibleSplitsKey = "audibleSplits"
  fileprivate static let audibleSplitsDefault = true

  fileprivate var warnedUserAboutLowRam: Bool
  fileprivate static let warnedUserAboutLowRamKey = "warnedUserAboutLowRam"
  fileprivate static let warnedUserAboutLowRamDefault = false
  
  fileprivate var realRunInProgress: Bool
  fileprivate static let realRunInProgressKey = "realRunInProgress"
  fileprivate static let realRunInProgressDefault = false
  
  fileprivate var multiplier: Double
  fileprivate static let multiplierKey = "multiplier"
  fileprivate static let multiplierDefault = 5.0

  fileprivate var stopAfter: Double
  static let never: Double = 0.0
  static let minStopAfter: Double = 0.1
  static let maxStopAfter: Double = 500
  fileprivate static let stopAfterKey = "stopAfter"
  fileprivate static let stopAfterDefault = SettingsManager.never

  fileprivate var reportEvery: Double
  fileprivate static let reportEveryKey = "reportEvery"
  fileprivate static let reportEveryDefault = Converter.metersInMile
  
  fileprivate var alreadyMadeSampleRun: Bool
  fileprivate static let alreadyMadeSampleRunKey = "alreadyMadeSampleRun"
  fileprivate static let alreadyMadeSampleRunDefault = false
  
  fileprivate var weight: Double
  static let weightDefault: Double = HumanWeight.defaultWeight
  fileprivate static let weightKey = "weight"
  
  fileprivate var showWeight: Bool
  fileprivate static let showWeightKey = "showWeight"
  fileprivate static let showWeightDefault = true
  
  fileprivate var highScore: Int
  fileprivate static let highScoreDefault = 0
  fileprivate static let highScoreKey = "highScore"
  
  fileprivate init() {
    userDefaults = UserDefaults.standard
    
    if let storedUnitTypeString = userDefaults.string(forKey: SettingsManager.unitTypeKey) {
      unitType = UnitType(rawValue: storedUnitTypeString)!
    }
    else {
      unitType = UnitType()
      userDefaults.set(unitType.rawValue, forKey: SettingsManager.unitTypeKey)
      userDefaults.synchronize()
    }
    
    if let storedSortTypeString = userDefaults.string(forKey: SettingsManager.sortTypeKey) {
      sortType = SortType(rawValue: storedSortTypeString)!
    }
    else {
      sortType = SortType()
      userDefaults.set(sortType.rawValue, forKey: SettingsManager.sortTypeKey)
      userDefaults.synchronize()
    }
    
    if let storedIconTypeString = userDefaults.string(forKey: SettingsManager.iconTypeKey) {
      iconType = RunnerIcons.IconType(rawValue: storedIconTypeString)!
    }
    else {
      iconType = RunnerIcons.IconType()
      userDefaults.set(iconType.rawValue, forKey: SettingsManager.iconTypeKey)
      userDefaults.synchronize()
    }
    
    if let storedLogSortFieldString = userDefaults.string(forKey: SettingsManager.logSortFieldKey) {
      logSortField = LogSortField(rawValue: storedLogSortFieldString)!
    }
    else {
      logSortField = LogSortField()
      userDefaults.set(logSortField.rawValue, forKey: SettingsManager.logSortFieldKey)
      userDefaults.synchronize()
    }
    
    if let storedShoesSortFieldString = userDefaults.string(forKey: SettingsManager.shoesSortFieldKey) {
      shoesSortField = ShoesSortField(rawValue: storedShoesSortFieldString)!
    }
    else {
      shoesSortField = ShoesSortField()
      userDefaults.set(shoesSortField.rawValue, forKey: SettingsManager.shoesSortFieldKey)
      userDefaults.synchronize()
    }
    
    if let storedAccentString = userDefaults.string(forKey: SettingsManager.accentKey) {
      accent = Accent(rawValue: storedAccentString)!
    }
    else {
      accent = Accent()
      userDefaults.set(accent.rawValue, forKey: SettingsManager.accentKey)
      userDefaults.synchronize()
    }

    if let storedOverlayString = userDefaults.string(forKey: SettingsManager.overlayKey) {
      overlay = Overlay(rawValue: storedOverlayString)!
    }
    else {
      overlay = Overlay()
      userDefaults.set(overlay.rawValue, forKey: SettingsManager.overlayKey)
      userDefaults.synchronize()
    }
    
    if let storedWeightString = userDefaults.string(forKey: SettingsManager.weightKey) {
      weight = (storedWeightString as NSString).doubleValue
    }
    else {
      weight = SettingsManager.weightDefault
      userDefaults.set(String(format:"%f", weight), forKey: SettingsManager.weightKey)
      userDefaults.synchronize()
    }
    
    if let storedBroadcastNextRunString = userDefaults.string(forKey: SettingsManager.broadcastNextRunKey) {
      broadcastNextRun = (storedBroadcastNextRunString as NSString).boolValue
    }
    else {
      broadcastNextRun = SettingsManager.broadcastNextRunDefault
      userDefaults.set("\(broadcastNextRun)", forKey: SettingsManager.broadcastNextRunKey)
      userDefaults.synchronize()
    }

    if let storedAllowStopString = userDefaults.string(forKey: SettingsManager.allowStopKey) {
      allowStop = (storedAllowStopString as NSString).boolValue
    }
    else {
      allowStop = SettingsManager.allowStopDefault
      userDefaults.set("\(allowStop)", forKey: SettingsManager.allowStopKey)
      userDefaults.synchronize()
    }
    
    if let storedShowedForecastCreditString = userDefaults.string(forKey: SettingsManager.showedForecastCreditKey) {
      showedForecastCredit = (storedShowedForecastCreditString as NSString).boolValue
    }
    else {
      showedForecastCredit = SettingsManager.showedForecastCreditDefault
      userDefaults.set("\(showedForecastCredit)", forKey: SettingsManager.showedForecastCreditKey)
      userDefaults.synchronize()
    }

    if let warnedUserAboutLowRamString = userDefaults.string(forKey: SettingsManager.warnedUserAboutLowRamKey) {
      warnedUserAboutLowRam = (warnedUserAboutLowRamString as NSString).boolValue
    }
    else {
      warnedUserAboutLowRam = SettingsManager.warnedUserAboutLowRamDefault
      userDefaults.set("\(warnedUserAboutLowRam)", forKey: SettingsManager.warnedUserAboutLowRamKey)
      userDefaults.synchronize()
    }

    if let realRunInProgressString = userDefaults.string(forKey: SettingsManager.realRunInProgressKey) {
      realRunInProgress = (realRunInProgressString as NSString).boolValue
    }
    else {
      realRunInProgress = SettingsManager.realRunInProgressDefault
      userDefaults.set("\(realRunInProgress)", forKey: SettingsManager.realRunInProgressKey)
      userDefaults.synchronize()
    }

    if let storedBroadcastNameString = userDefaults.string(forKey: SettingsManager.broadcastNameKey) {
      broadcastName = storedBroadcastNameString
    }
    else {
      broadcastName = SettingsManager.broadcastNameDefault
      userDefaults.set(broadcastName, forKey: SettingsManager.broadcastNameKey)
      userDefaults.synchronize()
    }
    
    if let storedAudibleSplitsString = userDefaults.string(forKey: SettingsManager.audibleSplitsKey) {
      audibleSplits = (storedAudibleSplitsString as NSString).boolValue
    }
    else {
      audibleSplits = SettingsManager.audibleSplitsDefault
      userDefaults.set("\(audibleSplits)", forKey: SettingsManager.audibleSplitsKey)
      userDefaults.synchronize()
    }
    
    if let storedAlreadyMadeSampleRunString = userDefaults.string(forKey: SettingsManager.alreadyMadeSampleRunKey) {
      alreadyMadeSampleRun = (storedAlreadyMadeSampleRunString as NSString).boolValue
    }
    else {
      alreadyMadeSampleRun = SettingsManager.alreadyMadeSampleRunDefault
      userDefaults.set("\(alreadyMadeSampleRun)", forKey: SettingsManager.alreadyMadeSampleRunKey)
      userDefaults.synchronize()
    }
    
    if let storedMultiplierString = userDefaults.string(forKey: SettingsManager.multiplierKey) {
      multiplier = (storedMultiplierString as NSString).doubleValue
    }
    else {
      multiplier = SettingsManager.multiplierDefault
      userDefaults.set(String(format:"%f", multiplier), forKey: SettingsManager.multiplierKey)
      userDefaults.synchronize()
    }
    
    if let storedStopAfterString = userDefaults.string(forKey: SettingsManager.stopAfterKey) {
      stopAfter = (storedStopAfterString as NSString).doubleValue
    }
    else {
      stopAfter = SettingsManager.stopAfterDefault
      userDefaults.set(String(format:"%f", stopAfter), forKey: SettingsManager.stopAfterKey)
      userDefaults.synchronize()
    }
    
    if let storedReportEveryString = userDefaults.string(forKey: SettingsManager.reportEveryKey) {
      reportEvery = (storedReportEveryString as NSString).doubleValue
    }
    else {
      reportEvery = SettingsManager.reportEveryDefault
      userDefaults.set(String(format:"%f", reportEvery), forKey: SettingsManager.reportEveryKey)
      userDefaults.synchronize()
    }
    
    if let storedShowWeightString = userDefaults.string(forKey: SettingsManager.showWeightKey) {
      showWeight = (storedShowWeightString as NSString).boolValue
    }
    else {
      showWeight = SettingsManager.showWeightDefault
      userDefaults.set("\(showWeight)", forKey: SettingsManager.showWeightKey)
      userDefaults.synchronize()
    }
    
    if let storedHighScoreString = userDefaults.string(forKey: SettingsManager.highScoreKey) {
      highScore = (Int)((storedHighScoreString as NSString).intValue)
    }
    else {
      highScore = SettingsManager.highScoreDefault
      userDefaults.set(String(format:"%d", highScore), forKey: SettingsManager.highScoreKey)
      userDefaults.synchronize()
    }
  }
  
  class func getUnitType() -> UnitType {
    return settingsManager.unitType
  }

  class func setUnitType(_ unitType: UnitType) {
    if unitType != settingsManager.unitType {
      settingsManager.unitType = unitType
      settingsManager.userDefaults.set(unitType.rawValue, forKey: SettingsManager.unitTypeKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getSortType() -> SortType {
    return settingsManager.sortType
  }
  
  class func setSortType(_ sortType: SortType) {
    if sortType != settingsManager.sortType {
      settingsManager.sortType = sortType
      settingsManager.userDefaults.set(sortType.rawValue, forKey: SettingsManager.sortTypeKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getIconType() -> RunnerIcons.IconType {
    return settingsManager.iconType
  }
  
  class func setIconType(_ iconType: RunnerIcons.IconType) {
    if iconType != settingsManager.iconType {
      settingsManager.iconType = iconType
      settingsManager.userDefaults.set(iconType.rawValue, forKey: SettingsManager.iconTypeKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getLogSortField() -> LogSortField {
    return settingsManager.logSortField
  }
  
  class func setLogSortField(_ logSortField: LogSortField) {
    if logSortField != settingsManager.logSortField {
      settingsManager.logSortField = logSortField
      settingsManager.userDefaults.set(logSortField.rawValue, forKey: SettingsManager.logSortFieldKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getShoesSortField() -> ShoesSortField {
    return settingsManager.shoesSortField
  }
  
  class func setShoesSortField(_ shoesSortField: ShoesSortField) {
    if shoesSortField != settingsManager.shoesSortField {
      settingsManager.shoesSortField = shoesSortField
      settingsManager.userDefaults.set(shoesSortField.rawValue, forKey: SettingsManager.shoesSortFieldKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getWeight() -> Double {
    return settingsManager.weight
  }
  
  class func setWeight(_ weight: Double) {
    if weight != settingsManager.weight {
      settingsManager.weight = weight
      settingsManager.userDefaults.set(String(format:"%f", weight), forKey: SettingsManager.weightKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getHighScore() -> Int {
    return settingsManager.highScore
  }
  
  class func setHighScore(_ highScore: Int) {
    if highScore != settingsManager.highScore {
      settingsManager.highScore = highScore
      settingsManager.userDefaults.set(String(format:"%d", highScore), forKey: SettingsManager.highScoreKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getAccent() -> Accent {
    return settingsManager.accent
  }
  
  class func setAccent(_ accent: Accent) {
    if accent != settingsManager.accent {
      settingsManager.accent = accent
      settingsManager.userDefaults.set(accent.rawValue, forKey: SettingsManager.accentKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getOverlay() -> Overlay {
    return settingsManager.overlay
  }
  
  class func setOverlay(_ overlay: Overlay) {
    if overlay != settingsManager.overlay {
      settingsManager.overlay = overlay
      settingsManager.userDefaults.set(overlay.rawValue, forKey: SettingsManager.overlayKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func setAccent(_ accent: String) {
    SettingsManager.setAccent(Accent.stringToAccent(accent))
  }
  
  class func getAlreadyMadeSampleRun() -> Bool {
    return settingsManager.alreadyMadeSampleRun
  }
  
  class func setAlreadyMadeSampleRun(_ alreadyMadeSampleRun: Bool) {
    if alreadyMadeSampleRun != settingsManager.alreadyMadeSampleRun {
      settingsManager.alreadyMadeSampleRun = alreadyMadeSampleRun
      settingsManager.userDefaults.set("\(alreadyMadeSampleRun)", forKey: SettingsManager.alreadyMadeSampleRunKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getRealRunInProgress() -> Bool {
    return settingsManager.realRunInProgress
  }
  
  class func setRealRunInProgress(_ realRunInProgress: Bool) {
    if realRunInProgress != settingsManager.realRunInProgress {
      settingsManager.realRunInProgress = realRunInProgress
      settingsManager.userDefaults.set("\(realRunInProgress)", forKey: SettingsManager.realRunInProgressKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getWarnedUserAboutLowRam() -> Bool {
    return settingsManager.warnedUserAboutLowRam
  }
  
  class func setWarnedUserAboutLowRam(_ warnedUserAboutLowRam: Bool) {
    if warnedUserAboutLowRam != settingsManager.warnedUserAboutLowRam {
      settingsManager.warnedUserAboutLowRam = warnedUserAboutLowRam
      settingsManager.userDefaults.set("\(warnedUserAboutLowRam)", forKey: SettingsManager.warnedUserAboutLowRamKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getShowedForecastCredit() -> Bool {
    return settingsManager.showedForecastCredit
  }
  
  class func setShowedForecastCredit(_ showedForecastCredit: Bool) {
    if showedForecastCredit != settingsManager.showedForecastCredit {
      settingsManager.showedForecastCredit = showedForecastCredit
      settingsManager.userDefaults.set("\(showedForecastCredit)", forKey: SettingsManager.showedForecastCreditKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getBroadcastNextRun() -> Bool {
    return settingsManager.broadcastNextRun
  }
  
  class func setBroadcastNextRun(_ broadcastNextRun: Bool) {
    if broadcastNextRun != settingsManager.broadcastNextRun {
      settingsManager.broadcastNextRun = broadcastNextRun
      settingsManager.userDefaults.set("\(broadcastNextRun)", forKey: SettingsManager.broadcastNextRunKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getAllowStop() -> Bool {
    return settingsManager.allowStop
  }
  
  class func setAllowStop(_ allowStop: Bool) {
    if allowStop != settingsManager.allowStop {
      settingsManager.allowStop = allowStop
      settingsManager.userDefaults.set("\(allowStop)", forKey: SettingsManager.allowStopKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getBroadcastName() -> String {
    return settingsManager.broadcastName
  }
  
  class func setBroadcastName(_ broadcastName: String) {
    if broadcastName != settingsManager.broadcastName {
      settingsManager.broadcastName = broadcastName
      settingsManager.userDefaults.set(broadcastName, forKey: SettingsManager.broadcastNameKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getAudibleSplits() -> Bool {
    return settingsManager.audibleSplits
  }
  
  class func setAudibleSplits(_ audibleSplits: Bool) {
    if audibleSplits != settingsManager.audibleSplits {
      settingsManager.audibleSplits = audibleSplits
      settingsManager.userDefaults.set("\(audibleSplits)", forKey: SettingsManager.audibleSplitsKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getMultiplier() -> Double {
    return settingsManager.multiplier
  }
  
  class func setMultiplier(_ multiplier: Double) {
    if multiplier != settingsManager.multiplier {
      settingsManager.multiplier = multiplier
      settingsManager.userDefaults.set(String(format:"%f", multiplier), forKey: SettingsManager.multiplierKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getReportEvery() -> Double {
    return settingsManager.reportEvery
  }
  
  class func setReportEvery(_ reportEvery: Double) {
    if reportEvery != settingsManager.reportEvery {
      settingsManager.reportEvery = reportEvery
      settingsManager.userDefaults.set(String(format:"%f", reportEvery), forKey: SettingsManager.reportEveryKey)
      settingsManager.userDefaults.synchronize()
    }
  }

  class func getStopAfter() -> Double {
    return settingsManager.stopAfter
  }
  
  class func setStopAfter(_ stopAfter: Double) {
    if stopAfter != settingsManager.stopAfter {
      settingsManager.stopAfter = stopAfter
      settingsManager.userDefaults.set(String(format:"%f", stopAfter), forKey: SettingsManager.stopAfterKey)
      settingsManager.userDefaults.synchronize()
    }
  }
  
  class func getShowWeight() -> Bool {
    return settingsManager.showWeight
  }
  
  class func setShowWeight(_ showWeight: Bool) {
    if showWeight != settingsManager.showWeight {
      settingsManager.showWeight = showWeight
      settingsManager.userDefaults.set("\(showWeight)", forKey: SettingsManager.showWeightKey)
      settingsManager.userDefaults.synchronize()
    }
  }
}
