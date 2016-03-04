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
import CloudKit

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
  @IBOutlet var accentButtons: [DLRadioButton]!
  @IBOutlet var weightLabel: UILabel!
  @IBOutlet var weightStepper: UIStepper!
  @IBOutlet var showWeightToggle: UISwitch!
  @IBOutlet var buyLabel: UILabel!
  @IBOutlet var runningHorseButton: UIButton!
  @IBOutlet var broadcastRunsButton: UIButton!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var restoreButton: UIButton!
  private var products = [SKProduct]()
  private static let distancePrompt = " To begin inputting, tap \"123\" on the bottom-left corner of your virtual keyboard."
  private static let bummerTitle = "😓"
  private static let noHorseMessage = "RaceRunner cannot display the animated horse during your runs because you have not purchased that feature."
  private static let noBroadcastMessage = "RaceRunner cannot broadcast your runs to spectators because you have not bought that feature. If you would like to buy it, tap the Broadcast Runs button in the Buy section below."
  private static let promoCodeTitle = "Input Promo Code"
  private static let promoCodePrompt = "To unlock RaceRunner's in-app purchases, input a promo code and tap Unlock."
  private static let promoCodeUnlock = "Unlock"
  private static let cancel = "Cancel"
  private static let promoCode = "Promo Code"
  private static let sweetTitle = "Sweet"
  private static let unlockedMessage = "In-app purchases unlocked!"
  private static let invalidPromoCodeMessage = "In-app purchases not unlocked. Promo code is invalid."
  private static let unlockErrorMessage = "Could not unlock in-app purchases"
  private static let broadcastNextRunTitle = "Broadcast Next Run"
  private static let stopBroadcastingTitle = "Stop Broadcasting"
  
  
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
    setUpProducts()
    let secretSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "unlockIaps")
    secretSwipeRecognizer.numberOfTouchesRequired = 2
    secretSwipeRecognizer.direction = .Down
    view.addGestureRecognizer(secretSwipeRecognizer)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    updateBroadcastButton()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func updateBroadcastButton() {
    broadcastNextRunButton.setTitle(SettingsManager.getBroadcastNextRun() ? SettingsVC.stopBroadcastingTitle : SettingsVC.broadcastNextRunTitle, forState: .Normal)
  }
  
  func unlockIaps() {
    let purchasedHorse = Products.store.isProductPurchased(Products.runningHorse)
    let purchasedBroadcast = Products.store.isProductPurchased(Products.broadcastRuns)
    if !purchasedBroadcast || !purchasedHorse {
      let alertController = UIAlertController(title: SettingsVC.promoCodeTitle, message: SettingsVC.promoCodePrompt, preferredStyle: UIAlertControllerStyle.Alert)
      let unlockAction = UIAlertAction(title: SettingsVC.promoCodeUnlock, style: UIAlertActionStyle.Default, handler: { (action) in
        let textFields = alertController.textFields!
        let predicate = NSPredicate(format: "promoCode = %@", textFields[0].text!.lowercaseString)
        let query = CKQuery(recordType: "PromoCodes", predicate: predicate)
        CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil) {
          results, error in
          if error == nil {
            if results!.count > 0 {
              dispatch_async(dispatch_get_main_queue()) {
                UIAlertController.showMessage(SettingsVC.unlockedMessage, title: SettingsVC.sweetTitle)
                Products.store.fakeIapPurchases()
              }
            }
            else {
              dispatch_async(dispatch_get_main_queue()) {
                UIAlertController.showMessage(SettingsVC.invalidPromoCodeMessage, title: SettingsVC.bummerTitle)
              }
            }
          }
          else {
            dispatch_async(dispatch_get_main_queue()) {
              UIAlertController.showMessage("\(SettingsVC.unlockErrorMessage): \(error!.localizedDescription)", title: SettingsVC.bummerTitle)
            }
          }
        }
      })
      alertController.addAction(unlockAction)
      let cancelAction = UIAlertAction(title: SettingsVC.cancel, style: UIAlertActionStyle.Cancel, handler: { (action) in })
      alertController.addAction(cancelAction)
      alertController.addTextFieldWithConfigurationHandler { (textField) in
        textField.placeholder = SettingsVC.promoCode
      }
      alertController.view.tintColor = UiConstants.intermediate1Color
      presentViewController(alertController, animated: true, completion: nil)
    }
  }
  
  func setUpProducts() {
    products = []
    Products.store.requestProductsWithCompletionHandler { success, products in
      if success {
        self.products = products
        //print("retrieved products")
      }
      else {
        print("failed to retrieve products")
      }
    }
    updatePurchaseWidgets()
  }
  
  func updatePurchaseWidgets() {
    let purchasedHorse = Products.store.isProductPurchased(Products.runningHorse)
    let purchasedBroadcast = Products.store.isProductPurchased(Products.broadcastRuns)
    if purchasedHorse && purchasedBroadcast {
      buyLabel.hidden = true
      runningHorseButton.hidden = true
      broadcastRunsButton.hidden = true
      priceLabel.hidden = true
      restoreButton.hidden = true
    }
    else if purchasedHorse && !purchasedBroadcast{
      buyLabel.hidden = false
      runningHorseButton.hidden = true
      broadcastRunsButton.hidden = false
      priceLabel.hidden = false
      restoreButton.hidden = false
    }
    else if !purchasedHorse && purchasedBroadcast{
      buyLabel.hidden = false
      runningHorseButton.hidden = false
      broadcastRunsButton.hidden = true
      priceLabel.hidden = false
      restoreButton.hidden = false
    }
    else {// purchased neither
      buyLabel.hidden = false
      runningHorseButton.hidden = false
      broadcastRunsButton.hidden = false
      priceLabel.hidden = false
      restoreButton.hidden = false
    }
  }
  
  func productPurchased(notification: NSNotification) {
//    let productIdentifier = notification.object as! String
//    for (index, product) in products.enumerate() {
//      if product.productIdentifier == productIdentifier {
//        print("purchased: \(productIdentifier)  index: \(index)")
//        break
//      }
//    }
    updatePurchaseWidgets()
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
    // TODO: enable this logic
//    if sender.on && !Products.store.isProductPurchased(Products.runningHorse) {
//      UIAlertController.showMessage(SettingsVC.noHorseMessage, title: SettingsVC.bummerTitle)
//      sender.on = false
//    }
//    else {
      if sender.on {
        SettingsManager.setIconType(RunnerIcons.IconType.Horse)
      }
      else {
        SettingsManager.setIconType(RunnerIcons.IconType.Human)
      }
//    }
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
    if products.count == 2 {
      Products.store.purchaseProduct(products[1])
    }
  }
  
  @IBAction func buyBroadcastRuns() {
    if products.count == 2 {
      Products.store.purchaseProduct(products[0])
    }
  }
  
  @IBAction func startOrStopBroadcasting() {
    // TODO: enable this logic
//    if !SettingsManager.getBroadcastRun() && !Products.store.isProductPurchased(Products.broadcastRuns) {
//      UIAlertController.showMessage(SettingsVC.noBroadcastMessage, title: SettingsVC.bummerTitle)
//      return
//    }
    if !SettingsManager.getBroadcastNextRun() {
      performSegueWithIdentifier("pan publish", sender: self)
    }
    else {
      SettingsManager.setBroadcastNextRun(false)
      updateBroadcastButton()
    }
  }
  
  @IBAction func restorePurchases(sender: UIButton) {
    Products.store.restoreCompletedTransactions()
  }
  
  @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {}
  
  override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    if let id = identifier {
      let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
        
      })
      return unwindSegue
    }
    return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "pan publish" {
      (segue.destinationViewController as! BroadcastVC).broadcastDelegate = self
    }
  }
  
  func userWantsToBroadcast(userWantsToBroadcast: Bool) {
    SettingsManager.setBroadcastNextRun(userWantsToBroadcast)
    updateBroadcastButton()
  }
}