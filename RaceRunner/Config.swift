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

  static func checkKeys() {
    if Config.googleMapsKey == "" {
      let googleMapsError = "Google Maps API key missing from Config.swift."
      fatalError(googleMapsError)
    }
    if Config.darkSkyKey == "" {
      let darkSkyError = "Dark Sky API key missing from Config.swift."
      fatalError(darkSkyError)
    }
    if Config.pubNubPublishKey == "" {
      let pubNubPublishError = "PubNub Publish API key missing from Config.swift."
      fatalError(pubNubPublishError)
    }
    if Config.pubNubSubscribeKey == "" {
      let pubNubSubscribeError = "PubNub Subscribe API key missing from Config.swift."
      fatalError(pubNubSubscribeError)
    }
  }
}
