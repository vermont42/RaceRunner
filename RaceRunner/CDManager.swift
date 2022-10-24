//
//  CDManager.swift
//  RaceRunner
//
//  Created by Josh Adams on 2/22/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.

import CoreData
import Foundation

class CDManager {
  static let sharedCDManager = CDManager()

  var context: NSManagedObjectContext

  init() {
    let modelFilename = "RaceRunner"
    let modelExtension = "momd"
    guard let modelURL = Bundle.main.url(forResource: modelFilename, withExtension: modelExtension) else {
      fatalError("modelURL was nil.")
    }
    guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("managedObjectModel was nil.")
    }
    context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    let storeFilename = "RaceRunner.sqlite"
    let storeURL: URL = applicationDocumentsDirectory().appendingPathComponent(storeFilename)
    let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    do {
      try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    } catch let error as NSError {
      fatalError(error.localizedDescription)
    }
    context.persistentStoreCoordinator = coordinator
  }

  class func saveContext () {
    let context = sharedCDManager.context
    if context.hasChanges {
      do {
        try context.save()
      } catch let error as NSError {
        fatalError(error.localizedDescription)
      }
    }
  }

  private func applicationDocumentsDirectory() -> URL {
    return URL(fileURLWithPath: NSHomeDirectory() + "/Documents/")
  }
}
