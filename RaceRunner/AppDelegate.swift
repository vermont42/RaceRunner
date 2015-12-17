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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
  
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Config.checkKeys()
        GMSServices.provideAPIKey(Config.googleMapsKey)
        SoundManager.enableBackgroundAudio()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        CDManager.saveContext()
    }

    func applicationWillTerminate(application: UIApplication) {
        CDManager.saveContext()
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        print("url: \(url)")
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        print("options: \(options) url: \(url)")
        // Try opening the file.
        return true
    }
}

