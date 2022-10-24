//
//  PubNubSubscriber.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

protocol PubNubSubscriber {
  func receiveProgress(_ progress: String)
  func runStopped()
}
