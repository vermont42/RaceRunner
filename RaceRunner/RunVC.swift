//
//  RunVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

class RunVC: ChildVC {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var paceLabel: UILabel!
  @IBOutlet var altLabel: UILabel!
  @IBOutlet var altGainedLabel: UILabel!
  @IBOutlet var altLostLabel: UILabel!
  @IBOutlet var startStopButton: UIButton!
  @IBOutlet var showMenuButton: UIButton!
  @IBOutlet var pauseResume: UIButton!
  @IBOutlet var map: GMSMapView!
  @IBOutlet var paceOrAltitude: UISegmentedControl!

  var runToSimulate: Run?
  var gpxFile: String?

  private static let gpxTitle = "Berkeley Hills "
  private static let didNotSaveMessage = "RaceRunner did not save this run because it was so short. The run, not RaceRunner. As a collection of electrons on your iPhone, RaceRunner has no physical height."
  private static let noGpsMessage = "RaceRunner cannot record your run because you have not given it permission to access the GPS sensors. You can give this permission in the Settings app."
  private static let pauseError = "Attempted to display details of run with zero locations."
  private static let bummerButtonTitle = "Bummer"
  private static let sadFaceTitle = "😢"
  private static let startTitle = " Start "
  private static let pauseTitle = " Pause "
  private static let stopTitle = " Stop "
  private static let resumeTitle = " Resume "

  private var totalDistance: Double = 0.0
  private var didReceiveLocationUpdate = false

