//
//  GpxLocationManager.swift
//  GpxLocationManager
//
//  Created by Josh Adams on 4/18/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import CoreLocation
import Foundation

open class GpxLocationManager {
  open var pausesLocationUpdatesAutomatically = true
  open var distanceFilter: CLLocationDistance = kCLDistanceFilterNone
  open var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
  open var activityType: CLActivityType = .other
  open var headingFilter: CLLocationDegrees = 1
  open var headingOrientation: CLDeviceOrientation = .portrait
  open var monitoredRegions: Set<NSObject>! { Set<NSObject>() }
  open var maximumRegionMonitoringDistance: CLLocationDistance { -1 }
  open var rangedRegions: Set<NSObject>! { Set<NSObject>() }
  open var heading: CLHeading! { nil }
  open var allowsBackgroundLocationUpdates = true
  open var secondLength = 1.0

  open func requestWhenInUseAuthorization() {}
  open func requestAlwaysAuthorization() {}
  open func startMonitoringSignificantLocationChanges() {}
  open func stopMonitoringSignificantLocationChanges() {}
  open func startUpdatingHeading() {}
  open func stopUpdatingHeading() {}
  open func dismissHeadingCalibrationDisplay() {}
  open func startMonitoringForRegion(_ region: CLRegion) {}
  open func stopMonitoringForRegion(_ region: CLRegion) {}
  open func startRangingBeaconsInRegion(_ region: CLBeaconRegion) {}
  open func stopRangingBeaconsInRegion(_ region: CLBeaconRegion) {}
  open func requestStateForRegion(_ region: CLRegion) {}
  open func startMonitoringVisits() {}
  open func stopMonitoringVisits() {}
  // swiftlint:disable function_default_parameter_at_end
  open func allowDeferredLocationUpdatesUntilTraveled(_ distance: CLLocationDistance = 0, timeout: TimeInterval) {}
  open func disallowDeferredLocationUpdates() {}

  open class func authorizationStatus() -> CLAuthorizationStatus { CLAuthorizationStatus.authorizedAlways }
  open class func locationServicesEnabled() -> Bool { true }
  open class func deferredLocationUpdatesAvailable() -> Bool { true }
  open class func significantLocationChangeMonitoringAvailable() -> Bool { true }
  open class func headingAvailable() -> Bool { true }
  open class func isMonitoringAvailableForClass(_ regionClass: AnyClass! = nil) -> Bool { true }
  open class func isRangingAvailable() -> Bool { true }

  open var location: CLLocation! { locations[lastLocation] }
  open weak var delegate: CLLocationManagerDelegate!
  open var shouldKill = false

  private var locations: [CLLocation] = []
  private var lastLocation = 0
  private var hasStarted = false
  private var isPaused = false
  private var callerQueue: DispatchQueue!
  private var updateQueue: DispatchQueue!
  private var dateFormatter = DateFormatter()
  private var dummyCLLocationManager: CLLocationManager!

  static let dateFudge: TimeInterval = 1.0

  private static let initWithNoArgumentsMessage = "Attempted to initialize GpxLocationManager with no arguments."
  private static let gpxParseErrorMessage = "Parsing of GPX file failed."

  open func startUpdatingLocation() {
    if !hasStarted {
      hasStarted = true
      dummyCLLocationManager = CLLocationManager()
      let startDate = Date()
      let timeInterval = round(startDate.timeIntervalSince(locations[0].timestamp))
      for i in 0 ..< locations.count {
        locations[i] = CLLocation(coordinate: locations[i].coordinate, altitude: locations[i].altitude, horizontalAccuracy: locations[i].horizontalAccuracy, verticalAccuracy: locations[i].verticalAccuracy, timestamp: locations[i].timestamp.addingTimeInterval(timeInterval))
      }
      callerQueue = OperationQueue.current?.underlyingQueue
      let updateQueue = DispatchQueue(label: "update queue", attributes: [])
      updateQueue.async(execute: {
        var currentIndex: Int = 0
        var timeIntervalSinceStart = 0.0
        var loopsCompleted = 0
        let routeDuration = round(self.locations[self.locations.count - 1].timestamp.timeIntervalSince(self.locations[0].timestamp))
        while true {
          if self.shouldKill {
            return
          }
          var currentLocation = self.locations[currentIndex]
          currentLocation = CLLocation(coordinate: currentLocation.coordinate, altitude: currentLocation.altitude, horizontalAccuracy: currentLocation.horizontalAccuracy, verticalAccuracy: currentLocation.verticalAccuracy, timestamp: currentLocation.timestamp.addingTimeInterval((routeDuration + TimeInterval(1.0)) * TimeInterval(loopsCompleted)))
          if abs(currentLocation.timestamp.timeIntervalSince(startDate.addingTimeInterval(timeIntervalSinceStart))) < GpxLocationManager.dateFudge {
            if !self.isPaused {
              self.callerQueue.async(execute: {
                self.delegate.locationManager?(self.dummyCLLocationManager, didUpdateLocations: [currentLocation])
              })
            }
            currentIndex += 1
          }
          timeIntervalSinceStart += 1.0
          if currentIndex == self.locations.count {
            currentIndex = 0
            loopsCompleted += 1
          }
          Thread.sleep(forTimeInterval: self.secondLength)
        }
      })
    } else {
      self.isPaused = false
    }
  }

  open func stopUpdatingLocation() {
    self.isPaused = true
  }

  open func kill() {
    shouldKill = true
  }

  public init() {
    fatalError(GpxLocationManager.initWithNoArgumentsMessage)
  }

  public init(gpxFile: String) {
    if let parser = GpxParser(file: gpxFile) {
      self.locations = parser.parse().locations
    } else {
      fatalError(GpxLocationManager.gpxParseErrorMessage)
    }
  }

  public init(locations: [CLLocation]) {
    self.locations = locations
  }

  private func makeLoc(_ latitude: NSString, longitude: NSString, altitude: NSString, timestamp: NSString) -> CLLocation {
    CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue), altitude: altitude.doubleValue, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, timestamp: dateFormatter.date(from: timestamp as String)!)
  }
}
