//
//  Shoes.swift
//  RaceRunner
//
//  Created by Josh Adams on 1/14/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import CoreData
import UIKit

class Shoes: NSManagedObject {
  static let defaultKilometers: Float = 0.0
  static let defaultMaxKilometers: Float = 644.0
  static let defaultThumbnail = UIImage.named("shoe")
  static let defaultName = ""
  static let maxNumberLength: Int = 3
  static let checked = UIImage.named("checked")
  static let unchecked = UIImage.named("unchecked")
  static let shoesWarning = "%@ have %@ on them. Their limit is %@. Please consider replacement."
  static let warningTitle = "Warning"
  static let gotIt = "Got It"
  static let areOkay = "shoes are okay"

  class func addMeters(_ meters: Double) -> String {
    // let fetchRequest = NSFetchRequest()
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shoes")
    let context = CDManager.sharedCDManager.context
    fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Shoes", in: context)
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    let pairs = (try? context.fetch(fetchRequest)) as? [Shoes] ?? []
    for shoes in pairs where shoes.isCurrent.boolValue {
      let currentKilometers = shoes.kilometers.doubleValue
      let newKilometers = currentKilometers + (meters / Converter.metersInKilometer)
      shoes.kilometers = NSNumber(value: newKilometers)
      CDManager.saveContext()
      if newKilometers > shoes.maxKilometers.doubleValue {
        return NSString(format: Shoes.shoesWarning as NSString, shoes.name, Converter.stringifyKilometers(Float(newKilometers), includeUnits: true), Converter.stringifyKilometers(shoes.maxKilometers.floatValue, includeUnits: true)) as String
      }
    }
    return Shoes.areOkay
  }
}
