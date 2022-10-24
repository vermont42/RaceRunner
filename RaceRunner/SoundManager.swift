//
//  SoundManager.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/18/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import AVFoundation
import Foundation

class SoundManager {
  private static let soundManager = SoundManager()
  private static let soundExtension = "mp3"

  private var sounds: [String: AVAudioPlayer] = [:]

  private init () {}

  static func play(_ sound: Sound) {
    if soundManager.sounds[sound.rawValue] == nil {
      if let audioUrl = Bundle.main.url(forResource: sound.rawValue, withExtension: soundExtension) {
        do {
          try soundManager.sounds[sound.rawValue] = AVAudioPlayer.init(contentsOf: audioUrl)
        } catch let error as NSError {
          print("\(error.localizedDescription)")
        }
      }
    }

    soundManager.sounds[sound.rawValue]?.play()
  }

  static func enableBackgroundAudio() {
    let session = AVAudioSession.sharedInstance()

    do {
      try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
      try session.setActive(true)
    } catch let error as NSError {
      print("\(error.localizedDescription)")
    }
  }
}
