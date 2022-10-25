//
//  Config.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/27/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

enum Config {
  static let googleMapsKey = ""
  static let pubNubPublishKey = ""
  static let pubNubSubscribeKey = ""
  static let openWeatherKey = ""

  static func checkKeys() {
    if Config.googleMapsKey == "" {
      let googleMapsError = "Google Maps API key missing from Config.swift."
      fatalError(googleMapsError)
    }
    if Config.pubNubPublishKey == "" {
      let pubNubPublishError = "PubNub Publish API key missing from Config.swift."
      fatalError(pubNubPublishError)
    }
    if Config.pubNubSubscribeKey == "" {
      let pubNubSubscribeError = "PubNub Subscribe API key missing from Config.swift."
      fatalError(pubNubSubscribeError)
    }
    if Config.openWeatherKey == "" {
      let pubNubSubscribeError = "Open Weather API key missing from Config.swift."
      fatalError(pubNubSubscribeError)
    }
  }
}
