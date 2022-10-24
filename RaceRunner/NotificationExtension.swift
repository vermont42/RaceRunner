//
//  NotificationExtension.swift
//  RaceRunner
//
//  Created by Josh Adams on 6/18/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation

extension Notification.Name {
  static let runDidStart = Notification.Name("runDidStart")
  static let runDidStop = Notification.Name("runDidStop")
  static let runDidPause = Notification.Name("runDidPause")
  static let runDidResume = Notification.Name("runDidResume")
  static let showInitialCoordinate = Notification.Name("showInitialCoordinate")
  static let plotToCoordinate = Notification.Name("plotToCoordinate")
  static let receiveProgress = Notification.Name("receiveProgress")
}
