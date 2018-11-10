//
//  Config.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/27/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

struct Config {
  static let darkSkyKey = ""
  static let googleMapsKey = ""
  static let pubNubPublishKey = ""
  static let pubNubSubscribeKey = ""
  private static let googleMapsError = "Google Maps API key missing from Config.swift."
  private static let darkSkyError = "Dark Sky API key missing from Config.swift."
  private static let pubNubPublishError = "PubNub Publish API key missing from Config.swift."
  private static let pubNubSubscribeError = "PubNub Subscribbe API key missing from Config.swift."

  static func checkKeys() {
    if Config.googleMapsKey == "" {
      fatalError(Config.googleMapsError)
    }
    if Config.darkSkyKey == "" {
      fatalError(Config.darkSkyError)
    }
    if Config.pubNubPublishKey == "" {
      fatalError(Config.pubNubPublishError)
    }
    if Config.pubNubSubscribeKey == "" {
      fatalError(Config.pubNubSubscribeError)
    }
  }
}
