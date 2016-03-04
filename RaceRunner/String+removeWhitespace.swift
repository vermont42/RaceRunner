//
//  String+removeWhitespace.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

extension String {
  func replace(string:String, replacement:String) -> String {
    return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
  }
  
  func removeWhitespace() -> String {
    return self.replace(" ", replacement: "")
  }
}
