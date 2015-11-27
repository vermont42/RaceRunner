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
            fatalError("Google Maps API Key missing from Config.swift.")
        }
        if Config.darkSkyKey == "" {
            fatalError("Dark Sky API Key missing from Config.swift.")
        }
        if Config.pubNubPublishKey == "" {
            fatalError("PubNub Publish API Key missing from Config.swift.")
        }
        if Config.pubNubSubscribeKey == "" {
            fatalError("PubNub Subscribe API Key missing from Config.swift.")
        }
    }
}