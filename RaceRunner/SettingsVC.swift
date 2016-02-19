//
//  SettingsVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import DLRadioButton
import StoreKit

class SettingsVC: ChildVC {
  @IBOutlet var unitsToggle: UISwitch!
  @IBOutlet var iconToggle: UISwitch!
  @IBOutlet var publishRunToggle: UISwitch!
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
  @IBOutlet var accentButtons: [DLRadioButton]!
  @IBOutlet var weightLabel: UILabel!
  @IBOutlet var weightStepper: UIStepper!
  @IBOutlet var showWeightToggle: UISwitch!
  
  private static let distancePrompt = " To begin inputting, tap \"123\" on the bottom-left corner of your virtual keyboard."
  private var products = [SKProduct]()

  
  @IBAction func showMenu(sender: UIButton) {
    showMenu()
  }
  
  override func viewDidLoad() {
    updateToggles()
    updateSplitsWidgets()
    updateAutoStopWidgets()
    updateMultiplierLabel()
    updateWeightStepper()
    updateWeightLabel()
    accentButtons[SettingsManager.getAccent().radioButtonPosition()].sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    multiplierSlider.value = Float(SettingsManager.getMultiplier())
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IapHelperProductPurchasedNotification, object: nil)
    products = []
    Products.store.requestProductsWithCompletionHandler { success, products in
      if success {
        self.products = products
//        print("retrieved products")
      }
      else {
//        print("failed to retrieve products")
      }
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func productPurchased(notification: NSNotification) {
    let productIdentifier = notification.object as! String
    for (index, product) in products.enumerate() {
      if product.productIdentifier == productIdentifier {
        print("purchased: \(productIdentifier)  index: \(index)")
        break
      }
    }
  }
  
  func updateToggles() {
    if SettingsManager.getUnitType() == .Imperial {
      unitsToggle.on = false
    }
    else {
      unitsToggle.on = true
    }
    if SettingsManager.getIconType() == RunnerIcons.IconType.Human {
      iconToggle.on = false
    }
    else {
      iconToggle.on = true
    }
    publishRunToggle.on = SettingsManager.getPublishRun()
    showWeightToggle.on = SettingsManager.getShowWeight()
    audibleSplitsToggle.on = SettingsManager.getAudibleSplits()
  }
  
  func updateWeightStepper() {
    switch SettingsManager.getUnitType() {
    case .Imperial:
      weightStepper.maximumValue = HumanWeight.maxImperial
      weightStepper.minimumValue = HumanWeight.minImperial
      weightStepper.value = SettingsManager.getWeight() * Converter.poundsPerKilogram
    case .Metric:
      weightStepper.maximumValue = HumanWeight.maxMetric
      weightStepper.minimumValue = HumanWeight.minMetric
      weightStepper.value = SettingsManager.getWeight()
    }
  }
  
  func updateWeightLabel() {
    weightLabel.text = "Weight: " + HumanWeight.weightAsString()
  }
  
  func updateDistanceWidgets(interval: Double, button: UIButton, toggle: UISwitch, prefix: String) {
    let buttonTitle: String
    if interval == SettingsManager.never {
      toggle.on = false
      buttonTitle = ""
    }
    else {
      toggle.on = true
      if interval < 1.0 {
        buttonTitle = String(format: "%@ %.2f %@", prefix, interval, Converter.getCurrentAbbreviatedLongUnitName())
      }
      else if interval == 1.0 {
        buttonTitle = "\(prefix) 1 \(Converter.getCurrentAbbreviatedLongUnitName())"
      }
      else if interval > 1.0 && interval < 100.00 {
        buttonTitle = String(format: "%@ %.2f %@", prefix, interval, Converter.getCurrentPluralLongUnitName())
      }
      else { // interval >= 100
        buttonTitle = String(format: "%@ %.1f %@", prefix, interval, Converter.getCurrentPluralLongUnitName())
      }
    }
    button.setTitle(buttonTitle, forState: .Normal)
  }
  
  func updateSplitsWidgets() {
    updateDistanceWidgets(Converter.convertMetersToLongDistance(SettingsManager.getReportEvery()), button: splitsButton, toggle: splitsToggle, prefix: "Every")
  }

  func updateAutoStopWidgets() {
    updateDistanceWidgets(Converter.convertMetersToLongDistance(SettingsManager.getStopAfter()), button: autoStopButton, toggle: autoStopToggle, prefix: "After")
  }
  
  @IBAction func toggleUnitType(sender: UISwitch) {
    if sender.on {
      SettingsManager.setUnitType(.Metric)
    }
    else {
      SettingsManager.setUnitType(.Imperial)
    }
    updateSplitsWidgets()
    updateAutoStopWidgets()
    updateWeightStepper()
    updateWeightLabel()
  }
  
  @IBAction func toggleIconType(sender: UISwitch) {
    if sender.on {
      SettingsManager.setIconType(RunnerIcons.IconType.Horse)
    }
    else {
      SettingsManager.setIconType(RunnerIcons.IconType.Human)
    }
  }
  
  @IBAction func togglePublishRun(sender: UISwitch) {
    if sender.on {
      SettingsManager.setPublishRun(true)
      Products.store.requestProductsWithCompletionHandler { success, products in
        if success {
          self.products = products
          print("Purchase request succeeded.")
        }
        else {
          print("Purchase request failed.")
        }
      }
    }
    else {
      SettingsManager.setPublishRun(false)
    }
  }
  
  @IBAction func toggleAutoStop(sender: UISwitch) {
    if sender.on {
      setAutoStop()
    }
    else {
      SettingsManager.setStopAfter(SettingsManager.never)
      updateAutoStopWidgets()
    }
  }
  
  @IBAction func toggleSplits(sender: UISwitch) {
    if sender.on {
      setSplits()
    }
    else {
      SettingsManager.setReportEvery(SettingsManager.never)
    }
    updateSplitsWidgets()
  }
  
  @IBAction func neverAutoStop() {
    if autoStopToggle.on {
      autoStopToggle.on = false
      autoStopButton.setTitle("", forState: .Normal)
      SettingsManager.setStopAfter(SettingsManager.never)
    }
  }
  
  func setAutoStop() {
    getDistanceInterval("How many \(Converter.getCurrentPluralLongUnitName()) would you like to stop the run after?")
    { newValue in
      SettingsManager.setStopAfter(Converter.convertLongDistanceToMeters(newValue))
      self.updateAutoStopWidgets()
    }
  }
  
  @IBAction func dontReportSplits() {
    if splitsToggle.on {
      splitsToggle.on = false
      splitsButton.setTitle("", forState: .Normal)
      SettingsManager.setReportEvery(SettingsManager.never)
    }
  }

  func setSplits() {
    getDistanceInterval("How far in \(Converter.getCurrentPluralLongUnitName()) would you like to run between audible reports of your progress?")
    { newValue in
      SettingsManager.setReportEvery(Converter.convertLongDistanceToMeters(newValue))
      self.updateSplitsWidgets()
    }
  }
  
  func getDistanceInterval(prompt: String, invalidValue: Bool? = nil, closure: (Double) -> Void) {
    var fullPrompt = prompt
    if invalidValue != nil && invalidValue == true {
      fullPrompt = "That is an invalid value. " + fullPrompt
    }
    let alertController = UIAlertController(title: "👟", message: fullPrompt + SettingsVC.distancePrompt, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.view.tintColor = UiConstants.darkColor
    let setAction = UIAlertAction(title: "Set", style: UIAlertActionStyle.Default, handler: { (action) in
      let textFields = alertController.textFields!
      if let text = textFields[0].text, numericValue = Double(text) where numericValue >= SettingsManager.minStopAfter && numericValue <= SettingsManager.maxStopAfter {
          closure(numericValue)
      }
      else {
          self.getDistanceInterval(prompt, invalidValue: true, closure: closure)
      }
    })
    alertController.addAction(setAction)
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Distance"
      textField.keyboardType = UIKeyboardType.Default
    }
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  @IBAction func changeSplits() {
    setSplits()
  }
  
  @IBAction func changeStopAfter() {
    setAutoStop()
  }
  
  @IBAction func toggleAudibleSplits(sender: UISwitch) {
    if sender.on {
      SettingsManager.setAudibleSplits(true)
    }
    else {
      SettingsManager.setAudibleSplits(false)
    }
  }
  
  @IBAction func changeAccent(sender: DLRadioButton) {
    let selectedFlag = sender.selectedButton().titleLabel?.text
    if let selectedFlag = selectedFlag {
      SettingsManager.setAccent(selectedFlag)
    }
  }
  
  @IBAction func multiplierChanged(sender: UISlider) {
    SettingsManager.setMultiplier(round(Double(sender.value)))
    updateMultiplierLabel()
  }
  
  func updateMultiplierLabel() {
    multiplierLabel.text = String(format: "%.0f%%", SettingsManager.getMultiplier() * 100.0)
  }
  
  @IBAction func weightChanged(sender: UIStepper) {
    switch SettingsManager.getUnitType() {
    case .Imperial:
      SettingsManager.setWeight(sender.value / Converter.poundsPerKilogram)
    case .Metric:
      SettingsManager.setWeight(sender.value)
    }
    updateWeightLabel()
  }
  
  @IBAction func toggleShowWeight(sender: UISwitch) {
    if sender.on {
      SettingsManager.setShowWeight(true)
    }
    else {
      SettingsManager.setShowWeight(false)
    }
  }
  
  @IBAction func buyRunningHorse() {
    Products.store.purchaseProduct(products[1])
  }
  
  @IBAction func buyBroadcastRuns() {
    Products.store.purchaseProduct(products[0])
  }
}