//
//  HelpVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class HelpVC: ChildVC {
  @IBOutlet var viewControllerTitle: UILabel!
  
  @IBAction func showMenu(sender: UIButton) {
    showMenu()
  }
  
  override func viewDidLoad() {
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    super.viewDidLoad()
  }
}