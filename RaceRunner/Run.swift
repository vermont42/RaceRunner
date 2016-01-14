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
  
    @NSManaged var distance: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var temperature: NSNumber
    @NSManaged var weather: NSString
    @NSManaged var timestamp: NSDate
    @NSManaged var locations: NSOrderedSet
    @NSManaged var autoName: NSString
    @NSManaged var customName: NSString
    @NSManaged var maxLongitude: NSNumber
    @NSManaged var minLongitude: NSNumber
    @NSManaged var maxLatitude: NSNumber
    @NSManaged var minLatitude: NSNumber
    @NSManaged var maxAltitude: NSNumber
    @NSManaged var minAltitude: NSNumber
    @NSManaged var altitudeGained: NSNumber
    @NSManaged var altitudeLost: NSNumber
    @NSManaged var weight: NSNumber
    
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
