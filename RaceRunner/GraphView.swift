//
//  GraphView.swift
//  RaceRunner
//
//  Created by Josh Adams on 2/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import CoreGraphics
import UIKit

// Watch video about Coco and Lucky, the cat and cockatiel.
class GraphView: UIView {
  var smoothSpeeds: [Double] = []
  var smoothAltitudes: [Double] = []
  var maxSmoothSpeed: Double = 0.0
  var minSmoothSpeed: Double = 0.0
  var timeSpan: Double?
  var distance: Double?
  var maxAltitude: Double?
  var minAltitude: Double?

  private static let minAltRange = 5.0
  private static let minSpeedRange = 0.1
  private static let stride: CGFloat = 1.0
  private static let chartOffset: CGFloat = 37.0
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
  private static let distLabelXOffset: CGFloat = 8.0
  private static let distLabelYOffset: CGFloat = 20.0
  private static let shortTics: Int = 4
  private static let longTics: Int = 7

  private enum Orientation {
    case landscape
    case portrait
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard
      let timeSpan = timeSpan,
      let distance = distance,
      let maxAltitude = maxAltitude,
      let minAltitude = minAltitude
    else {
      return
    }
    let orientation: Orientation
    let chartHeight = bounds.size.height - 2 * GraphView.chartOffset
    let chartWidth = bounds.size.width - 2 * GraphView.chartOffset
    if chartHeight > chartWidth {
      orientation = .portrait
    } else {
      orientation = .landscape
    }
    let xAxisPath = UIBezierPath()
    xAxisPath.move(to: CGPoint(x: GraphView.chartOffset, y: chartHeight + GraphView.chartOffset))
    xAxisPath.addLine(to: CGPoint(x: GraphView.chartOffset + chartWidth, y: chartHeight + GraphView.chartOffset))
    UIConstants.darkColor.setStroke()
    xAxisPath.lineWidth = GraphView.lineWidth
    xAxisPath.stroke()

    let overlay = SettingsManager.getOverlay()
    if overlay == .both || overlay == .altitude {
      let yAxisPath = UIBezierPath()
      yAxisPath.move(to: CGPoint(x: GraphView.chartOffset, y: GraphView.chartOffset))
      yAxisPath.addLine(to: CGPoint(x: GraphView.chartOffset, y: chartHeight + GraphView.chartOffset))
      UIConstants.darkColor.setStroke()
      yAxisPath.lineWidth = GraphView.lineWidth
      yAxisPath.stroke()
      drawGraph(color: UIConstants.intermediate3Color, maxVal: maxAltitude, minVal: minAltitude, minRange: GraphView.minAltRange, getVal: { (x: Int) -> Double in
        smoothAltitudes[self.xToIndex(x)]
      })
    }
    if overlay == .both || overlay == .pace {
      let yAxisPath = UIBezierPath()
      yAxisPath.move(to: CGPoint(x: GraphView.chartOffset + chartWidth, y: GraphView.chartOffset))
      yAxisPath.addLine(to: CGPoint(x: GraphView.chartOffset + chartWidth, y: chartHeight + GraphView.chartOffset))
      UIConstants.darkColor.setStroke()
      yAxisPath.lineWidth = GraphView.lineWidth
      yAxisPath.stroke()
      drawGraph(color: UIConstants.intermediate1Color.withAlphaComponent(GraphView.speedAlpha), maxVal: maxSmoothSpeed, minVal: minSmoothSpeed, minRange: GraphView.minSpeedRange, getVal: { (x: Int) -> Double in
        self.smoothSpeeds[self.xToIndex(x)]
      })
    }
    let xTics = orientation == .landscape ? GraphView.longTics : GraphView.shortTics
    let ticPath = UIBezierPath()
    ticPath.lineWidth = GraphView.lineWidth
    let chunkWidth = chartWidth / CGFloat((xTics + 1))

