//
//  LowMemoryHandler.swift
//  RaceRunner
//
//  Created by Josh Adams on 6/9/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation

enum LowMemoryHandler {
  private static let lowMemoryWarning = "iOS issued RaceRunner a low memory warning. Run recording may be interrupted."

  static func handleLowMemory() {
    if SettingsManager.getRealRunInProgress() {
      Utterer.utter(lowMemoryWarning)
    }
  }
}
