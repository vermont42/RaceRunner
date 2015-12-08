//
//  RunVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

class RunVC: ChildVC, RunDelegate {
    @IBOutlet var viewControllerTitle: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var paceLabel: UILabel!
    @IBOutlet var altLabel: UILabel!
    @IBOutlet var altGainedLabel: UILabel!
    @IBOutlet var altLostLabel: UILabel!
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var showMenuButton: UIButton!
    @IBOutlet var pauseResume: UIButton!
    @IBOutlet var map: GMSMapView!
    
    private var currentCoordinate: CLLocationCoordinate2D!
    private var pin: GMSMarker!
    private var runnerIcons = RunnerIcons()
    private var lastDirection: RunnerIcons.Direction = .Stationary
    
    private static let gpxTitle = "Berkeley Hills"
    private static let didNotSaveMessage = "RaceRunner did not save this run because it was so short. The run, not RaceRunner. As a collection of electrons on your phone, RaceRunner has no physical height."
    private static let bummerButtonTitle = "Bummer"
    private static let sadFaceTitle = "😢"
    private static let startTitle = " Start "
    private static let pauseTitle = " Pause "
    private static let stopTitle = " Stop "
    private static let resumeTitle = " Resume "
    
    var runToSimulate: Run?
    var gpxFile: String?
    
    override func viewDidLoad() {
        showMenuButton.setImage(UiHelpers.maskedImageNamed("menu", color: UiConstants.lightColor), forState: .Normal)
        map.mapType = kGMSTypeTerrain
        map.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let runToSimulate = runToSimulate {
            RunModel.initializeRunModel(runToSimulate)
            if runToSimulate.customName.isEqualToString("") {
                viewControllerTitle.text = runToSimulate.autoName as String
            }
            else {
                viewControllerTitle.text = runToSimulate.customName as String
            }
            startStop()
        }
        else if let gpxFile = gpxFile {
            RunModel.initializeRunModelWithGpxFile(gpxFile)
            viewControllerTitle.text = RunVC.gpxTitle
            startStop()
        }
        else {
            RunModel.initializeRunModel()
            viewControllerTitle.text = "Run"
        }
        viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
        
        let runModel = RunModel.runModel
        runModel.runDelegate = self
        switch runModel.status {
        case .PreRun:
            hideLabels()
            startStopButton.backgroundColor = UiConstants.intermediate3Color
            startStopButton.setTitle(RunVC.startTitle, forState: UIControlState.Normal)
            startStopButton.hidden = false
            pauseResume.hidden = true
        case .InProgress:
            showLabels()
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle(RunVC.stopTitle, forState: UIControlState.Normal)
            pauseResume.hidden = false
            startStopButton.hidden = false
            pauseResume.setTitle(RunVC.pauseTitle, forState: UIControlState.Normal)
            addOverlays()
            map.hidden = false
        case .Paused:
            showLabels()
            pauseResume.hidden = false
            startStopButton.hidden = false
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle(RunVC.stopTitle, forState: UIControlState.Normal)
            pauseResume.setTitle(RunVC.resumeTitle, forState: UIControlState.Normal)
            addOverlays()
            map.camera = GMSCameraPosition.cameraWithLatitude(currentCoordinate.latitude, longitude: currentCoordinate.longitude, zoom: UiConstants.cameraZoom)
            map.hidden = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        RunModel.runModel.runDelegate = nil
        if (runToSimulate != nil || gpxFile != nil) && (RunModel.runModel.status != .PreRun)  {
          RunModel.runModel.stop()
        }
    }
  
    func addOverlays() {
        let locations = RunModel.runModel.locations
        for var i = 0; i < locations.count - 1; i++ {
            var coords: [CLLocationCoordinate2D] = [locations[i].coordinate, locations[i + 1].coordinate]
            let path = GMSMutablePath()
            path.addCoordinate(coords[0])
            path.addCoordinate(coords[1])
            let polyline = GMSPolyline()
            polyline.path = path
            polyline.strokeColor = UiConstants.darkColor
            polyline.strokeWidth = UiConstants.polylineWidth
            polyline.map = map
        }
        currentCoordinate = locations.last?.coordinate
        pin = GMSMarker()
    }
    
    func showInitialCoordinate(coordinate: CLLocationCoordinate2D) {
        map.camera = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude: coordinate.longitude, zoom: UiConstants.cameraZoom)
        currentCoordinate = coordinate
        if pin == nil {
            pin = GMSMarker()
        }
        pin.position = coordinate
        pin.icon = runnerIcons.nextIcon()
        pin.map = map
    }
    
