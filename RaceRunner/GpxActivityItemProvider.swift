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
    override func item() -> AnyObject {
        // The following approach would be appropriate for a gpx file in the main bundle.
        //
        if let filePath = NSBundle.mainBundle().pathForResource("Runmeter", ofType: "gpx") {
            if let fileData = NSData(contentsOfFile: filePath) {
                return fileData
            }
        }
        return NSString(string: "error")
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: String?) -> String {
        return "com.topografix.gpx"
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return "run recorded by Runmeter"
    }
}