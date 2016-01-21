//
//  Config.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/27/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

struct Config {
    static let darkSkyKey = "51e9be2653fc075c805c92db32a50432"
    static let googleMapsKey = "AIzaSyCYphUv_GzYX-OIWqn77u6Cpa51e1rJ2Rs"
    static let pubNubPublishKey = "pub-c-0d826075-d0b1-4788-a7b6-40cdffc0414d"
    static let pubNubSubscribeKey = "sub-c-8da5fcec-8aee-11e5-a04a-0619f8945a4f"

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