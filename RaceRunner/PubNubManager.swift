//
//  PubNubManager.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/14/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation
import PubNub
import CoreLocation

class PubNubManager: NSObject, PNObjectEventListener {
  private let pubNub: PubNub?
  private var pubNubSubscriber: PubNubSubscriber?
  private var pubNubPublisher: PubNubPublisher?
  static let sharedNub = PubNubManager()
  static let publicChannel = "foo"
  static let stopped = "stopped"
  private static let stopRun = "stop run"
  private static let messageLabel = "message: "

  override init() {
    pubNub = PubNub.clientWithConfiguration(PNConfiguration(publishKey: Config.pubNubPublishKey, subscribeKey: Config.pubNubSubscribeKey))
    super.init()
    pubNub?.addListener(self)
  }
  
  func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
    let messageString = "\(message.data.message!)"
    if messageString == PubNubManager.stopped {
      pubNubSubscriber?.runStopped()
    }
    else if messageString == PubNubManager.stopRun {
      pubNubPublisher?.stopRun()
    }
    else if (messageString as NSString).substringToIndex(PubNubManager.messageLabel.characters.count) == PubNubManager.messageLabel {
      pubNubPublisher?.receiveMessage((messageString as NSString).substringFromIndex(PubNubManager.messageLabel.characters.count))
    }
    else {
      pubNubSubscriber?.receiveProgress(messageString)
    }
  }

  class func publishLocation(location: CLLocation, distance: Double, seconds: Int, publisher: String) {
    let message = "\(location.coordinate.latitude) \(location.coordinate.longitude) \(location.altitude) \(distance) \(seconds) \(SettingsManager.getAllowStop())"
    sharedNub.pubNub?.publish(message, toChannel: publisher, storeInHistory: false, compressed: false, withCompletion: { (status) -> Void in
      if !status.error {
          //print("Successfully published.")
      }
      else {
          // Handle message publish error. Check 'category' property
          // to find out possible reason because of which request did fail.
          // Review 'errorData' property (which has PNErrorData data type) of status
          // object to get additional information about issue.
          // Request can be resent using: status.retry()
      }
    })
  }
  
  class func publishRunStoppage(publisher: String) {
    sharedNub.pubNub?.publish(PubNubManager.stopRun, toChannel: publisher, storeInHistory: false, compressed: false, withCompletion: nil)
  }

  class func publishMessage(message: String, publisher: String) {
    sharedNub.pubNub?.publish(PubNubManager.messageLabel + message, toChannel: publisher, storeInHistory: false, compressed: false, withCompletion: nil)
  }
  
  class func runStopped() {
    sharedNub.pubNub?.publish(PubNubManager.stopped, toChannel: PubNubManager.publicChannel, storeInHistory: false, compressed: false, withCompletion: nil)
  }
  
  class func subscribeToChannel(pubNubSubscriber: PubNubSubscriber, publisher: String) {
    sharedNub.pubNubSubscriber = pubNubSubscriber
    sharedNub.pubNub?.subscribeToChannels([publisher], withPresence: true)
  }
  
  class func subscribeToChannel(pubNubPublisher: PubNubPublisher, publisher: String) {
    sharedNub.pubNubPublisher = pubNubPublisher
    sharedNub.pubNub?.subscribeToChannels([publisher], withPresence: true)
  }
  
  class func unsubscribeFromChannel(publisher: String) {
    if let _ = sharedNub.pubNubSubscriber {
      sharedNub.pubNub?.unsubscribeFromChannels([publisher], withPresence: true)
      sharedNub.pubNubSubscriber = nil
    }
  }
}