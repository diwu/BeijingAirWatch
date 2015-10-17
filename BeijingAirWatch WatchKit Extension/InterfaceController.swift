//
//  InterfaceController.swift
//  BeijingAirWatch WatchKit Extension
//
//  Created by Di Wu on 10/15/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var refreshButton: WKInterfaceButton!
    @IBOutlet var cityButton: WKInterfaceButton!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var aqiLabel: WKInterfaceLabel!
    @IBOutlet var sourceLabel: WKInterfaceLabel!
    @IBOutlet var concentrationLabel: WKInterfaceLabel!
    
    private var aqi: Int = -1
    private var concentration: Double = -1.0
    private var time: String? = "Invalid"
    private var session: NSURLSession?
    
    @IBAction func cityButtonPressed() {

    }
    @IBAction func refreshButtonPressed() {
        test()
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        test()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func populateLabels() {
        if self.aqi <= 1 {
            timeLabel.setText("--")
            aqiLabel.setText("--")
            concentrationLabel.setText("--")
        } else {
            timeLabel.setText(time)
            aqiLabel.setText("AQI: \(aqi)")
            concentrationLabel.setText("PM2.5: \(concentration)")
        }
    }

    func test() {
        sourceLabel.setText(sourceDescription())
        refreshButton.setEnabled(false)
        refreshButton.setTitle("Refreshing...")
        self.aqi = NSUserDefaults.standardUserDefaults().integerForKey("a")
        self.concentration = NSUserDefaults.standardUserDefaults().doubleForKey("c")
        self.time = NSUserDefaults.standardUserDefaults().stringForKey("t")
        if self.time == nil {
            self.time = "Invalid"
        }
        if self.aqi <= 1 {
            self.aqi = -1
        }
        if self.concentration <= 1.0 {
            self.concentration = -1.0
        }
        populateLabels()
        let request = createRequest()
        if session == nil {
            session = sessionForWatchExtension()
        }
        httpGet(session, request: request){
            (data, error) -> Void in
            if error != nil {
                print(error)
            } else {
                let tmpAQI = parseAQI(data)
                let tmpConcentration = parseConcentration(data)
                let tmpTime = parseTime(data)
                if tmpAQI > 1 && tmpConcentration > 1.0 && tmpTime.containsString(",") {
                    self.aqi = tmpAQI
                    self.concentration = tmpConcentration
                    self.time = tmpTime
                    print("wc - data loaded (by Interface Controller): api = \(self.aqi), concentration = \(self.concentration)， time = \(self.time)")
                    self.populateLabels()
                    let delegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
                    delegate.wcUserInfo = ["a": self.aqi, "c": self.concentration, "t": self.time!]
                    delegate.reloadComplication()
                    self.refreshButton.setTitle("Refresh")
                    self.refreshButton.setEnabled(true)
                    return
                }
            }
            self.refreshButton.setTitle("Refresh")
            self.refreshButton.setEnabled(true)
        }
    }
}
