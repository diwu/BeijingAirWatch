//
//  ComplicationController.swift
//  BeijingAirWatch WatchKit Extension
//
//  Created by Di Wu on 10/15/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    private var aqi: Int = -1
    private var concentration: Double = -1.0
    private var session: NSURLSession?
    private var isFromIOSApp: Bool = true
    
    func rememberMyOwnComplication(complication: CLKComplication) {
        let delegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        delegate.myOwnComplication = complication
    }
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        rememberMyOwnComplication(complication)
        handler([.None])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        rememberMyOwnComplication(complication)
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        rememberMyOwnComplication(complication)
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        rememberMyOwnComplication(complication)
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func createTimeLineEntry(firstLine firstLine: String, secondLine: String, date: NSDate) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: firstLine)
        template.line2TextProvider = CLKSimpleTextProvider(text: secondLine)
        template.highlightLine2 = true
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        rememberMyOwnComplication(complication)
        print("wc - getCurrentTimelineEntryForComplication()")
        if complication.family == .ModularSmall {
            if processDataFromDelegate() == true {
                let entry = createTimeLineEntry(firstLine: "\(aqi)", secondLine: "\(concentration)", date: NSDate())
                handler(entry)
                NSUserDefaults.standardUserDefaults().setInteger(self.aqi, forKey: "a")
                NSUserDefaults.standardUserDefaults().setDouble(self.concentration, forKey: "c")
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                let entry = createTimeLineEntry(firstLine: "--", secondLine: "--", date: NSDate())
                handler(entry)
            }
        } else {
            handler(nil)
        }
        isFromIOSApp = true
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        rememberMyOwnComplication(complication)
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        rememberMyOwnComplication(complication)
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        print("wc - getNextRequestedUpdateDateWithHandler()")
        handler(NSDate.init(timeIntervalSinceNow: 60 * 10));
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        rememberMyOwnComplication(complication)
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: "AQI")
        template.line2TextProvider = CLKSimpleTextProvider(text: "PM2.5")
        template.highlightLine2 = true
        handler(template)
    }
    
    func requestedUpdateDidBegin() {
        print("wc - func requestedUpdateDidBegin()")
        test()
    }
    func requestedUpdateBudgetExhausted() {
        print("wc - func requestedUpdateBudgetExhausted()")
        test()
    }
    
    func test() {
        self.aqi = NSUserDefaults.standardUserDefaults().integerForKey("a")
        self.concentration = NSUserDefaults.standardUserDefaults().doubleForKey("c")
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
                if tmpAQI > 1 && tmpConcentration > 1.0 && (tmpAQI != self.aqi || tmpConcentration != self.concentration) {
                    self.aqi = tmpAQI
                    self.concentration = tmpConcentration
                    print("wc - data loaded: api = \(self.aqi), concentration = \(self.concentration)")
                    self.isFromIOSApp = false
                    let delegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
                    delegate.reloadComplication()
                    return
                }
            }
        }
    }
    
    func processDataFromDelegate() -> Bool {
        if isFromIOSApp == true {
            let delegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
            if let unwrappedInfo = delegate.wcUserInfo {
                let tmpA: Int = unwrappedInfo["a"] as! Int
                let tmpC: Double = unwrappedInfo["c"] as! Double
                if tmpA > 1 && tmpC > 1 {
                    aqi = tmpA
                    concentration = tmpC
                    return true;
                }
            }
            return false
        } else {
            return true
        }
    }
}
