//
//  Run+CoreDataProperties.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/14/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation
import CoreData

extension Run {
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
}
