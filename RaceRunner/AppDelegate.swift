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
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    Config.checkKeys()
    GMSServices.provideAPIKey(Config.googleMapsKey)
    SoundManager.enableBackgroundAudio()
    Fabric.with([Answers.self])
    //Fabric.sharedSDK().debug = true
    return true
  }
    
  func applicationWillResignActive(application: UIApplication) {
    CDManager.saveContext()
  }

  func applicationWillTerminate(application: UIApplication) {
    CDManager.saveContext()
  }
    
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    return RunModel.addRun(url)
  }
}

