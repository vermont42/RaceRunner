//
//  SortType.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

enum SortType: String {
  case Normal = "Normal"
  case Reverse = "Reverse"
  
  static func reverse(sortType: SortType) -> SortType {
    if sortType == .Normal {
      return .Reverse
    }
    else {
      return .Normal
    }
  }
  
  init() {
    self = .Normal
  }
}