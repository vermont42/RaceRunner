//
//  AWSAnalyticsService.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/16/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Foundation
import AWSPinpoint

class AWSAnalyticsService: NSObject {
  var pinpoint: AWSPinpoint
  static let shared = AWSAnalyticsService()
  
  override init() {
    let config = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: nil)
    pinpoint = AWSPinpoint(configuration: config)
    super.init()
    recordCustomProfileDemographics()
    //    AWSDDLog.sharedInstance.logLevel = .verbose
    //    AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
  }
  
  func recordEvent(_ eventName: String, parameters: [String: String]? = nil, metrics: [String: Double]? = nil) {
    let event = pinpoint.analyticsClient.createEvent(withEventType: eventName)
    if let parameters = parameters {
      for (key, value) in parameters {
        event.addAttribute(value, forKey: key)
      }
    }
    if let metrics = metrics {
      for (key, value) in metrics {
        event.addMetric(NSNumber(value: value), forKey: key)
      }
    }
    pinpoint.analyticsClient.record(event)
    pinpoint.analyticsClient.submitEvents()
  }
  
  func recordEvent(_ eventName: String) {
    recordEvent(eventName, parameters: nil, metrics: nil)
  }
  
  func recordVisitation(viewController: String) {
    let visited = "visited"
    let viewControllerKey = "viewController"
    recordEvent(visited, parameters: [viewControllerKey: "\(viewController)"], metrics: nil)
  }
  
  func recordRunStart() {
    let runStart = "runStart"
    recordEvent(runStart)
  }

  func recordRunPause() {
    let runPause = "runPause"
    recordEvent(runPause)
  }

  func recordRunResume() {
    let runResume = "runResume"
    recordEvent(runResume)
  }

  func recordRunStop() {
    let runStop = "runStop"
    recordEvent(runStop)
  }

  func recordBecameActive() {
    let becameActive = "becameActive"
    let modelKey = "model"
    let localeKey = "locale"
    let none = "none"
    let NONE = "NONE"

    let modelName = UIDevice.current.modelName
    let language = NSLocale.current.languageCode ?? none
    let region = NSLocale.current.regionCode ?? NONE
    let locale = language + region

    recordEvent(becameActive, parameters: [modelKey: modelName, localeKey: locale], metrics: nil)
  }

  private func recordCustomProfileDemographics() {
    let profile: AWSPinpointEndpointProfile = (pinpoint.targetingClient.currentEndpointProfile())
    profile.demographic?.model = UIDevice.current.modelName
    profile.demographic?.platformVersion = UIDevice.current.systemVersion
    pinpoint.targetingClient.update(profile)
  }
}
