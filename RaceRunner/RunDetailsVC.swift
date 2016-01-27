//
//  RunDetailsVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/8/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import GoogleMaps

class RunDetailsVC: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, GMSMapViewDelegate {
  @IBOutlet var map: GMSMapView!
  @IBOutlet var date: UILabel!
  @IBOutlet var distance: UILabel!
  @IBOutlet var time: UILabel!
  @IBOutlet var pace: UILabel!
  @IBOutlet var minAlt: UILabel!
  @IBOutlet var maxAlt: UILabel!
  @IBOutlet var gain: UILabel!
  @IBOutlet var loss: UILabel!
  @IBOutlet var temp: UILabel!
  @IBOutlet var weather: UILabel!
  @IBOutlet var weight: UILabel!
  @IBOutlet var calories: UILabel!
  @IBOutlet var paceOrAltitude: UISegmentedControl!
  @IBOutlet var netOrTotalCals: UISegmentedControl!
  
  @IBOutlet var route: MarqueeLabel!
  @IBOutlet var customTitleButton: UIButton!
  @IBOutlet var exportButton: UIButton!
  var run: Run!
  private var alertView: UIAlertView!
  private var paceSpans: [GMSStyleSpan] = []
  private var altitudeSpans: [GMSStyleSpan] = []
  private var addedOverlays: Bool = false
  private var latestStrokeColor = UiConstants.intermediate2ColorDarkened
  private var path = GMSMutablePath()
  private var polyline = GMSPolyline()
  
  private static let newRunNamePrompt = "Enter a new name for this run."
  private static let newRunNameTitle = "Run Name"
  private static let setRunNameButtonTitle = "Set"
  private static let noLocationsError = "Attempted to display details of run with zero locations."
  
