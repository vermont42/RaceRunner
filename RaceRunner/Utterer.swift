//
//  Utterer.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/6/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation
import AVFoundation

class Utterer {
  private static let synth = AVSpeechSynthesizer()
  private static let rate: Float = 0.5
  private static let pitchMultiplier: Float = 0.8
  
  static func utter(thingToUtter: String) {
    let utterance = AVSpeechUtterance(string: thingToUtter)
    utterance.rate = Utterer.rate
    utterance.voice = AVSpeechSynthesisVoice(language: "en-\(SettingsManager.getAccent().languageCode())")
    utterance.pitchMultiplier = Utterer.pitchMultiplier
    synth.speakUtterance(utterance)
    SoundManager.play(.Silence) // https://forums.developer.apple.com/thread/23160
  }
}
