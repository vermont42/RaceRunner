//
//  AppDelegate.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/7/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import AVFoundation
import GoogleMaps
import Intents
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    _ = AWSAnalyticsService.shared
    Config.checkKeys()
    GMSServices.provideAPIKey(Config.googleMapsKey)
    SoundManager.enableBackgroundAudio()
    SettingsManager.setRealRunInProgress(false)
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    CDManager.saveContext()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    CDManager.saveContext()
    Utterer.utter("Terminating RaceRunner.")
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    RunModel.addRun(url)
  }

  func application(_ application: UIApplication, handle intent: INIntent, completionHandler: @escaping (INIntentResponse) -> Void) {
    completionHandler(IntentHandler.handle(intent: intent))
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    AWSAnalyticsService.shared.recordBecameActive()
  }
}
