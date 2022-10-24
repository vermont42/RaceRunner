//
//  Shoes+CoreDataProperties.swift
//  
//
//  Created by Josh Adams on 1/14/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData
import Foundation

extension Shoes {
  @NSManaged var name: String
  @NSManaged var kilometers: NSNumber
  @NSManaged var maxKilometers: NSNumber
  @NSManaged var thumbnail: Data
  @NSManaged var isCurrent: NSNumber
}
