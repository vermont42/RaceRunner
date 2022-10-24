//
//  ArrayExtension.swift
//  RaceRunner
//
//  Created by Josh Adams on 12/10/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

extension Array {
  func insertionIndexOf(_ elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
    var lo = 0
    var hi = self.count - 1
    while lo <= hi {
      let mid = (lo + hi) / 2
      if isOrderedBefore(self[mid], elem) {
        lo = mid + 1
      } else if isOrderedBefore(elem, self[mid]) {
        hi = mid - 1
      } else {
        return mid
      }
    }
    return lo
  }
}
