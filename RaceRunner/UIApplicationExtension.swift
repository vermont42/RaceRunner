//
//  UIApplicationExtension.swift
//  RaceRunner
//
//  Created by Josh Adams on 1/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit

extension UIApplication {
  class func topViewController(_ base: UIViewController? = UIApplication.shared.compatibilityWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(presented)
    }
    return base
  }
}

extension UIApplication { // https://stackoverflow.com/a/57169802/8248798
  var compatibilityWindow: UIWindow? {
    UIApplication.shared.connectedScenes
    .filter({ $0.activationState == .foregroundActive })
    .map({ $0 as? UIWindowScene })
    .compactMap({ $0 })
    .first?.windows
    .filter({ $0.isKeyWindow }).first
  }
}
