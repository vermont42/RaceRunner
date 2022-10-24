//
//  GpxActivityItemProvider.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/30/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import UIKit

class GpxActivityItemProvider: UIActivityItemProvider {
  override var item: Any {
    // The following approach would be appropriate for a gpx file in the main bundle.
    let runmeter = "Runmeter"
    let gpx = "gpx"
    if let filePath = Bundle.main.path(forResource: runmeter, ofType: gpx) {
      if let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
        return fileData as AnyObject
      }
    }
    let error = "error"
    return NSString(string: error)
  }

  override func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
    let dataTypeIdentifier = "com.topografix.gpx"
    return dataTypeIdentifier
  }

  override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
    let subject = "run recorded by Runmeter"
    return subject
  }
}
