//
//  RunnerIcons.swift
//  RaceRunner
//
//  Created by Joshua Adams on 4/17/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

class RunnerIcons {
  enum Direction {
    case stationary
    case west
    case east
  }
  
  enum IconType: String {
    case Human = "Human"
    case Horse = "Horse"
    
    init() {
      self = .Human
    }
  }
  
  private let stationaryIcon = UIImage(named: "stationary.png")!
  private let westIcons = [UIImage(named: "west1.png")!, UIImage(named: "west2.png")!, UIImage(named: "west3.png")!, UIImage(named: "west4.png")!, UIImage(named: "west5.png")!, UIImage(named: "west6.png")!, UIImage(named: "west7.png")!, UIImage(named: "west8.png")!, UIImage(named: "west9.png")!, UIImage(named: "west10.png")!]
  private let eastIcons = [UIImage(named: "east1.png")!, UIImage(named: "east2.png")!, UIImage(named: "east3.png")!, UIImage(named: "east4.png")!, UIImage(named: "east5.png")!, UIImage(named: "east6.png")!, UIImage(named: "east7.png")!, UIImage(named: "east8.png")!, UIImage(named: "east9.png")!, UIImage(named: "east10.png")!]
  private let stationaryHorseIcon = UIImage(named: "stationaryHorse.png")!
  private let westHorseIcons = [UIImage(named: "west1Horse.png")!, UIImage(named: "west2Horse.png")!, UIImage(named: "west3Horse.png")!, UIImage(named: "west4Horse.png")!, UIImage(named: "west5Horse.png")!, UIImage(named: "west6Horse.png")!, UIImage(named: "west7Horse.png")!, UIImage(named: "west8Horse.png")!, UIImage(named: "west9Horse.png")!, UIImage(named: "west10Horse.png")!, UIImage(named: "west11Horse.png")!]
  private let eastHorseIcons = [UIImage(named: "east1Horse.png")!, UIImage(named: "east2Horse.png")!, UIImage(named: "east3Horse.png")!, UIImage(named: "east4Horse.png")!, UIImage(named: "east5Horse.png")!, UIImage(named: "east6Horse.png")!, UIImage(named: "east7Horse.png")!, UIImage(named: "east8Horse.png")!, UIImage(named: "east9Horse.png")!, UIImage(named: "east10Horse.png")!, UIImage(named: "east11Horse.png")!]
  var currentIndex: Int = 0
  var direction: Direction = .stationary {
    willSet {
      if newValue == .stationary {
        currentIndex = 0
      }
    }
  }
      
  func nextIcon() -> UIImage {
    let iconType = SettingsManager.getIconType()
    switch direction {
    case .stationary:
      if iconType == IconType.Human {
        return stationaryIcon
      }
      else {
        return stationaryHorseIcon
      }
    case .west:
      let westIcon: UIImage
      if iconType == IconType.Human {
        if currentIndex > westIcons.count - 1 {
          currentIndex = westIcons.count - 1
        }
        westIcon = westIcons[currentIndex]
        if currentIndex == westIcons.count - 1 {
          currentIndex = 0
        }
        else {
          currentIndex += 1
        }
      }
      else {
        if currentIndex > westHorseIcons.count - 1 {
          currentIndex = westHorseIcons.count - 1
        }
        westIcon = westHorseIcons[currentIndex]
        if currentIndex == westHorseIcons.count - 1 {
          currentIndex = 0
        }
        else {
          currentIndex += 1
        }
      }
      return westIcon
    case .east:
      let eastIcon: UIImage
      if iconType == IconType.Human {
        if currentIndex > eastIcons.count - 1 {
          currentIndex = eastIcons.count - 1
        }
        eastIcon = eastIcons[currentIndex]
        if currentIndex == eastIcons.count - 1 {
          currentIndex = 0
        }
        else {
          currentIndex += 1
        }
      }
      else {
        if currentIndex > eastHorseIcons.count - 1 {
          currentIndex = eastHorseIcons.count - 1
        }
        eastIcon = eastHorseIcons[currentIndex]
        if currentIndex == eastHorseIcons.count - 1 {
          currentIndex = 0
        }
        else {
          currentIndex += 1
        }
      }
      return eastIcon
    }
  }
}
