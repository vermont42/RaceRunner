//
//  PanSegue.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//
//  This code is adapted from http://www.appcoda.com/custom-segue-animations/ .

import UIKit

class PanSegue: UIStoryboardSegue {
  override func perform() {
    let firstVCView = self.source.view as UIView
    let secondVCView = self.destination.view as UIView
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    secondVCView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
    // The following line, if uncommented, may induce motion sickness.
    // secondVCView.transform = CGAffineTransformRotate(secondVCView.transform, CGFloat(M_PI))

    let window = UIApplication.shared.compatibilityWindow

    if
      let viewWillAppear = class_getInstanceMethod(destination.classForCoder, #selector(UIViewController.viewWillAppear)),
      let noop = class_getInstanceMethod(UIViewController.classForCoder(), #selector(UIViewController.viewWillAppearNoOp)) {
      // Swizzle to avoid spurious call to viewWillAppear().
      method_exchangeImplementations(viewWillAppear, noop)
      window?.insertSubview(secondVCView, aboveSubview: firstVCView)
      // Unswizzle.
      method_exchangeImplementations(noop, viewWillAppear)
      UIView.animate(
        withDuration: UIConstants.panDuration,
        animations: { () -> Void in
          firstVCView.frame = firstVCView.frame.offsetBy(dx: -screenWidth, dy: 0)
          secondVCView.frame = secondVCView.frame.offsetBy(dx: -screenWidth, dy: 0)
        },
        completion: { _ in
          self.destination.modalPresentationStyle = .fullScreen
          self.source.present(self.destination, animated: false, completion: nil)
        }
      )
    }
  }
}
