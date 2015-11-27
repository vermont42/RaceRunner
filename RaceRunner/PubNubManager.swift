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

protocol PubNubSubscriber {
    func receiveProgress(progress: String)
}

class PubNubManager: NSObject, PNObjectEventListener {
    private let pubNub: PubNub?
    private var pubNubSubscriber: PubNubSubscriber?
    static let sharedNub = PubNubManager()
    static let publicChannel = "RaceRunner Channel"
  
    override init() {
        pubNub = PubNub.clientWithConfiguration(PNConfiguration(publishKey: Config.pubNubPublishKey, subscribeKey: Config.pubNubSubscribeKey))
        super.init()
        pubNub?.addListener(self)
    }
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        pubNubSubscriber?.receiveProgress("received message \(message.data.message)")
    }
  
    class func pubishLocation(location: CLLocation, distance: Double, seconds: Int) {
        let message = "\(location.coordinate.latitude) \(location.coordinate.longitude) \(location.altitude) \(distance) \(seconds)"
        sharedNub.pubNub?.publish(message, toChannel: PubNubManager.publicChannel, storeInHistory: false,
            compressed: false, withCompletion: { (status) -> Void in
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
    
    class func subscribeToPublicChannel(pubNubSubscriber: PubNubSubscriber) {
        sharedNub.pubNubSubscriber = pubNubSubscriber
        sharedNub.pubNub?.subscribeToChannels([publicChannel], withPresence: true)
    }
    
    class func unsubscribeFromPublicChannel() {
        if let _ = sharedNub.pubNubSubscriber {
            sharedNub.pubNub?.unsubscribeFromChannels([publicChannel], withPresence: true)
            sharedNub.pubNubSubscriber = nil
        }
    }
}