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
  private var broadcaster: String = ""
  private var previousLongitude: Double?
  private var runnerIcons = RunnerIcons()
  private var pin: GMSMarker = GMSMarker()
  private var counter = 0
  private static let runEnded = "Run ended."
  private static let runEndedTitle = "Ended"
  private static let broadcasterTitle = "Select Runner"
  private static let broadcasterPrompt = "Whose run would you like to spectate?"
  private static let broadcasterButtonTitle = "Start Spectating"
  private static let cancel = "Cancel"
  private static let notSpectating = "Not currently spectating."
  private static let spectating = "You are spectating "
  private static let start = "Start"
  private static let stop = "Stop"
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
    spectationLabel.text = SpectateVC.notSpectating
    startStopButton.setTitle(SpectateVC.start, forState: .Normal)
    map.camera = GMSCameraPosition.cameraWithLatitude(SpectateVC.centerLatitude, longitude: SpectateVC.centerLongitude, zoom: SpectateVC.initialZoom)
  }
  
  func getBroadcasterAndSubscribe() {
    let alertController = UIAlertController(title: SpectateVC.broadcasterTitle, message: SpectateVC.broadcasterPrompt, preferredStyle: UIAlertControllerStyle.Alert)
    let subscribeAction = UIAlertAction(title: SpectateVC.broadcasterButtonTitle, style: UIAlertActionStyle.Default, handler: { (action) in
      let textFields = alertController.textFields!
      self.broadcaster = textFields[0].text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      if self.broadcaster != "" {
        self.spectationLabel.text = SpectateVC.spectating + self.broadcaster + "."
        self.startStopButton.setTitle(SpectateVC.stop, forState: .Normal)
        PubNubManager.subscribeToChannel(self, broadcaster: self.broadcaster)
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
  }
  
  func runStopped() {
    UIAlertController.showMessage(SpectateVC.runEnded, title: SpectateVC.runEndedTitle)
    runnerIcons.direction = .Stationary
    pin.icon = runnerIcons.nextIcon()
    unsubscribe()
  }
  
  private func unsubscribe() {
    PubNubManager.unsubscribeFromChannel(broadcaster)
    pin.map = nil
    spectationLabel.text = SpectateVC.notSpectating
    startStopButton.setTitle(SpectateVC.start, forState: .Normal)
    broadcaster = ""
  }
  
  @IBAction func startStop() {
    if broadcaster == "" {
      getBroadcasterAndSubscribe()
    }
    else {
      unsubscribe()
      pin.icon = nil
    }
  }
  
  @IBAction func showMenu(sender: UIButton) {
    unsubscribe()
    showMenu()
  }
}