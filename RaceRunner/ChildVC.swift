//
//  ChildVC.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class ChildVC: UIViewController {
  override var prefersStatusBarHidden: Bool {
    true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSwipeGestureRecognizer()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    LowMemoryHandler.handleLowMemory()
  }

  func setupSwipeGestureRecognizer() {
    let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ChildVC.showMenu))
    swipeGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.right
    self.view.addGestureRecognizer(swipeGestureRecognizer)
  }

  @objc func showMenu() {
    self.performSegue(withIdentifier: "unwind pan", sender: self)
  }
}
