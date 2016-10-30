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
  fileprivate static let lowMemoryTitle = "Ended Game"
  fileprivate static let lowMemoryMessage = "RaceRunner had to end your game because of a RAM shortage on your iPhone. Apologies."
  
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
  
  @IBAction func showMenu(_ sender: UIButton) {
    showMenu()
  }
  
  override var shouldAutorotate : Bool {
    return true
  }
  
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    pauseGame()
    showMenu()
  }
  
  func handleApplicationWillResignActive (_ note: Notification) {
    pauseGame()
  }
  
  func handleApplicationDidBecomeActive (_ note: Notification) {
    let skView = view as! SKView
    skView.isPaused = false
  }
  
  fileprivate func pauseGame() {
    let skView = view as! SKView
    skView.isPaused = true
  }
}
