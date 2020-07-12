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
  var logTypeToShow: LogVC.LogType = .history

  private static let resumeRunLabel = "Resume Run"
  private static let startRunLabel = "Start Run"
  private static let historyLabel = "History"
  private static let simulateLabel = "Simulate"
  private static let demoLabel = "Demo"
  private static let menuFontSize: CGFloat = 42.0
  private static let rowHeight: CGFloat = 50.0
  private static let realRunMessage = "There is a real run in progress. Please tap the Resume Run button and stop the run before attempting to simulate a run."
  private static let gpxFile = "iSmoothRun"
  private static let sadFaceTitle = "😢"

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text ?? "")
    menuTable.separatorStyle = .none
    menuTable.backgroundColor = UIColor.clear
    menuTable.scrollsToTop = false
    menuTable.delegate = self
    menuTable.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AWSAnalyticsService.shared.recordVisitation(viewController: "\(MenuVC.self)")
    NotificationCenter.default.addObserver(self, selector: #selector(updateRunButton), name: .runDidStart, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateRunButton), name: .runDidStop, object: nil)
    updateRunButton()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return controllerLabels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellIdentifier = "Cell"
    var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
      guard let initializedCell = cell else {
        fatalError("initializedCell on MenuVC screen was nil.")
      }
      initializedCell.backgroundColor = UIColor.clear
      if (indexPath as NSIndexPath).row % 2 == 0 {
        initializedCell.textLabel?.textColor = UiConstants.intermediate2Color
      } else {
        initializedCell.textLabel?.textColor = UiConstants.intermediate3Color
      }
      let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: initializedCell.frame.size.width, height: initializedCell.frame.size.height))
      selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
      initializedCell.textLabel?.textAlignment = NSTextAlignment.center
      initializedCell.selectedBackgroundView = selectedBackgroundView
      initializedCell.textLabel?.font = UIFont(name: UiConstants.globalFont, size: MenuVC.menuFontSize)
    }
    guard let initializedOrDequeuedCell = cell else {
      fatalError("initializedOrDequeuedCell on MenuVC screen was nil.")
    }
    initializedOrDequeuedCell.textLabel?.text = controllerLabels[(indexPath as NSIndexPath).row]
    initializedOrDequeuedCell.textLabel?.attributedText = UiHelpers.letterPressedText(controllerLabels[(indexPath as NSIndexPath).row])
    return initializedOrDequeuedCell
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
    } else {
      performSegue(withIdentifier: panSegues[(indexPath as NSIndexPath).row], sender: self)
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let shimmerDivisor: CGFloat = 2.0
    let shimmerReducer: CGFloat = 10.0
    viewControllerTitle.alpha = 1.0 + sin(scrollView.contentOffset.y / shimmerDivisor) / shimmerReducer
  }
  
  @objc private func updateRunButton() {
    if RunModel.runModel.status == .preRun && controllerLabels[0] == MenuVC.resumeRunLabel {
      controllerLabels[0] = MenuVC.startRunLabel
    }
    else if RunModel.runModel.status != .preRun && controllerLabels[0] == MenuVC.startRunLabel {
      controllerLabels[0] = MenuVC.resumeRunLabel
    }
    DispatchQueue.main.async {
      self.menuTable.reloadData()
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pan log" {
      if let logVC = segue.destination as? LogVC {
        logVC.logType = logTypeToShow
      }
    }
    else if segue.identifier == "pan GPX run" {
      if let runVC = segue.destination as? RunVC {
        runVC.gpxFile = MenuVC.gpxFile
      }
    }
  }
  
  @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {}
  
  override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    return UnwindPanSegue(identifier: identifier ?? "", source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }
}
