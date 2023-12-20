//
//  LogVC.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import CoreData
import MapKit
import UIKit

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

  var viewControllerTitleText = ""
  var runs: [Run] = []
  var selectedRun = 0
  enum LogType {
    case history
    case simulate
  }
  var logType: LogType = .history
  var locFile = "Runmeter"
  private static let rowHeight: CGFloat = 92.0
  private var oldLogSortField = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    fieldPicker.dataSource = self
    fieldPicker.delegate = self
    tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    pickerToolbar.isHidden = true
    fieldPicker.isHidden = true
    fieldPicker.selectRow(SettingsManager.getLogSortField().pickerPosition(), inComponent: 0, animated: false)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AWSAnalyticsService.shared.recordVisitation(viewController: "\(LogVC.self)")
    self.viewControllerTitle.text = viewControllerTitleText
    if logType == LogVC.LogType.history {
      viewControllerTitle.text = "History"
    } else if logType == LogVC.LogType.simulate {
      viewControllerTitle.text = "Simulate"
    }
    showPickerButton.setTitle(SettingsManager.getLogSortField().rawValue, for: UIControl.State())
    viewControllerTitle.attributedText = UIHelpers.letterPressedText(viewControllerTitle.text ?? "")
    fetchRuns()
    runs.sort { LogSortField.compare($0, run2: $1) }
    RunModel.registerForImportedRunNotifications(self)
  }

  override func viewDidAppear(_ animated: Bool) {
    tableView.reloadData()
    super.viewDidAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    RunModel.deregisterForImportedRunNotifications()
  }

  override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    UnwindPanSegue(identifier: identifier ?? "", source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }

  @IBAction func importRuns() {
    performSegue(withIdentifier: "pan import from log", sender: self)
  }

  @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {}

  @IBAction func reverseSort() {
    SettingsManager.setSortType(SortType.reverseSortType(SettingsManager.getSortType()))
    runs.sort { LogSortField.compare($0, run2: $1) }
    tableView.reloadData()
  }

  @IBAction func showPicker() {
    pickerToolbar.isHidden = false
    fieldPicker.isHidden = false
    oldLogSortField = fieldPicker.selectedRow(inComponent: 0)
  }

  @IBAction func dismissPicker(_ sender: UIBarButtonItem) {
    pickerToolbar.isHidden = true
    fieldPicker.isHidden = true
    let newLogSortField = fieldPicker.selectedRow(inComponent: 0)
    if newLogSortField != oldLogSortField {
      SettingsManager.setLogSortField(LogSortField.sortFieldForPosition(newLogSortField))
      showPickerButton.setTitle(SettingsManager.getLogSortField().rawValue, for: UIControl.State())
      runs.sort { LogSortField.compare($0, run2: $1) }
      tableView.reloadData()
    }
  }

  func runWasImported() {
    fetchRuns()
    tableView.reloadData()
  }

  @IBAction func showMenu(_ sender: UIButton) {
    showMenu()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !runs.isEmpty {
      return runs.count
    } else if !SettingsManager.getAlreadyMadeSampleRun() {
      if let parser = GpxParser(file: locFile) {
        let parseResult = parser.parse()
        runs = [RunModel.addRun(parseResult.locations, autoName: parseResult.autoName, customName: parseResult.customName, timestamp: parseResult.locations[0].timestamp, weather: parseResult.weather, temperature: parseResult.temperature, weight: parseResult.weight)]
        SettingsManager.setAlreadyMadeSampleRun(true)
      } else {
        fatalError(GpxParser.parseError)
      }
      return 1
    } else {
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell") as? LogCell else {
      fatalError("Could not dequeue \(LogCell.self) in LogVC.")
    }
    cell.displayRun(runs[(indexPath as NSIndexPath).row])
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedRun = (indexPath as NSIndexPath).row
    if logType == .history {
      performSegue(withIdentifier: "pan details from log", sender: self)
    } else if logType == .simulate {
      performSegue(withIdentifier: "pan run from log", sender: self)
    }
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCell.EditingStyle.delete {
      CDManager.sharedCDManager.context.delete(runs[(indexPath as NSIndexPath).row])
      CDManager.saveContext()
      runs.remove(at: (indexPath as NSIndexPath).row)
      tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    LogVC.rowHeight
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pan details from log" {
      if let runDetailsVC: RunDetailsVC = segue.destination as? RunDetailsVC {
        runDetailsVC.run = runs[selectedRun]
      }
    } else if segue.identifier == "pan run from log" {
      if let runVC: RunVC = segue.destination as? RunVC {
        runVC.runToSimulate = runs[selectedRun]
      }
    }
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    LogSortField.all().count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    LogSortField.all()[row]
  }

  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    NSAttributedString(string: LogSortField.all()[row], attributes: [NSAttributedString.Key.foregroundColor: UIConstants.intermediate3Color])
  }

  private func fetchRuns() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
    let context = CDManager.sharedCDManager.context
    fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Run", in: context)
    let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    runs = ((try? context.fetch(fetchRequest)) as? [Run]) ?? []
  }
}
