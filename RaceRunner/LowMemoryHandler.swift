//
//  LowMemoryHandler.swift
//  RaceRunner
//
//  Created by Joshua Adams on 6/9/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

class LowMemoryHandler {
  private static var dateOfMostRecentHandlingOfLowMemory = Date()
  private static let minimumSecondsBetweenHandlingLowMemory: TimeInterval = 30
  private static var hasHandledLowMemoryAtLeastOnce = false
  private static let lowRamWarning = "Your iPhone is running out of RAM. Your iPhone may therefore cause RaceRunner to stop recording your run. No problem if it does. RaceRunner has saved the progress of your run. If your iPhone causes RaceRunner to stop recording, RaceRunner will restore your run the next time you launch the app."
  private static let recordingInterruptedTitle = "Recording Interrupted"
  private static let recordingInterruptedPrompt = "You iPhone forced RaceRunner to stop recording your run because of a low-RAM situation. Before quitting, RaceRunner saved the state of your run in progress. Would you like to resume this run or discard the saved state?"
  private static let resumeButtonTitle = "Resume"
  private static let discardButtonTitle = "Discard"
  private static var resumeController: UIAlertController = UIAlertController(title: recordingInterruptedTitle, message: recordingInterruptedPrompt, preferredStyle: UIAlertControllerStyle.alert)
  private static var completion: (() -> Void)!
  
  static func handleLowMemory(_ anyObject: AnyObject) {
    if ((Date().timeIntervalSince(dateOfMostRecentHandlingOfLowMemory) > minimumSecondsBetweenHandlingLowMemory) || !hasHandledLowMemoryAtLeastOnce) && SettingsManager.getRealRunInProgress() {
      hasHandledLowMemoryAtLeastOnce = true
      dateOfMostRecentHandlingOfLowMemory = Date()
      if !SettingsManager.getWarnedUserAboutLowRam() {
        SettingsManager.setWarnedUserAboutLowRam(true)
        Utterer.utter(lowRamWarning)
      }
      RunModel.saveState()
    }
  }

  static func askWhetherToResumeRun(_ viewController: UIViewController, completion: @escaping () -> Void) {
    LowMemoryHandler.completion = completion
    viewController.present(resumeController, animated: true, completion: nil)
    resumeController.view.tintColor = UiConstants.intermediate1Color
  }
  
  static func appStarted() {
    SettingsManager.setWarnedUserAboutLowRam(false)
    if SettingsManager.getRealRunInProgress() {
      let resumeAction = UIAlertAction(title: resumeButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
        RunModel.loadStateAndStart()
        PersistentMapState.initMapState()
        LowMemoryHandler.completion()
      })
      resumeController.addAction(resumeAction)
      let discardAction = UIAlertAction(title: discardButtonTitle, style: UIAlertActionStyle.cancel, handler: { (action) in
        RunModel.deleteSavedRun()
      })
      resumeController.addAction(discardAction)
    }
  }
}
