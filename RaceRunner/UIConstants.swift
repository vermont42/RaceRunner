//
//  UIConstants.swift
//  RaceRunner
//
//  Created by Josh Adams on 8/28/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

enum UIConstants {
  static let lightColor = UIColor(red: 247.0 / 255.0, green: 225.0 / 255.0, blue: 215.0 / 255.0, alpha: 1.0)
  static let darkColor = UIColor(red: 74.0 / 255.0, green: 87.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
  static let intermediate1Color = UIColor(red: 237.0 / 255.0, green: 175.0 / 255.0, blue: 184.0 / 255.0, alpha: 1.0) // pink
  static let intermediate2Color = UIColor(red: 222.0 / 255.0, green: 219.0 / 255.0, blue: 210.0 / 255.0, alpha: 1.0) // yellow
  static let intermediate3Color = UIColor(red: 176.0 / 255.0, green: 196.0 / 255.0, blue: 177.0 / 255.0, alpha: 1.0) // light green
  static let darkening: CGFloat = 0.85
  static let intermediate2ColorDarkened = UIColor(red: (222.0 / 255.0) * darkening, green: (219.0 / 255.0) * darkening, blue: (210.0 / 255.0) * darkening, alpha: 1.0) // yellow
  static let globalFont = "AvenirNext-Demibold"
  static let globalFontBold = "AvenirNext-Heavy"
  static let bodyFontSize: CGFloat = 18.0
  static let panDuration: TimeInterval = 0.4
  static let polylineWidth: CGFloat = 8.0
  static let cameraZoom: Float = 16.0
  static let messageDelay: Double = 2.0
  static let notDoneAlpha: CGFloat = 0.50
}
