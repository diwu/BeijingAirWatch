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

    private var aqi: Int = -1
    private var concentration: Double = -1.0
    private var time: String? = "Invalid"
    private var session: NSURLSession?
    
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

    func test() {
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
                if tmpAQI > 1 && tmpConcentration > 1.0 && (tmpAQI != self.aqi || tmpConcentration != self.concentration || tmpTime != self.time) {
                    self.aqi = tmpAQI
                    self.concentration = tmpConcentration
                    self.time = tmpTime
                    print("wc - data loaded (by Interface Controller): api = \(self.aqi), concentration = \(self.concentration)， time = \(self.time)")
                    let delegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
                    delegate.wcUserInfo = ["a": self.aqi, "c": self.concentration, "t": self.time!]
                    delegate.reloadComplication()
                    return
                }
            }
        }
    }
}
