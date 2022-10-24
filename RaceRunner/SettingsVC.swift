//
//  SettingsVC.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class SettingsVC: ChildVC, BroadcastDelegate {
  @IBOutlet var unitsToggle: UISwitch!
  @IBOutlet var iconToggle: UISwitch!
  @IBOutlet var broadcastNextRunButton: UIButton!
  @IBOutlet var multiplierSlider: UISlider!
  @IBOutlet var multiplierLabel: UILabel!
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var showMenuButton: UIButton!
  @IBOutlet var autoStopToggle: UISwitch!
  @IBOutlet var autoStopButton: UIButton!
  @IBOutlet var splitsToggle: UISwitch!
  @IBOutlet var splitsButton: UIButton!
  @IBOutlet var neverButton: UIButton!
  @IBOutlet var noneButton: UIButton!
  @IBOutlet var audibleSplitsToggle: UISwitch!
  @IBOutlet var weightLabel: UILabel!
  @IBOutlet var weightStepper: UIStepper!
  @IBOutlet var showWeightToggle: UISwitch!
  @IBOutlet var accentControl: UISegmentedControl!

  private static let distancePrompt = " To begin inputting, tap \"123\" on the bottom-left corner of your virtual keyboard."
  private static let bummerTitle = "😓"
  private static let broadcastNextRunTitle = "Broadcast Next Run"
  private static let stopBroadcastingTitle = "Stop Broadcasting"

  @IBAction func showMenu(_ sender: UIButton) {
    showMenu()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    updateToggles()
    updateSplitsWidgets()
    updateAutoStopWidgets()
    updateMultiplierLabel()
    updateWeightStepper()
    updateWeightLabel()
    updateAccentControl()
    multiplierSlider.value = Float(SettingsManager.getMultiplier())
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text ?? "")
    SettingsManager.setBroadcastNextRun(false)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AWSAnalyticsService.shared.recordVisitation(viewController: "\(SettingsVC.self)")
    updateBroadcastButton()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    return UnwindPanSegue(identifier: identifier ?? "", source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pan publish" {
      (segue.destination as? BroadcastVC)?.broadcastDelegate = self
    }
  }

  @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {}

  @IBAction func toggleUnitType(_ sender: UISwitch) {
    if sender.isOn {
      SettingsManager.setUnitType(.metric)
    } else {
      SettingsManager.setUnitType(.imperial)
    }
    updateSplitsWidgets()
    updateAutoStopWidgets()
    updateWeightStepper()
    updateWeightLabel()
  }

  @IBAction func toggleIconType(_ sender: UISwitch) {
    if sender.isOn {
      SettingsManager.setIconType(RunnerIcons.IconType.horse)
    } else {
      SettingsManager.setIconType(RunnerIcons.IconType.human)
    }
  }

  @IBAction func toggleAutoStop(_ sender: UISwitch) {
    if sender.isOn {
      setAutoStop()
    } else {
      SettingsManager.setStopAfter(SettingsManager.never)
      updateAutoStopWidgets()
    }
  }

  @IBAction func toggleSplits(_ sender: UISwitch) {
    if sender.isOn {
      setSplits()
    } else {
      SettingsManager.setReportEvery(SettingsManager.never)
    }
    updateSplitsWidgets()
  }

  @IBAction func neverAutoStop() {
    if autoStopToggle.isOn {
      autoStopToggle.isOn = false
      autoStopButton.setTitle("", for: UIControl.State())
      SettingsManager.setStopAfter(SettingsManager.never)
    }
  }

  @IBAction func changeSplits() {
    setSplits()
  }

  @IBAction func changeStopAfter() {
    setAutoStop()
  }

  @IBAction func toggleAudibleSplits(_ sender: UISwitch) {
    if sender.isOn {
      SettingsManager.setAudibleSplits(true)
    } else {
      SettingsManager.setAudibleSplits(false)
    }
  }

  @IBAction func accentChanged() {
    SettingsManager.setAccent(Accent.positionToAccent(accentControl.selectedSegmentIndex))
  }

  @IBAction func multiplierChanged(_ sender: UISlider) {
    SettingsManager.setMultiplier(round(Double(sender.value)))
    updateMultiplierLabel()
  }

  @IBAction func weightChanged(_ sender: UIStepper) {
    switch SettingsManager.getUnitType() {
    case .imperial:
      SettingsManager.setWeight(sender.value / Converter.poundsPerKilogram)
    case .metric:
      SettingsManager.setWeight(sender.value)
    }
    updateWeightLabel()
  }

  @IBAction func toggleShowWeight(_ sender: UISwitch) {
    if sender.isOn {
      SettingsManager.setShowWeight(true)
    } else {
      SettingsManager.setShowWeight(false)
    }
  }

  @IBAction func startOrStopBroadcasting() {
    if !SettingsManager.getBroadcastNextRun() {
      performSegue(withIdentifier: "pan publish", sender: self)
    } else {
      SettingsManager.setBroadcastNextRun(false)
      updateBroadcastButton()
      PubNubManager.runStopped()
    }
  }

  func updateBroadcastButton() {
    broadcastNextRunButton.setTitle(SettingsManager.getBroadcastNextRun() ? SettingsVC.stopBroadcastingTitle : SettingsVC.broadcastNextRunTitle, for: UIControl.State())
  }

  func updateToggles() {
    if SettingsManager.getUnitType() == .imperial {
      unitsToggle.isOn = false
    } else {
      unitsToggle.isOn = true
    }
    if SettingsManager.getIconType() == RunnerIcons.IconType.human {
      iconToggle.isOn = false
    } else {
      iconToggle.isOn = true
    }
    showWeightToggle.isOn = SettingsManager.getShowWeight()
    audibleSplitsToggle.isOn = SettingsManager.getAudibleSplits()
  }

  func updateWeightStepper() {
    switch SettingsManager.getUnitType() {
    case .imperial:
      weightStepper.maximumValue = HumanWeight.maxImperial
      weightStepper.minimumValue = HumanWeight.minImperial
      weightStepper.value = SettingsManager.getWeight() * Converter.poundsPerKilogram
    case .metric:
      weightStepper.maximumValue = HumanWeight.maxMetric
      weightStepper.minimumValue = HumanWeight.minMetric
      weightStepper.value = SettingsManager.getWeight()
    }
  }

  func updateWeightLabel() {
    weightLabel.text = "Weight: " + HumanWeight.weightAsString()
  }

  private func updateAccentControl() {
    accentControl.selectedSegmentIndex = SettingsManager.getAccent().radioButtonPosition
  }

  func updateDistanceWidgets(_ interval: Double, button: UIButton, toggle: UISwitch, prefix: String) {
    let buttonTitle: String
    if interval == SettingsManager.never {
      toggle.isOn = false
      buttonTitle = ""
    } else {
      toggle.isOn = true
      if interval < 1.0 {
        buttonTitle = String(format: "%@ %.2f %@", prefix, interval, Converter.getCurrentAbbreviatedLongUnitName())
      } else if interval == 1.0 {
        buttonTitle = "\(prefix) 1 \(Converter.getCurrentAbbreviatedLongUnitName())"
      } else if interval > 1.0 && interval < 100.00 {
        buttonTitle = String(format: "%@ %.2f %@", prefix, interval, Converter.getCurrentPluralLongUnitName())
      } else { // interval >= 100
        buttonTitle = String(format: "%@ %.1f %@", prefix, interval, Converter.getCurrentPluralLongUnitName())
      }
    }
    button.setTitle(buttonTitle, for: UIControl.State())
  }

  func updateSplitsWidgets() {
    updateDistanceWidgets(Converter.convertMetersToLongDistance(SettingsManager.getReportEvery()), button: splitsButton, toggle: splitsToggle, prefix: "Every")
  }

  func updateAutoStopWidgets() {
    updateDistanceWidgets(Converter.convertMetersToLongDistance(SettingsManager.getStopAfter()), button: autoStopButton, toggle: autoStopToggle, prefix: "After")
  }

  func setAutoStop() {
    getDistanceInterval("How many \(Converter.getCurrentPluralLongUnitName()) would you like to stop the run after?") { newValue in
      SettingsManager.setStopAfter(Converter.convertLongDistanceToMeters(newValue))
      self.updateAutoStopWidgets()
    }
  }

  @IBAction func dontReportSplits() {
    if splitsToggle.isOn {
      splitsToggle.isOn = false
      splitsButton.setTitle("", for: UIControl.State())
      SettingsManager.setReportEvery(SettingsManager.never)
    }
  }

  func setSplits() {
    getDistanceInterval("How far in \(Converter.getCurrentPluralLongUnitName()) would you like to run between audible reports of your progress?") { newValue in
      SettingsManager.setReportEvery(Converter.convertLongDistanceToMeters(newValue))
      self.updateSplitsWidgets()
    }
  }

  func getDistanceInterval(_ prompt: String, invalidValue: Bool? = nil, closure: @escaping (Double) -> Void) {
    var fullPrompt = prompt
    if invalidValue != nil && invalidValue == true {
      fullPrompt = "That is an invalid value. " + fullPrompt
    }
    let alertController = UIAlertController(title: "👟", message: fullPrompt + SettingsVC.distancePrompt, preferredStyle: UIAlertController.Style.alert)
    alertController.view.tintColor = UIConstants.darkColor
    let setAction = UIAlertAction(title: "Set", style: UIAlertAction.Style.default, handler: { _ in
      let textFields = alertController.textFields ?? []
      if let text = textFields[0].text, let numericValue = Double(text), numericValue >= SettingsManager.minStopAfter && numericValue <= SettingsManager.maxStopAfter {
          closure(numericValue)
      } else {
          self.getDistanceInterval(prompt, invalidValue: true, closure: closure)
      }
    })
    alertController.addAction(setAction)
    alertController.addTextField { textField in
      textField.placeholder = "Distance"
      textField.keyboardType = UIKeyboardType.default
    }
    present(alertController, animated: true, completion: nil)
  }

  func updateMultiplierLabel() {
    multiplierLabel.text = String(format: "%.0f%%", SettingsManager.getMultiplier() * 100.0)
  }

  func userWantsToBroadcast(_ userWantsToBroadcast: Bool) {
    SettingsManager.setBroadcastNextRun(userWantsToBroadcast)
    updateBroadcastButton()
  }
}
