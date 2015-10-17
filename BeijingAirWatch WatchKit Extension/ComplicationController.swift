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
    private var time: String? = "Invalid"
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
    
    func createTimeLineEntryModularSmall(firstLine firstLine: String, secondLine: String, date: NSDate) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: firstLine)
        template.line2TextProvider = CLKSimpleTextProvider(text: secondLine)
        template.highlightLine2 = true
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }
    
    func createTimeLineEntryModularLarge(firstLine firstLine: String, secondLine: String, thirdLine: String, date: NSDate) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateModularLargeColumns()
        if thirdLine.containsString(",") == true {
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "Date")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(thirdLine.componentsSeparatedByString(" ")[0])\(thirdLine.componentsSeparatedByString(" ")[1])\(thirdLine.componentsSeparatedByString(" ")[3])\(thirdLine.componentsSeparatedByString(" ")[4])")
        }
        template.row2Column1TextProvider = CLKSimpleTextProvider(text: "AQI")
        template.row3Column1TextProvider = CLKSimpleTextProvider(text: "PM2.5")
        template.row2Column2TextProvider = CLKSimpleTextProvider(text: firstLine)
        template.row3Column2TextProvider = CLKSimpleTextProvider(text: secondLine)
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        rememberMyOwnComplication(complication)
        print("wc - getCurrentTimelineEntryForComplication()")
        if complication.family == .ModularSmall {
            if processDataFromDelegate() == true {
                let entry = createTimeLineEntryModularSmall(firstLine: "\(aqi)", secondLine: "\(concentration)", date: NSDate())
                handler(entry)
                NSUserDefaults.standardUserDefaults().setInteger(self.aqi, forKey: "a")
                NSUserDefaults.standardUserDefaults().setDouble(self.concentration, forKey: "c")
                NSUserDefaults.standardUserDefaults().setObject(self.time, forKey: "t")
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                let entry = createTimeLineEntryModularSmall(firstLine: "?", secondLine: "?", date: NSDate())
                handler(entry)
            }
        } else if complication.family == .ModularLarge {
            if processDataFromDelegate() == true {
                let entry = createTimeLineEntryModularLarge(firstLine: "\(aqi)", secondLine: "\(concentration)", thirdLine: time!, date: NSDate())
                handler(entry)
                NSUserDefaults.standardUserDefaults().setInteger(self.aqi, forKey: "a")
                NSUserDefaults.standardUserDefaults().setDouble(self.concentration, forKey: "c")
                NSUserDefaults.standardUserDefaults().setObject(self.time, forKey: "t")
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                let entry = createTimeLineEntryModularLarge(firstLine: "?", secondLine: "?", thirdLine: "?", date: NSDate())
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
        if complication.family == .ModularSmall {
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "AQI")
            template.line2TextProvider = CLKSimpleTextProvider(text: "PM2.5")
            template.highlightLine2 = true
            handler(template)
        } else {
            let template = CLKComplicationTemplateModularLargeColumns()
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "Date :")
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "AQI  :")
            template.row3Column1TextProvider = CLKSimpleTextProvider(text: "PM2.5:")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "?")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "?")
            template.row3Column2TextProvider = CLKSimpleTextProvider(text: "?")
            handler(template)
        }
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
                    print("wc - data loaded: api = \(self.aqi), concentration = \(self.concentration)， time = \(self.time)")
                    NSUserDefaults.standardUserDefaults().setInteger(self.aqi, forKey: "a")
                    NSUserDefaults.standardUserDefaults().setDouble(self.concentration, forKey: "c")
                    NSUserDefaults.standardUserDefaults().setObject(self.time, forKey: "t")
                    NSUserDefaults.standardUserDefaults().synchronize()
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
                let tmpT: String = unwrappedInfo["t"] as! String
                if tmpA > 1 && tmpC > 1 {
                    aqi = tmpA
                    concentration = tmpC
                    time = tmpT
                    return true;
                }
            }
            return false
        } else {
            return true
        }
    }
}
