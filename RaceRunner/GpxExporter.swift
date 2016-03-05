//
//  GpxExporter.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/22/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import MessageUI

class GpxExporter: NSObject, MFMailComposeViewControllerDelegate {
  private static let failureMessage = "RaceRunner could not export this run because RaceRunner could not open the Mail app. One possible cause is that there are no email accounts configured for Mail."
  private static let failureTitle = "Export Failed"
  private static let subject = "run exported by RaceRunner"
  private static let body = "This run was recorded by RaceRunner, a run-tracking app designed in Kāʻanapali, Hawaiʻi and coded in Berkeley, California."
  private static let mimeType = "text/xml"
  private static let fileName = "run.gpx"
  private static let gpxExporter = GpxExporter()
  private static var dateFormatter = NSDateFormatter()
  private static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
  private static let prelude =
  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n" +
  "<gpx version=\"1.1\" creator=\"RaceRunner - https://github.com/vermont42/RaceRunner/\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd\" xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:gpxtpx=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\" xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n" +
  "<metadata>\n"
  private static let interlude =
  "</metadata>\n" +
  "<trk>\n" +
  "<trkseg>\n"
  private static let trkpt =
  "<trkpt lat=\"%f\" lon=\"%f\">\n" +
  "<ele>%f</ele>\n" +
  "<time>%@</time>\n" +
  "</trkpt>\n"
  private static let coda =
  "</trkseg>\n" +
  "</trk>\n" +
  "</gpx>\n"
  private static let autoName = ("<name>", "</name>\n")
  private static let customName = ("<customName>", "</customName>\n")
  private static let weather = ("<weather>", "</weather>\n")
  private static let temperature = ("<temperature>", "</temperature>\n")
  private static let weight = ("<weight>", "</weight>\n")
  
  class func export(run: Run) {
    if(MFMailComposeViewController.canSendMail()) {
      var contents = GpxExporter.prelude
      GpxExporter.dateFormatter.dateFormat = GpxExporter.dateFormat
      contents += autoName.0 + (run.autoName as String) + autoName.1
      if run.customName != Run.noCustomName {
        contents += customName.0 + (run.customName as String) + customName.1
      }
      if run.weather != Run.noWeather {
        contents += weather.0 + (run.weather as String) + weather.1
      }
      if run.temperature != Run.noTemperature {
        contents += temperature.0 + "\(run.temperature.doubleValue.roundToPlaces(0))" + temperature.1
      }
      if run.weight != Run.noWeight {
        contents += weight.0 + "\(run.weight.doubleValue.roundToPlaces(0))" + weight.1
      }
      contents += GpxExporter.interlude
      for location in run.locations {
        let locationCD = location as! Location
        contents += String(format: GpxExporter.trkpt, locationCD.latitude.doubleValue, locationCD.longitude.doubleValue, locationCD.altitude.doubleValue, GpxExporter.dateFormatter.stringFromDate(location.timestamp))
      }
      contents += GpxExporter.coda
      let mailComposer = MFMailComposeViewController()
      mailComposer.mailComposeDelegate = GpxExporter.gpxExporter
      mailComposer.setSubject(GpxExporter.subject)
      mailComposer.setMessageBody(GpxExporter.body, isHTML: false)
      let data = contents.dataUsingEncoding(NSUTF8StringEncoding)
      mailComposer.addAttachmentData(data!, mimeType: GpxExporter.mimeType, fileName: GpxExporter.fileName)
      UIApplication.topViewController()?.presentViewController(mailComposer, animated: true, completion: nil)
    }
    else {
      SoundManager.play("sadTrombone")
      UIAlertController.showMessage(GpxExporter.failureMessage, title: failureTitle)
    }
  }
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    UIApplication.topViewController()?.dismissViewControllerAnimated(true, completion: nil)
  }
}
