//
//  CalorieType.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/29/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

enum CalorieType: String {
    case Net = "Net"
    case Total = "Total"
    init() {
        self = .Total
    }
}
