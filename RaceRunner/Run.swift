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
    static let noStreetNameDetected: String = "no street name detected"
    static let unnamedRoute = "Unnamed Route"
      
    func displayName() -> String {
        if customName != "" {
            return customName as String
        }
        if autoName == Run.noStreetNameDetected {
            return Run.unnamedRoute
        }
        else {
            return autoName as String
        }
    }
}
