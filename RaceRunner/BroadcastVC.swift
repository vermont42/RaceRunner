//
//  BroadcastVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/27/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import CoreData

class BroadcastVC: UIViewController {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var doneButton: UIButton!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    disableDoneButton()
  }

  @IBAction func cancel() {
    performSegueWithIdentifier("unwind pan", sender: self)
  }
  
  @IBAction func done() {
    performSegueWithIdentifier("unwind pan", sender: self)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  func disableDoneButton() {
    doneButton.alpha = UiConstants.notDoneAlpha
    doneButton.enabled = false
  }
  
  func enableDoneButton() {
    doneButton.alpha = 1.0
    doneButton.enabled = true
  }
}