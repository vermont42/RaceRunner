//
//  ChildVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class ChildVC: UIViewController {
  override var prefersStatusBarHidden: Bool {
    return true
  }

  override func viewDidLoad() {
    setupSwipeGestureRecognizer()
  }
  
  override func didReceiveMemoryWarning() {
    LowMemoryHandler.handleLowMemory(self)
  }
  
  func setupSwipeGestureRecognizer() {
    let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ChildVC.showMenu))
    swipeGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.right
    self.view.addGestureRecognizer(swipeGestureRecognizer)
  }
  
  @objc func showMenu() {
    self.performSegue(withIdentifier: "unwind pan", sender: self)
  }
}
