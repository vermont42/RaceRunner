//
//  GameVC.swift
//  RaceRunner
//
//  Created by Josh Adams on 6/6/16.
//  Copyright (c) 2016 Josh Adams. All rights reserved.
//

import SpriteKit
import UIKit

class GameVC: ChildVC {
  override var shouldAutorotate: Bool {
    true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    UIInterfaceOrientationMask.portrait
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let skView = self.view as! SKView
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.ignoresSiblingOrder = true
    let scene = GameScene(size: skView.frame.size)
    skView.presentScene(scene)
    NotificationCenter.default.addObserver(self, selector: #selector(GameVC.handleApplicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(GameVC.handleApplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AWSAnalyticsService.shared.recordVisitation(viewController: "\(GameVC.self)")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    pauseGame()
    showMenu()
  }

  @IBAction func showMenu(_ sender: UIButton) {
    showMenu()
  }

  @objc func handleApplicationWillResignActive (_ note: Notification) {
    pauseGame()
  }

  @objc func handleApplicationDidBecomeActive (_ note: Notification) {
    let skView = view as! SKView
    skView.isPaused = false
  }

  private func pauseGame() {
    let skView = view as! SKView
    skView.isPaused = true
  }
}
