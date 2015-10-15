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
    private var session: NSURLSession?
    private let TIME_OUT_LIMIT: Double = 10.0;
    private var wcSession: WCSession?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        if (WCSession.isSupported()) {
            wcSession = WCSession.defaultSession()
            wcSession?.delegate = self
            wcSession?.activateSession()
        }
        if NSUserDefaults.standardUserDefaults().integerForKey("a") > 1 {
            aqi = NSUserDefaults.standardUserDefaults().integerForKey("a")
        }
        if NSUserDefaults.standardUserDefaults().doubleForKey("c") > 1.0 {
            concentration = NSUserDefaults.standardUserDefaults().doubleForKey("c")
        }

        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("called... complication enabled = \(wcSession?.complicationEnabled)");
        if wcSession?.complicationEnabled == true {
            test(completionHandler)
        } else {
            completionHandler(.NewData)
        }
    }
    
    func httpGet(request: NSURLRequest!, callback: (String, String?) -> Void) {
        if session == nil {
            session = NSURLSession.sharedSession()
            session?.configuration.timeoutIntervalForRequest = TIME_OUT_LIMIT
            session?.configuration.timeoutIntervalForResource = TIME_OUT_LIMIT
        }
        let task = session?.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if error != nil {
                callback("", error!.localizedDescription)
            } else {
                let result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                callback(result as String, nil)
            }
        }
        task?.resume()
    }
    
    func parseAQI(data: String) -> Int {
        let escapedString: String? = data.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        if let unwrapped = escapedString {
            let arr = unwrapped.componentsSeparatedByString("%20AQI%0D%0A")
            for s in arr {
                let subArr = s.componentsSeparatedByString("%09%09%09%09%09%09%09%09%09")
                if let tmp = subArr.last {
                    if Int(tmp) > 1 {
                        return Int(tmp)!
                    }
                }
            }
        }
        return -1
    }
    
    func parseConcentration(data: String) -> Double {
        let escapedString: String? = data.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        if let unwrapped = escapedString {
            let arr = unwrapped.componentsSeparatedByString("%20%C3%82%C2%B5g%2Fm%C3%82%C2%B3%20%0D%0A%09%09%09%09%09%09%09%09")
            for s in arr {
                let subArr = s.componentsSeparatedByString("%09%09%09%09%09%09%09%09%09")
                if let tmp = subArr.last {
                    if Double(tmp) > 1 {
                        return Double(tmp)!
                    }
                }
            }
        }
        return -1.0
    }
    
    func test(completionHandler: (UIBackgroundFetchResult) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.stateair.net/web/post/1/1.html")!)
        httpGet(request){
            (data, error) -> Void in
            if error != nil {
                print(error)
            } else {
                let tmpAQI = self.parseAQI(data)
                let tmpConcentration = self.parseConcentration(data)
                if tmpAQI > 1 && tmpConcentration > 1.0 && (tmpAQI != self.aqi || tmpConcentration != self.concentration) {
                    self.aqi = tmpAQI
                    self.concentration = tmpConcentration
                    NSUserDefaults.standardUserDefaults().setInteger(self.aqi, forKey: "a")
                    NSUserDefaults.standardUserDefaults().setDouble(self.concentration, forKey: "c")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    print("data loaded: api = \(self.aqi), concentration = \(self.concentration)")
                    if self.wcSession?.complicationEnabled == true {
                        self.wcSession?.transferCurrentComplicationUserInfo(["a": tmpAQI, "c": tmpConcentration])
                    }
                    completionHandler(.NewData)
                    return
                }
            }
            self.isLoadingData = false
            completionHandler(.NewData)
        }
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