  override func viewDidLoad() {
    map.mapType = .terrain
    map.isHidden = true
    paceOrAltitude.isHidden = true
    view.sendSubviewToBack(map)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RunVC.announceCurrentPace)))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AWSAnalyticsService.shared.recordVisitation(viewController: "\(RunVC.self)")
    NotificationCenter.default.addObserver(self, selector: #selector(runDidStart), name: .runDidStart, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(runDidStop), name: .runDidStop, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(runDidPause), name: .runDidPause, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(runDidResume), name: .runDidResume, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(plotToCoordinate), name: .plotToCoordinate, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(plotToCoordinate), name: .showInitialCoordinate, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(receiveProgress), name: .receiveProgress, object: nil)
    map.clear()
    if let runToSimulate = runToSimulate {
      RunModel.initializeRunModelWithRun(runToSimulate)
      if runToSimulate.customName.isEqual(to: "") {
        viewControllerTitle.text = runToSimulate.autoName as String
      } else {
        viewControllerTitle.text = runToSimulate.customName as String
      }
      PersistentMapState.initMapState()
      RunModel.runModel.start()
    } else if let gpxFile = gpxFile {
      RunModel.initializeRunModelWithGpxFile(gpxFile)
      viewControllerTitle.text = RunVC.gpxTitle
      PersistentMapState.initMapState()
      RunModel.runModel.start()
    } else {
      RunModel.initializeRunModel()
      viewControllerTitle.text = "Run"
    }
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text ?? "")

    switch RunModel.runModel.status {
    case .preRun:
      hideLabels()
      startStopButton.backgroundColor = UiConstants.intermediate3Color
      startStopButton.isHidden = false
      pauseResume.isHidden = true
      PersistentMapState.initMapState()
    case .paused, .inProgress:
      showLabels()
      pauseResume.isHidden = false
      startStopButton.isHidden = false
      startStopButton.backgroundColor = UiConstants.intermediate1Color
      if runToSimulate == nil && gpxFile == nil && !SettingsManager.getStartedViaSiri() {
        addPolylineAndPin()
      }
      if didReceiveLocationUpdate {
        map.isHidden = false
      }
      paceOrAltitude.isHidden = false
      if PersistentMapState.currentCoordinate != nil {
        map.camera = GMSCameraPosition.camera(withLatitude: PersistentMapState.currentCoordinate?.latitude ?? 0.0, longitude: PersistentMapState.currentCoordinate?.longitude ?? 0.0, zoom: UiConstants.cameraZoom)
      } else if let last = RunModel.runModel.locations.last {
        showInitialCoordinate(last.coordinate)
      }
    }
    updateButtonLabels()
  }

  @objc private func updateButtonLabels() {
    switch RunModel.runModel.status {
    case .preRun:
      startStopButton.setTitle(RunVC.startTitle, for: UIControl.State())
      startStopButton.backgroundColor = UiConstants.intermediate3Color
      pauseResume.isHidden = true
    case .paused:
      startStopButton.setTitle(RunVC.stopTitle, for: UIControl.State())
      startStopButton.backgroundColor = UiConstants.intermediate1Color
      pauseResume.setTitle(RunVC.resumeTitle, for: UIControl.State())
      pauseResume.isHidden = false
    case .inProgress:
      startStopButton.setTitle(RunVC.stopTitle, for: UIControl.State())
      startStopButton.backgroundColor = UiConstants.intermediate1Color
      pauseResume.setTitle(RunVC.pauseTitle, for: UIControl.State())
      pauseResume.isHidden = false
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if (runToSimulate != nil || gpxFile != nil) && (RunModel.runModel.status != .preRun)  {
      RunModel.runModel.stop()
    }
    NotificationCenter.default.removeObserver(self)
  }

  @objc func announceCurrentPace() {
    RunModel.runModel.announceCurrentPace()
  }

  func addPolylineAndPin() {
    PersistentMapState.polyline.map = map
    PersistentMapState.pin.position = RunModel.runModel.locations.last?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon
    PersistentMapState.pin.map = map
  }

  @objc func showInitialCoordinate(_ notification: NSNotification) {
    guard let initialCoordinate = notification.userInfo?["\(CLLocationCoordinate2D.self)"] as? CLLocationCoordinate2D else {
      return
    }
    showInitialCoordinate(initialCoordinate)
  }

  func showInitialCoordinate(_ coordinate: CLLocationCoordinate2D) {
    map.camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: UiConstants.cameraZoom)
    PersistentMapState.currentCoordinate = coordinate
    PersistentMapState.pin.position = coordinate
    PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon
    PersistentMapState.pin.map = map
  }
  
  @objc func plotToCoordinate(_ notification: NSNotification) {
    guard let runCoordinate = notification.userInfo?["\(RunCoordinate.self)"] as? RunCoordinate else {
      return
    }
    didReceiveLocationUpdate = true
    if PersistentMapState.currentCoordinate != nil {
      if PersistentMapState.currentCoordinate?.longitude ?? 0.0 > runCoordinate.coordinate.longitude {
        PersistentMapState.runnerIcons.direction = .west
        PersistentMapState.latestDirection = .west
      } else if PersistentMapState.currentCoordinate?.longitude ?? 0.0 < runCoordinate.coordinate.longitude {
        PersistentMapState.runnerIcons.direction = .east
        PersistentMapState.latestDirection = .east
      }
      let coords: [CLLocationCoordinate2D] = [PersistentMapState.currentCoordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), runCoordinate.coordinate]
      map.camera = GMSCameraPosition.camera(withLatitude: runCoordinate.coordinate.latitude, longitude: runCoordinate.coordinate.longitude, zoom: UiConstants.cameraZoom)
      PersistentMapState.path.add(coords[1])
      PersistentMapState.polyline.path = PersistentMapState.path
      let altitudeGradient = GMSStrokeStyle.gradient(from: PersistentMapState.latestAltitudeStrokeColor, to: runCoordinate.altitudeColor)
      let paceGradient = GMSStrokeStyle.gradient(from: PersistentMapState.latestPaceStrokeColor, to: runCoordinate.paceColor)
      PersistentMapState.latestAltitudeStrokeColor = runCoordinate.altitudeColor
      PersistentMapState.latestPaceStrokeColor = runCoordinate.paceColor
      PersistentMapState.altitudeSpans.append(GMSStyleSpan(style: altitudeGradient))
      PersistentMapState.paceSpans.append(GMSStyleSpan(style: paceGradient))
      if paceOrAltitude.selectedSegmentIndex == 0 {
        PersistentMapState.polyline.spans = PersistentMapState.altitudeSpans
      } else {
        PersistentMapState.polyline.spans = PersistentMapState.paceSpans
      }
      PersistentMapState.polyline.map = map
      PersistentMapState.pin.map = nil
      PersistentMapState.pin.position = runCoordinate.coordinate
      PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon
      PersistentMapState.pin.map = map
      PersistentMapState.currentCoordinate = runCoordinate.coordinate
    } else {
      showInitialCoordinate(runCoordinate.coordinate)
    }
    map.isHidden = false
  }
  
  @objc func receiveProgress(_ notification: NSNotification) {
    guard let progressUpdate = notification.userInfo?["\(ProgressUpdate.self)"] as? ProgressUpdate else {
      return
    }
    totalDistance = progressUpdate.totalDistance
    timeLabel.text = "Time: \(Converter.stringifySecondCount(progressUpdate.totalSeconds, useLongFormat: false))"
    altLabel.text = "Alt.: " + Converter.stringifyAltitude(progressUpdate.altitude)
    distanceLabel.text = "Dist.: \(Converter.stringifyDistance(totalDistance))"
    paceLabel.text = "Pace: " + Converter.stringifyPace(totalDistance, seconds: progressUpdate.totalSeconds)
    altGainedLabel.text = "+: " + Converter.stringifyAltitude(progressUpdate.altGained)
    altLostLabel.text = "-: " + Converter.stringifyAltitude(progressUpdate.altLost)
    let stopAfter = SettingsManager.getStopAfter()
    if (stopAfter != SettingsManager.never) && (totalDistance >= stopAfter) {
      SettingsManager.setStopAfter(SettingsManager.never)
      RunModel.runModel.stop()
    }
  }
  
  @IBAction func showMenu(_ sender: UIButton) {
    if runToSimulate != nil || gpxFile != nil {
      RunModel.runModel.stop()
    }
    showMenu()
  }
  
  @IBAction func startOrStop() {
    switch RunModel.runModel.status {
    case .preRun:
      if runToSimulate != nil || gpxFile != nil || RunModel.gpsIsAvailable() {
        RunModel.runModel.start()
      } else {
        UIAlertController.showMessage(RunVC.noGpsMessage, title: RunVC.sadFaceTitle, okTitle: RunVC.bummerButtonTitle, handler: { action in
          SoundManager.play(.sadTrombone)
        })
      }
    case .inProgress, .paused:
      RunModel.runModel.stop()
      map.isHidden = true
    }
  }

  @IBAction func pauseOrResume() {
    let runModel = RunModel.runModel
    switch RunModel.runModel.status {
    case .preRun:
      fatalError(RunVC.pauseError)
    case .inProgress:
      runModel.pause()
    case .paused:
      runModel.resume()
    }
  }

  @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {
    PersistentMapState.pin.map = map
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pan details from run" {
      if let runDetailsVC = segue.destination as? RunDetailsVC {
        if runToSimulate == nil && gpxFile == nil {
          runDetailsVC.run = RunModel.runModel.run
        }
      }
    }
  }
  
  override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    return UnwindPanSegue(identifier: identifier ?? "", source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }
  
  @IBAction func changeOverlay(_ sender: UISegmentedControl) {
    if paceOrAltitude.selectedSegmentIndex == 0 {
      PersistentMapState.polyline.spans = PersistentMapState.altitudeSpans
    } else {
      PersistentMapState.polyline.spans = PersistentMapState.paceSpans
    }
    PersistentMapState.polyline.map = nil
    PersistentMapState.polyline.map = map
  }
  
  func hideLabels() {
    distanceLabel.isHidden = true
    timeLabel.isHidden = true
    paceLabel.isHidden = true
    altLabel.isHidden = true
    altGainedLabel.isHidden = true
    altLostLabel.isHidden = true
  }
  
  func showLabels() {
    distanceLabel.isHidden = false
    timeLabel.isHidden = false
    paceLabel.isHidden = false
    altLabel.isHidden = false
    altGainedLabel.isHidden = false
    altLostLabel.isHidden = false
  }
  
  @objc func runDidStop() {
    updateButtonLabels()
    hideLabels()
    PersistentMapState.runnerIcons.direction = .stationary
    pauseResume.isHidden = true
    if runToSimulate == nil && gpxFile == nil {
      if totalDistance > RunModel.minDistance {
        totalDistance = 0.0
        ReviewPrompter.promptableActionHappened()
        performSegue(withIdentifier: "pan details from run", sender: self)
      } else {
        totalDistance = 0.0
        UIAlertController.showMessage(RunVC.didNotSaveMessage, title: RunVC.sadFaceTitle, okTitle: RunVC.bummerButtonTitle, handler: { action in
          SoundManager.play(.sadTrombone)
          self.showMenu()
        })
      }
    } else if runToSimulate != nil {
      self.performSegue(withIdentifier: "unwind pan log", sender: self)
    } else { // if gpxFile != nil
      showMenu()
    }
  }

  @objc func runDidStart() {
    paceOrAltitude.isHidden = false
    updateButtonLabels()
    showLabels()
  }

  @objc func runDidPause() {
    PersistentMapState.runnerIcons.direction = .stationary
    PersistentMapState.pin.map = nil
    PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon
    PersistentMapState.pin.map = map
    updateButtonLabels()
  }

  @objc func runDidResume() {
    PersistentMapState.runnerIcons.direction = PersistentMapState.latestDirection
    updateButtonLabels()
  }
}
