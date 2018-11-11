//
//  SoundManager.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/18/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
  private static let soundManager = SoundManager()
  private static let soundExtension = "mp3"

  private var sounds: [String: AVAudioPlayer]

  private init () {
    sounds = Dictionary()
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print(error.localizedDescription)
    }
  }
  
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

    // https://forums.swift.org/t/using-methods-marked-unavailable-in-swift-4-2/14949/7

//    do {
//      try session.setCategory(convertFromAVAudioSessionCategory(AVAudioSession.Category.playback), with: AVAudioSession.CategoryOptions.mixWithOthers)
//    }
//    catch let error as NSError {
//      print("\(error.localizedDescription)")
//    }
//  }

    do {
      try AVAudioSessionPatch.setSession(session, category: .playback, with: .mixWithOthers)
    }
    catch let error as NSError {
      print("\(error.localizedDescription)")
    }
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
