//
//  GpxActivityItemProvider.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/30/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

class GpxActivityItemProvider: UIActivityItemProvider {
  override var item : Any {
    // The following approach would be appropriate for a gpx file in the main bundle.
    //
    if let filePath = Bundle.main.path(forResource: "Runmeter", ofType: "gpx") {
      if let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
        return fileData as AnyObject
      }
    }
    return NSString(string: "error")
  }
  
  override func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivityType?) -> String {
    return "com.topografix.gpx"
  }
  
  override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
    return "run recorded by Runmeter"
  }
}
