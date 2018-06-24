//
//  IntentHandler.swift
//  RaceRunner
//
//  Created by Joshua Adams on 5/23/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation
import Intents

struct IntentHandler {
  static func handle(intent: INIntent) -> INIntentResponse {
    let response: INIntentResponse
    SoundManager.enableBackgroundAudio()

    if let _ = intent as? INStartWorkoutIntent {
      if !RunModel.gpsIsAvailable() {
        response = INStartWorkoutIntentResponse(code: .failure, userActivity: nil)
      }
      else if RunModel.runModel.status == .inProgress || RunModel.runModel.status == .paused {
        response = INStartWorkoutIntentResponse(code: .failureOngoingWorkout, userActivity: nil)
      }
      else {
        RunModel.initializeRunModel()
        RunModel.runModel.start(isViaSiri: true)
        PersistentMapState.initMapState()
        response = INStartWorkoutIntentResponse(code: .success, userActivity: nil)
      }
    }
    else if let _ = intent as? INPauseWorkoutIntent {
      switch RunModel.runModel.status {
      case .preRun, .paused:
        response = INPauseWorkoutIntentResponse(code: .failure, userActivity: nil)
      case .inProgress:
        RunModel.runModel.pause()
        response = INPauseWorkoutIntentResponse(code: .success, userActivity: nil)
      }
    }
    else if let _ = intent as? INResumeWorkoutIntent {
      switch RunModel.runModel.status {
      case .preRun, .inProgress:
        response = INResumeWorkoutIntentResponse(code: .failure, userActivity: nil)
      case .paused:
        RunModel.runModel.resume()
        response = INResumeWorkoutIntentResponse(code: .success, userActivity: nil)
      }
    }
    else if let _ = intent as? INEndWorkoutIntent {
      switch RunModel.runModel.status {
      case .preRun:
        response = INPauseWorkoutIntentResponse(code: .failure, userActivity: nil)
      case .inProgress, .paused:
        RunModel.runModel.stop()
        response = INPauseWorkoutIntentResponse(code: .success, userActivity: nil)
      }
    }
    else {
      response = INStartWorkoutIntentResponse(code: .failure, userActivity: nil)
    }
    return response
  }
}
