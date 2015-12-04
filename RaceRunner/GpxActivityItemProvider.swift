//
//  GpxActivityItemProvider.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/30/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

// credit http://aplus.rs/2014/how-to-properly-share-slash-export-gpx-files-on-ios/

class GpxActivityItemProvider: UIActivityItemProvider {
    override func item() -> AnyObject {
        //return "inset xml data here".dataUsingEncoding(NSUTF8StringEncoding)!
        
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
    
//    override func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
//        return "iSmoothRun.gpx"
//    }
}