//
//  SoundManager.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/18/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation
import AVFoundation.AVAudioPlayer
import AVFoundation.AVAudioSession

class SoundManager {
  // MARK: properties
  
  private static let soundManager = SoundManager()
  private var sounds: [String: AVAudioPlayer]
  private static let soundExtension = "mp3"
  
  // MARK: methods
  
  private init () {
    sounds = Dictionary()
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback) // was ambient
    } catch let error as NSError {
      print("\(error.localizedDescription)")
    }
  }
  
  static func play(sound: Sound) {
    if soundManager.sounds[sound.rawValue] == nil {
      if let audioUrl = NSBundle.mainBundle().URLForResource(sound.rawValue, withExtension: soundExtension) {
        do {
          try soundManager.sounds[sound.rawValue] = AVAudioPlayer.init(contentsOfURL: audioUrl)
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
      try session.setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
    }
    catch let error as NSError {
      print("\(error.localizedDescription)")
    }
  }
}
