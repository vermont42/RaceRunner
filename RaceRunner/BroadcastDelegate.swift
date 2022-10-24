//
//  BroadcastDelegate.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation

protocol BroadcastDelegate: AnyObject {
  func userWantsToBroadcast(_ userWantsToBroadcast: Bool)
}
