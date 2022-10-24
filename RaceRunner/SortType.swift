//
//  SortType.swift
//  RaceRunner
//
//  Created by Josh Adams on 1/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

enum SortType: String {
  case normal = "Normal"
  case reverse = "Reverse"

  static func reverseSortType(_ sortType: SortType) -> SortType {
    if sortType == .normal {
      return .reverse
    } else {
      return .normal
    }
  }

  init() {
    self = .normal
  }
}
