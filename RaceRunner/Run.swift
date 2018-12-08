//
//  Run.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/8/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreData

class Run: NSManagedObject {
  static let noTemperature: Double = -99.0
  static let noTemperatureText = "Unknown Temp"
  static let noWeather = "Unknown Weather"
  static let noAutoName = "Unnamed Route"
  static let noCustomName = ""
  static let noWeight: Double = -99.0

  func displayName() -> String {
    if customName != "" {
      return customName as String
    } else {
      return autoName as String
    }
  }
}
