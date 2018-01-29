//
//  MenuVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class MenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
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
    menuTable.separatorStyle = .none
    menuTable.backgroundColor = UIColor.clear
    menuTable.scrollsToTop = false
    menuTable.delegate = self
    menuTable.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    menuTable.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
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
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return controllerLabels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
      cell!.backgroundColor = UIColor.clear
      if (indexPath as NSIndexPath).row % 2 == 0 {
        cell!.textLabel?.textColor = UiConstants.intermediate2Color
      }
      else {
        cell!.textLabel?.textColor = UiConstants.intermediate3Color
      }
      let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
      selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
      cell!.textLabel?.textAlignment = NSTextAlignment.center
      cell!.selectedBackgroundView = selectedBackgroundView
      cell!.textLabel?.font = UIFont(name: UiConstants.globalFont, size: MenuVC.menuFontSize)
    }
    updateRunButton()
    cell!.textLabel?.text = controllerLabels[(indexPath as NSIndexPath).row]
    cell!.textLabel?.attributedText = UiHelpers.letterPressedText(controllerLabels[(indexPath as NSIndexPath).row])
    return cell!
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return MenuVC.rowHeight
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if controllerLabels[(indexPath as NSIndexPath).row] == MenuVC.historyLabel {
      logTypeToShow = .history
    }
    else if controllerLabels[(indexPath as NSIndexPath).row] == MenuVC.simulateLabel || controllerLabels[(indexPath as NSIndexPath).row] == MenuVC.demoLabel {
      logTypeToShow = .simulate
    }
    if (controllerLabels[(indexPath as NSIndexPath).row] == MenuVC.simulateLabel || controllerLabels[(indexPath as NSIndexPath).row] == MenuVC.demoLabel) && SettingsManager.getRealRunInProgress() {
      UIAlertController.showMessage(MenuVC.realRunMessage, title: MenuVC.sadFaceTitle)
    }
    else {
      performSegue(withIdentifier: panSegues[(indexPath as NSIndexPath).row], sender: self)
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let shimmerDivisor: CGFloat = 2.0
    let shimmerReducer: CGFloat = 10.0
    viewControllerTitle.alpha = 1.0 + sin(scrollView.contentOffset.y / shimmerDivisor) / shimmerReducer
  }
  
  private func updateRunButton() {
    if RunModel.runModel.status == .preRun && controllerLabels[0] == MenuVC.resumeRunLabel {
      controllerLabels[0] = MenuVC.startRunLabel
    }
    else if RunModel.runModel.status != .preRun && controllerLabels[0] == MenuVC.startRunLabel {
      controllerLabels[0] = MenuVC.resumeRunLabel
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pan log" {
      let logVC: LogVC = segue.destination as! LogVC
      logVC.logType = logTypeToShow
    }
    else if segue.identifier == "pan GPX run" {
      let runVC: RunVC = segue.destination as! RunVC
      runVC.gpxFile = MenuVC.gpxFile
    }
  }
  
  @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {}
  
  override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    return UnwindPanSegue(identifier: identifier!, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
}
