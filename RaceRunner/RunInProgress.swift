//
//  RunInProgress.swift
//  RaceRunner
//
//  Created by Joshua Adams on 6/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation
import CoreData

class RunInProgress: NSManagedObject {
  @NSManaged var oldSplitAltitude: NSNumber
  @NSManaged var totalSeconds: NSNumber
  @NSManaged var lastSeconds: NSNumber
  @NSManaged var totalDistance: NSNumber
  @NSManaged var lastDistance: NSNumber
  @NSManaged var currentAltitude: NSNumber
  @NSManaged var currentSplitDistance: NSNumber
  @NSManaged var altGained: NSNumber
  @NSManaged var altLost: NSNumber
  @NSManaged var maxLong: NSNumber
  @NSManaged var minLong: NSNumber
  @NSManaged var maxLat: NSNumber
  @NSManaged var minLat: NSNumber
  @NSManaged var maxAlt: NSNumber
  @NSManaged var minAlt: NSNumber
  @NSManaged var tempLocations: NSOrderedSet
}
