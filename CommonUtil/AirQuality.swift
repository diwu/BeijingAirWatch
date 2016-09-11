//
//  AirQualityData.swift
//  BeijingAirWatch
//
//  Created by Di Wu on 9/10/16.
//  Copyright © 2016 Beijing Air Watch. All rights reserved.
//

import Foundation

private let timePlaceholder = "N/A"

struct AirQuality {
    var aqi = -1
    var concentration = -1.0
    var time = timePlaceholder
    func saveToDisk() {
        UserDefaults.standard.set(aqi, forKey: "a")
        UserDefaults.standard.set(concentration, forKey: "c")
        UserDefaults.standard.set(time, forKey: "t")
        UserDefaults.standard.synchronize()
    }
    static func cleanDisk() {
        UserDefaults.standard.set(nil, forKey: "a")
        UserDefaults.standard.set(nil, forKey: "c")
        UserDefaults.standard.set(nil, forKey: "t")
        UserDefaults.standard.synchronize()
    }
    init?() {
        guard let a = UserDefaults.standard.value(forKey: "a") as? Int else {
            return nil
        }
        guard let c = UserDefaults.standard.value(forKey: "c") as? Double else {
            return nil
        }
        guard let t = UserDefaults.standard.value(forKey: "t") as? String else {
            return nil
        }
        self.init(aqi: a, concentration: c, time: t)
    }
    init?(aqi a: Int, concentration c: Double, time t: String) {
        guard a > 1 else {
            return nil
        }
        guard c > 1.0 else {
            return nil
        }
        guard t != timePlaceholder else {
            return nil
        }
        aqi = a
        concentration = c
        time = t
    }
    
}
