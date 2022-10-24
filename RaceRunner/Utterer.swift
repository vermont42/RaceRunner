//
//  Utterer.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/6/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import AVFoundation
import Foundation

enum Utterer {
  private static let synth = AVSpeechSynthesizer()
  private static let rate: Float = 0.5
  private static let pitchMultiplier: Float = 0.8

  static func utter(_ thingToUtter: String) {
    let utterance = AVSpeechUtterance(string: thingToUtter)
    utterance.rate = Utterer.rate
    utterance.voice = AVSpeechSynthesisVoice(language: "en-\(SettingsManager.getAccent().languageCode)")
    utterance.pitchMultiplier = Utterer.pitchMultiplier
    synth.speak(utterance)
    SoundManager.play(.silence) // https://forums.developer.apple.com/thread/23160
  }
}
