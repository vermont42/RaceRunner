//
//  UiConstants.swift
//  RaceRunner
//
//  Created by Joshua Adams on 8/28/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

class UiConstants {
    static let lightColor = UIColor(red: 247.0/255.0, green: 225.0/255.0, blue: 215.0/255.0, alpha: 1.0)
    static let darkColor = UIColor(red: 74.0/255.0, green: 87.0/255.0, blue: 89.0/255.0, alpha: 1.0)
    static let intermediate1Color = UIColor(red: 237.0/255.0, green: 175.0/255.0, blue: 184.0/255.0, alpha: 1.0) // pink
    static let intermediate2Color = UIColor(red: 222.0/255.0, green: 219.0/255.0, blue: 210.0/255.0, alpha: 1.0) // yellow
    static let intermediate3Color = UIColor(red: 176.0/255.0, green: 196.0/255.0, blue: 177.0/255.0, alpha: 1.0) // light green
    static let darkening: CGFloat = 0.75
    static let intermediate2ColorDarkened = UIColor(red: (222.0/255.0) * darkening, green: (219.0/255.0) * darkening, blue: (210.0/255.0) * darkening, alpha: 1.0) // yellow
    static let titleFont = "Avenir Next"
    static let titleFontSize: CGFloat = 42.0
    static let panDuration: NSTimeInterval = 0.4
    static let polylineWidth: CGFloat = 7.0
    static let cameraZoom: Float = 16.0
    static let longitudeCushion: Double = 0.00851970939493185
    static let bigStrideZoomThreshhold: Float = 13.0
    static let bigStride: Int = 10
    static let applauseSampleCount: UInt32 = 3
}