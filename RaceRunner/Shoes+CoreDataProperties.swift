//
//  Shoes+CoreDataProperties.swift
//  
//
//  Created by Joshua Adams on 1/14/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Shoes {
  @NSManaged var name: String
  @NSManaged var kilometers: NSNumber
  @NSManaged var maxKilometers: NSNumber
  @NSManaged var thumbnail: NSData
  @NSManaged var isCurrent: NSNumber
}
