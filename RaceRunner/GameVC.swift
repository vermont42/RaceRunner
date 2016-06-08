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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let skView = self.view as! SKView
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.ignoresSiblingOrder = true
    let scene = GameScene(size: skView.frame.size)
    skView.presentScene(scene)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameVC.handleApplicationWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameVC.handleApplicationDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  @IBAction func showMenu(sender: UIButton) {
    showMenu()
  }
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    pauseGame()
    showMenu()
  }
  
  func handleApplicationWillResignActive (note: NSNotification) {
    pauseGame()
  }
  
  func handleApplicationDidBecomeActive (note: NSNotification) {
    let skView = view as! SKView
    skView.paused = false
  }
  
  private func pauseGame() {
    let skView = view as! SKView
    skView.paused = true
  }
}