  func mapView(mapView:GMSMapView!,idleAtCameraPosition position:GMSCameraPosition!) {
    if !addedOverlays {
      addOverlays()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if self.run.locations.count > 0 {
      configureView()
    }
    else {
      fatalError(RunDetailsVC.noLocationsError)
    }
    map.mapType = kGMSTypeTerrain
    map.delegate = self
    polyline.strokeWidth = UiConstants.polylineWidth
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func configureView() {
    var northeast = CLLocationCoordinate2D(latitude: run.maxLatitude.doubleValue, longitude: run.maxLongitude.doubleValue)
    var southwest = CLLocationCoordinate2D(latitude: run.minLatitude.doubleValue, longitude: run.minLongitude.doubleValue)
    northeast.longitude += UiConstants.longitudeCushion
    southwest.longitude -= UiConstants.longitudeCushion
    map.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)))
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    date.text = dateFormatter.stringFromDate(run.timestamp)
    distance.text = "Dist: \(Converter.stringifyDistance(run.distance.doubleValue))"
    time.text = "Time: \(Converter.stringifySecondCount(run.duration.integerValue, useLongFormat: false))"
    pace.text = "Pace: \(Converter.stringifyPace(run.distance.doubleValue, seconds: run.duration.integerValue))"
    minAlt.text = "Min Alt: \(Converter.stringifyAltitude(run.minAltitude.doubleValue))"
    maxAlt.text = "Max Alt: \(Converter.stringifyAltitude(run.maxAltitude.doubleValue))"
    gain.text = "Gained: \(Converter.stringifyAltitude(run.altitudeGained.doubleValue))"
    loss.text = "Lost: \(Converter.stringifyAltitude(run.altitudeLost.doubleValue))"
    if run.weather as String == Run.noWeather {
      weather.text = Run.noWeather
    }
    else {
      weather.text = "Weather: \(run.weather as String)"
    }
    if run.temperature.floatValue == Run.noTemperature {
      temp.text = Run.noTemperatureText
    }
    else {
      temp.text = "Temp: \(Converter.stringifyTemperature(run.temperature.floatValue))"
    }
    route.text = "Name: \(run.displayName())"
    if SettingsManager.getShowWeight() && run.weight.doubleValue != Run.noWeight {
      weight.text = "Weight: \(HumanWeight.weightAsString(run.weight.doubleValue, unitType: SettingsManager.getUnitType()))"
    }
    else {
      weight.text = " "
    }
    updateCalories()
  }
  
  func updateCalories() {
    let weight = run.weight.doubleValue != Run.noWeight ? run.weight.doubleValue : HumanWeight.defaultWeight
    if netOrTotalCals.selectedSegmentIndex == 0 { // total
      self.calories.text = Converter.totalCaloriesAsString(run.distance.doubleValue, weight: weight)
    }
    else { // net
      self.calories.text = Converter.netCaloriesAsString(run.distance.doubleValue, weight: weight)
    }
  }
  
  func addOverlays() {
    if run.locations.count > 1 {
      map.clear()
      if (paceOrAltitude.selectedSegmentIndex == 1 && paceSpans.count == 0) ||
          (paceOrAltitude.selectedSegmentIndex == 0 && altitudeSpans.count == 0) {
        var rawValues: [Double] = []
        if paceOrAltitude.selectedSegmentIndex == 1 {
          for var i = 1; i < run.locations.count; i++ {
            let firstLoc = run.locations[i - 1] as! Location
            let secondLoc = run.locations[i] as! Location
            let firstLocCL = CLLocation(latitude: firstLoc.latitude.doubleValue, longitude: firstLoc.longitude.doubleValue)
            let secondLocCL = CLLocation(latitude: secondLoc.latitude.doubleValue, longitude: secondLoc.longitude.doubleValue)
            let distance = secondLocCL.distanceFromLocation(firstLocCL)
            let time = secondLoc.timestamp.timeIntervalSinceDate(firstLoc.timestamp)
            let speed = distance / time
            rawValues.append(speed)
          }
        }
        else {
          for var i = 0; i < run.locations.count; i++ {
            let location = run.locations[i] as! Location
            rawValues.append(location.altitude.doubleValue)
          }
        }
        let idealSmoothReachSize = 33 // about 133 locations/mile
        var smoothValues: [Double] = []
        for (var i = 0; i < rawValues.count; i++) {
          var lowerBound = i - idealSmoothReachSize / 2
          var upperBound = i + idealSmoothReachSize / 2
          if lowerBound < 0 {
            lowerBound = 0;
          }
          if upperBound > (rawValues.count - 1) {
            upperBound = rawValues.count - 1
          }
          var range = NSRange()
          range.location = lowerBound
          range.length = upperBound - lowerBound
          let indexSet = NSMutableIndexSet(indexesInRange: range)
          var relevantValues: [Double] = []
          for index in indexSet {
            relevantValues.append(rawValues[index])
          }
          var total = 0.0
          for value in relevantValues {
            total += value
          }
          let smoothAverage = total / Double(upperBound - lowerBound)
          smoothValues.append(smoothAverage)
        }
        var sortedValues = smoothValues
        sortedValues.sortInPlace { $0 < $1 }
        for var i = 1; i < run.locations.count; i++ {
          let firstLoc = run.locations[i - 1] as! Location
          let secondLoc = run.locations[i] as! Location
          let firstLocCL = CLLocation(latitude: firstLoc.latitude.doubleValue, longitude: firstLoc.longitude.doubleValue)
          let secondLocCL = CLLocation(latitude: secondLoc.latitude.doubleValue, longitude: secondLoc.longitude.doubleValue)
          var coords = [firstLocCL.coordinate, secondLocCL.coordinate]
          let value = smoothValues[i - 1]
          var index = sortedValues.indexOf(value)
          if index == nil {
            index = 0
          }
          if !addedOverlays {
            path.addCoordinate(coords[1])
          }
          let color = UiHelpers.colorForValue(value, sortedArray: sortedValues, index: index!)
          let gradient = GMSStrokeStyle.gradientFromColor(latestStrokeColor, toColor: color)
          latestStrokeColor = color
          if paceOrAltitude.selectedSegmentIndex == 1 {
            paceSpans.append(GMSStyleSpan(style: gradient))
          }
          else {
            altitudeSpans.append(GMSStyleSpan(style: gradient))
          }
        }
        addedOverlays = true
      }
      polyline.path = path
      if paceOrAltitude.selectedSegmentIndex == 1 {
        polyline.spans = paceSpans
      }
      else {
        polyline.spans = altitudeSpans
      }
      polyline.map = map
    }
  }
  
  @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {}
  
  override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    if let id = identifier{
      let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
        
      })
      return unwindSegue
    }
    
    return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "pan graphs from details" {
      let graphsVC: GraphsVC = segue.destinationViewController as! GraphsVC
      graphsVC.run = run
    }
  }

  @IBAction func setCustomName() {
    let alertController = UIAlertController(title: RunDetailsVC.newRunNameTitle, message: RunDetailsVC.newRunNamePrompt, preferredStyle: UIAlertControllerStyle.Alert)
    let setAction = UIAlertAction(title: RunDetailsVC.setRunNameButtonTitle, style: UIAlertActionStyle.Default, handler: { (action) in
      let textFields = alertController.textFields!
      self.route.text = "Name: \(textFields[0].text!)"
      self.run.customName = textFields[0].text!
      CDManager.saveContext()
    })
    alertController.addAction(setAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) in })
    alertController.addAction(cancelAction)
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Name"
    }
    alertController.view.tintColor = UiConstants.intermediate1Color
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  @IBAction func changeOverlay(sender: UISegmentedControl) {
    addOverlays()
  }
  
  @IBAction func changeCalorieType(sender: UISegmentedControl) {
    updateCalories()
  }
  
  @IBAction func back(sender: UIButton) {
    performSegueWithIdentifier("unwind pan log", sender: self)
  }
  
  @IBAction func export() {
    GpxExporter.export(run)
  }
  
  @IBAction func graph() {
    performSegueWithIdentifier("pan graphs from details", sender: self)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

