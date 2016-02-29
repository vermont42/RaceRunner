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
  @IBOutlet var subUnsubButton: UIButton!
  @IBOutlet var map: GMSMapView!
  @IBAction func showMenu(sender: UIButton) {
    showMenu()
  }
  private var previousLongitude: Double?
  private var runnerIcons = RunnerIcons()
  private var pin: GMSMarker = GMSMarker()
  private var counter = 0
  private static let updateStride: Int = 5
  
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

  func receiveProgress(progress: String) {
    // If didReceiveMessage() is not called on the main thread, this needs GCD.
    counter++
    if counter % SpectateVC.updateStride == 0 {
      let progressArray = progress.componentsSeparatedByString(" ")
      let latitude = Double(progressArray[2])!
      let longitude = Double(progressArray[3])!
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
  }
  
  @IBAction func subscribeUnsubscribe() {
    if subUnsubButton.titleForState(UIControlState.Normal) == "Subscribe" {
      PubNubManager.subscribeToPublicChannel(self)
      subUnsubButton.setTitle("Unsubscribe", forState: .Normal)
    }
    else {
      unsubscribe()
    }
  }
  
  private func unsubscribe() {
    PubNubManager.unsubscribeFromPublicChannel()
    subUnsubButton.setTitle("Subscribe", forState: .Normal)
    pin.map = nil
  }
}