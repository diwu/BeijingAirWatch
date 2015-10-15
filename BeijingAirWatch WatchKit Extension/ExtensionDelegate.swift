//
//  ExtensionDelegate.swift
//  BeijingAirWatch WatchKit Extension
//
//  Created by Di Wu on 10/15/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    var wcSession: WCSession?
    var wcUserInfo: [String: AnyObject]?
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("did receive info: \(userInfo)")
        wcUserInfo = userInfo
    }
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        print("did launch")
        if (WCSession.isSupported()) {
            wcSession = WCSession.defaultSession()
            wcSession!.delegate = self
            wcSession!.activateSession()
            print("did activate session")
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
