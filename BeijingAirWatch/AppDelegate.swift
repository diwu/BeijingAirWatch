//
//  AppDelegate.swift
//  BeijingAirWatch
//
//  Created by Di Wu on 10/15/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?

    private var isLoadingData: Bool = false
    private var aqi: Int = -1
    private var concentration: Double = -1.0
    private var time: String? = "Invalid"
    var wcSession: WCSession?
    private var session: URLSession?
    private var bgTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    private var task: URLSessionDataTask?
    private var gregorianCal: NSCalendar?
    
    func getLatestDataHour() -> Int? {
        if time != nil && time?.contains(",") == true {
            let isAm = (time?.components(separatedBy:" ")[4] == "AM")
            if isAm == true {
                return Int((time?.components(separatedBy:" ")[3])!)
            } else {
                if Int((time?.components(separatedBy:" ")[3])!)! == 12 {
                    return 12
                } else {
                    return Int((time?.components(separatedBy:" ")[3])!)! + 12
                }
            }
        } else {
            return nil
        }
    }
    
    func getCurrentHour() -> Int? {
        let date: Date = Date()
        if gregorianCal == nil {
            gregorianCal = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        }
        let comps: DateComponents? = gregorianCal?.components(in: TimeZone.init(abbreviation: "HKT")!, from: date)
        return comps?.hour
    }
    
    func alreadyFetchedLatestData() -> Bool {
        let currHour: Int? = getCurrentHour()
        let dataHour: Int? = getLatestDataHour()
        if currHour != nil && dataHour != nil && currHour! == dataHour! {
            self.sendLocalNotif(text: "OS Time:\(currHour). Data Time:\(dataHour).Pause refreshing.", badge: -1)
            return true
        } else {
            self.sendLocalNotif(text: "OS Time:\(currHour). Data Time:\(dataHour).Keep refreshing.", badge: -1)
            return false
        }
    }
    
    func startWCSession() {
        if (WCSession.isSupported() && wcSession == nil) {
            wcSession = WCSession.default()
            wcSession?.delegate = self
            wcSession?.activate()
        } else if (WCSession.isSupported() && wcSession != nil) {
            wcSession?.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let city = message["selected_city"] as? String {
            UserDefaults.standard.set(city, forKey: "selected_city")
            UserDefaults.standard.synchronize()
            print("ios app sourcel url: \(sourceDescription())")
            sendLocalNotif(text: "Updating City to:\(selectedCity())", badge: -1)
        } else if let bg = message["bg_handler"] as? String {
            sendLocalNotif(text: "Bg handler:\(bg)", badge: -1)
        }
        print("did receive wc session msg (ios app side): \(message)")
        replyHandler(["xxx":"xxx"])
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if error != nil {
            let userInfo : [String : Any]? = userInfoTransfer.userInfo
            if let unwrapped = userInfo {
                let tmpTime : String? = unwrapped["t"] as! String?
                if let unwrappedTime = tmpTime {
                    if self.time != nil && self.time! == unwrappedTime {
                        sendLocalNotif(text: "Transfer failed. Valid. \(self.time)", badge: -1)
                        self.wcSession?.transferCurrentComplicationUserInfo(unwrapped)
                        return
                    }
                }
            }
            sendLocalNotif(text: "Transfer failed. Invalid. \(self.time)", badge: -1)
            userInfoTransfer.cancel()
        } else {
            sendLocalNotif(text: "Transfer done. \(self.time)", badge: -1)
        }
    }
    
    /*
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        if userInfo["selected_city"] != nil {
            let city: String = userInfo["selected_city"] as! String
            UserDefaults.standard.setObject(city, forKey: "selected_city")
            UserDefaults.standard.synchronize()
        }
        print("did receive info (ios app side): \(userInfo)")
        print("ios app sourcel url: \(sourceDescription())")
    }
*/
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        startWCSession()
        
        if UserDefaults.standard.integer(forKey: "a") > 1 {
            aqi = UserDefaults.standard.integer(forKey: "a")
        }
        if UserDefaults.standard.double(forKey: "c") > 1.0 {
            concentration = UserDefaults.standard.double(forKey: "c")
        }
        if UserDefaults.standard.string(forKey: "t") != nil {
            time = UserDefaults.standard.string(forKey: "t")
        }
        
        if DEBUG_LOCAL_NOTIFICATION == true {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        return true
    }
    
    func properlyEndBgTaskIfThereIsOne() {
        if self.bgTaskID != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(self.bgTaskID)
            self.bgTaskID = UIBackgroundTaskInvalid
        }
    }
    
    func sendLocalNotif(text: String, badge: Int) {
        if DEBUG_LOCAL_NOTIFICATION == true {
            let notif = UILocalNotification()
            notif.fireDate = Date(timeIntervalSinceNow: 1)
            notif.alertBody = text
            notif.timeZone = TimeZone.current
            notif.soundName = UILocalNotificationDefaultSoundName
            if badge > 0 {
                notif.applicationIconBadgeNumber = badge
            }
            UIApplication.shared.scheduleLocalNotification(notif)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("ios app did become active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

