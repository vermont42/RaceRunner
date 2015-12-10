//
//  RunDetailsVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/8/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import GoogleMaps
import MessageUI

class RunDetailsVC: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, GMSMapViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet var map: GMSMapView!
    @IBOutlet var date: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var pace: UILabel!
    @IBOutlet var minAlt: UILabel!
    @IBOutlet var maxAlt: UILabel!
    @IBOutlet var gain: UILabel!
    @IBOutlet var loss: UILabel!
    @IBOutlet var temp: UILabel!
    @IBOutlet var weather: UILabel!
    @IBOutlet var weight: UILabel!
    @IBOutlet var calories: UILabel!
    @IBOutlet var paceOrAltitude: UISegmentedControl!
    @IBOutlet var netOrTotalCals: UISegmentedControl!
    
    @IBOutlet var route: MarqueeLabel!
    @IBOutlet var customTitleButton: UIButton!
    @IBOutlet var exportButton: UIButton!
    var run: Run!
    var logType: LogVC.LogType!
    private var alertView: UIAlertView!
    private var colorPaceSegments: [GMSPolyline] = []
    private var colorAltitudeSegments: [GMSPolyline] = []
    private var addedOverlays: Bool = false
    
    private static let newRunNamePrompt = "Enter a new name for this run."
    private static let newRunNameTitle = "Run Name"
    private static let setRunNameButtonTitle = "Set"
    
    func mapView(mapView:GMSMapView!,idleAtCameraPosition position:GMSCameraPosition!) {
        if !addedOverlays {
            addOverlays()
            addedOverlays = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.run.locations.count > 0 {
            configureView()
        }
        else {
            fatalError("Attempted to display details of run with zero locations.")
        }
        customTitleButton.setImage(UiHelpers.maskedImageNamed("edit", color: UiConstants.intermediate2Color), forState: UIControlState.Normal)
        exportButton.setImage(UiHelpers.maskedImageNamed("export", color: UiConstants.intermediate2Color), forState: UIControlState.Normal)
        map.mapType = kGMSTypeTerrain
        map.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configureView() {
        var northeast = CLLocationCoordinate2D(latitude: run.maxLatitude.doubleValue, longitude: run.maxLongitude.doubleValue)
        var southwest = CLLocationCoordinate2D(latitude: run.minLatitude.doubleValue, longitude: run.minLongitude.doubleValue)
        northeast.longitude += UiConstants.longitudeCushion
        southwest.longitude -= UiConstants.longitudeCushion
        map.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        date.text = dateFormatter.stringFromDate(run.timestamp)
        distance.text = "Dist: \(Converter.stringifyDistance(run.distance.doubleValue))"
        time.text = "Time: \(Converter.stringifySecondCount(run.duration.integerValue, useLongFormat: false))"
        pace.text = "Pace: \(Converter.stringifyPace(run.distance.doubleValue, seconds: run.duration.integerValue))"
        self.minAlt.text = "Min Alt: \(Converter.stringifyAltitude(run.minAltitude.doubleValue))"
        self.maxAlt.text = "Max Alt: \(Converter.stringifyAltitude(run.maxAltitude.doubleValue))"
        self.gain.text = "Gained: \(Converter.stringifyAltitude(run.altitudeGained.doubleValue))"
        self.loss.text = "Lost: \(Converter.stringifyAltitude(run.altitudeLost.doubleValue))"
        if run.weather as String == DarkSky.weatherError {
            self.weather.text = "Unknown Weather"
        }
        else {
            self.weather.text = "Weather: \(run.weather as String)"
        }
        if run.temperature.floatValue == DarkSky.temperatureError {
            self.temp.text = "Unknown Temp"
        }
        else {
            self.temp.text = "Temp: \(Converter.stringifyTemperature(run.temperature.floatValue))"
        }
        if run.customName == "" {
            if self.run.autoName == RunModel.noStreetNameDetected {
                self.route.text = "Unnamed Route"
            }
            else {
                self.route.text = "Name: \(run.autoName as String)"
            }
        }
        else {
            self.route.text = "Name: \(run.customName as String)"
        }
        if SettingsManager.getShowWeight() {
        self.weight.text = "Weight: \(HumanWeight.weightAsString(run.weight.doubleValue, unitType: SettingsManager.getUnitType()))"
        }
        else {
            self.weight.text = " "
        }
        updateCalories()
    }
    
    func updateCalories() {
        if netOrTotalCals.selectedSegmentIndex == 0 { // total
            self.calories.text = Converter.totalCaloriesAsString(run.distance.doubleValue, weight: run.weight.doubleValue)
        }
        else { // net
            self.calories.text = Converter.netCaloriesAsString(run.distance.doubleValue, weight: run.weight.doubleValue)
        }
    }
    
    func addOverlays() {
        if run.locations.count > 1 {
            map.clear()
            if (paceOrAltitude.selectedSegmentIndex == 1 && colorPaceSegments.count == 0) ||
                (paceOrAltitude.selectedSegmentIndex == 0 && colorAltitudeSegments.count == 0) {
                    var rawValues: [Double] = []
                    if paceOrAltitude.selectedSegmentIndex == 1 {
                        for var i = 1; i < run.locations.count; i++ {
                            let firstLoc = run.locations[i - 1] as! Location
                            let secondLoc = run.locations[i] as! Location
                            let firstLocCL = CLLocation(latitude: firstLoc.latitude.doubleValue, longitude: firstLoc.longitude.doubleValue)
                            let secondLocCL = CLLocation(latitude: secondLoc.latitude.doubleValue, longitude: secondLoc.longitude.doubleValue)
                            let distance = secondLocCL.distanceFromLocation(firstLocCL)
                            let time = secondLoc.timestamp.timeIntervalSinceDate(firstLoc.timestamp)
                            let speed = distance / time
                            rawValues.append(speed)
                        }
                    }
                    else {
                        for var i = 0; i < run.locations.count; i++ {
                            let location = run.locations[i] as! Location
                            rawValues.append(location.altitude.doubleValue)
                        }
                    }
                    let idealSmoothReachSize = 33 // about 133 locations/mile
                    var smoothValues: [Double] = []
                    for (var i = 0; i < rawValues.count; i++) {
                        var lowerBound = i - idealSmoothReachSize / 2
                        var upperBound = i + idealSmoothReachSize / 2
                        if lowerBound < 0 {
                            lowerBound = 0;
                        }
                        if upperBound > (rawValues.count - 1) {
                            upperBound = rawValues.count - 1
                        }
                        var range = NSRange()
                        range.location = lowerBound
                        range.length = upperBound - lowerBound
                        let indexSet = NSMutableIndexSet(indexesInRange: range)
                        var relevantValues: [Double] = []
                        for index in indexSet {
                            relevantValues.append(rawValues[index])
                        }
                        var total = 0.0
                        for value in relevantValues {
                            total += value
                        }
                        let smoothAverage = total / Double(upperBound - lowerBound)
                        smoothValues.append(smoothAverage)
                    }
                    var sortedValues = smoothValues
                    sortedValues.sortInPlace { $0 < $1 }
                    var colorSegments: [GMSPolyline] = []
                    let stride: Int // https://en.wikipedia.org/wiki/Stride_of_an_array
                    if map.camera.zoom < UiConstants.bigStrideZoomThreshhold {
                        stride = UiConstants.bigStride
                    }
                    else {
                        stride = 1
                    }
                    for var i = 1; i < run.locations.count - stride + 1; i += stride {
                        let firstLoc = run.locations[i - 1] as! Location
                        let secondLoc = run.locations[i + stride - 1] as! Location
                        let firstLocCL = CLLocation(latitude: firstLoc.latitude.doubleValue, longitude: firstLoc.longitude.doubleValue)
                        let secondLocCL = CLLocation(latitude: secondLoc.latitude.doubleValue, longitude: secondLoc.longitude.doubleValue)
                        var coords = [firstLocCL.coordinate, secondLocCL.coordinate]
                        let value = smoothValues[i - 1]
                        var index = sortedValues.indexOf(value)
                        if (index == nil) {
                            index = 0
                        }
                        let path = GMSMutablePath()
                        path.addCoordinate(coords[0])
                        path.addCoordinate(coords[1])
                        let segment = GMSPolyline()
                        segment.path = path
                        segment.strokeColor = UiHelpers.colorForValue(value, sortedArray: sortedValues, index: index!)
                        segment.strokeWidth = UiConstants.polylineWidth
                        colorSegments.append(segment)
                    }
                    for segment in colorSegments {
                        segment.map = map
                    }
                    if paceOrAltitude.selectedSegmentIndex == 1 {
                        colorPaceSegments = colorSegments
                    }
                    else {
                        colorAltitudeSegments = colorSegments
                    }
            }
            else {
                for segment in (paceOrAltitude.selectedSegmentIndex == 1 ? colorPaceSegments: colorAltitudeSegments) {
                    segment.map = map
                }
            }
        }
    }

    @IBAction func setCustomName() {        
        let alertController = UIAlertController(title: RunDetailsVC.newRunNameTitle, message: RunDetailsVC.newRunNamePrompt, preferredStyle: UIAlertControllerStyle.Alert)
        let setAction = UIAlertAction(title: RunDetailsVC.setRunNameButtonTitle, style: UIAlertActionStyle.Default, handler: { (action) in
            let textFields = alertController.textFields!
            self.route.text = "Name: \(textFields[0].text!)"
            self.run.customName = textFields[0].text!
            CDManager.saveContext()
        })
        alertController.addAction(setAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) in })
        alertController.addAction(cancelAction)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeOverlay(sender: UISegmentedControl) {
        addOverlays()
    }
    
    @IBAction func changeCalorieType(sender: UISegmentedControl) {
        updateCalories()
    }
    
    @IBAction func back(sender: UIButton) {
        if logType == LogVC.LogType.History {
            self.performSegueWithIdentifier("unwind pan log", sender: self)
        }
        else if logType == LogVC.LogType.Simulate {
            self.performSegueWithIdentifier("unwind pan", sender: self)
        }
    }
    
    @IBAction func export() {
//        let someText:String = "foo"
//        let google:NSURL = NSURL(string:"http://google.com/")!
        
        // let's add a String and an NSURL
//        let activityViewController = UIActivityViewController(
//            activityItems: [GpxActivityItemProvider(placeholderItem: NSData())],
//            applicationActivities: nil)
//        self.presentViewController(activityViewController, animated: true, completion: nil)
        /*
        let contents = "some text"
        if(MFMailComposeViewController.canSendMail()) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("run exported from iSmoothRun")
            mailComposer.setMessageBody("This run was recorded by iSmoothRun.", isHTML: false)
            //let data = contents.dataUsingEncoding(NSUTF8StringEncoding)
            //mailComposer.addAttachmentData(data!, mimeType: "text/xml", fileName: "run.gpx")
            
            if let filePath = NSBundle.mainBundle().pathForResource("iSmoothRun", ofType: "gpx") {
                if let fileData = NSData(contentsOfFile: filePath) {
                    mailComposer.addAttachmentData(fileData, mimeType: "audio/wav", fileName: "iSmoothRun.gpx")
                }
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
*/
        let alertController = UIAlertController(title: "Coming Soon", message: "Share functionality has not yet been implemented.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let noProbAction = UIAlertAction(title: "No Prob", style: UIAlertActionStyle.Default, handler: { (action) in
            SoundManager.play("sadTrombone")
        })
        alertController.addAction(noProbAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
