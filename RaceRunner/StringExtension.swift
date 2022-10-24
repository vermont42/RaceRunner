//
//  StringExtension.swift
//  RaceRunner
//
//  Created by Josh Adams on 3/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

extension String {
  var stringByRemovingWhitespace: String {
    return components(separatedBy: .whitespaces).joined(separator: "")
  }
}
