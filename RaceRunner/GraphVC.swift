//
//  GraphVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/25/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import DLRadioButton

class GraphVC: ChildVC {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var overlays: [DLRadioButton]!
  @IBOutlet var graphView: GraphView!
  
  var run: Run!
  var smoothSpeeds: [Double]!
  var maxSmoothSpeed: Double!
  var minSmoothSpeed: Double!
  
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    graphView.setNeedsDisplay()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    overlays[SettingsManager.getOverlay().radioButtonPosition()].sendActions(for: UIControlEvents.touchUpInside)    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    graphView.run = run
    graphView.smoothSpeeds = smoothSpeeds
    graphView.maxSmoothSpeed = maxSmoothSpeed
    graphView.minSmoothSpeed = minSmoothSpeed
    graphView.setNeedsDisplay()
  }
  
  @IBAction func back() {
    performSegue(withIdentifier: "unwind pan", sender: self)
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  @IBAction func changeOverlay(_ sender: DLRadioButton) {
    let selectedOverlay = sender.selected()!.titleLabel?.text
    if let selectedOverlay = selectedOverlay {
      SettingsManager.setOverlay(Overlay.stringToOVerlay(selectedOverlay))
      graphView.setNeedsDisplay()
    }
  }
}
