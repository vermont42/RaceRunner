//
//  ImportVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 12/14/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import UIKit

class ImportVC: ChildVC {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var instructionsField: UITextView!
  private static let importInstructions = "^Background^\n\nMost run-tracking apps, including Digifit, iSmoothRun, RaceRunner, Runtastic, Runkeeper, Runmeter, Strava, and Wahoo Fitness, can share run data using a file format called .gpx, a variant of XML. In general terms, the way to import runs from another app into RaceRunner is to export them from the other app to email and then to import into RaceRunner. Here are detailed instructions for exporting from various apps and importing into RaceRunner.\n\n^Exporting from Digifit^\n\nTap the hamburger menu in the upper-left corner. Tap \"Results\". Tap the run you want to export. Tap \"Share\". Tap \"Email\". Enter your email address. Tap \"Send\". Fire up your Mac and open the email that Digifit sent you. Click \"View Online\". If you are not already logged in, click \"Sign Up\". Log in. Click \"Details\". Hover over \"Export\" and click \"GPX\". Click \"Download\". The .gpx file will be in your Downloads folder. If you plan to import the file into RaceRunner, email this file to yourself.\n\n^Exporting from iSmoothRun^\n\nTap \"Settings\". Tap \"Social & Export\", which, as of the time of writing, is the fifth setting from the top. Tap \"e-mail\". Input your email address in the light-blue area. Ensure that GPX file format is selected but others are not. Tap \"Log\". Tap the run you want to export. Tap the button whose icon is a cloud with an arrow pointing up into it. Tap \"e-mail\". Tap \"Send\".\n\n^Exporting from Runtastic^\n\nTap the hamburger menu in the upper-left corner. Tap \"History\". Tap the run you want to export. Tap the share button in the upper-right corner. Tap the email icon. Enter your email address. Tap \"Send\". Fire up your Mac and open the email that Runtastic sent you. Click the link in the email Runtastic sent you. After the page loads, click \"Options\". Click \"Export as .gpx file\". The .gpx file will be in your Downloads folder. If you plan to import the file into RaceRunner, email this file to yourself.\n\n^Exporting from Strava^\n\nTap \"Feed\". Tap the share button on the run you want to export. Tap \"Mail\". Enter your email address. Tap \"Send\". Fire up your Mac. Log into Strava in a web browser. Click the name of the run you want to export. Click the wrench icon. Click \"Export GPX\". The .gpx file will be in your Downloads folder. If you plan to import the file into RaceRunner, email this file to yourself.\n\n^Exporting from Wahoo Fitness^\n\nTap \"History\". Tap the run you want to export. Tap the share icon in the top-right corner. Tap \"Mail\". Tap \".GPX\". Enter your email address. Tap \"Send\".\n\n^Exporting from WeatherRun^\n\nWeatherRun does not export data in a format RaceRunner can import. Instructions for exporting from WeatherRun are therefore not provided here.\n\n^Exporting from Runkeeper^\n\nAfter you finish a run, fire up your Mac and go to runkeeper.com/settings. Click Export Data. Select a data range. Click \"Export Data\". Click \"Download Now!\". Open the zip file that is stored in your Downloads folder. Email yourself the .gpx file in the zip file.\n\n^Importing into RaceRunner^\n\nThese instructions assume that you have exported a run to email using one of the techniques described above. Open this email in Apple's Mail app on your iPhone. Scroll down to the bottom of the email. If the attachment says \"Tap to Download\", tap it. Next, hold down your finger on (long press) the attachment. A menu of options pops up. Tap \"Copy to RaceRunner\"."
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    instructionsField.text = ImportVC.importInstructions
    instructionsField.textColor = UiConstants.lightColor
    instructionsField.attributedText = UiHelpers.styleText(instructionsField.text)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    instructionsField.scrollRangeToVisible(NSMakeRange(0, 0))    
  }
  
  @IBAction func back() {
    self.performSegueWithIdentifier("unwind pan", sender: self)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}