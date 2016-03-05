//
//  RunDelegate.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/5/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import CoreLocation

protocol RunDelegate {
  func showInitialCoordinate(coordinate: CLLocationCoordinate2D)
  func plotToCoordinate(coordinate: CLLocationCoordinate2D, altitudeColor: UIColor, paceColor: UIColor)
  func receiveProgress(totalDistance: Double, totalSeconds: Int, altitude: Double, altGained: Double, altLost: Double)
  func stopRun()
}

