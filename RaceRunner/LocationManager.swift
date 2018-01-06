//
//  LocationManager.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/23/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreLocation

open class LocationManager {
  private var gpxLocationManager: GpxLocationManager!
  private var cLLocationManager: CLLocationManager!
  
  public enum LocationManagerType {
    case gpx
    case coreLocation
    
    init() {
      self = .coreLocation
    }
  }
  open var location: CLLocation! {
    get {
      switch locationManagerType {
      case .gpx:
        return gpxLocationManager.location
      case .coreLocation:
        return cLLocationManager.location
      }
    }
  }
  open weak var delegate: CLLocationManagerDelegate! {
    get {
      switch locationManagerType {
      case .gpx:
        return gpxLocationManager.delegate
      case .coreLocation:
        return cLLocationManager.delegate
      }
    }
    set {
      switch locationManagerType {
      case .gpx:
        gpxLocationManager.delegate = newValue
      case .coreLocation:
        cLLocationManager.delegate = newValue
      }
    }
  }
  open var desiredAccuracy: CLLocationAccuracy {
    get {
      switch locationManagerType {
      case .gpx:
        return gpxLocationManager.desiredAccuracy
      case .coreLocation:
        return cLLocationManager.desiredAccuracy
      }
    }
    set {
      switch locationManagerType {
      case .gpx:
        gpxLocationManager.desiredAccuracy = newValue
      case .coreLocation:
        cLLocationManager.desiredAccuracy = newValue
      }
    }
  }
  open var activityType: CLActivityType {
    get {
      switch locationManagerType {
      case .gpx:
        return gpxLocationManager.activityType
      case .coreLocation:
        return cLLocationManager.activityType
      }
    }
    set {
      switch locationManagerType {
      case .gpx:
        gpxLocationManager.activityType = newValue
      case .coreLocation:
        cLLocationManager.activityType = newValue
      }
    }
  }
  open var distanceFilter: CLLocationDistance {
    get {
      switch locationManagerType {
      case .gpx:
        return gpxLocationManager.distanceFilter
      case .coreLocation:
        return cLLocationManager.distanceFilter
      }
    }
    set {
      switch locationManagerType {
      case .gpx:
        gpxLocationManager.distanceFilter = newValue
      case .coreLocation:
        cLLocationManager.distanceFilter = newValue
      }
    }
  }
  open var pausesLocationUpdatesAutomatically: Bool {
    get {
      switch locationManagerType {
      case .gpx:
        return gpxLocationManager.pausesLocationUpdatesAutomatically
      case .coreLocation:
        return cLLocationManager.pausesLocationUpdatesAutomatically
      }
    }
    set {
      switch locationManagerType {
      case .gpx:
        gpxLocationManager.pausesLocationUpdatesAutomatically = newValue
      case .coreLocation:
        cLLocationManager.pausesLocationUpdatesAutomatically = newValue
      }
    }
  }
  open func requestAlwaysAuthorization() {
    switch locationManagerType {
    case .gpx:
      gpxLocationManager.requestAlwaysAuthorization()
    case .coreLocation:
      cLLocationManager.requestAlwaysAuthorization()
    }
  }
  open var secondLength: Double {
    get {
      switch locationManagerType {
      case .gpx:
        return gpxLocationManager.secondLength
      case .coreLocation:
        return 1.0
      }
    }
    set {
      switch locationManagerType {
      case .gpx:
        gpxLocationManager.secondLength = newValue
      case .coreLocation:
        break
      }
    }
  }
  open var allowsBackgroundLocationUpdates: Bool {
    get {
      switch locationManagerType {
      case .gpx:
        return gpxLocationManager.allowsBackgroundLocationUpdates
      case .coreLocation:
        return cLLocationManager.allowsBackgroundLocationUpdates
      }
    }
    set {
      switch locationManagerType {
      case .gpx:
        gpxLocationManager.allowsBackgroundLocationUpdates = newValue
      case .coreLocation:
        cLLocationManager.allowsBackgroundLocationUpdates = newValue
        break
      }
    }
  }
  
  open func kill() {
    switch locationManagerType {
    case .gpx:
      gpxLocationManager.kill()
    case .coreLocation:
      break
    }
  }

  open let locationManagerType: LocationManagerType
  
  public init() {
    cLLocationManager = CLLocationManager()
    locationManagerType = .coreLocation
  }
  
  public init(gpxFile: String) {
    gpxLocationManager = GpxLocationManager(gpxFile: gpxFile)
    locationManagerType = .gpx
  }
  
  public init(locations: [CLLocation]) {
    gpxLocationManager = GpxLocationManager(locations: locations)
    locationManagerType = .gpx
  }
  
  open func stopUpdatingLocation() {
    switch locationManagerType {
    case .gpx:
      gpxLocationManager.stopUpdatingLocation()
    case .coreLocation:
      cLLocationManager.stopUpdatingLocation()
    }
  }
  
  open func startUpdatingLocation() {
    switch locationManagerType {
    case .gpx:
      gpxLocationManager.startUpdatingLocation()
    case .coreLocation:
      cLLocationManager.startUpdatingLocation()
    }
  }
}
