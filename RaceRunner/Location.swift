//
//  Location.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/8/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import CoreData
import Foundation

class Location: NSManagedObject {
  @NSManaged var altitude: NSNumber
  @NSManaged var latitude: NSNumber
  @NSManaged var longitude: NSNumber
  @NSManaged var timestamp: Date
  @NSManaged var run: Run
}
