//
//  PubNubPublisher.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/5/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

protocol PubNubPublisher {
  func stopRun()
  func receiveMessage(_ message: String)
}
