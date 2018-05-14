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

class RunVC: ChildVC, RunDelegate {
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
  
  var runToSimulate: Run?
  var gpxFile: String?
  private var modelStoppedRun = false
  
  override func viewDidLoad() {
    map.mapType = .terrain
    map.isHidden = true
    paceOrAltitude.isHidden = true
    view.sendSubview(toBack: map)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RunVC.announceCurrentPace)))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    map.clear()

    if let runToSimulate = runToSimulate {
      RunModel.initializeRunModelWithRun(runToSimulate)
      if runToSimulate.customName.isEqual(to: "") {
        viewControllerTitle.text = runToSimulate.autoName as String
      }
      else {
        viewControllerTitle.text = runToSimulate.customName as String
      }
      PersistentMapState.initMapState()
      startStop()
    }
    else if let gpxFile = gpxFile {
      RunModel.initializeRunModelWithGpxFile(gpxFile)
      viewControllerTitle.text = RunVC.gpxTitle
      PersistentMapState.initMapState()
      startStop()
    }
    else {
      RunModel.initializeRunModel()
      viewControllerTitle.text = "Run"
    }
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    
    let runModel = RunModel.runModel
    runModel.runDelegate = self
    switch runModel.status {
    case .preRun:
      hideLabels()
      startStopButton.backgroundColor = UiConstants.intermediate3Color
      startStopButton.setTitle(RunVC.startTitle, for: UIControlState())
      startStopButton.isHidden = false
      pauseResume.isHidden = true
      PersistentMapState.initMapState()
    case .inProgress:
      pauseResume.setTitle(RunVC.pauseTitle, for: UIControlState())
    case .paused:
      pauseResume.setTitle(RunVC.resumeTitle, for: UIControlState())
      map.camera = GMSCameraPosition.camera(withLatitude: PersistentMapState.currentCoordinate.latitude, longitude: PersistentMapState.currentCoordinate.longitude, zoom: UiConstants.cameraZoom)
    }
    
    if runModel.status == .inProgress || runModel.status == .paused {
      showLabels()
      pauseResume.isHidden = false
      startStopButton.isHidden = false
      startStopButton.backgroundColor = UiConstants.intermediate1Color
      startStopButton.setTitle(RunVC.stopTitle, for: UIControlState())
      if runToSimulate == nil && gpxFile == nil {
        addPolylineAndPin()
      }
      map.isHidden = false
      paceOrAltitude.isHidden = false
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    RunModel.runModel.runDelegate = nil
    if (runToSimulate != nil || gpxFile != nil) && (RunModel.runModel.status != .preRun)  {
      RunModel.runModel.stop()
    }
  }

  @objc func announceCurrentPace() {
    RunModel.runModel.announceCurrentPace()
  }

  func addPolylineAndPin() {
    PersistentMapState.polyline.map = map
    PersistentMapState.pin.position = RunModel.runModel.locations.last!.coordinate
    PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon()
    PersistentMapState.pin.map = map
  }
  
  func showInitialCoordinate(_ coordinate: CLLocationCoordinate2D) {
    map.camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: UiConstants.cameraZoom)
    PersistentMapState.currentCoordinate = coordinate
    PersistentMapState.pin.position = coordinate
    PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon()
    PersistentMapState.pin.map = map
  }
  
  func plotToCoordinate(_ coordinate: CLLocationCoordinate2D, altitudeColor: UIColor, paceColor: UIColor) {
    if PersistentMapState.currentCoordinate != nil {
      if PersistentMapState.currentCoordinate.longitude > coordinate.longitude {
        PersistentMapState.runnerIcons.direction = .west
        PersistentMapState.latestDirection = .west
      }
      else if PersistentMapState.currentCoordinate.longitude < coordinate.longitude {
        PersistentMapState.runnerIcons.direction = .east
        PersistentMapState.latestDirection = .east
      }
      var coords: [CLLocationCoordinate2D] = [PersistentMapState.currentCoordinate, coordinate]
      map.camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: UiConstants.cameraZoom)
      PersistentMapState.path.add(coords[1])
      PersistentMapState.polyline.path = PersistentMapState.path
      let altitudeGradient = GMSStrokeStyle.gradient(from: PersistentMapState.latestAltitudeStrokeColor, to: altitudeColor)
      let paceGradient = GMSStrokeStyle.gradient(from: PersistentMapState.latestPaceStrokeColor, to: paceColor)
      PersistentMapState.latestAltitudeStrokeColor = altitudeColor
      PersistentMapState.latestPaceStrokeColor = paceColor
      PersistentMapState.altitudeSpans.append(GMSStyleSpan(style: altitudeGradient))
      PersistentMapState.paceSpans.append(GMSStyleSpan(style: paceGradient))
      if paceOrAltitude.selectedSegmentIndex == 0 {
        PersistentMapState.polyline.spans = PersistentMapState.altitudeSpans
      }
      else {
        PersistentMapState.polyline.spans = PersistentMapState.paceSpans
      }
      PersistentMapState.polyline.map = map
      PersistentMapState.pin.map = nil
      PersistentMapState.pin.position = coordinate
      PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon()
      PersistentMapState.pin.map = map
      PersistentMapState.currentCoordinate = coordinate
    }
    else {
      showInitialCoordinate(coordinate)
    }
  }
  
  func receiveProgress(_ totalDistance: Double, totalSeconds: Int, altitude: Double, altGained: Double, altLost: Double) {
    timeLabel.text = "Time: \(Converter.stringifySecondCount(totalSeconds, useLongFormat: false))"
    altLabel.text = "Alt.: " + Converter.stringifyAltitude(altitude)
    distanceLabel.text = "Dist.: \(Converter.stringifyDistance(totalDistance))"
    paceLabel.text = "Pace: " + Converter.stringifyPace(totalDistance, seconds: totalSeconds)
    altGainedLabel.text = "+: " + Converter.stringifyAltitude(altGained)
    altLostLabel.text = "-: " + Converter.stringifyAltitude(altLost)
    let stopAfter = SettingsManager.getStopAfter()
    if (stopAfter != SettingsManager.never) && (totalDistance >= stopAfter) {
      stop()
    }
  }
  
  @IBAction func showMenu(_ sender: UIButton) {
    if runToSimulate == nil && gpxFile == nil {
      showMenu()
    }
    else {
      stop()
    }
  }
  
  @IBAction func startStop() {
    switch RunModel.runModel.status {
    case .preRun:
      if runToSimulate != nil || gpxFile != nil || RunModel.gpsIsAvailable() {
        showLabels()
        startStopButton.backgroundColor = UiConstants.intermediate1Color
        startStopButton.setTitle("  Stop  ", for: UIControlState())
        pauseResume.isHidden = false
        pauseResume.setTitle("  Pause  ", for: UIControlState())
        RunModel.runModel.start()
        SoundManager.play(.gun)
        map.isHidden = false
        paceOrAltitude.isHidden = false
      }
      else {
        UIAlertController.showMessage(RunVC.noGpsMessage, title: RunVC.sadFaceTitle, okTitle: RunVC.bummerButtonTitle, handler: {(action) in
          SoundManager.play(.sadTrombone)
        })
      }
    case .inProgress, .paused:
      stop()
      map.isHidden = true
      paceOrAltitude.isHidden = true
    }
  }
  
  func stop() {
    PersistentMapState.runnerIcons.direction = .stationary
    startStopButton.backgroundColor = UiConstants.intermediate3Color
    startStopButton.setTitle("  Start  ", for: UIControlState())
    pauseResume.isHidden = true
    let totalDistance = RunModel.runModel.totalDistance
    if !modelStoppedRun {
      RunModel.runModel.stop()
    }
    else {
      modelStoppedRun = false
    }
    if runToSimulate == nil && gpxFile == nil {
      if totalDistance > RunModel.minDistance {
        let randomApplause = arc4random_uniform(Sound.applauseCount) + 1
        switch randomApplause {
        case 1:
          SoundManager.play(.applause1)
        case 2:
          SoundManager.play(.applause2)
        case 3:
          SoundManager.play(.applause3)
        default:
          break
        }
        ReviewPrompter.promptableActionHappened()
        performSegue(withIdentifier: "pan details from run", sender: self)
      }
      else {
        UIAlertController.showMessage(RunVC.didNotSaveMessage, title: RunVC.sadFaceTitle, okTitle: RunVC.bummerButtonTitle, handler: {(action) in
          SoundManager.play(.sadTrombone)
          self.showMenu()
        })
      }
    }
    else if runToSimulate != nil {
      self.performSegue(withIdentifier: "unwind pan log", sender: self)
    }
    else { // if gpxFile != nil
      showMenu()
    }
  }
  
  @IBAction func pauseResume(_ sender: UIButton) {
    SoundManager.play(.click)
    let runModel = RunModel.runModel
    switch runModel.status {
    case .preRun:
      fatalError(RunVC.pauseError)
    case .inProgress:
      pauseResume.setTitle(RunVC.resumeTitle, for: UIControlState())
      runModel.pause()
      PersistentMapState.runnerIcons.direction = .stationary
      PersistentMapState.pin.map = nil
      PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon()
      PersistentMapState.pin.map = map
    case .paused:
      pauseResume.setTitle(RunVC.pauseTitle, for: UIControlState())
      PersistentMapState.runnerIcons.direction = PersistentMapState.latestDirection
      runModel.resume()
    }
  }
  
  @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {
    PersistentMapState.pin.map = map
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pan details from run" {
      let runDetailsVC: RunDetailsVC = segue.destination as! RunDetailsVC
      if runToSimulate == nil && gpxFile == nil {
        runDetailsVC.run = RunModel.runModel.run
      }
    }
  }
  
  override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    return UnwindPanSegue(identifier: identifier!, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }
  
  @IBAction func changeOverlay(_ sender: UISegmentedControl) {
    if paceOrAltitude.selectedSegmentIndex == 0 {
      PersistentMapState.polyline.spans = PersistentMapState.altitudeSpans
    }
    else {
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
  
  func stopRun() {
    modelStoppedRun = true
    startStop()
  }
}