    func plotToCoordinate(coordinate: CLLocationCoordinate2D) {
        if currentCoordinate != nil {
            if currentCoordinate.longitude > coordinate.longitude {
                runnerIcons.direction = .West
                lastDirection = .West
            }
            else if currentCoordinate.longitude < coordinate.longitude {
                runnerIcons.direction = .East
                lastDirection = .East
            }
            var coords: [CLLocationCoordinate2D] = [currentCoordinate, coordinate]
            map.camera = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude: coordinate.longitude, zoom: UiConstants.cameraZoom)
            let path = GMSMutablePath()
            path.addCoordinate(coords[0])
            path.addCoordinate(coords[1])
            let polyline = GMSPolyline()
            polyline.path = path
            polyline.strokeColor = UiConstants.darkColor
            polyline.strokeWidth = UiConstants.polylineWidth
            polyline.map = map
            pin.map = nil
            pin.position = coordinate
            pin.icon = runnerIcons.nextIcon()
            pin.map = map
            currentCoordinate = coordinate
        }
        else {
            showInitialCoordinate(coordinate)
        }
    }
    
    func receiveProgress(distance: Double, time: Int, paceString: String, altitude: Double, altGainedString: String, altLostString: String) {
        timeLabel.text = "Time: \(Converter.stringifySecondCount(time, useLongFormat: false))"
        distanceLabel.text = "Dist.: \(Converter.stringifyDistance(distance))"
        paceLabel.text = "Pace: " + paceString
        altLabel.text = "Alt.: " + Converter.stringifyAltitude(altitude)
        altGainedLabel.text = "+: " + altGainedString
        altLostLabel.text = "-: " + altLostString
        let stopAfter = SettingsManager.getStopAfter()
        if (stopAfter != SettingsManager.never) && (distance >= stopAfter) {
            stop()
        }
    }
    
    @IBAction func showMenu(sender: UIButton) {
        showMenu()
    }
    
    @IBAction func startStop() {
        switch RunModel.runModel.status {
        case .PreRun:
            showLabels()
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle("  Stop  ", forState: UIControlState.Normal)
            pauseResume.hidden = false
            pauseResume.setTitle("  Pause  ", forState: UIControlState.Normal)
            RunModel.runModel.start()
            SoundManager.play("gun")
            map.hidden = false
        case .InProgress:
            stop()
            map.hidden = true
        case .Paused:
            stop()
            map.hidden = true
        }
    }
    
    func stop() {
        arc4random_uniform(UiConstants.applauseSampleCount) + 1
        SoundManager.play("applause\(arc4random_uniform(SoundManager.applauseCount) + 1)")
        runnerIcons.direction = .Stationary
        startStopButton.backgroundColor = UiConstants.intermediate3Color
        startStopButton.setTitle("  Start  ", forState: UIControlState.Normal)
        pauseResume.hidden = true
        pin.map = nil
        RunModel.runModel.stop()
        
        if runToSimulate == nil && gpxFile == nil {
            if RunModel.runModel.totalDistance > RunModel.minDistance {
                performSegueWithIdentifier("pan details from run", sender: self)
                map.clear()
            }
            else {
                let alertController = UIAlertController(title: RunVC.sadFaceTitle, message: RunVC.didNotSaveMessage, preferredStyle: .Alert)
                let bummerAction: UIAlertAction = UIAlertAction(title: RunVC.bummerButtonTitle, style: .Cancel) { action -> Void in
                    self.showMenu()
                }
                alertController.addAction(bummerAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else if runToSimulate != nil {
            self.performSegueWithIdentifier("unwind pan log", sender: self)
        }
        else { // if gpxFile != nil
            showMenu()
        }
    }
    
    @IBAction func pauseResume(sender: UIButton) {
        SoundManager.play("click")
        let runModel = RunModel.runModel
        switch runModel.status {
        case .PreRun:
            fatalError("Attempted to pause before run started.")
        case .InProgress:
            pauseResume.setTitle(RunVC.resumeTitle, forState: UIControlState.Normal)
            runModel.pause()
            runnerIcons.direction = .Stationary
            pin.map = nil
            pin.icon = runnerIcons.nextIcon()
            pin.map = map
        case .Paused:
            pauseResume.setTitle(RunVC.pauseTitle, forState: UIControlState.Normal)
            runnerIcons.direction = lastDirection
            runModel.resume()
        }
        
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {
        pin.map = map
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pan details from run" {
            let runDetailsVC: RunDetailsVC = segue.destinationViewController as! RunDetailsVC
            if runToSimulate == nil && gpxFile == nil {
                runDetailsVC.run = RunModel.runModel.run
                runDetailsVC.logType = .History
            }
        }
    }
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
            })
            return unwindSegue
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }
    
    func hideLabels() {
        distanceLabel.hidden = true
        timeLabel.hidden = true
        paceLabel.hidden = true
        altLabel.hidden = true
        altGainedLabel.hidden = true
        altLostLabel.hidden = true
    }
    
    func showLabels() {
        distanceLabel.hidden = false
        timeLabel.hidden = false
        paceLabel.hidden = false
        altLabel.hidden = false
        altGainedLabel.hidden = false
        altLostLabel.hidden = false
    }
}