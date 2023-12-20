// Copyright © 2015 Knut Inge Grøsland. All rights reserved.

import UIKit

class BezierTableView: UITableView {
  open override func layoutSubviews() {
    super.layoutSubviews()
    updateBezierPointsIfNeeded(bounds)
    layoutVisibleCells()
  }

  func layoutVisibleCells() {
    guard let indexPathsForVisibleRows else {
      return
    }

    let totalVisibleCells = indexPathsForVisibleRows.count - 1
    if totalVisibleCells <= 0 {
      return
    }

    for index in 0...totalVisibleCells {
      let indexPath = indexPathsForVisibleRows[index]
      if let cell = cellForRow(at: indexPath) {
        var frame = cell.frame

        if let superview {
          let point = convert(frame.origin, to: superview)
          let pointScale = point.y / CGFloat(superview.bounds.size.height)
          frame.origin.x = bezierXFor(pointScale)
        }
        cell.frame = frame
      }
    }
  }
}
