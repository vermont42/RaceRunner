//
//  MenuVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class MenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet var menuTable: UITableView!
  @IBOutlet var viewControllerTitle: UILabel!
  
  var controllerLabels = ["Start Run", "Simulate", "Demo", "History", "Spectate", "Settings", "Shoes", "Help", "Game"]
  var panSegues = ["pan run", "pan log", "pan GPX run", "pan log", "pan spectate", "pan settings", "pan shoes", "pan help", "pan game"]
  var selectedMenuItem: Int = 0
  var logTypeToShow: LogVC.LogType!
  private var firstAppearance = true

  private static let resumeRunLabel = "Resume Run"
  private static let startRunLabel = "Start Run"
  private static let historyLabel = "History"
  private static let simulateLabel = "Simulate"
  private static let demoLabel = "Demo"
  
  private static let rowHeight: CGFloat = 50.0
  private static let realRunMessage = "There is a real run in progress. Please tap the Continue menu item and stop the run before attempting to simulate a run."
  private static let okButtonText = "OK"
  private static let gpxFile = "iSmoothRun"
  private static let sadFaceTitle = "😢"
  static let menuFontSize: CGFloat = 42.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    menuTable.separatorStyle = .None
    menuTable.backgroundColor = UIColor.clearColor()
    menuTable.scrollsToTop = false
    menuTable.delegate = self
    menuTable.dataSource = self
    SettingsManager.getUnitType()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    menuTable.reloadData()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if firstAppearance {
      firstAppearance = false
      if SettingsManager.getRealRunInProgress() {
        LowMemoryHandler.askWhetherToResumeRun(self, completion: {
          self.updateRunButton()
          self.menuTable.reloadData()
        })
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    LowMemoryHandler.handleLowMemory(self)
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return controllerLabels.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
      cell!.backgroundColor = UIColor.clearColor()
      if indexPath.row % 2 == 0 {
        cell!.textLabel?.textColor = UiConstants.intermediate2Color
      }
      else {
        cell!.textLabel?.textColor = UiConstants.intermediate3Color
      }
      let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
      selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
      cell!.textLabel?.textAlignment = NSTextAlignment.Center
      cell!.selectedBackgroundView = selectedBackgroundView
      cell!.textLabel?.font = UIFont(name: UiConstants.globalFont, size: MenuVC.menuFontSize)
    }
    updateRunButton()
    cell!.textLabel?.text = controllerLabels[indexPath.row]
    cell!.textLabel?.attributedText = UiHelpers.letterPressedText(controllerLabels[indexPath.row])
    return cell!
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return MenuVC.rowHeight
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if controllerLabels[indexPath.row] == MenuVC.historyLabel {
      logTypeToShow = .History
    }
    else if controllerLabels[indexPath.row] == MenuVC.simulateLabel || controllerLabels[indexPath.row] == MenuVC.demoLabel {
      logTypeToShow = .Simulate
    }
    if (controllerLabels[indexPath.row] == MenuVC.simulateLabel || controllerLabels[indexPath.row] == MenuVC.demoLabel) && SettingsManager.getRealRunInProgress() {
      UIAlertController.showMessage(MenuVC.realRunMessage, title: MenuVC.sadFaceTitle)
    }
    else {
      performSegueWithIdentifier(panSegues[indexPath.row], sender: self)
    }
  }
  
  private func updateRunButton() {
    if RunModel.runModel.status == .PreRun && controllerLabels[0] == MenuVC.resumeRunLabel {
      controllerLabels[0] = MenuVC.startRunLabel
    }
    else if RunModel.runModel.status != .PreRun && controllerLabels[0] == MenuVC.startRunLabel {
      controllerLabels[0] = MenuVC.resumeRunLabel
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "pan log" {
      let logVC: LogVC = segue.destinationViewController as! LogVC
      logVC.logType = logTypeToShow
    }
    else if segue.identifier == "pan GPX run" {
      let runVC: RunVC = segue.destinationViewController as! RunVC
      runVC.gpxFile = MenuVC.gpxFile
    }
  }
  
  @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {}
  
  override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    return UnwindPanSegue(identifier: identifier!, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
