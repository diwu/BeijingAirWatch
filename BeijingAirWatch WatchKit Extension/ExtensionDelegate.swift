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

public let LATEST_DATA_READY_NOTIFICATION_NAME = "LATEST_DATA_READY_NOTIFICATION_NAME"

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate, URLSessionDownloadDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("handle called")
        for task in backgroundTasks {
            if task is WKApplicationRefreshBackgroundTask {
                print("handle WKApplicationRefreshBackgroundTask")
                scheduleBgRefresh()
                scheduleDownloadTask()
                wcSession?.sendMessage(["bg_handler": "application"], replyHandler: { (replayHandler: [String : Any]) in
                    
                    }, errorHandler: { (error: Error) in
                        
                })
            }
            task.setTaskCompleted()
        }
    }
    
    private let SESSION_ID = "beijingairid"
    
    func scheduleDownloadTask() {
        let session = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: SESSION_ID), delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.downloadTask(with: createRequest())
        task.resume()
    }
    
    private func scheduleBgRefresh() {
        print("schedule bg refres")
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow:30 * 60), userInfo: nil, scheduledCompletion: { (error: Error?) in
        })
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("download task did finish, url = \(location)")
        do {
            let data = try Data(contentsOf: location)
            guard let dataStr = String(data: data, encoding: .ascii) else {
                return
            }
            let aqi = parseAQI(data: dataStr)
            let concentration = parseConcentration(data: dataStr)
            let time = parseTime(data: dataStr)
            print("parse result \(aqi), \(concentration), \(time)")
            defer {
                NotificationCenter.default.post(name: Notification.Name(LATEST_DATA_READY_NOTIFICATION_NAME), object: nil)
            }
            guard let airQuality = AirQuality(aqi: parseAQI(data: dataStr), concentration: parseConcentration(data: dataStr), time: parseTime(data: dataStr)) else {
                AirQuality.cleanDisk()
                reloadComplication()
                return
            }
            airQuality.saveToDisk()
            self.reloadComplication()
            print("get valid data!")
            reloadComplication()
        } catch {
            print("download data invalid")
        }
    }


    var wcSession: WCSession?
    var wcUserInfo: [String: Any]?
    var myOwnComplication: CLKComplication?
    
    func tryAskIOSAppToRegisterVOIPCallback() {
        wcSession?.sendMessage(["xxx":"xxx"], replyHandler: { (reply: [String : Any]) in
            
            }, errorHandler: { (error: Error) in
                
        })
    }
    
    func startWCSession() {
        if (WCSession.isSupported() && wcSession == nil) {
            wcSession = WCSession.default()
            wcSession?.delegate = self
            wcSession?.activate()
            tryAskIOSAppToRegisterVOIPCallback()
        } else if (WCSession.isSupported() && wcSession != nil) {
            wcSession?.activate()
        }
    }
    
    func reloadComplication() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        guard let cmpls = complicationServer.activeComplications else {
            return
        }
        print("reload every complication")
        for complication in cmpls {
            complicationServer.reloadTimeline(for: complication)
        }
    }
    
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        print("did receive info: \(userInfo)")
        if userInfo["a"] != nil {
            wcUserInfo = userInfo
            reloadComplication()
        }
    }
    
    func sendCityToIOSApp(replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)?) {
//        wcSession?.transferUserInfo(["selected_city": selectedCity().rawValue])
        //     public func sendMessage(message: [String : AnyObject], replyHandler: (([String : AnyObject]) -> Void)?, errorHandler: ((NSError) -> Void)?)

        wcSession?.sendMessage(["selected_city": selectedCity().rawValue], replyHandler: replyHandler, errorHandler:errorHandler)
    }
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        print("did launch")
        startWCSession()
        scheduleBgRefresh()
        scheduleDownloadTask()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
