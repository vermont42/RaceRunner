//
//  ReviewPrompter.swift
//  Conjugar
//
//  Created by Joshua Adams on 1/5/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation
import StoreKit

struct ReviewPrompter {
  private static let promptModulo = 3
  private static let promptInterval: TimeInterval = 60 /* seconds */ * 60 /* minutes */ * 24 /* hours */ * 180 /* days */

  internal static func promptableActionHappened() {
    var actionCount = SettingsManager.getPromptActionCount()
    actionCount += 1
    SettingsManager.setPromptActionCount(actionCount)
    let lastReviewPromptDate = SettingsManager.getLastReviewPromptDate()
    let now = Date()
    if actionCount % promptModulo == 0 && now.timeIntervalSince(lastReviewPromptDate) >= promptInterval {
      SKStoreReviewController.requestReview()
      SettingsManager.setLastReviewPromptDate(now)
    }
  }
}
