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
import Fabric
import Answers

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Config.checkKeys()
    GMSServices.provideAPIKey(Config.googleMapsKey)
    SoundManager.enableBackgroundAudio()
    Fabric.with([Answers.self])
    //Fabric.sharedSDK().debug = true
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
}
