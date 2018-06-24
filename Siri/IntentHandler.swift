//
//  IntentHandler.swift
//  Siri
//
//  Created by Joshua Adams on 5/20/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Intents

class IntentHandler: INExtension, INStartWorkoutIntentHandling, INEndWorkoutIntentHandling, INPauseWorkoutIntentHandling, INResumeWorkoutIntentHandling {
  func handle(intent: INPauseWorkoutIntent, completion: @escaping (INPauseWorkoutIntentResponse) -> Void) {
    completion(INPauseWorkoutIntentResponse(code: .handleInApp, userActivity: nil))
  }

  func handle(intent: INResumeWorkoutIntent, completion: @escaping (INResumeWorkoutIntentResponse) -> Void) {
    completion(INResumeWorkoutIntentResponse(code: .handleInApp, userActivity: nil))
  }

  func handle(intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
    completion(INStartWorkoutIntentResponse(code: .handleInApp, userActivity: nil))
  }

  func handle(intent: INEndWorkoutIntent, completion: @escaping (INEndWorkoutIntentResponse) -> Void) {
    completion(INEndWorkoutIntentResponse(code: .handleInApp, userActivity: nil))
  }
}
