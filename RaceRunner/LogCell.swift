//
//  LogCell.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/15/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {
  @IBOutlet var pace: UILabel!
  @IBOutlet var distance: UILabel!
  @IBOutlet var dateTime: UILabel!
  @IBOutlet var duration: UILabel!
  @IBOutlet var route: UILabel!
  
  func displayRun(run: Run) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateTime.text = dateFormatter.stringFromDate(run.timestamp)
    duration.text = Converter.stringifySecondCount(run.duration.integerValue, useLongFormat: false)
    pace.text = Converter.stringifyPace(run.distance.doubleValue, seconds: run.duration.integerValue)
    distance.text = Converter.stringifyDistance(run.distance.doubleValue)
    route.text = run.displayName()
  }
}
