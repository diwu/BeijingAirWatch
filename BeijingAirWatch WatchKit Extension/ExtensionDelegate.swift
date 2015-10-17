//
//  ExtensionDelegate.swift
//  BeijingAirWatch WatchKit Extension
//
//  Created by Di Wu on 10/15/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import WatchKit
import WatchConnectivity
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    var wcSession: WCSession?
    var wcUserInfo: [String: AnyObject]?
    var myOwnComplication: CLKComplication?
    
    func startWCSession() {
        if (WCSession.isSupported() && wcSession == nil) {
            wcSession = WCSession.defaultSession()
            wcSession?.delegate = self
            wcSession?.activateSession()
        } else if (WCSession.isSupported() && wcSession != nil) {
            wcSession?.activateSession()
        }
    }
    
    func reloadComplication() {
        if myOwnComplication == nil {
            let complicationServer = CLKComplicationServer.sharedInstance()
            for complication in complicationServer.activeComplications {
                complicationServer.reloadTimelineForComplication(complication)
            }
        } else {
            let complicationServer = CLKComplicationServer.sharedInstance()
            complicationServer.reloadTimelineForComplication(myOwnComplication)
        }
    }
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("did receive info: \(userInfo)")
        if userInfo["a"] != nil {
            wcUserInfo = userInfo
            reloadComplication()
        }
    }
    
    func sendCityToIOSApp() {
        wcSession?.transferUserInfo(["selected_city": selectedCity().rawValue])
    }
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        print("did launch")
        startWCSession()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
