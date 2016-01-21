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
    var controllerLabels = ["Start Run", "Simulate", "Demo", "History", "Spectate", "Settings", "Shoes"]
    var panSegues = ["pan run", "pan log", "pan GPX run", "pan log", "pan spectate", "pan settings", "pan shoes"]
    var selectedMenuItem: Int = 0
    var logTypeToShow: LogVC.LogType!

    private static let rowHeight: CGFloat = 50.0
    private static let realRunMessage = "There is a real run in progress. Please click the Run menu item and stop the run before attempting to simulate a run."
    private static let okButtonText = "OK"
    private static let gpxFile = "iSmoothRun2"
    private static let sadFaceTitle = "😢"
    static let menuFontSize: CGFloat = 42.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if RunModel.runModel.status == .PreRun && controllerLabels[0] == "Continue"
        {
            controllerLabels[0] = "Start Run"
        }
        else if RunModel.runModel.status != .PreRun && controllerLabels[0] == "Start Run" {
            controllerLabels[0] = "Continue"
        }
        cell!.textLabel?.text = controllerLabels[indexPath.row]
        cell!.textLabel?.attributedText = UiHelpers.letterPressedText(controllerLabels[indexPath.row])
        return cell!
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MenuVC.rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if controllerLabels[indexPath.row] == "History" {
            logTypeToShow = .History
        }
        else if controllerLabels[indexPath.row] == "Simulate" || controllerLabels[indexPath.row] == "Demo" {
            logTypeToShow = .Simulate
        }
        if (controllerLabels[indexPath.row] == "Simulate" || controllerLabels[indexPath.row] == "Demo") && RunModel.runModel.realRunInProgress {
            UIAlertController.showMessage(MenuVC.realRunMessage, title: MenuVC.sadFaceTitle)
        }
        else {
            performSegueWithIdentifier(panSegues[indexPath.row], sender: self)
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
        if let id = identifier{
            let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
            })
            return unwindSegue
        }
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
