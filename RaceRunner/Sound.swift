//
//  Sound.swift
//  RaceRunner
//
//  Created by Josh Adams on 4/9/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation

enum Sound: String {
  case applause1 = "applause1"
  case applause2 = "applause2"
  case applause3 = "applause3"
  case click = "click"
  case gun1 = "gun1"
  case gun2 = "gun2"
  case neigh = "neigh"
  case sadTrombone = "sadTrombone"
  case scream1 = "scream1"
  case scream2 = "scream2"
  case scream3 = "scream3"
  case silence = "silence"

  static var randomScream: Sound {
    return randomSound(base: "scream", count: 3, defaultSound: .scream1)
  }

  static var randomApplause: Sound {
    return randomSound(base: "applause", count: 3, defaultSound: .applause1)
  }

  private static func randomSound(base: String, count: Int, defaultSound: Sound) -> Sound {
    let randomIndex = Int.random(in: 1 ... count)
    return Sound(rawValue: base + "\(randomIndex)") ?? defaultSound
  }
}
