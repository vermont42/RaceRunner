//
//  GraphView.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import CoreGraphics

// Watch video about Coco and Lucky, the cat and cockatiel.
class GraphView: UIView {
  var run: Run?
  var smoothSpeeds: [Double]!
  var maxSmoothSpeed: Double!
  var minSmoothSpeed: Double!
  private static let minAltRange = 5.0
  private static let minSpeedRange = 0.1
  private static let altitudePoints = 50
  private static let stride: CGFloat = 2.0
  private static let chartOffset: CGFloat = 20.0
  private static let speedOffset: CGFloat = 2.0
  private static let lineWidth: CGFloat = 4.0
  private static let speedAlpha: CGFloat = 0.85
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    print("\(SettingsManager.getOverlay())")
    
    if let run = run {
      let chartHeight = bounds.size.height - 2 * GraphView.chartOffset
      let chartWidth = bounds.size.width - 2 * GraphView.chartOffset
      let xAxisPath = UIBezierPath()
      xAxisPath.moveToPoint(CGPoint(x: GraphView.chartOffset, y: chartHeight + GraphView.chartOffset))
      xAxisPath.addLineToPoint(CGPoint(x: GraphView.chartOffset + chartWidth, y: chartHeight + GraphView.chartOffset))
      UiConstants.darkColor.setStroke()
      xAxisPath.lineWidth = GraphView.lineWidth
      xAxisPath.stroke()

      let overlay = SettingsManager.getOverlay()
      if overlay == .Both || overlay == .Altitude {
        let yAxisPath = UIBezierPath()
        yAxisPath.moveToPoint(CGPoint(x: GraphView.chartOffset, y: GraphView.chartOffset))
        yAxisPath.addLineToPoint(CGPoint(x: GraphView.chartOffset, y: chartHeight + GraphView.chartOffset))
        UiConstants.darkColor.setStroke()
        yAxisPath.lineWidth = GraphView.lineWidth
        yAxisPath.stroke()
        drawGraph(color: UiConstants.intermediate3Color, maxVal: run.maxAltitude.doubleValue, minVal: run.minAltitude.doubleValue, minRange: GraphView.minAltRange, getVal: { (x: Int) -> Double in
          return (run.locations[self.xToIndex(x)] as! Location).altitude.doubleValue
        })
      }
      if overlay == .Both || overlay == .Pace {
        let yAxisPath = UIBezierPath()
        yAxisPath.moveToPoint(CGPoint(x: GraphView.chartOffset + chartWidth, y: GraphView.chartOffset))
        yAxisPath.addLineToPoint(CGPoint(x: GraphView.chartOffset + chartWidth, y: chartHeight + GraphView.chartOffset))
        UiConstants.darkColor.setStroke()
        yAxisPath.lineWidth = GraphView.lineWidth
        yAxisPath.stroke()
        drawGraph(color: UiConstants.intermediate1Color.colorWithAlphaComponent(GraphView.speedAlpha), maxVal: maxSmoothSpeed, minVal: minSmoothSpeed, minRange: GraphView.minSpeedRange, getVal: { (x: Int) -> Double in
          return self.smoothSpeeds[self.xToIndex(x)]
        })
      }
    }
  }
  
  private func xToIndex(x: Int) -> Int {
    return Int(CGFloat(run!.locations.count) * (CGFloat(x) / (self.bounds.size.width - 2 * GraphView.chartOffset)))
  }
  
  private func drawGraph(color color: UIColor, maxVal: Double, minVal: Double, minRange: Double, getVal: (x: Int) -> Double) {
    let path = UIBezierPath()
    let width = bounds.size.width
    let height = bounds.size.height
    let chartHeight = height - 2 * GraphView.chartOffset
    let chartWidth = width - 2 * GraphView.chartOffset
    let valRange = maxVal - minVal
    if valRange < minRange {
      path.moveToPoint(CGPoint(x: GraphView.chartOffset, y: height / 2))
      path.addLineToPoint(CGPoint(x: width - GraphView.chartOffset, y: height / 2))
    }
    else {
      let firstVal = getVal(x: 0)
      let zeroBasedFirstVal = firstVal - minVal
      let firstY = GraphView.chartOffset + chartHeight - (chartHeight * CGFloat((zeroBasedFirstVal / valRange)))
      path.moveToPoint(CGPoint(x: GraphView.chartOffset, y: firstY))
      for var x: CGFloat = GraphView.stride; x < chartWidth; x += GraphView.stride {
        let curVal = getVal(x: Int(x))
        let zeroBasedCurVal = curVal - minVal
        let curY = GraphView.chartOffset + chartHeight - (chartHeight * CGFloat((zeroBasedCurVal / valRange)))
        path.addLineToPoint(CGPoint(x: x + GraphView.chartOffset, y: curY))
      }
    }
    color.setStroke()
    path.lineWidth = GraphView.lineWidth
    path.stroke()
  }
}

