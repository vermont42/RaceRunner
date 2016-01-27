//
//  GraphsVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/25/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import DLRadioButton

class GraphsVC: ChildVC {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var overlays: [DLRadioButton]!
  
  var run: Run!
  
  override func viewDidLoad() {
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    super.viewDidLoad()
  }
  
  @IBAction func back() {
    performSegueWithIdentifier("unwind pan", sender: self)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}