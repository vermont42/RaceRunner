//
//  HumanWeight.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/29/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

struct HumanWeight {
    static let maxMetric = 454.0
    static let minMetric = 1.0
    static let maxImperial = 999.0
    static let minImperial = 2.0
    static let defaultWeight = 68.0
    
    static func weightAsString() -> String {
        switch SettingsManager.getUnitType() {
        case .Metric:
            return String(format: "%.0f kg", SettingsManager.getWeight())
        case .Imperial:
            return String(format: "%.0f lb", SettingsManager.getWeight() * Converter.poundsPerKilogram)
        }
    }
}