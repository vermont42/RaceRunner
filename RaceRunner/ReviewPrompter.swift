//
//  ReviewPrompter.swift
//  Conjugar
//
//  Created by Josh Adams on 1/5/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation
import StoreKit

enum ReviewPrompter {
  private static let promptModulo = 3
  private static let promptInterval: TimeInterval = 60 /* seconds */ * 60 /* minutes */ * 24 /* hours */ * 180 /* days */

  static func promptableActionHappened() {
    var actionCount = SettingsManager.getPromptActionCount()
    actionCount += 1
    SettingsManager.setPromptActionCount(actionCount)
    let lastReviewPromptDate = SettingsManager.getLastReviewPromptDate()
    let now = Date()
    if actionCount % promptModulo == 0 && now.timeIntervalSince(lastReviewPromptDate) >= promptInterval {
      #if RELEASE
      if let scene = UIApplication.shared.connectedScenes.first(
        where: { $0.activationState == .foregroundActive }
      ) as? UIWindowScene {
        DispatchQueue.main.async {
          SKStoreReviewController.requestReview(in: scene)
        }
      }
      #endif
      SettingsManager.setLastReviewPromptDate(now)
    }
  }
}
