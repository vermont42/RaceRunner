//
//  IntentHandler.swift
//  RaceRunner
//
//  Created by Josh Adams on 5/23/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation
import Intents

enum IntentHandler {
  static func handle(intent: INIntent) -> INIntentResponse {
    let response: INIntentResponse
    SoundManager.enableBackgroundAudio()

    if (intent as? INStartWorkoutIntent) != nil {
      if !RunModel.gpsIsAvailable() {
        response = INStartWorkoutIntentResponse(code: .failure, userActivity: nil)
      } else if RunModel.runModel.status == .inProgress || RunModel.runModel.status == .paused {
        response = INStartWorkoutIntentResponse(code: .failureOngoingWorkout, userActivity: nil)
      } else {
        RunModel.initializeRunModel()
        RunModel.runModel.start(isViaSiri: true)
        PersistentMapState.initMapState()
        response = INStartWorkoutIntentResponse(code: .success, userActivity: nil)
      }
    } else if (intent as? INPauseWorkoutIntent) != nil {
      switch RunModel.runModel.status {
      case .preRun, .paused:
        response = INPauseWorkoutIntentResponse(code: .failure, userActivity: nil)
      case .inProgress:
        RunModel.runModel.pause()
        response = INPauseWorkoutIntentResponse(code: .success, userActivity: nil)
      }
    } else if (intent as? INResumeWorkoutIntent) != nil {
      switch RunModel.runModel.status {
      case .preRun, .inProgress:
        response = INResumeWorkoutIntentResponse(code: .failure, userActivity: nil)
      case .paused:
        RunModel.runModel.resume()
        response = INResumeWorkoutIntentResponse(code: .success, userActivity: nil)
      }
    } else if (intent as? INEndWorkoutIntent) != nil {
      switch RunModel.runModel.status {
      case .preRun:
        response = INPauseWorkoutIntentResponse(code: .failure, userActivity: nil)
      case .inProgress, .paused:
        RunModel.runModel.stop()
        response = INPauseWorkoutIntentResponse(code: .success, userActivity: nil)
      }
    } else {
      response = INStartWorkoutIntentResponse(code: .failure, userActivity: nil)
    }
    return response
  }
}
