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
  
  private static let gpxTitle = "Berkeley Hills"
  private static let didNotSaveMessage = "RaceRunner did not save this run because it was so short. The run, not RaceRunner. As a collection of electrons on your phone, RaceRunner has no physical height."
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
    map.mapType = kGMSTypeTerrain
    map.hidden = true
    paceOrAltitude.hidden = true
    view.sendSubviewToBack(map)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let runToSimulate = runToSimulate {
      RunModel.initializeRunModelWithRun(runToSimulate)
      if runToSimulate.customName.isEqualToString("") {
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
    case .PreRun:
      hideLabels()
      startStopButton.backgroundColor = UiConstants.intermediate3Color
      startStopButton.setTitle(RunVC.startTitle, forState: UIControlState.Normal)
      startStopButton.hidden = false
      pauseResume.hidden = true
      PersistentMapState.initMapState()
    case .InProgress:
      pauseResume.setTitle(RunVC.pauseTitle, forState: UIControlState.Normal)
    case .Paused:
      pauseResume.setTitle(RunVC.resumeTitle, forState: UIControlState.Normal)
      map.camera = GMSCameraPosition.cameraWithLatitude(PersistentMapState.currentCoordinate.latitude, longitude: PersistentMapState.currentCoordinate.longitude, zoom: UiConstants.cameraZoom)
    }
    
    if runModel.status == .InProgress || runModel.status == .Paused {
      showLabels()
      pauseResume.hidden = false
      startStopButton.hidden = false
      startStopButton.backgroundColor = UiConstants.intermediate1Color
      startStopButton.setTitle(RunVC.stopTitle, forState: UIControlState.Normal)
      if runToSimulate == nil && gpxFile == nil {
        addPolylineAndPin()
      }
      map.hidden = false
      paceOrAltitude.hidden = false
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    RunModel.runModel.runDelegate = nil
    if (runToSimulate != nil || gpxFile != nil) && (RunModel.runModel.status != .PreRun)  {
      RunModel.runModel.stop()
    }
  }

  func addPolylineAndPin() {
    PersistentMapState.polyline.map = map
    PersistentMapState.pin.position = RunModel.runModel.locations.last!.coordinate
    PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon()
    PersistentMapState.pin.map = map
  }
  
  func showInitialCoordinate(coordinate: CLLocationCoordinate2D) {
    map.camera = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude: coordinate.longitude, zoom: UiConstants.cameraZoom)
    PersistentMapState.currentCoordinate = coordinate
    PersistentMapState.pin.position = coordinate
    PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon()
    PersistentMapState.pin.map = map
  }
  
  func plotToCoordinate(coordinate: CLLocationCoordinate2D, altitudeColor: UIColor, paceColor: UIColor) {
    if PersistentMapState.currentCoordinate != nil {
      if PersistentMapState.currentCoordinate.longitude > coordinate.longitude {
        PersistentMapState.runnerIcons.direction = .West
        PersistentMapState.latestDirection = .West
      }
      else if PersistentMapState.currentCoordinate.longitude < coordinate.longitude {
        PersistentMapState.runnerIcons.direction = .East
        PersistentMapState.latestDirection = .East
      }
      var coords: [CLLocationCoordinate2D] = [PersistentMapState.currentCoordinate, coordinate]
      map.camera = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude: coordinate.longitude, zoom: UiConstants.cameraZoom)
      PersistentMapState.path.addCoordinate(coords[1])
      PersistentMapState.polyline.path = PersistentMapState.path
      let altitudeGradient = GMSStrokeStyle.gradientFromColor(PersistentMapState.latestAltitudeStrokeColor, toColor: altitudeColor)
      let paceGradient = GMSStrokeStyle.gradientFromColor(PersistentMapState.latestPaceStrokeColor, toColor: paceColor)
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
  
  func receiveProgress(totalDistance: Double, totalSeconds: Int, altitude: Double, altGained: Double, altLost: Double) {
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
  
  @IBAction func showMenu(sender: UIButton) {
    showMenu()
  }
  
  @IBAction func startStop() {
    switch RunModel.runModel.status {
    case .PreRun:
      showLabels()
      startStopButton.backgroundColor = UiConstants.intermediate1Color
      startStopButton.setTitle("  Stop  ", forState: UIControlState.Normal)
      pauseResume.hidden = false
      pauseResume.setTitle("  Pause  ", forState: UIControlState.Normal)
      RunModel.runModel.start()
      SoundManager.play("gun")
      map.hidden = false
      paceOrAltitude.hidden = false
    case .InProgress, .Paused:
      stop()
      map.hidden = true
      paceOrAltitude.hidden = true
    }
  }
  
  func stop() {
    PersistentMapState.runnerIcons.direction = .Stationary
    startStopButton.backgroundColor = UiConstants.intermediate3Color
    startStopButton.setTitle("  Start  ", forState: UIControlState.Normal)
    pauseResume.hidden = true
    PersistentMapState.pin.map = nil
    let totalDistance = RunModel.runModel.totalDistance
    if !modelStoppedRun {
      RunModel.runModel.stop()
    }
    else {
      modelStoppedRun = false
    }
    if runToSimulate == nil && gpxFile == nil {
      if totalDistance > RunModel.minDistance {
        arc4random_uniform(UiConstants.applauseSampleCount) + 1
        SoundManager.play("applause\(arc4random_uniform(SoundManager.applauseCount) + 1)")
        performSegueWithIdentifier("pan details from run", sender: self)
        print("pan details")
        map.clear()
      }
      else {
        UIAlertController.showMessage(RunVC.didNotSaveMessage, title: RunVC.sadFaceTitle, okTitle: RunVC.bummerButtonTitle, handler: {(action) in
          SoundManager.play("sadTrombone")
          self.showMenu()
        })
      }
    }
    else if runToSimulate != nil {
      self.performSegueWithIdentifier("unwind pan log", sender: self)
    }
    else { // if gpxFile != nil
      showMenu()
    }
  }
  
  @IBAction func pauseResume(sender: UIButton) {
    SoundManager.play("click")
    let runModel = RunModel.runModel
    switch runModel.status {
    case .PreRun:
      fatalError(RunVC.pauseError)
    case .InProgress:
      pauseResume.setTitle(RunVC.resumeTitle, forState: UIControlState.Normal)
      runModel.pause()
      PersistentMapState.runnerIcons.direction = .Stationary
      PersistentMapState.pin.map = nil
      PersistentMapState.pin.icon = PersistentMapState.runnerIcons.nextIcon()
      PersistentMapState.pin.map = map
    case .Paused:
      pauseResume.setTitle(RunVC.pauseTitle, forState: UIControlState.Normal)
      PersistentMapState.runnerIcons.direction = PersistentMapState.latestDirection
      runModel.resume()
    }
  }
  
  @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {
    PersistentMapState.pin.map = map
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "pan details from run" {
      let runDetailsVC: RunDetailsVC = segue.destinationViewController as! RunDetailsVC
      if runToSimulate == nil && gpxFile == nil {
        runDetailsVC.run = RunModel.runModel.run
      }
    }
  }
  
  override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    if let id = identifier{
      let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
      })
      return unwindSegue
    }
    return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
  }
  
  @IBAction func changeOverlay(sender: UISegmentedControl) {
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
    distanceLabel.hidden = true
    timeLabel.hidden = true
    paceLabel.hidden = true
    altLabel.hidden = true
    altGainedLabel.hidden = true
    altLostLabel.hidden = true
  }
  
  func showLabels() {
    distanceLabel.hidden = false
    timeLabel.hidden = false
    paceLabel.hidden = false
    altLabel.hidden = false
    altGainedLabel.hidden = false
    altLostLabel.hidden = false
  }
  
  func stopRun() {
    modelStoppedRun = true
    startStop()
  }
}