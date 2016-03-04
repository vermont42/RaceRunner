//
//  BroadcastDelegate.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation

protocol BroadcastDelegate: class {
  func userWantsToBroadcast(userWantsToBroadcast: Bool)
}