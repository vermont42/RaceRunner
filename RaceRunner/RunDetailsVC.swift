//
//  RunDetailsVC.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/8/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import GoogleMaps
import MarqueeLabel
import UIKit

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

  var run: Run?

  private static let newRunNamePrompt = "Enter a new name for this run."
  private static let newRunNameTitle = "Run Name"
  private static let setRunNameButtonTitle = "Set"
  private static let noLocationsError = "Attempted to display details of run with zero locations."
  private static let cancel = "Cancel"
  private static let name = "Name"
  private static let weatherMessage = "Weather data powered by Open Weather. openweathermap.org"
  private static let weatherTitle = "Credit"
  private static let weatherOkay = "Got It"

  private let nilMessage = "run was nil in \(RunDetailsVC.self)."
  private var paceSpans: [GMSStyleSpan] = []
  private var altitudeSpans: [GMSStyleSpan] = []
  private var smoothSpeeds: [Double]?
  private var maxSmoothSpeed = 0.0
  private var minSmoothSpeed = Double(LONG_MAX)
  private var addedOverlays = false
  private var latestStrokeColor = UIConstants.intermediate2ColorDarkened
  private var path = GMSMutablePath()
  private var polyline = GMSPolyline()

  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    if !addedOverlays {
      addOverlays()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    map.mapType = .terrain
    map.delegate = self
    polyline.strokeWidth = UIConstants.polylineWidth
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AWSAnalyticsService.shared.recordVisitation(viewController: "\(RunDetailsVC.self)")
    if !SettingsManager.getShowedWeatherCredit() {
      UIAlertController.showMessage(RunDetailsVC.weatherMessage, title: RunDetailsVC.weatherTitle, okTitle: RunDetailsVC.weatherOkay)
      SettingsManager.setShowedWeatherCredit(true)
    }

    configureView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    configureMap()
  }

  private func configureMap() {
    guard let run = run else {
      fatalError(nilMessage + "viewDidLoad()")
    }

    // swiftlint:disable empty_count
    guard run.locations.count > 0 else {
      fatalError(RunDetailsVC.noLocationsError)
    }

    var northeast = CLLocationCoordinate2D(latitude: run.maxLatitude.doubleValue, longitude: run.maxLongitude.doubleValue)
    var southwest = CLLocationCoordinate2D(latitude: run.minLatitude.doubleValue, longitude: run.minLongitude.doubleValue)
    let cushion: Double = 0.0013
    northeast.latitude += cushion
    southwest.latitude -= cushion
    northeast.longitude += cushion
    southwest.longitude -= cushion

    let bounds = GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
    map.camera = map.camera(for: bounds, insets: UIEdgeInsets())!
  }

  private func configureView() {
    guard let run = run else {
      fatalError(nilMessage + "configureView()")
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.timeStyle = DateFormatter.Style.short
    date.text = dateFormatter.string(from: run.timestamp as Date)
    distance.text = "Dist: \(Converter.stringifyDistance(run.distance.doubleValue))"
    time.text = "Time: \(Converter.stringifySecondCount(run.duration.intValue, useLongFormat: false))"
    pace.text = "Pace: \(Converter.stringifyPace(run.distance.doubleValue, seconds: run.duration.intValue))"
    minAlt.text = "Min Alt: \(Converter.stringifyAltitude(run.minAltitude.doubleValue))"
    maxAlt.text = "Max Alt: \(Converter.stringifyAltitude(run.maxAltitude.doubleValue))"
    gain.text = "Gained: \(Converter.stringifyAltitude(run.altitudeGained.doubleValue))"
    loss.text = "Lost: \(Converter.stringifyAltitude(run.altitudeLost.doubleValue))"
    if run.weather as String == Run.noWeather {
      weather.text = Run.noWeather
    } else {
      weather.text = "Weather: \(run.weather as String)"
    }
    if run.temperature.doubleValue == Run.noTemperature {
      temp.text = Run.noTemperatureText
    } else {
      temp.text = "Temp: \(Converter.stringifyTemperature(run.temperature.doubleValue))"
    }
    route.text = "\(RunDetailsVC.name): \(run.displayName()) "
    if SettingsManager.getShowWeight() && run.weight.doubleValue != Run.noWeight {
      weight.text = "Weight: \(HumanWeight.weightAsString(run.weight.doubleValue, unitType: SettingsManager.getUnitType()))"
    } else {
      weight.text = " "
    }
    updateCalories()
  }

  private func updateCalories() {
    guard let run = run else {
      fatalError(nilMessage + "updateCalories()")
    }
    let weight = run.weight.doubleValue != Run.noWeight ? run.weight.doubleValue : HumanWeight.defaultWeight
    if netOrTotalCals.selectedSegmentIndex == 0 { // total
      self.calories.text = Converter.totalCaloriesAsString(run.distance.doubleValue, weight: weight)
    } else { // net
      self.calories.text = Converter.netCaloriesAsString(run.distance.doubleValue, weight: weight)
    }
  }

  private func addOverlays() {
    guard let run = run else {
      fatalError(nilMessage + "addOverlays()")
    }
    if run.locations.count > 1 {
      map.clear()
      let areSpeeds = paceOrAltitude.selectedSegmentIndex == 1 ? true : false
      if (areSpeeds && paceSpans.count == 0) || (!areSpeeds && altitudeSpans.count == 0) {
        makeSpans(areSpeeds: areSpeeds)
        addedOverlays = true
      }
      polyline.path = path
      if areSpeeds {
        polyline.spans = paceSpans
      } else {
        polyline.spans = altitudeSpans
      }
      polyline.map = map
    }
  }

  private func makeSpans(areSpeeds: Bool) {
    guard let run = run else {
      fatalError(nilMessage + "makeSpans()")
    }
    var rawValues: [Double] = []
    if areSpeeds {
      for i in 1 ..< run.locations.count {
        let firstLoc = run.locations[i - 1] as? Location ?? Location(context: CDManager.sharedCDManager.context)
        let secondLoc = run.locations[i] as? Location ?? Location(context: CDManager.sharedCDManager.context)
        let firstLocCL = CLLocation(latitude: firstLoc.latitude.doubleValue, longitude: firstLoc.longitude.doubleValue)
        let secondLocCL = CLLocation(latitude: secondLoc.latitude.doubleValue, longitude: secondLoc.longitude.doubleValue)
        let distance = secondLocCL.distance(from: firstLocCL)
        let time = secondLoc.timestamp.timeIntervalSince(firstLoc.timestamp as Date)
        let speed = distance / time
        rawValues.append(speed)
      }
    } else {
      for i in 0 ..< run.locations.count {
        if let location = run.locations[i] as? Location {
          rawValues.append(location.altitude.doubleValue)
        }
      }
    }
    let idealSmoothReachSize = 33 // about 133 locations/mile
    var smoothValues: [Double] = []
    for i in 0 ..< rawValues.count {
      var lowerBound = i - idealSmoothReachSize / 2
      var upperBound = i + idealSmoothReachSize / 2
      if lowerBound < 0 {
        lowerBound = 0
      }
      if upperBound > (rawValues.count - 1) {
        upperBound = rawValues.count - 1
      }
      var range = NSRange()
      range.location = lowerBound
      range.length = upperBound - lowerBound
      let indexSet = NSMutableIndexSet(indexesIn: range)
      var relevantValues: [Double] = []
      for index in indexSet {
        relevantValues.append(rawValues[index])
      }
      var total = 0.0
      for value in relevantValues {
        total += value
      }
      let smoothAverage = total / Double(upperBound - lowerBound)
      if areSpeeds {
        if smoothAverage > maxSmoothSpeed {
          maxSmoothSpeed = smoothAverage
        }
        if smoothAverage < minSmoothSpeed {
          minSmoothSpeed = smoothAverage
        }
      }
      smoothValues.append(smoothAverage)
    }
    if areSpeeds {
      smoothSpeeds = smoothValues
    }

    var sortedValues = smoothValues
    sortedValues.sort { $0 < $1 }
    for i in 1 ..< run.locations.count {
      if let firstLoc = run.locations[i - 1] as? Location, let secondLoc = run.locations[i] as? Location {
        let firstLocCL = CLLocation(latitude: firstLoc.latitude.doubleValue, longitude: firstLoc.longitude.doubleValue)
        let secondLocCL = CLLocation(latitude: secondLoc.latitude.doubleValue, longitude: secondLoc.longitude.doubleValue)
        let coords = [firstLocCL.coordinate, secondLocCL.coordinate]
        let value = smoothValues[i - 1]
        var index = sortedValues.firstIndex(of: value)
        if index == nil {
          index = 0
        }
        if !addedOverlays {
          path.add(coords[1])
        }
        let color = UiHelpers.colorForValue(value, sortedArray: sortedValues, index: index ?? 0)
        let gradient = GMSStrokeStyle.gradient(from: latestStrokeColor, to: color)
        latestStrokeColor = color
        if areSpeeds {
          paceSpans.append(GMSStyleSpan(style: gradient))
        } else {
          altitudeSpans.append(GMSStyleSpan(style: gradient))
        }
      }
    }
  }

  @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {}

  override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    UnwindPanSegue(identifier: identifier ?? "", source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pan graphs from details" {
      if let graphVC = segue.destination as? GraphVC {
        graphVC.run = run
        if smoothSpeeds == nil {
          makeSpans(areSpeeds: true)
        }
        if let smoothSpeeds = smoothSpeeds {
          graphVC.smoothSpeeds = smoothSpeeds
          graphVC.maxSmoothSpeed = maxSmoothSpeed
          graphVC.minSmoothSpeed = minSmoothSpeed
        }
      }
    }
  }

  @IBAction func setCustomName() {
    let alertController = UIAlertController(title: RunDetailsVC.newRunNameTitle, message: RunDetailsVC.newRunNamePrompt, preferredStyle: UIAlertController.Style.alert)
    let setAction = UIAlertAction(title: RunDetailsVC.setRunNameButtonTitle, style: UIAlertAction.Style.default, handler: { _ in
      if let textFields = alertController.textFields {
        let text = textFields[0].text ?? ""
        self.route.text = "\(RunDetailsVC.name): \(text)"
        guard let run = self.run else {
          fatalError(self.nilMessage + "setCustomName()")
        }
        run.customName = text as NSString
        CDManager.saveContext()
      }
    })
    alertController.addAction(setAction)
    let cancelAction = UIAlertAction(title: RunDetailsVC.cancel, style: UIAlertAction.Style.cancel, handler: { _ in })
    alertController.addAction(cancelAction)
    alertController.addTextField { textField in
      textField.placeholder = "\(RunDetailsVC.name)"
    }
    alertController.view.tintColor = UIConstants.intermediate1Color
    present(alertController, animated: true, completion: nil)
    alertController.view.tintColor = UIConstants.intermediate1Color
  }

  @IBAction func changeOverlay(_ sender: UISegmentedControl) {
    addOverlays()
  }

  @IBAction func changeCalorieType(_ sender: UISegmentedControl) {
    updateCalories()
  }

  @IBAction func back(_ sender: UIButton) {
    performSegue(withIdentifier: "unwind pan log", sender: self)
  }

  @IBAction func export() {
    guard let run = run else {
      fatalError(nilMessage + "export()")
    }
    GpxExporter.export(run)
  }

  @IBAction func graph() {
    performSegue(withIdentifier: "pan graphs from details", sender: self)
  }

  override var prefersStatusBarHidden: Bool {
    true
  }
}
