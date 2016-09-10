//
//  CommonUtil.swift
//  BeijingAirWatch
//
//  Created by Di Wu on 10/15/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import Foundation

let DEBUG_LOCAL_NOTIFICATION : Bool = false

let TIME_OUT_LIMIT: Double = 15.0;
let TIME_OUT_LIMIT_IOS: Double = 30.0;

enum City: String {
    case Beijing = "Beijing"
    case Chengdu = "Chengdu"
    case Guangzhou = "Guangzhou"
    case Shanghai = "Shanghai"
    case Shenyang = "Shenyang"
}

func parseTime(data: String) -> String {
    let escapedString: String? = data.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
//    print("data = \(escapedString)")
    if let unwrapped = escapedString {
        let arr = unwrapped.components(separatedBy: "%0D%0A%09%09%09%09%09%09%09%09%3C")
        for s in arr {
            let subArr = s.components(separatedBy: "%3E%0D%0A%09%09%09%09%09%09%09%09%09")
            if let tmp = subArr.last {
                if (tmp.contains("PM") || tmp.contains("AM")) && tmp.characters.count <= 40 {
                    return tmp.removingPercentEncoding!
                }
            }
        }
    }
    return "Invalid Time"
}

func parseAQI(data: String) -> Int {
    let escapedString: String? = data.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    if let unwrapped = escapedString {
        let arr = unwrapped.components(separatedBy: "%20AQI%0D%0A")
        for s in arr {
            let subArr = s.components(separatedBy: "%09%09%09%09%09%09%09%09%09")
            if let tmp = subArr.last {
                guard let intValue = Int(tmp) else {
                    return -1
                }
                guard intValue > 1 else {
                    return -1
                }
                return intValue
            }
        }
    }
    return -1
}

func parseConcentration(data: String) -> Double {
    let escapedString: String? = data.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    if let unwrapped = escapedString {
        let arr = unwrapped.components(separatedBy: "%20%C3%82%C2%B5g%2Fm%C3%82%C2%B3%20%0D%0A%09%09%09%09%09%09%09%09")
        for s in arr {
            let subArr = s.components(separatedBy: "%09%09%09%09%09%09%09%09%09")
            if let tmp = subArr.last {
                guard let doubleValue = Double(tmp) else {
                    return -1.0
                }
                guard doubleValue > 1.0 else {
                    return -1
                }
                return doubleValue
            }
        }
    }
    return -1.0
}

func sharedSessionForIOS() -> URLSession {
    let session = URLSession.shared
    session.configuration.timeoutIntervalForRequest = TIME_OUT_LIMIT_IOS
    session.configuration.timeoutIntervalForResource = TIME_OUT_LIMIT_IOS
    return session
}

func sessionForWatchExtension() -> URLSession {
    let session = URLSession.shared
    session.configuration.timeoutIntervalForRequest = TIME_OUT_LIMIT
    session.configuration.timeoutIntervalForResource = TIME_OUT_LIMIT
    return session
}

func createHttpGetDataTask(session: URLSession?, request: URLRequest!, callback: @escaping (String, String?) -> Void) -> URLSessionDataTask? {
    let task = session?.dataTask(with: request){
        (data, response, error) -> Void in
        if error != nil {
            callback("", error!.localizedDescription)
        } else {
            let result = String(data: data!, encoding: .ascii)!
            callback(result, nil)
        }
    }
    return task
}

func createRequest() -> URLRequest {
    return URLRequest(url: URL(string: sourceURL(city: selectedCity()))!)
}

func sourceURL(city: City) -> String {
    switch city {
    case .Beijing:
        return "http://www.stateair.net/web/post/1/1.html";
    case .Chengdu:
        return "http://www.stateair.net/web/post/1/2.html";
    case .Guangzhou:
        return "http://www.stateair.net/web/post/1/3.html";
    case .Shanghai:
        return "http://www.stateair.net/web/post/1/4.html";
    case .Shenyang:
        return "http://www.stateair.net/web/post/1/5.html";
    }
}

func selectedCity() -> City {
    let sc: String? = UserDefaults.standard.string(forKey:"selected_city")
    if sc == nil {
        return .Beijing
    } else {
        return City(rawValue: sc!)!
    }
}

func sourceDescription() -> String {
    return "\(selectedCity()): \(sourceURL(city:selectedCity()))"
}

let CitiesList: [City] = [.Beijing, .Chengdu, .Guangzhou, .Shanghai, .Shenyang]

