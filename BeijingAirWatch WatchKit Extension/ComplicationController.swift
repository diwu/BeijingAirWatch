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

    func rememberMyOwnComplication(complication: CLKComplication) {
        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
        delegate.myOwnComplication = complication
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
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "City")
            template.row3Column1TextProvider = CLKSimpleTextProvider(text: "PM2.5")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: firstLine)
            template.row3Column2TextProvider = CLKSimpleTextProvider(text: "\(secondLine) µg/m³")
            let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return(entry)
        } else {
            let template = CLKComplicationTemplateModularLargeColumns()
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "Time")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "?")
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "City")
            template.row3Column1TextProvider = CLKSimpleTextProvider(text: "PM2.5")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "?")
            template.row3Column2TextProvider = CLKSimpleTextProvider(text: "?")
            let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return(entry)
        }
    }
    
    func createTimeLineEntryCircularSmall(firstLine: String, secondLine: String, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateCircularSmallStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: firstLine)
        template.line2TextProvider = CLKSimpleTextProvider(text: secondLine)
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
    
    func createTimeLineEntryExtraLarge(firstLine: String, secondLine: String, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateExtraLargeStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: firstLine)
        template.line2TextProvider = CLKSimpleTextProvider(text: secondLine)
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        rememberMyOwnComplication(complication: complication)
        print("wc - getCurrentTimelineEntryForComplication()")
        
        var ret = false
        var time: String? = nil
        var concentration = -1.0
        var aqi = -1
        
        if let airQuality = AirQuality() {
            ret = true
            time = airQuality.time
            concentration = airQuality.concentration
            aqi = airQuality.aqi
        }
        
        switch complication.family {
        case .modularSmall:
            if ret == true {
                let entry = createTimeLineEntryModularSmall(firstLine: "\(time!.components(separatedBy:" ")[3])\(time!.components(separatedBy:" ")[4])", secondLine: "\(concentration)", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryModularSmall(firstLine: "?", secondLine: "?", date: Date())
                handler(entry)
            }
        case .modularLarge:
            if ret == true {
                let entry = createTimeLineEntryModularLarge(firstLine: "\(selectedCity().rawValue)", secondLine: "\(concentration)", thirdLine: time!, date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryModularLarge(firstLine: "?", secondLine: "?", thirdLine: "?", date: Date())
                handler(entry)
            }
        case .circularSmall:
            if ret == true {
                let entry = createTimeLineEntryCircularSmall(firstLine: "\(time!.components(separatedBy:" ")[3])\(time!.components(separatedBy:" ")[4])", secondLine: "\(concentration)", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryCircularSmall(firstLine: "?", secondLine: "?", date: Date())
                handler(entry)
            }
        case .utilitarianLarge:
            if ret == true {
                let entry = createTimeLineEntryUtilitarianLarge(firstLine: "\(time!.components(separatedBy:" ")[3]) \(time!.components(separatedBy:" ")[4]) \(concentration)", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryUtilitarianLarge(firstLine: "?", date: Date())
                handler(entry)
            }
        case .utilitarianSmall, .utilitarianSmallFlat:
            if ret == true {
                let entry = createTimeLineEntryUtilitarianSmall(firstLine: "\(time!.components(separatedBy:" ")[3])|\(Int(concentration))", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryUtilitarianSmall(firstLine: "?", date: Date())
                handler(entry)
            }
        case .extraLarge:
            if ret == true {
                let entry = createTimeLineEntryExtraLarge(firstLine: "\(time!.components(separatedBy:" ")[3])\(time!.components(separatedBy:" ")[4])", secondLine: "\(concentration)", date: Date())
                handler(entry)
            } else {
                let entry = createTimeLineEntryExtraLarge(firstLine: "?", secondLine: "?", date: Date())
                handler(entry)
            }
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        rememberMyOwnComplication(complication: complication)
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        rememberMyOwnComplication(complication: complication)
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        print("wc - getNextRequestedUpdateDateWithHandler()")
        handler(Date(timeIntervalSinceNow: 60 * 60));
    }
    
    // MARK: - Placeholder Templates
    

    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        rememberMyOwnComplication(complication: complication)
        var aTemplate: CLKComplicationTemplate?
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "City")
            template.line2TextProvider = CLKSimpleTextProvider(text: "PM2.5")
            template.highlightLine2 = true
            aTemplate = template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeColumns()
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "Time")
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "City")
            template.row3Column1TextProvider = CLKSimpleTextProvider(text: "PM2.5")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "?")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "?")
            template.row3Column2TextProvider = CLKSimpleTextProvider(text: "?")
            aTemplate = template
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "?")
            template.line2TextProvider = CLKSimpleTextProvider(text: "?")
            aTemplate = template
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "PM2.5")
            aTemplate = template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "PM2.5")
            aTemplate = template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "PM2.5")
            aTemplate = template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "?")
            template.line2TextProvider = CLKSimpleTextProvider(text: "?")
            aTemplate = template
        }
        handler(aTemplate)
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
}
