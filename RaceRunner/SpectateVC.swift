//
//  SpectateVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import GoogleMaps
import MarqueeLabel

class SpectateVC: ChildVC, PubNubSubscriber {
  @IBOutlet var showMenuButton: UIButton!
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var map: GMSMapView!
  @IBOutlet var startStopButton: UIButton!
  @IBOutlet var messageButton: UIButton!
  @IBOutlet var spectationLabel: MarqueeLabel!
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var paceLabel: UILabel!
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var altitudeLabel: UILabel!
  fileprivate var publisher: String = ""
  fileprivate var previousLongitude: Double?
  fileprivate var runnerIcons = RunnerIcons()
  fileprivate var pin: GMSMarker = GMSMarker()
  fileprivate var counter = 0
  fileprivate var canStopRun = false
  fileprivate static let runEnded = "Run ended."
  fileprivate static let runEndedTitle = "Ended"
  fileprivate static let broadcasterTitle = "Select Runner"
  fileprivate static let broadcasterPrompt = "Whose run would you like to spectate?"
  fileprivate static let subscribeAlertTitle = "Start Spectating"
  fileprivate static let stopBothPrompt = "Would you like to stop spectating or stop the run?"
  fileprivate static let stopSpectatingPrompt = "Stop spectating?"
  fileprivate static let stopSpectatingButtonTitle = "Stop Spectating"
  fileprivate static let stopRunButtonTitle = "Stop Run"
  fileprivate static let sendMessageTitle = "Send Message"
  fileprivate static let sendMessagePrompt = "Enter a message for the runner and tap Send."
  fileprivate static let sendAlertTitle = "Send"
  fileprivate static let message = "Message"
  fileprivate static let runner = "Runner"
  fileprivate static let cancel = "Cancel"
  fileprivate static let start = "Start"
  fileprivate static let stop = "Stop"
  fileprivate static let spectate = "Spectate"
  fileprivate static let spectating = "Spectating"
  fileprivate static let centerLatitude = 39.8333
  fileprivate static let centerLongitude = -98.5833
  fileprivate static let initialZoom: Float = 2.0

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    messageButton.isHidden = true
    map.camera = GMSCameraPosition.camera(withLatitude: SpectateVC.centerLatitude, longitude: SpectateVC.centerLongitude, zoom: SpectateVC.initialZoom)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    pin.map = nil
    runnerIcons.direction = .stationary
    unsubscribe()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    clearLabels()
    startStopButton.setTitle(SpectateVC.start, for: UIControlState())
  }
  
  fileprivate func clearLabels() {
    distanceLabel.text = ""
    timeLabel.text = ""
    paceLabel.text = ""
    altitudeLabel.text = ""
    startStopButton.setTitle(SpectateVC.start, for: UIControlState())
    startStopButton.backgroundColor = UiConstants.intermediate3Color
    messageButton.isHidden = true
    viewControllerTitle.text = SpectateVC.spectate
    spectationLabel.text = ""
  }
  
  fileprivate func getBroadcasterAndSubscribe() {
    let alertController = UIAlertController(title: SpectateVC.broadcasterTitle, message: SpectateVC.broadcasterPrompt, preferredStyle: UIAlertControllerStyle.alert)
    let subscribeAction = UIAlertAction(title: SpectateVC.subscribeAlertTitle, style: UIAlertActionStyle.default, handler: { (action) in
      let textFields = alertController.textFields!
      self.publisher = textFields[0].text!.trimmingCharacters(in: CharacterSet.whitespaces)
      if self.publisher != "" {
        self.spectationLabel.text = self.publisher
        self.viewControllerTitle.text = SpectateVC.spectating
        self.startStopButton.setTitle(SpectateVC.stop, for: UIControlState())
        self.startStopButton.backgroundColor = UiConstants.intermediate1Color
        self.messageButton.isHidden = false
        PubNubManager.subscribeToChannel(self, publisher: self.publisher)
      }
    })
    alertController.addAction(subscribeAction)
    let cancelAction = UIAlertAction(title: SpectateVC.cancel, style: UIAlertActionStyle.cancel, handler: nil)
    alertController.addAction(cancelAction)
    alertController.addTextField { (textField) in
      textField.placeholder = SpectateVC.runner
    }
    alertController.view.tintColor = UiConstants.intermediate1Color
    present(alertController, animated: true, completion: nil)
  }
  
  func receiveProgress(_ progress: String) {
    // If didReceiveMessage() is not called on the main thread, this needs GCD.
    counter += 1
    let progressArray = progress.components(separatedBy: " ")
    let latitude = Double(progressArray[0])!
    let longitude = Double(progressArray[1])!
    map.camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: UiConstants.cameraZoom)
    if let previousLongitude = previousLongitude {
      if previousLongitude > longitude {
        runnerIcons.direction = .west
      }
      else if previousLongitude < longitude {
        runnerIcons.direction = .east
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
    runnerIcons.direction = .stationary
    pin.icon = runnerIcons.nextIcon()
    unsubscribe()
    clearLabels()
  }
  
  fileprivate func unsubscribe() {
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
      let alertController = UIAlertController(title: SpectateVC.stop, message: prompt, preferredStyle: UIAlertControllerStyle.alert)
      let stopSpectatingAction = UIAlertAction(title: SpectateVC.stopSpectatingButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
        self.stopSpectating()
      })
      alertController.addAction(stopSpectatingAction)
      if canStopRun {
        let stopRunAction = UIAlertAction(title: SpectateVC.stopRunButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
          self.stopRun()
          self.stopSpectating()
        })
        alertController.addAction(stopRunAction)
      }
      let cancelAction = UIAlertAction(title: SpectateVC.cancel, style: UIAlertActionStyle.cancel, handler: { (action) in })
      alertController.addAction(cancelAction)
      alertController.view.tintColor = UiConstants.intermediate1Color
      present(alertController, animated: true, completion: nil)
    }
  }
  
  @IBAction func sendMessage() {
    let alertController = UIAlertController(title: SpectateVC.sendMessageTitle, message: SpectateVC.sendMessagePrompt, preferredStyle: UIAlertControllerStyle.alert)
    let sendAction = UIAlertAction(title: SpectateVC.sendAlertTitle, style: UIAlertActionStyle.default, handler: { (action) in
      let message = alertController.textFields![0].text!
      if message != "" {
        PubNubManager.publishMessage(message, publisher: self.publisher)
      }
    })
    alertController.addAction(sendAction)
    let cancelAction = UIAlertAction(title: SpectateVC.cancel, style: UIAlertActionStyle.cancel, handler: nil)
    alertController.addAction(cancelAction)
    alertController.addTextField { (textField) in
      textField.placeholder = SpectateVC.message
    }
    alertController.view.tintColor = UiConstants.intermediate1Color
    present(alertController, animated: true, completion: nil)
  }
  
  fileprivate func stopSpectating() {
    unsubscribe()
    pin.icon = nil
    clearLabels()
  }
  
  internal func stopRun() {
    PubNubManager.publishRunStoppage(publisher)
  }
  
  @IBAction func showMenu(_ sender: UIButton) {
    unsubscribe()
    showMenu()
  }
}
