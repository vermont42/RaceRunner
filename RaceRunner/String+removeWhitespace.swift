//
//  String+removeWhitespace.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

extension String {
  var stringByRemovingWhitespace: String {
    return components(separatedBy: .whitespaces).joined(separator: "")
  }
}
