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
  private static let stride: CGFloat = 3.0
  private static let chartOffset: CGFloat = 37.0
  private static let speedOffset: CGFloat = 2.0
  private static let lineWidth: CGFloat = 4.0
  private static let dashedLineWidth: CGFloat = 1.0
  private static let speedAlpha: CGFloat = 0.70
  private static let dashAlpha: CGFloat = 0.2
  private static let firstDashLength: CGFloat = 4.0
  private static let secondDashLength: CGFloat = 2.0
  private static let ticLength: CGFloat = 4.0
  private static let labelYOffset: CGFloat = 8.0
  private static let altLabelXOffset: CGFloat = 32.0
  private static let paceLabelXOffset: CGFloat = 6.0
  private static let timeLabelYOffset: CGFloat = 4.0
  private static let timeLabelXOffset: CGFloat = 12.0
  private static let shortTics: Int = 4
  private static let longTics: Int = 7
  
  private enum Orientation {
    case Landscape
    case Portrait
  }
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)    
    if let run = run {
      let orientation: Orientation
      let chartHeight = bounds.size.height - 2 * GraphView.chartOffset
      let chartWidth = bounds.size.width - 2 * GraphView.chartOffset
      if chartHeight > chartWidth {
        orientation = .Portrait
      }
      else {
        orientation = .Landscape
      }
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
      let xTics = orientation == .Landscape ? GraphView.longTics : GraphView.shortTics
      let ticPath = UIBezierPath()
      ticPath.lineWidth = GraphView.lineWidth
      let chunkWidth = chartWidth / CGFloat((xTics + 1))
      let start = (run.locations[0] as! Location).timestamp
      let end = (run.locations.lastObject as! Location).timestamp
      let span = end.timeIntervalSinceDate(start)
      let timeChunk = Int(span) / (xTics + 1)
      for var x = 0; x < xTics; x++ {
        UiConstants.darkColor.setStroke()
        ticPath.moveToPoint(CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth), y: GraphView.chartOffset + chartHeight))
        ticPath.addLineToPoint(CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth), y: GraphView.chartOffset + chartHeight + GraphView.ticLength))
        ticPath.stroke()
        let dashedPath = UIBezierPath()
        UiConstants.lightColor.colorWithAlphaComponent(GraphView.dashAlpha).setStroke()
        dashedPath.lineWidth = GraphView.dashedLineWidth
        let dashes = [GraphView.firstDashLength, GraphView.secondDashLength]
        dashedPath.setLineDash(dashes, count: dashes.count, phase: 0)
        dashedPath.moveToPoint(CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth), y: GraphView.chartOffset + chartHeight))
        dashedPath.addLineToPoint(CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth), y: GraphView.chartOffset))
        dashedPath.stroke()
        let time = Converter.stringifySecondCount((x * timeChunk) + timeChunk, useLongFormat: false)
        time.drawAtPoint(CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth) - GraphView.timeLabelXOffset, y: GraphView.chartOffset + chartHeight + GraphView.timeLabelYOffset), withAttributes: [NSForegroundColorAttributeName: UiConstants.lightColor])
      }
      let yTics = orientation == .Landscape ? GraphView.shortTics : GraphView.longTics
      let chunkHeight = chartHeight / CGFloat((yTics + 1))
      let altChunkSpan = (run.maxAltitude.doubleValue - run.minAltitude.doubleValue) / Double(yTics + 1)
      let paceChunkSpan = (maxSmoothSpeed - minSmoothSpeed) / Double(yTics)
      for var y = 0; y < yTics + 2; y++ {
        if overlay == .Both || overlay == .Altitude {
          UiConstants.darkColor.setStroke()
          ticPath.moveToPoint(CGPoint(x: GraphView.chartOffset, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
          ticPath.addLineToPoint(CGPoint(x: GraphView.chartOffset - GraphView.ticLength, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
          ticPath.stroke()
          let labelX = GraphView.chartOffset - GraphView.altLabelXOffset
          let labelY = GraphView.chartOffset + (CGFloat(y) * chunkHeight) - GraphView.labelYOffset
          let label = Converter.stringifyAltitude(run.maxAltitude.doubleValue - ((Double(y) * altChunkSpan)), unabbreviated: true, includeUnit: false)
          label.drawAtPoint(CGPoint(x: labelX, y: labelY), withAttributes: [NSForegroundColorAttributeName: UiConstants.intermediate3Color])
        }
        if overlay == .Both || overlay == .Pace {
          UiConstants.darkColor.setStroke()
          ticPath.moveToPoint(CGPoint(x: GraphView.chartOffset + chartWidth, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
          ticPath.addLineToPoint(CGPoint(x: GraphView.chartOffset + chartWidth + GraphView.ticLength, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
          ticPath.stroke()
          let labelX = GraphView.chartOffset + chartWidth + GraphView.paceLabelXOffset
          let labelY = GraphView.chartOffset + (CGFloat(y) * chunkHeight) - GraphView.labelYOffset
          let pace = maxSmoothSpeed - (Double(y) * paceChunkSpan)
          let label = Converter.stringifyPace(pace, seconds: 1, forSpeaking: false, includeUnit: false)
          label.drawAtPoint(CGPoint(x: labelX, y: labelY), withAttributes: [NSForegroundColorAttributeName: UiConstants.intermediate1Color])
        }
        let dashedPath = UIBezierPath()
        UiConstants.lightColor.colorWithAlphaComponent(GraphView.dashAlpha).setStroke()
        dashedPath.lineWidth = GraphView.dashedLineWidth
        let dashes = [GraphView.firstDashLength, GraphView.secondDashLength]
        dashedPath.setLineDash(dashes, count: dashes.count, phase: 0)
        dashedPath.moveToPoint(CGPoint(x: GraphView.chartOffset, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
        dashedPath.addLineToPoint(CGPoint(x: GraphView.chartOffset + chartWidth, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
        dashedPath.stroke()
      }
    }
  }
  
  private func xToIndex(x: Int) -> Int {
    return Int(CGFloat(smoothSpeeds.count) * (CGFloat(x) / (self.bounds.size.width - 2 * GraphView.chartOffset)))
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
