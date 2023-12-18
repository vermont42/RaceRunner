//
//  PubNubManager.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/14/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import CoreLocation
import Foundation
import PubNub

class PubNubManager: NSObject, PNEventsListener { // PNObjectEventListener {
  static let sharedNub = PubNubManager()
  static let publicChannel = "foo"
  static let stopped = "stopped"
  private static let stopRun = "stop run"
  private static let messageLabel = "message: "
  private let pubNub: PubNub?
  private var pubNubSubscriber: PubNubSubscriber?
  private var pubNubPublisher: PubNubPublisher?

  override init() {
    // pubNub = PubNub.clientWithConfiguration(PNConfiguration(publishKey: Config.pubNubPublishKey, subscribeKey: Config.pubNubSubscribeKey, uuid: "\(UUID())"))
    pubNub = PubNub.clientWithConfiguration(
      PNConfiguration(
        publishKey: Config.pubNubPublishKey,
        subscribeKey: Config.pubNubSubscribeKey,
        userID: "\(UUID())"
      )
    )
    super.init()
    pubNub?.addListener(self)
  }

  class func publishLocation(_ location: CLLocation, distance: Double, seconds: Int, publisher: String) {
    let message = "\(location.coordinate.latitude) \(location.coordinate.longitude) \(location.altitude) \(distance) \(seconds) \(SettingsManager.getAllowStop())"
    sharedNub.pubNub?.publish(message, toChannel: publisher, storeInHistory: false, compressed: false, withCompletion: { (status) -> Void in
      if !status.isError {
          // print("Successfully published.")
      } else {
          // Handle message publish error. Check 'category' property
          // to find out possible reason because of which request did fail.
          // Review 'errorData' property (which has PNErrorData data type) of status
          // object to get additional information about issue.
          // Request can be resent using: status.retry()
      }
    })
  }

  class func publishRunStoppage(_ publisher: String) {
    sharedNub.pubNub?.publish(PubNubManager.stopRun, toChannel: publisher, storeInHistory: false, compressed: false, withCompletion: nil)
  }

  class func publishMessage(_ message: String, publisher: String) {
    sharedNub.pubNub?.publish(PubNubManager.messageLabel + message, toChannel: publisher, storeInHistory: false, compressed: false, withCompletion: nil)
  }

  class func runStopped() {
    sharedNub.pubNub?.publish(PubNubManager.stopped, toChannel: PubNubManager.publicChannel, storeInHistory: false, compressed: false, withCompletion: nil)
  }

  class func subscribeToChannel(_ pubNubSubscriber: PubNubSubscriber, publisher: String) {
    sharedNub.pubNubSubscriber = pubNubSubscriber
    sharedNub.pubNub?.subscribeToChannels([publisher], withPresence: true)
  }

  class func subscribeToChannel(_ pubNubPublisher: PubNubPublisher, publisher: String) {
    sharedNub.pubNubPublisher = pubNubPublisher
    sharedNub.pubNub?.subscribeToChannels([publisher], withPresence: true)
  }

  class func unsubscribeFromChannel(_ publisher: String) {
    if sharedNub.pubNubSubscriber != nil {
      sharedNub.pubNub?.unsubscribeFromChannels([publisher], withPresence: true)
      sharedNub.pubNubSubscriber = nil
    }
  }

  func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
    let messageString: String
    if let messageData = message.data.message {
      messageString = "\(messageData)"
    } else {
      messageString = ""
    }
    if messageString == PubNubManager.stopped {
      pubNubSubscriber?.runStopped()
    } else if messageString == PubNubManager.stopRun {
      pubNubPublisher?.stopRun()
    } else if (messageString as NSString).substring(to: PubNubManager.messageLabel.count) == PubNubManager.messageLabel {
      pubNubPublisher?.receiveMessage((messageString as NSString).substring(from: PubNubManager.messageLabel.count))
    } else {
      pubNubSubscriber?.receiveProgress(messageString)
    }
  }
}
