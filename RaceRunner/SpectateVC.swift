//
//  SpectateVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import GoogleMaps

class SpectateVC: ChildVC, PubNubSubscriber {
  @IBOutlet var showMenuButton: UIButton!
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var map: GMSMapView!
  @IBOutlet var startStopButton: UIButton!
  @IBOutlet var spectationLabel: MarqueeLabel!
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var paceLabel: UILabel!
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var altitudeLabel: UILabel!
  private var publisher: String = ""
  private var previousLongitude: Double?
  private var runnerIcons = RunnerIcons()
  private var pin: GMSMarker = GMSMarker()
  private var counter = 0
  private var canStopRun = false
  private static let runEnded = "Run ended."
  private static let runEndedTitle = "Ended"
  private static let broadcasterTitle = "Select Runner"
  private static let broadcasterPrompt = "Whose run would you like to spectate?"
  private static let broadcasterButtonTitle = "Start Spectating"
  private static let stopBothPrompt = "Would you like to stop spectating or stop the run?"
  private static let stopSpectatingPrompt = "Stop spectating?"
  private static let stopSpectatingButtonTitle = "Stop Spectating"
  private static let stopRunButtonTitle = "Stop Run"
  private static let cancel = "Cancel"
  private static let start = "Start"
  private static let stop = "Stop"
  private static let spectate = "Spectate"
  private static let spectating = "Spectating"
  private static let centerLatitude = 39.8333
  private static let centerLongitude = -98.5833
  private static let initialZoom: Float = 2.0

  override func viewDidLoad() {
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    super.viewDidLoad()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    pin.map = nil
    runnerIcons.direction = .Stationary
    unsubscribe()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    clearLabels()
    startStopButton.setTitle(SpectateVC.start, forState: .Normal)
    map.camera = GMSCameraPosition.cameraWithLatitude(SpectateVC.centerLatitude, longitude: SpectateVC.centerLongitude, zoom: SpectateVC.initialZoom)
  }
  
  private func clearLabels() {
    distanceLabel.text = ""
    timeLabel.text = ""
    paceLabel.text = ""
    altitudeLabel.text = ""
    startStopButton.setTitle(SpectateVC.broadcasterButtonTitle, forState: .Normal)
    startStopButton.backgroundColor = UiConstants.intermediate3Color
    viewControllerTitle.text = SpectateVC.spectate
    spectationLabel.text = ""
  }
  
  private func getBroadcasterAndSubscribe() {
    let alertController = UIAlertController(title: SpectateVC.broadcasterTitle, message: SpectateVC.broadcasterPrompt, preferredStyle: UIAlertControllerStyle.Alert)
    let subscribeAction = UIAlertAction(title: SpectateVC.broadcasterButtonTitle, style: UIAlertActionStyle.Default, handler: { (action) in
      let textFields = alertController.textFields!
      self.publisher = textFields[0].text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      if self.publisher != "" {
        self.spectationLabel.text = self.publisher
        self.viewControllerTitle.text = SpectateVC.spectating
        self.startStopButton.setTitle(SpectateVC.stop, forState: .Normal)
        self.startStopButton.backgroundColor = UiConstants.intermediate1Color
        PubNubManager.subscribeToChannel(self, publisher: self.publisher)
      }
    })
    alertController.addAction(subscribeAction)
    let cancelAction = UIAlertAction(title: SpectateVC.cancel, style: UIAlertActionStyle.Cancel, handler: { (action) in })
    alertController.addAction(cancelAction)
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Runner"
    }
    alertController.view.tintColor = UiConstants.intermediate1Color
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  func receiveProgress(progress: String) {
    // If didReceiveMessage() is not called on the main thread, this needs GCD.
    counter++
    let progressArray = progress.componentsSeparatedByString(" ")
    let latitude = Double(progressArray[0])!
    let longitude = Double(progressArray[1])!
    map.camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: UiConstants.cameraZoom)
    if let previousLongitude = previousLongitude {
      if previousLongitude > longitude {
        runnerIcons.direction = .West
      }
      else if previousLongitude < longitude {
        runnerIcons.direction = .East
      }
    }
    pin.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    pin.icon = runnerIcons.nextIcon()
    pin.map = map
    previousLongitude = longitude
    timeLabel.text = "Time: \(Converter.stringifySecondCount(Int(progressArray[4])!, useLongFormat: false))"
    altitudeLabel.text = "Alt.: " + Converter.stringifyAltitude(Double(progressArray[2])!)
    distanceLabel.text = "Dist.: \(Converter.stringifyDistance(Double(progressArray[3])!))"
    paceLabel.text = "Pace: " + Converter.stringifyPace(Double(progressArray[3])!, seconds: Int(progressArray[4])!)
    canStopRun = NSString(string: progressArray[5]).boolValue
  }
  
  func runStopped() {
    UIAlertController.showMessage(SpectateVC.runEnded, title: SpectateVC.runEndedTitle)
    runnerIcons.direction = .Stationary
    pin.icon = runnerIcons.nextIcon()
    unsubscribe()
    clearLabels()
  }
  
  private func unsubscribe() {
    PubNubManager.unsubscribeFromChannel(publisher)
    pin.map = nil
    publisher = ""
    canStopRun = false
  }
  
  @IBAction func startStop() {
    if publisher == "" {
      getBroadcasterAndSubscribe()
    }
    else {
      let prompt: String
      if canStopRun {
        prompt = SpectateVC.stopBothPrompt
      }
      else {
        prompt = SpectateVC.stopSpectatingPrompt
      }
      let alertController = UIAlertController(title: SpectateVC.stop, message: prompt, preferredStyle: UIAlertControllerStyle.Alert)
      let stopSpectatingAction = UIAlertAction(title: SpectateVC.stopSpectatingButtonTitle, style: UIAlertActionStyle.Default, handler: { (action) in
        self.stopSpectating()
      })
      alertController.addAction(stopSpectatingAction)
      if canStopRun {
        let stopRunAction = UIAlertAction(title: SpectateVC.stopRunButtonTitle, style: UIAlertActionStyle.Default, handler: { (action) in
          self.stopRun()
          self.stopSpectating()
        })
        alertController.addAction(stopRunAction)
      }
      let cancelAction = UIAlertAction(title: SpectateVC.cancel, style: UIAlertActionStyle.Cancel, handler: { (action) in })
      alertController.addAction(cancelAction)
      alertController.view.tintColor = UiConstants.intermediate1Color
      presentViewController(alertController, animated: true, completion: nil)
    }
  }
  
  private func stopSpectating() {
    unsubscribe()
    pin.icon = nil
    clearLabels()
  }
  
  internal func stopRun() {
    PubNubManager.publishRunStoppage(publisher)
  }
  
  @IBAction func showMenu(sender: UIButton) {
    unsubscribe()
    showMenu()
  }
}