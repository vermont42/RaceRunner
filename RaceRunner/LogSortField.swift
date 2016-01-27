//
//  LogSortField.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

enum LogSortField: String {
  case Date = "Date"
  case Name = "Name"
  case Pace = "Pace"
  case Distance = "Distance"
  case Duration = "Duration"
  
  init() {
    self = .Date
  }
  
  static func all() -> [String] {
    return [LogSortField.Date.asString(), LogSortField.Name.asString(), LogSortField.Pace.asString(), LogSortField.Distance.asString(), LogSortField.Duration.asString()]
  }
  
  static func sortFieldForPosition(position: Int) -> LogSortField {
    switch position {
    case 0:
      return .Date
    case 1:
      return .Name
    case 2:
      return .Pace
    case 3:
      return .Distance
    case 4:
      return .Duration
    default:
      return .Date
    }
  }
  
  // This method exists in case I internationalize at some point.
  func asString() -> String {
    switch self {
    case .Date:
      return self.rawValue
    case .Name:
      return self.rawValue
    case .Pace:
      return self.rawValue
    case .Distance:
      return self.rawValue
    case .Duration:
      return self.rawValue
    }
  }
  
  func pickerPosition() -> Int {
    switch self {
    case .Date:
      return 0
    case .Name:
      return 1
    case .Pace:
      return 2
    case .Distance:
      return 3
    case .Duration:
      return 4
    }
  }
  
  static func compare(run1: Run, run2: Run) -> Bool {
    let sortType = SettingsManager.getSortType()
    let sortField = SettingsManager.getLogSortField()
    var ordering: NSComparisonResult
    switch sortType {
    case .Normal:
      ordering = .OrderedDescending
    case .Reverse:
      ordering = .OrderedAscending
    }
    switch sortField {
    case .Date:
      return run1.timestamp.compare(run2.timestamp) == ordering
    case .Name:
      let name1: String = run1.displayName()
      let name2: String = run2.displayName()
      return name1.localizedCaseInsensitiveCompare(name2) == ordering
    case .Pace:
      let pace1 = run1.duration.doubleValue / run1.distance.doubleValue
      let pace2 = run2.duration.doubleValue / run2.distance.doubleValue
      var result = pace1 < pace2
      if ordering == .OrderedDescending {
        result = !result
      }
      return result
    case .Distance:
      var result = run1.distance.doubleValue < run2.distance.doubleValue
      if ordering == .OrderedDescending {
        result = !result
      }
      return result
    case .Duration:
      var result = run1.duration.intValue < run2.duration.intValue
      if ordering == .OrderedDescending {
        result = !result
      }
      return result
    }
  }
}


