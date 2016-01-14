//
//  LogVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class LogVC: ChildVC, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ImportedRunDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var viewControllerTitle: UILabel!
    @IBOutlet var showMenuButton: UIButton!
    @IBOutlet var importButton: UIButton!
    @IBOutlet var sortFieldButton: UIButton!
    @IBOutlet var reverseSortButton: UIButton!
    @IBOutlet var fieldPicker: UIPickerView!
    @IBOutlet var pickerToolbar: UIToolbar!
    @IBOutlet var showPickerButton: UIButton!
    
    var viewControllerTitleText: String!
    var context: NSManagedObjectContext!
    var runs: [Run]?
    var selectedRun = 0
    enum LogType {
        case History
        case Simulate
    }
    var logType: LogType!
    var locFile = "iSmoothRun2"
    private static let rowHeight: CGFloat = 92.0
    private var oldSortField: Int!

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return LogVC.rowHeight
    }
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        fieldPicker.dataSource = self
        fieldPicker.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        showMenuButton.setImage(UiHelpers.maskedImageNamed("menu", color: UiConstants.lightColor), forState: .Normal)
        reverseSortButton.setImage(UiHelpers.maskedImageNamed("arrow", color: UiConstants.intermediate3Color), forState: .Normal)
        pickerToolbar.hidden = true
        fieldPicker.hidden = true
        fieldPicker.selectRow(SettingsManager.getSortField().pickerPosition(), inComponent: 0, animated: false)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.viewControllerTitle.text = viewControllerTitleText
        if logType == LogVC.LogType.History {
            viewControllerTitle.text = "History"
        }
        else if logType == LogVC.LogType.Simulate {
            viewControllerTitle.text = "Simulate"
        }
        showPickerButton.setTitle(SettingsManager.getSortField().rawValue, forState: .Normal)
        viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
        fetchRuns()
        runs?.sortInPlace { SortField.compare($0, run2: $1) }
        RunModel.registerForImportedRunNotifications(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        RunModel.deregisterForImportedRunNotifications()
    }
    
    func runWasImported() {
        fetchRuns()
        tableView.reloadData()
    }
    
    private func fetchRuns() {
        let fetchRequest = NSFetchRequest()
        let context = CDManager.sharedCDManager.context
        fetchRequest.entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: context)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        runs = (try? context.executeFetchRequest(fetchRequest)) as? [Run]
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        super.viewDidAppear(animated)
    }
    
    @IBAction func showMenu(sender: UIButton) {
        showMenu()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let runs = runs {
            return runs.count
        }
        else if !SettingsManager.getAlreadyMadeSampleRun() {
            if let parser = GpxParser(file: locFile) {
                let parseResult = parser.parse()
                runs = [RunModel.addRun(parseResult.locations, customName: parseResult.name, timestamp: parseResult.locations[0].timestamp, weather: parseResult.weather, temperature: parseResult.temperature)]
                SettingsManager.setAlreadyMadeSampleRun(true)
            }
            else {
                fatalError("Could not parse GPX file.")
            }
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? LogCell
        cell?.displayRun(runs![indexPath.row])
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRun = indexPath.row
        if logType == .History {
            performSegueWithIdentifier("pan details from log", sender: self)
        }
        else if logType == .Simulate {
            performSegueWithIdentifier("pan run from log", sender: self)
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            CDManager.sharedCDManager.context.deleteObject(runs![indexPath.row])
            CDManager.saveContext()
            runs!.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pan details from log" {
            let runDetailsVC: RunDetailsVC = segue.destinationViewController as! RunDetailsVC
            runDetailsVC.run = runs![selectedRun]
        }
        else {
            if segue.identifier == "pan run from log" {
                let runVC: RunVC = segue.destinationViewController as! RunVC
                runVC.runToSimulate = runs![selectedRun]
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SortField.all().count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SortField.all()[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: SortField.all()[row], attributes: [NSForegroundColorAttributeName: UiConstants.intermediate3Color])
    }
    
    @IBAction func importRuns() {
        performSegueWithIdentifier("pan import from log", sender: self)
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
    
    @IBAction func reverseSort() {
        SettingsManager.setSortType(SortType.reverse(SettingsManager.getSortType()))
        runs?.sortInPlace { SortField.compare($0, run2: $1) }
        tableView.reloadData()
    }
    
    @IBAction func showPicker() {
        pickerToolbar.hidden = false
        fieldPicker.hidden = false
        oldSortField = fieldPicker.selectedRowInComponent(0)
    }
    
    @IBAction func dismissPicker(sender: UIBarButtonItem) {
        pickerToolbar.hidden = true
        fieldPicker.hidden = true
        let newSortField = fieldPicker.selectedRowInComponent(0)
        if newSortField != oldSortField {
            SettingsManager.setSortField(SortField.sortFieldForPosition(newSortField))
            showPickerButton.setTitle(SettingsManager.getSortField().rawValue, forState: .Normal)
            runs?.sortInPlace { SortField.compare($0, run2: $1) }
            tableView.reloadData()
        }
    }
    
}