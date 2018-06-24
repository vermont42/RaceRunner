//
//  AppDelegate.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/7/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import GoogleMaps
import AVFoundation
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Config.checkKeys()
    GMSServices.provideAPIKey(Config.googleMapsKey)
    SoundManager.enableBackgroundAudio()
    LowMemoryHandler.appStarted()
    return true
  }
    
  func applicationWillResignActive(_ application: UIApplication) {
    CDManager.saveContext()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    CDManager.saveContext()
  }
    
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
    return RunModel.addRun(url)
  }

  func application(_ application: UIApplication, handle intent: INIntent, completionHandler: @escaping (INIntentResponse) -> Void) {
    completionHandler(IntentHandler.handle(intent: intent))
  }
}
