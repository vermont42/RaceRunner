//
//  GameVC.swift
//  RaceRunner
//
//  Created by Josh Adams on 6/6/16.
//  Copyright (c) 2016 Josh Adams. All rights reserved.
//

import UIKit
import SpriteKit

class GameVC: ChildVC {
  private static let lowMemoryTitle = "Ended Game"
  private static let lowMemoryMessage = "RaceRunner had to end your game because of a RAM shortage on your iPhone. Apologies."

  override var shouldAutorotate: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let skView = self.view as! SKView
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.ignoresSiblingOrder = true
    let scene = GameScene(size: skView.frame.size)
    skView.presentScene(scene)
    NotificationCenter.default.addObserver(self, selector: #selector(GameVC.handleApplicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(GameVC.handleApplicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
