//
//  RunDelegate.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/5/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import CoreLocation
import UIKit

protocol RunDelegate {
  func showInitialCoordinate(_ coordinate: CLLocationCoordinate2D)
  func plotToCoordinate(_ coordinate: CLLocationCoordinate2D, altitudeColor: UIColor, paceColor: UIColor)
  func receiveProgress(_ totalDistance: Double, totalSeconds: Int, altitude: Double, altGained: Double, altLost: Double)
  func stopRun()
}

