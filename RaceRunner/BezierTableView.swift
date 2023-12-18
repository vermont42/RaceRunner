// Copyright © 2015 Knut Inge Grøsland. All rights reserved.

import UIKit

class BezierTableView: UITableView {
  open override func layoutSubviews() {
    super.layoutSubviews()
    updateBezierPointsIfNeeded(bounds)
    layoutVisibleCells()
  }

  func layoutVisibleCells() {
    guard let indexpaths = indexPathsForVisibleRows else {
      return
    }

    let totalVisibleCells = indexpaths.count - 1
    if totalVisibleCells <= 0 {
      return
    }

    for index in 0...totalVisibleCells {
      let indexPath = indexpaths[index]
      if let cell = cellForRow(at: indexPath) {
        var frame = cell.frame

        if let superView = superview {
          let point = convert(frame.origin, to: superView)
          let pointScale = point.y / CGFloat(superView.bounds.size.height)
          frame.origin.x = bezierXFor(pointScale)
        }
        cell.frame = frame
      }
    }
  }
}
