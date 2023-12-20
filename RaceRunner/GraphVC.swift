//
//  GraphVC.swift
//  RaceRunner
//
//  Created by Josh Adams on 1/25/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit

class GraphVC: ChildVC {
  @IBOutlet var viewControllerTitle: UILabel!

  @IBOutlet weak var overlayControl: UISegmentedControl!
  @IBOutlet var graphView: GraphView!

  var run: Run?
  var smoothSpeeds: [Double] = []
  var maxSmoothSpeed: Double = 0.0
  var minSmoothSpeed: Double = 0.0

  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    graphView.setNeedsDisplay()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerTitle.attributedText = UIHelpers.letterPressedText(viewControllerTitle.text ?? "")
    overlayControl.selectedSegmentIndex = SettingsManager.getOverlay().radioButtonPosition
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AWSAnalyticsService.shared.recordVisitation(viewController: "\(GraphVC.self)")
    configureGraphView()
  }

  private func configureGraphView() {
    guard let run = run else {
      return
    }

    var smoothAltitudes: [Double] = []
    if run.locations.count < 3 {
      smoothAltitudes = run.locations.map {
        ($0 as? Location)?.altitude.doubleValue ?? 0.0
      }
    } else {
      for i in 0 ..< run.locations.count {
        if i == 0 {
          let alt1 = (run.locations[0] as? Location)?.altitude.doubleValue ?? 0.0
          let alt2 = (run.locations[1] as? Location)?.altitude.doubleValue ?? 0.0
          smoothAltitudes.append((alt1 + alt2) / 2.0)
        } else if i == run.locations.count - 1 {
          let alt1 = (run.locations[i - 1] as? Location)?.altitude.doubleValue ?? 0.0
          let alt2 = (run.locations[i] as? Location)?.altitude.doubleValue ?? 0.0
          smoothAltitudes.append((alt1 + alt2) / 2.0)
        } else {
          let alt1 = (run.locations[i - 1] as? Location)?.altitude.doubleValue ?? 0.0
          let alt2 = (run.locations[i] as? Location)?.altitude.doubleValue ?? 0.0
          let alt3 = (run.locations[i + 1] as? Location)?.altitude.doubleValue ?? 0.0
          smoothAltitudes.append((alt1 + alt2 + alt3) / 3.0)
        }
      }
    }
    graphView.smoothAltitudes = smoothAltitudes

    var smootherSpeeds: [Double] = []
    if smoothSpeeds.count < 3 {
      smootherSpeeds = smoothSpeeds
    } else {
      for i in 0 ..< smoothSpeeds.count {
        if i == 0 {
          smootherSpeeds.append((smoothSpeeds[0] + smoothSpeeds[i]) / 2.0)
        } else if i == smoothSpeeds.count - 1 {
          smootherSpeeds.append((smoothSpeeds[i - 1] + smoothSpeeds[i]) / 2.0)
        } else {
          smootherSpeeds.append((smoothSpeeds[i - 1] + smoothSpeeds[i] + smoothSpeeds[i + 1]) / 3.0)
        }
      }
    }
    graphView.smoothSpeeds = smootherSpeeds
    graphView.maxSmoothSpeed = maxSmoothSpeed
    graphView.minSmoothSpeed = minSmoothSpeed

    let startDate: Date
    if let startLocation = run.locations[0] as? Location {
      startDate = startLocation.timestamp
    } else {
      startDate = Date()
    }
    let endDate: Date
    if let endLocation = run.locations.lastObject as? Location {
      endDate = endLocation.timestamp
    } else {
      endDate = Date()
    }
    graphView.timeSpan = endDate.timeIntervalSince(startDate)

    graphView.distance = run.distance.doubleValue
    graphView.minAltitude = run.minAltitude.doubleValue
    graphView.maxAltitude = run.maxAltitude.doubleValue

    graphView.setNeedsDisplay()
  }

  @IBAction func back() {
    performSegue(withIdentifier: "unwind pan", sender: self)
  }

  override var prefersStatusBarHidden: Bool {
    true
  }

  @IBAction func overlayChanged() {
    SettingsManager.setOverlay(Overlay.positionToOverlay(overlayControl.selectedSegmentIndex))
    graphView.setNeedsDisplay()
  }
}
