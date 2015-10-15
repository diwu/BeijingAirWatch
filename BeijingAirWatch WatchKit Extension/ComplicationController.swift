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
    private var currentAQI: Int = -1
    private var currentConcentration: Double = -1.0
    
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
        print(" - 2 -")
        if complication.family == .ModularSmall {
            if currentAQI > 1 && currentConcentration > 1 {
                let entry = createTimeLineEntry(firstLine: "\(currentAQI)", secondLine: "\(currentConcentration)", date: NSDate())
                handler(entry)
            } else {
                let entry = createTimeLineEntry(firstLine: "--", secondLine: "--", date: NSDate())
                handler(entry)
            }
        } else {
            handler(nil)
        }
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
        print(" - 1 -")
        handler(nil);
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
        let delegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        print(" - 3 - \(delegate.wcUserInfo)")
        if let unwrappedInfo = delegate.wcUserInfo {
            let tmpA: Int = unwrappedInfo["a"] as! Int
            let tmpC: Double = unwrappedInfo["c"] as! Double
            if tmpA > 1 && tmpC > 1 && tmpA != currentAQI && tmpC != currentConcentration {
                currentAQI = tmpA
                currentConcentration = tmpC
                let complicationServer = CLKComplicationServer.sharedInstance()
                if delegate.myOwnComplication == nil {
                    for complication in complicationServer.activeComplications {
                        complicationServer.reloadTimelineForComplication(complication)
                    }
                } else {
                    complicationServer.reloadTimelineForComplication(delegate.myOwnComplication)
                }
            }
        }
    }
    func requestedUpdateBudgetExhausted() {
        print(" - 4 - ")
    }
}
