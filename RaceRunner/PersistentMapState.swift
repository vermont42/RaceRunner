//
//  PersistentMapState.swift
//  RaceRunner
//
//  Created by Josh Adams on 12/12/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation
import GoogleMaps

enum PersistentMapState {
  static var pin = GMSMarker()
  static var currentCoordinate: CLLocationCoordinate2D?
  static var runnerIcons = RunnerIcons()
  static var latestDirection = RunnerIcons.Direction.stationary
  static var latestAltitudeStrokeColor = UIConstants.intermediate2ColorDarkened
  static var latestPaceStrokeColor = UIConstants.intermediate2ColorDarkened
  static var path = GMSMutablePath()
  static var polyline = GMSPolyline()
  static var altitudeSpans: [GMSStyleSpan] = []
  static var paceSpans: [GMSStyleSpan] = []

  static func initMapState() {
    polyline = GMSPolyline()
    path = GMSMutablePath()
    paceSpans = []
    altitudeSpans = []
    polyline.strokeWidth = UIConstants.polylineWidth
    currentCoordinate = nil
    pin = GMSMarker()
    runnerIcons = RunnerIcons()
    latestDirection = .stationary
    latestAltitudeStrokeColor = UIConstants.intermediate2ColorDarkened
    latestPaceStrokeColor = UIConstants.intermediate2ColorDarkened
  }
}
