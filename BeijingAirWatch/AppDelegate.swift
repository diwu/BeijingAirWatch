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
    
    func registerBackgroundVOIPCallback() {
        let ret = UIApplication.shared.setKeepAliveTimeout(600) { () -> Void in
            NSLog("voip called...")
            self.properlyEndBgTaskIfThereIsOne()
            if self.alreadyFetchedLatestData() == true {
                return
            }
            self.bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
                self.properlyEndBgTaskIfThereIsOne()
            })
//            let interval: dispatch_time_t = UInt64(TIME_OUT_LIMIT_IOS) * NSEC_PER_SEC
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(interval)), dispatch_get_main_queue(), { () -> Void in
                self.fetchNewData()
//            })
        }
        self.sendLocalNotif(text: "Trying to register VOIP. Result=\(ret)", badge: -1)
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
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : Any]) -> Void) {
        if message["selected_city"] != nil {
            let city: String = message["selected_city"] as! String
            UserDefaults.standard.set(city, forKey: "selected_city")
            UserDefaults.standard.synchronize()
            print("ios app sourcel url: \(sourceDescription())")
            sendLocalNotif(text: "Updating City to:\(selectedCity())", badge: -1)
        }
        print("did receive wc session msg (ios app side): \(message)")
        replyHandler(["xxx":"xxx"])
        registerBackgroundVOIPCallback()
    }
    
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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
            /*
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge,UIUserNotificationType.Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
 */
        }

        return true
    }
    
    /*
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        self.sendLocalNotif("Bg fetch API wakes up the app.", badge: -1)

        registerBackgroundVOIPCallback()

        completionHandler(.NoData)
    }
*/
    
    func fetchNewData() {
        print("called... complication enabled = \(wcSession?.isComplicationEnabled)");
        startWCSession()
        
        test(completionHandler: nil)

        /*
        if wcSession?.complicationEnabled == true {
            test(nil)
        } else {
            sendLocalNotif("\(selectedCity()):未激活，不刷新", badge: -1)
            properlyEndBgTaskIfThereIsOne()
        }
*/
    }
    
    func properlyEndBgTaskIfThereIsOne() {
        if self.bgTaskID != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(self.bgTaskID)
            self.bgTaskID = UIBackgroundTaskInvalid
        }
    }
    
    func sendLocalNotif(text: String, badge: Int) {
        /*
        if DEBUG_LOCAL_NOTIFICATION == true {
            let notif = UILocalNotification()
            notif.fireDate = NSDate.init(timeIntervalSinceNow: 1)
            notif.alertBody = text
            notif.timeZone = NSTimeZone.defaultTimeZone()
            notif.soundName = UILocalNotificationDefaultSoundName
            if badge > 0 {
                notif.applicationIconBadgeNumber = badge
            }
            UIApplication.shared.scheduleLocalNotification(notif)
        }
 */
    }
    
    func test(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        sendLocalNotif(text: "\(selectedCity()):Fetching new data...", badge: -1)
        let request = createRequest()
        if session == nil {
            session = sharedSessionForIOS()
        }
        self.task?.cancel()
        self.task = createHttpGetDataTask(session: session, request: request){
            (data, error) -> Void in
            if error != nil {
                print(error)
                self.sendLocalNotif(text: "\(selectedCity()):Failed to fetch latest data. Will retry in 10 minutes.", badge: -1)
            } else {
                let tmpAQI = parseAQI(data: data)
                let tmpConcentration = parseConcentration(data: data)
                let tmpTime = parseTime(data: data)
                if tmpAQI > 1 && tmpConcentration > 1.0 && (tmpAQI != self.aqi || tmpConcentration != self.concentration || tmpTime != self.time) {
                    self.aqi = tmpAQI
                    self.concentration = tmpConcentration
                    self.time = tmpTime
                    UserDefaults.standard.set(self.aqi, forKey: "a")
                    UserDefaults.standard.set(self.concentration, forKey: "c")
                    UserDefaults.standard.set(self.time, forKey: "t")
                    UserDefaults.standard.synchronize()
                    print("data loaded: api = \(self.aqi), concentration = \(self.concentration), time = \(tmpTime)")
                    self.wcSession?.transferCurrentComplicationUserInfo(["a": tmpAQI, "c": tmpConcentration, "t": tmpTime])
                    self.sendLocalNotif(text: "\(selectedCity()):New data available. Transfering to watch.", badge: tmpAQI)
                    completionHandler?(.newData)
                    self.properlyEndBgTaskIfThereIsOne()
                    return
                }
                if tmpAQI < 1 || tmpConcentration < 1 {
                    self.sendLocalNotif(text: "\(selectedCity()):Error when parsing data. Will retry in 10 minutes.", badge: -1)
                }
                if tmpAQI == self.aqi && tmpConcentration == self.concentration {
                    self.sendLocalNotif(text: "\(selectedCity()):Source data unchanged.", badge: -1)
                }
                self.sendLocalNotif(text: "\(selectedCity()):Fetching done for now.", badge: -1)
            }
            self.isLoadingData = false
            completionHandler?(.noData)
            self.properlyEndBgTaskIfThereIsOne()
        }
        self.task?.resume()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("ios app did become active")
        registerBackgroundVOIPCallback()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

