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
    private var session: NSURLSession?
    
    func startWCSession() {
        if (WCSession.isSupported() && wcSession == nil) {
            wcSession = WCSession.defaultSession()
            wcSession?.delegate = self
            wcSession?.activateSession()
        } else if (WCSession.isSupported() && wcSession != nil) {
            wcSession?.activateSession()
        }
    }
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        if userInfo["selected_city"] != nil {
            let city: String = userInfo["selected_city"] as! String
            NSUserDefaults.standardUserDefaults().setObject(city, forKey: "selected_city")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        print("did receive info (ios app side): \(userInfo)")
        print("ios app sourcel url: \(sourceDescription())")
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        startWCSession()
        
        if NSUserDefaults.standardUserDefaults().integerForKey("a") > 1 {
            aqi = NSUserDefaults.standardUserDefaults().integerForKey("a")
        }
        if NSUserDefaults.standardUserDefaults().doubleForKey("c") > 1.0 {
            concentration = NSUserDefaults.standardUserDefaults().doubleForKey("c")
        }
        if NSUserDefaults.standardUserDefaults().stringForKey("t") != nil {
            time = NSUserDefaults.standardUserDefaults().stringForKey("t")
        }
        
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge,UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(settings)

        return true
    }
    
    /*
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        completionHandler(.NoData)

        print("called... complication enabled = \(wcSession?.complicationEnabled)");
        if wcSession?.complicationEnabled == true {
            test(completionHandler)
        } else {
            completionHandler(.NoData)
        }

    }
*/
    
    func fetchNewData() {
        print("called... complication enabled = \(wcSession?.complicationEnabled)");
        startWCSession()
        if wcSession?.complicationEnabled == true {
            test(nil)
        }
    }
    
    func sendLocalNotif(text: String, badge: Int) {
        let notif = UILocalNotification()
        notif.fireDate = NSDate.init(timeIntervalSinceNow: 5)
        notif.alertBody = text
        notif.timeZone = NSTimeZone.defaultTimeZone()
        notif.soundName = UILocalNotificationDefaultSoundName
        if badge > 0 {
            notif.applicationIconBadgeNumber = badge
        }
        UIApplication.sharedApplication().scheduleLocalNotification(notif)
    }
    
    func test(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        sendLocalNotif("尝试获取数据", badge: -1)
        let request = createRequest()
        if session == nil {
            session = sharedSessionForIOS()
        }
        httpGet(session, request: request){
            (data, error) -> Void in
            if error != nil {
                print(error)
                self.sendLocalNotif("获取数据出错", badge: -1)
            } else {
                let tmpAQI = parseAQI(data)
                let tmpConcentration = parseConcentration(data)
                let tmpTime = parseTime(data)
                if tmpAQI > 1 && tmpConcentration > 1.0 && (tmpAQI != self.aqi || tmpConcentration != self.concentration || tmpTime != self.time) {
                    self.aqi = tmpAQI
                    self.concentration = tmpConcentration
                    self.time = tmpTime
                    NSUserDefaults.standardUserDefaults().setInteger(self.aqi, forKey: "a")
                    NSUserDefaults.standardUserDefaults().setDouble(self.concentration, forKey: "c")
                    NSUserDefaults.standardUserDefaults().setObject(self.time, forKey: "t")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    print("data loaded: api = \(self.aqi), concentration = \(self.concentration), time = \(tmpTime)")
                    if self.wcSession?.complicationEnabled == true {
                        self.wcSession?.transferCurrentComplicationUserInfo(["a": tmpAQI, "c": tmpConcentration, "t": tmpTime])
                    }
                    self.sendLocalNotif("解析得到新数据，刷新手表", badge: tmpAQI)
                    completionHandler?(.NewData)
                    return
                }
                if tmpAQI < 1 || tmpConcentration < 1 {
                    self.sendLocalNotif("解析数据出错", badge: -1)
                }
                if tmpAQI == self.aqi && tmpConcentration == self.concentration {
                    self.sendLocalNotif("数据未变", badge: -1)
                }
            }
            self.isLoadingData = false
            completionHandler?(.NoData)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UIApplication.sharedApplication().setKeepAliveTimeout(600) { () -> Void in
            NSLog("voip called...")
            self.fetchNewData()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

