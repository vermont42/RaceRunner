//
//  GraphVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/25/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import DLRadioButton
import SwiftCharts

class GraphVC: ChildVC {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var overlays: [DLRadioButton]!
  @IBOutlet var graphView: GraphView!
  
  var run: Run!
  var smoothSpeeds: [Double]!
  var maxSmoothSpeed: Double!
  var minSmoothSpeed: Double!
  
  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    graphView.setNeedsDisplay()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    overlays[SettingsManager.getOverlay().radioButtonPosition()].sendActionsForControlEvents(UIControlEvents.TouchUpInside)    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    graphView.run = run
    graphView.smoothSpeeds = smoothSpeeds
    graphView.maxSmoothSpeed = maxSmoothSpeed
    graphView.minSmoothSpeed = minSmoothSpeed
    graphView.setNeedsDisplay()
  }
  
  @IBAction func back() {
    performSegueWithIdentifier("unwind pan", sender: self)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  @IBAction func changeOverlay(sender: DLRadioButton) {
    let selectedOverlay = sender.selectedButton().titleLabel?.text
    if let selectedOverlay = selectedOverlay {
      SettingsManager.setOverlay(Overlay.stringToOVerlay(selectedOverlay))
      graphView.setNeedsDisplay()
    }
  }
}