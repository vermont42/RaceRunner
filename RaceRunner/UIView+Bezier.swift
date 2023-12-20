// Copyright © 2015 Knut Inge Grøsland. All rights reserved.

import UIKit

extension UIView {
  enum BezierPoints {
    static var p1 = CGPoint(x: -128, y: 0)
    static var p2 = CGPoint(x: 260, y: 374)
    static var p3 = CGPoint(x: -250, y: 168)
    static var p4 = CGPoint(x: 5, y: 480)
  }

  func updateBezierPointsIfNeeded(_ frame: CGRect) {
    if
      BezierPoints.p1 == CGPoint.zero
      && BezierPoints.p2 == CGPoint.zero
      && BezierPoints.p3 == CGPoint.zero
      && BezierPoints.p4 == CGPoint.zero
    {
      BezierPoints.p1 = CGPoint.zero
      BezierPoints.p2 = CGPoint(x: floor(frame.size.height / 3), y: floor(frame.size.height / 3))
      BezierPoints.p3 = CGPoint(x: floor(frame.size.height / 3), y: floor(frame.size.height / 2))
      BezierPoints.p4 = CGPoint(x: 40, y: frame.size.height)
    }
  }

  func bezierInterpolation(_ t: CGFloat, a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat) -> CGFloat {
    let t2: CGFloat = t * t
    let t3: CGFloat = t2 * t
    return a + (-a * 3 + t * (3 * a - a * t)) * t
    + (3 * b + t * (-6 * b + b * 3 * t)) * t
    + (c * 3 - c * 3 * t) * t2
    + d * t3
  }

  func bezierXFor(_ t: CGFloat) -> CGFloat {
    bezierInterpolation(t, a: BezierPoints.p1.x, b: BezierPoints.p2.x, c: BezierPoints.p3.x, d: BezierPoints.p4.x)
  }

  func bezierYFor(_ t: CGFloat) -> CGFloat {
    bezierInterpolation(t, a: BezierPoints.p1.y, b: BezierPoints.p2.y, c: BezierPoints.p3.y, d: BezierPoints.p4.y)
  }
}
