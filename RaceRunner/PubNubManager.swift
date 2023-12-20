//
//  PubNubManager.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/14/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import CoreLocation
import PubNub
import UIKit

class PubNubManager: BaseSubscriptionListener /*: PNEventsListener */ { // PNObjectEventListener {
  static let sharedNub = PubNubManager()
  static let publicChannel = "foo"
  static let stopped = "stopped"
  private static let stopRun = "stop run"
  private static let messageLabel = "message: "
  private let pubNub: PubNub?
  private var pubNubSubscriber: PubNubSubscriber?
  private var pubNubPublisher: PubNubPublisher?
  private let listener = SubscriptionListener()

  init() {
    let config = PubNubConfiguration(
      publishKey: Config.pubNubPublishKey,
      subscribeKey: Config.pubNubSubscribeKey,
      userId: UIDevice.current.identifierForVendor?.uuidString ?? "defaultId"
    )
    pubNub = PubNub(configuration: config)
    listener.didReceiveSubscription = { event in
      PubNubManager.handleEvent(event)
    }
    pubNub?.add(listener)
    super.init()
  }

  class func publishLocation(_ location: CLLocation, distance: Double, seconds: Int, publisher: String) {
    let message = "\(location.coordinate.latitude) \(location.coordinate.longitude) \(location.altitude) \(distance) \(seconds) \(SettingsManager.getAllowStop())"

    sharedNub.pubNub?.publish(channel: publisher, message: message) { _ in
      // For debugging, change the parameter from _ to result and uncomment the following.
//      switch result {
//      case .success:
//        print("Publish succeeded.")
//      case .failure(let error):
//        print("Publish failed with error: \(error)")
//      }
    }
  }

  class func publishRunStoppage(_ publisher: String) {
    sharedNub.pubNub?.publish(channel: publisher, message: PubNubManager.stopRun, completion: nil)
  }

  class func publishMessage(_ message: String, publisher: String) {
    sharedNub.pubNub?.publish(channel: publisher, message: PubNubManager.messageLabel + message, completion: nil)
  }

  class func runStopped() {
    sharedNub.pubNub?.publish(channel: PubNubManager.publicChannel, message: PubNubManager.stopped, completion: nil)
  }

  class func subscribeToChannel(_ pubNubSubscriber: PubNubSubscriber, publisher: String) {
    sharedNub.pubNubSubscriber = pubNubSubscriber
    sharedNub.pubNub?.subscribe(to: [publisher])
  }

  class func subscribeToChannel(_ pubNubPublisher: PubNubPublisher, publisher: String) {
    sharedNub.pubNubPublisher = pubNubPublisher
    sharedNub.pubNub?.subscribe(to: [publisher])
  }

  private class func handleEvent(_ event: SubscriptionEvent) {
    switch event {
    case let .messageReceived(message):
      var cleanPayload = "\(message.payload)"
      cleanPayload = cleanPayload.replacingOccurrences(of: "\"", with: "")

      if cleanPayload == PubNubManager.stopped {
        sharedNub.pubNubSubscriber?.runStopped()
      } else if cleanPayload == PubNubManager.stopRun {
        sharedNub.pubNubPublisher?.stopRun()
      } else if cleanPayload.hasPrefix(PubNubManager.messageLabel) {
        sharedNub.pubNubPublisher?.receiveMessage(String(cleanPayload.dropFirst(PubNubManager.messageLabel.count)))
      } else {
        sharedNub.pubNubSubscriber?.receiveProgress(cleanPayload)
      }
    default:
      break
    }
  }

  class func unsubscribeFromChannel(_ publisher: String) {
    if sharedNub.pubNubSubscriber != nil {
      sharedNub.pubNub?.unsubscribe(from: [publisher])
      sharedNub.pubNubSubscriber = nil
    }
  }
}
