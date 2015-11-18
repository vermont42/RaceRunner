//
//  SoundManager.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/18/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation
import AVFoundation.AVAudioPlayer
import AVFoundation.AVAudioSession

class SoundManager {
    private static let soundManager = SoundManager()
    private var sounds: [String: AVAudioPlayer]
    
    private init () {
        sounds = Dictionary()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
    }
    
    static func play(sound: String) {
        if soundManager.sounds[sound] == nil {
            if let audioUrl = NSBundle.mainBundle().URLForResource(sound, withExtension: "wav") {
                do {
                    try soundManager.sounds[sound] = AVAudioPlayer.init(contentsOfURL: audioUrl)
                } catch let error as NSError {
                    print("\(error.localizedDescription)")
                }
            }

        }
        soundManager.sounds[sound]?.play()
    }
}