    let timeChunk = Int(timeSpan) / (xTics + 1)
    let distanceChunk = distance / Double(xTics + 1)
    for x in 0 ... xTics {
      if x != xTics {
        UIConstants.darkColor.setStroke()
        ticPath.move(to: CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth), y: GraphView.chartOffset + chartHeight))
        ticPath.addLine(to: CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth), y: GraphView.chartOffset + chartHeight + GraphView.ticLength))
        ticPath.stroke()
        let dashedPath = UIBezierPath()
        UIConstants.lightColor.withAlphaComponent(GraphView.dashAlpha).setStroke()
        dashedPath.lineWidth = GraphView.dashedLineWidth
        let dashes = [GraphView.firstDashLength, GraphView.secondDashLength]
        dashedPath.setLineDash(dashes, count: dashes.count, phase: 0)
        dashedPath.move(to: CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth), y: GraphView.chartOffset + chartHeight))
        dashedPath.addLine(to: CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth), y: GraphView.chartOffset))
        dashedPath.stroke()
      }
      let time = Converter.stringifySecondCount((x * timeChunk) + timeChunk, useLongFormat: false)
      time.draw(at: CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth) - GraphView.timeLabelXOffset, y: GraphView.chartOffset + chartHeight + GraphView.timeLabelYOffset), withAttributes: [NSAttributedString.Key.foregroundColor: UIConstants.lightColor])
      let distance = Converter.stringifyDistance((Double(x) * distanceChunk) + distanceChunk, format: "%.1f", omitUnits: true)
      distance.draw(at: CGPoint(x: chunkWidth + GraphView.chartOffset + (CGFloat(x) * chunkWidth) - GraphView.distLabelXOffset, y: GraphView.chartOffset + chartHeight + GraphView.distLabelYOffset), withAttributes: [NSAttributedString.Key.foregroundColor: UIConstants.lightColor])
    }

    let timeLabel = "Time"
    timeLabel.draw(at: CGPoint(x: GraphView.chartOffset - GraphView.timeLabelXOffset, y: GraphView.chartOffset + chartHeight + GraphView.timeLabelYOffset), withAttributes: [NSAttributedString.Key.foregroundColor: UIConstants.lightColor])
    let distLabel = " Dist."
    distLabel.draw(at: CGPoint(x: GraphView.chartOffset - GraphView.timeLabelXOffset, y: GraphView.chartOffset + chartHeight + GraphView.distLabelYOffset), withAttributes: [NSAttributedString.Key.foregroundColor: UIConstants.lightColor])

    let yTics = orientation == .landscape ? GraphView.shortTics : GraphView.longTics
    let chunkHeight = chartHeight / CGFloat((yTics + 1))
    let altChunkSpan = (maxAltitude - minAltitude) / Double(yTics + 1)
    let paceChunkSpan = (maxSmoothSpeed - minSmoothSpeed) / Double(yTics)
    for y in 0 ..< yTics + 1 {
      if overlay == .both || overlay == .altitude {
        UIConstants.darkColor.setStroke()
        ticPath.move(to: CGPoint(x: GraphView.chartOffset, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
        ticPath.addLine(to: CGPoint(x: GraphView.chartOffset - GraphView.ticLength, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
        ticPath.stroke()
        let labelX = GraphView.chartOffset - GraphView.altLabelXOffset
        let labelY = GraphView.chartOffset + (CGFloat(y) * chunkHeight) - GraphView.labelYOffset
        let label = Converter.stringifyAltitude(maxAltitude - ((Double(y) * altChunkSpan)), unabbreviated: true, includeUnit: false)
        label.draw(at: CGPoint(x: labelX, y: labelY), withAttributes: [NSAttributedString.Key.foregroundColor: UIConstants.intermediate3Color])
      }

      if overlay == .both || overlay == .pace {
        UIConstants.darkColor.setStroke()
        ticPath.move(to: CGPoint(x: GraphView.chartOffset + chartWidth, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
        ticPath.addLine(to: CGPoint(x: GraphView.chartOffset + chartWidth + GraphView.ticLength, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
        ticPath.stroke()
        let labelX = GraphView.chartOffset + chartWidth + GraphView.paceLabelXOffset
        let labelY = GraphView.chartOffset + (CGFloat(y) * chunkHeight) - GraphView.labelYOffset
        let pace = maxSmoothSpeed - (Double(y) * paceChunkSpan)
        let label = Converter.stringifyPace(pace, seconds: 1, forSpeaking: false, includeUnit: false)
        label.draw(at: CGPoint(x: labelX, y: labelY), withAttributes: [NSAttributedString.Key.foregroundColor: UIConstants.intermediate1Color])
      }

      let dashedPath = UIBezierPath()
      UIConstants.lightColor.withAlphaComponent(GraphView.dashAlpha).setStroke()
      dashedPath.lineWidth = GraphView.dashedLineWidth
      let dashes = [GraphView.firstDashLength, GraphView.secondDashLength]
      dashedPath.setLineDash(dashes, count: dashes.count, phase: 0)
      dashedPath.move(to: CGPoint(x: GraphView.chartOffset, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
      dashedPath.addLine(to: CGPoint(x: GraphView.chartOffset + chartWidth, y: GraphView.chartOffset + (CGFloat(y) * chunkHeight)))
      dashedPath.stroke()
    }
  }

  private func xToIndex(_ x: Int) -> Int {
    Int(CGFloat(smoothSpeeds.count) * (CGFloat(x) / (self.bounds.size.width - 2 * GraphView.chartOffset)))
  }

  private func drawGraph(color: UIColor, maxVal: Double, minVal: Double, minRange: Double, getVal: (_ x: Int) -> Double) {
    let path = UIBezierPath()
    let width = bounds.size.width
    let height = bounds.size.height
    let chartHeight = height - 2 * GraphView.chartOffset
    let chartWidth = width - 2 * GraphView.chartOffset
    let valRange = maxVal - minVal
    if valRange < minRange {
      path.move(to: CGPoint(x: GraphView.chartOffset, y: height / 2))
      path.addLine(to: CGPoint(x: width - GraphView.chartOffset, y: height / 2))
    } else {
      let firstVal = getVal(0)
      let zeroBasedFirstVal = firstVal - minVal
      let firstY = GraphView.chartOffset + chartHeight - (chartHeight * CGFloat((zeroBasedFirstVal / valRange)))
      path.move(to: CGPoint(x: GraphView.chartOffset, y: firstY))
      var x: CGFloat = GraphView.stride
      while x < chartWidth {
        let curVal = getVal(Int(x))
        let zeroBasedCurVal = curVal - minVal
        let curY = GraphView.chartOffset + chartHeight - (chartHeight * CGFloat((zeroBasedCurVal / valRange)))
        path.addLine(to: CGPoint(x: x + GraphView.chartOffset, y: curY))
        x += GraphView.stride
      }
    }
    color.setStroke()
    path.lineWidth = GraphView.lineWidth
    path.stroke()
  }
}
