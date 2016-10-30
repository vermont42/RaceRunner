//
//  PersistentMapState.swift
//  RaceRunner
//
//  Created by Joshua Adams on 12/12/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation
import GoogleMaps

class PersistentMapState {
  static var pin: GMSMarker!
  static var currentCoordinate: CLLocationCoordinate2D!
  static var runnerIcons: RunnerIcons!
  static var latestDirection: RunnerIcons.Direction!
  static var latestAltitudeStrokeColor: UIColor!
  static var latestPaceStrokeColor: UIColor!
  static var path: GMSMutablePath!
  static var polyline: GMSPolyline!
  static var altitudeSpans: [GMSStyleSpan]!
  static var paceSpans: [GMSStyleSpan]!
  
  static func initMapState() {
    polyline = GMSPolyline()
    path = GMSMutablePath()
    paceSpans = []
    altitudeSpans = []
    polyline.strokeWidth = UiConstants.polylineWidth
    currentCoordinate = nil
    pin = GMSMarker()
    runnerIcons = RunnerIcons()
    latestDirection = .stationary
    latestAltitudeStrokeColor = UiConstants.intermediate2ColorDarkened
    latestPaceStrokeColor = UiConstants.intermediate2ColorDarkened
  }
}
