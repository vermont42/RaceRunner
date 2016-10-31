//
//  UIAlertController+showMessage.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit

extension UIAlertController {
  // See http://stackoverflow.com/a/39975404/2084036 for why this needs to be a class method rather than a class property.
  static func okTitle() -> String { return "OK" }
  
  class func showMessage(_ message: String, title: String, okTitle: String = UIAlertController.okTitle(), handler: ((UIAlertAction) -> Void)? = nil) {
    if let topController = UIApplication.topViewController() {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
      let okAction = UIAlertAction(title: okTitle, style: UIAlertActionStyle.default, handler: handler)
      alertController.addAction(okAction)
      alertController.view.tintColor = UiConstants.intermediate1Color
      topController.present(alertController, animated: true, completion: nil)
      alertController.view.tintColor = UiConstants.intermediate1Color
      // https://openradar.appspot.com/22209332
    }
  }
}
