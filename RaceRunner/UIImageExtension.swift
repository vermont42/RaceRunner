//
//  UIImageExtension.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/4/18.
//

import UIKit

extension UIImage {
  static func named(_ name: String) -> UIImage {
    if let image = UIImage(named: name) {
      return image
    } else {
      fatalError("Could not initialize \(UIImage.self) named \(name).")
    }
  }
}
