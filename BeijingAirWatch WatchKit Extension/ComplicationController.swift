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
    private var session: URLSession?
    private var isFromIOSApp: Bool = true
    private var task: URLSessionDataTask?

    func rememberMyOwnComplication(complication: CLKComplication) {
        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
        delegate.myOwnComplication = complication
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        rememberMyOwnComplication(complication: complication)
        handler(nil)
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        rememberMyOwnComplication(complication: complication)
        handler([])
    }
    
    func getTimelineStartDateForComplication(for complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        rememberMyOwnComplication(complication: complication)
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(for complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        rememberMyOwnComplication(complication: complication)
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(for complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        rememberMyOwnComplication(complication: complication)
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func createTimeLineEntryModularSmall(firstLine: String, secondLine: String, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: firstLine)
        template.line2TextProvider = CLKSimpleTextProvider(text: secondLine)
        template.highlightLine2 = true
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }
    
    func createTimeLineEntryModularLarge(firstLine: String, secondLine: String, thirdLine: String, date: Date) -> CLKComplicationTimelineEntry {
        if thirdLine.contains(",") == true {
            let template = CLKComplicationTemplateModularLargeColumns()
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "Time")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(thirdLine.components(separatedBy:" ")[3]):15 \(thirdLine.components(separatedBy:" ")[4])")
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "AQI")
            template.row3Column1TextProvider = CLKSimpleTextProvider(text: "PM2.5")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: firstLine)
            template.row3Column2TextProvider = CLKSimpleTextProvider(text: "\(secondLine) µg/m³")
            let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return(entry)
        } else {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Real-time PM2.5")
            template.body1TextProvider = CLKSimpleTextProvider(text: "Press to select city")
            template.body2TextProvider = CLKSimpleTextProvider(text: "& start auto-refresh.")
            let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return(entry)
        }
    }
    
    func createTimeLineEntryCircularSmall(firstLine: String, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateCircularSmallSimpleText()
        template.textProvider = CLKSimpleTextProvider(text: firstLine)
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }
    
    func createTimeLineEntryUtilitarianLarge(firstLine: String, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = CLKSimpleTextProvider(text: firstLine)
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }
    
    func createTimeLineEntryUtilitarianSmall(firstLine: String, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = CLKSimpleTextProvider(text: firstLine)
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        rememberMyOwnComplication(complication: complication)
        print("wc - getCurrentTimelineEntryForComplication()")
        let ret = processDataFromDelegate()
        
        if ret == true {
            UserDefaults.standard.set(self.aqi, forKey: "a")
            UserDefaults.standard.set(self.concentration, forKey: "c")
            UserDefaults.standard.set(self.time, forKey: "t")
            UserDefaults.standard.synchronize()
        }

        if complication.family == .modularSmall {
            if ret == true {
                let entry = createTimeLineEntryModularSmall(firstLine: "\(time!.components(separatedBy:" ")[3])\(time!.components(separatedBy:" ")[4])", secondLine: "\(concentration)", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryModularSmall(firstLine: "?", secondLine: "?", date: Date())
                handler(entry)
            }
        } else if complication.family == .modularLarge {
            if ret == true {
                let entry = createTimeLineEntryModularLarge(firstLine: "\(aqi)", secondLine: "\(concentration)", thirdLine: time!, date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryModularLarge(firstLine: "?", secondLine: "?", thirdLine: "?", date: Date())
                handler(entry)
            }
        } else if complication.family == .circularSmall {
            if ret == true {
                let entry = createTimeLineEntryCircularSmall(firstLine: "\(concentration)", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryCircularSmall(firstLine: "?", date: Date())
                handler(entry)
            }
        } else if complication.family == .utilitarianLarge {
            if ret == true {
                let entry = createTimeLineEntryUtilitarianLarge(firstLine: "\(time!.components(separatedBy:" ")[3]) \(time!.components(separatedBy:" ")[4]) \(concentration)", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryUtilitarianLarge(firstLine: "Press to Refresh", date: Date())
                handler(entry)
            }
        } else {
            if ret == true {
                let entry = createTimeLineEntryUtilitarianSmall(firstLine: "\(concentration)", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryUtilitarianSmall(firstLine: "?", date: Date())
                handler(entry)
            }
        }
        isFromIOSApp = true
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: Date, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        rememberMyOwnComplication(complication: complication)
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: Date, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        rememberMyOwnComplication(complication: complication)
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (Date?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        print("wc - getNextRequestedUpdateDateWithHandler()")
        handler(Date(timeIntervalSinceNow: 60 * 60));
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        rememberMyOwnComplication(complication: complication)
        if complication.family == .modularSmall {
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "AQI")
            template.line2TextProvider = CLKSimpleTextProvider(text: "PM2.5")
            template.highlightLine2 = true
            handler(template)
        } else if complication.family == .modularLarge {
            let template = CLKComplicationTemplateModularLargeColumns()
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "Time")
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "AQI")
            template.row3Column1TextProvider = CLKSimpleTextProvider(text: "PM2.5")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "?")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "?")
            template.row3Column2TextProvider = CLKSimpleTextProvider(text: "?")
            handler(template)
        } else if complication.family == .circularSmall {
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "PM2.5")
            handler(template)
        } else if complication.family == .utilitarianLarge {
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "PM2.5")
            handler(template)
        } else {
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "PM2.5")
            handler(template)
        }
    }
    
    func requestedUpdateDidBegin() {
        print("wc - func requestedUpdateDidBegin()")
        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
        delegate.tryAskIOSAppToRegisterVOIPCallback()
    }
    func requestedUpdateBudgetExhausted() {
        print("wc - func requestedUpdateBudgetExhausted()")
        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
        delegate.tryAskIOSAppToRegisterVOIPCallback()
    }
    
    func test() {
        self.aqi = UserDefaults.standard.integer(forKey: "a")
        self.concentration = UserDefaults.standard.double(forKey:"c")
        self.time = UserDefaults.standard.string(forKey:"t")
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
        self.task?.cancel()
        self.task = createHttpGetDataTask(session: session, request: request){
            (data, error) -> Void in
            if error != nil {
                print(error)
            } else {
                let tmpAQI = parseAQI(data: data)
                let tmpConcentration = parseConcentration(data: data)
                let tmpTime = parseTime(data: data)
                if tmpAQI > 1 && tmpConcentration > 1.0 && (tmpAQI != self.aqi || tmpConcentration != self.concentration || tmpTime != self.time) {
                    self.aqi = tmpAQI
                    self.concentration = tmpConcentration
                    self.time = tmpTime
                    print("wc - data loaded: api = \(self.aqi), concentration = \(self.concentration)， time = \(self.time)")
                    UserDefaults.standard.set(self.aqi, forKey: "a")
                    UserDefaults.standard.set(self.concentration, forKey: "c")
                    UserDefaults.standard.set(self.time, forKey: "t")
                    UserDefaults.standard.synchronize()
                    self.isFromIOSApp = false
                    let delegate = WKExtension.shared().delegate as! ExtensionDelegate
                    delegate.reloadComplication()
                    return
                }
            }
        }
        self.task?.resume()
    }
    
    func processDataFromDelegate() -> Bool {
        if isFromIOSApp == true {
            let delegate = WKExtension.shared().delegate as! ExtensionDelegate
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
