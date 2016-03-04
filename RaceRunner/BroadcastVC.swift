//
//  BroadcastVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/27/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import CoreData

class BroadcastVC: UIViewController, UITextFieldDelegate {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var doneButton: UIButton!
  @IBOutlet var nameField: UITextField!
  @IBOutlet var visibleToggle: UISwitch!
  @IBOutlet var stopToggle: UISwitch!
  weak var broadcastDelegate: BroadcastDelegate!

  override func viewDidLoad() {
    nameField.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    visibleToggle.on = SettingsManager.getBroadcastAvailability()
    stopToggle.on = SettingsManager.getAllowStop()
    nameField.text = SettingsManager.getBroadcastName()
    setupDoneButton()
  }

  @IBAction func cancel() {
    broadcastDelegate.userWantsToBroadcast(false)
    performSegueWithIdentifier("unwind pan", sender: self)
  }
  
  @IBAction func done() {
    broadcastDelegate.userWantsToBroadcast(true)
    performSegueWithIdentifier("unwind pan", sender: self)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  @IBAction func toggleVisible() {
    SettingsManager.setBroadcastAvailability(!SettingsManager.getBroadcastAvailability())
  }
  
  @IBAction func toggleStop() {
    SettingsManager.setAllowStop(!SettingsManager.getAllowStop())
  }
  
  func setupDoneButton() {
    if nameField.text! != "" {
      enableDoneButton()
    }
    else {
      disableDoneButton()
    }
  }
  
  func disableDoneButton() {
    doneButton.alpha = UiConstants.notDoneAlpha
    doneButton.enabled = false
  }
  
  func enableDoneButton() {
    doneButton.alpha = 1.0
    doneButton.enabled = true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    nameField.resignFirstResponder()
    nameField.text! = nameField.text!.removeWhitespace()
    if nameField.text! != "" {
      SettingsManager.setBroadcastName(nameField.text!)
    }
    setupDoneButton()
    return true
  }
}