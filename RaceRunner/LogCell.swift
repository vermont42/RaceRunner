//
//  LogCell.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/15/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {
  @IBOutlet var pace: UILabel!
  @IBOutlet var distance: UILabel!
  @IBOutlet var dateTime: UILabel!
  @IBOutlet var duration: UILabel!
  @IBOutlet var route: UILabel!

  func displayRun(_ run: Run) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.timeStyle = DateFormatter.Style.short
    dateTime.text = dateFormatter.string(from: run.timestamp as Date)
    duration.text = Converter.stringifySecondCount(run.duration.intValue, useLongFormat: false)
    pace.text = Converter.stringifyPace(run.distance.doubleValue, seconds: run.duration.intValue)
    distance.text = Converter.stringifyDistance(run.distance.doubleValue)
    route.text = run.displayName()
  }
}
