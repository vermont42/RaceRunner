//
//  BroadcastVC.swift
//  RaceRunner
//
//  Created by Josh Adams on 2/27/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import CoreData
import UIKit

class BroadcastVC: UIViewController, UITextFieldDelegate {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var doneButton: UIButton!
  @IBOutlet var nameField: UITextField!
  @IBOutlet var stopToggle: UISwitch!

  weak var broadcastDelegate: BroadcastDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()
    nameField.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AWSAnalyticsService.shared.recordVisitation(viewController: "\(BroadcastVC.self)")
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    stopToggle.isOn = SettingsManager.getAllowStop()
    nameField.text = SettingsManager.getBroadcastName()
    setupDoneButton()
  }

  @IBAction func cancel() {
    broadcastDelegate.userWantsToBroadcast(false)
    performSegue(withIdentifier: "unwind pan", sender: self)
  }

  @IBAction func done() {
    broadcastDelegate.userWantsToBroadcast(true)
    performSegue(withIdentifier: "unwind pan", sender: self)
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  @IBAction func toggleStop() {
    SettingsManager.setAllowStop(!SettingsManager.getAllowStop())
  }

  func setupDoneButton() {
    if nameField.text! != "" {
      enableDoneButton()
    } else {
      disableDoneButton()
    }
  }

  func disableDoneButton() {
    doneButton.alpha = UIConstants.notDoneAlpha
    doneButton.isEnabled = false
  }

  func enableDoneButton() {
    doneButton.alpha = 1.0
    doneButton.isEnabled = true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nameField.resignFirstResponder()
    nameField.text = nameField.text?.stringByRemovingWhitespace
    if let text = nameField.text, !text.isEmpty {
      SettingsManager.setBroadcastName(text)
    }
    setupDoneButton()
    return true
  }
}
