//
//  RunnerIcons.swift
//  RaceRunner
//
//  Created by Josh Adams on 4/17/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class RunnerIcons {
  static let runnerAvatar = "Runner"
  static let horseAvatar = "Horse"
  static let west = "west"
  static let east = "east"
  static let stationary = "stationary"
  static let runnerIconCount = 10
  static let horseIconCount = 11

  private let stationaryRunnerIcon: UIImage
  private let stationaryHorseIcon: UIImage
  private var westRunnerIcons: [UIImage] = []
  private var eastRunnerIcons: [UIImage] = []
  private var westHorseIcons: [UIImage] = []
  private var eastHorseIcons: [UIImage] = []

  var currentIndex: Int = 0
  var direction: Direction = .stationary {
    willSet {
      if newValue == .stationary {
        currentIndex = 0
      }
    }
  }

  enum Direction {
    case stationary
    case west
    case east
  }

  enum IconType: String {
    case human = "Human"
    case horse = "Horse"

    init() {
      self = .human
    }
  }

  init() {
    stationaryRunnerIcon = UIImage.named(RunnerIcons.stationary + RunnerIcons.runnerAvatar)
    stationaryHorseIcon = UIImage.named(RunnerIcons.stationary + RunnerIcons.horseAvatar)

    westRunnerIcons = iconArray(avatar: RunnerIcons.runnerAvatar, direction: RunnerIcons.west, count: RunnerIcons.runnerIconCount)
    eastRunnerIcons = iconArray(avatar: RunnerIcons.runnerAvatar, direction: RunnerIcons.east, count: RunnerIcons.runnerIconCount)

    westHorseIcons = iconArray(avatar: RunnerIcons.horseAvatar, direction: RunnerIcons.west, count: RunnerIcons.horseIconCount)
    eastHorseIcons = iconArray(avatar: RunnerIcons.horseAvatar, direction: RunnerIcons.east, count: RunnerIcons.horseIconCount)
  }

  private func iconArray(avatar: String, direction: String, count: Int) -> [UIImage] {
    var array: [UIImage] = []
    (1...count).forEach {
      array.append(UIImage.named(direction + "\($0)" + avatar))
    }
    return array
  }

  var nextIcon: UIImage {
    let iconType = SettingsManager.getIconType()
    switch direction {
    case .stationary:
      if iconType == IconType.human {
        return stationaryRunnerIcon
      } else {
        return stationaryHorseIcon
      }
    case .west:
      let westIcon: UIImage
      if iconType == IconType.human {
        if currentIndex > westRunnerIcons.count - 1 {
          currentIndex = westRunnerIcons.count - 1
        }
        westIcon = westRunnerIcons[currentIndex]
        if currentIndex == westRunnerIcons.count - 1 {
          currentIndex = 0
        } else {
          currentIndex += 1
        }
      } else {
        if currentIndex > westHorseIcons.count - 1 {
          currentIndex = westHorseIcons.count - 1
        }
        westIcon = westHorseIcons[currentIndex]
        if currentIndex == westHorseIcons.count - 1 {
          currentIndex = 0
        } else {
          currentIndex += 1
        }
      }
      return westIcon
    case .east:
      let eastIcon: UIImage
      if iconType == IconType.human {
        if currentIndex > eastRunnerIcons.count - 1 {
          currentIndex = eastRunnerIcons.count - 1
        }
        eastIcon = eastRunnerIcons[currentIndex]
        if currentIndex == eastRunnerIcons.count - 1 {
          currentIndex = 0
        } else {
          currentIndex += 1
        }
      } else {
        if currentIndex > eastHorseIcons.count - 1 {
          currentIndex = eastHorseIcons.count - 1
        }
        eastIcon = eastHorseIcons[currentIndex]
        if currentIndex == eastHorseIcons.count - 1 {
          currentIndex = 0
        } else {
          currentIndex += 1
        }
      }
      return eastIcon
    }
  }
}
