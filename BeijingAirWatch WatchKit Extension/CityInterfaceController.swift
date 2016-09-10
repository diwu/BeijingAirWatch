//
//  CityInterfaceController.swift
//  BeijingAirWatch
//
//  Created by Di Wu on 10/16/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import WatchKit
import Foundation

class CityInterfaceController: WKInterfaceController {
    
    private var selectedIndex: Int = -1
    
    @IBOutlet var cityPicker: WKInterfacePicker!
    
    @IBOutlet var confirmCityButton: WKInterfaceButton!
    @IBAction func cityDidSelected(value: Int) {
        print("selected city: \(CitiesList[value].rawValue)")
        confirmCityButton.setTitle("Confirm: \(CitiesList[value].rawValue)")
        selectedIndex = value
    }
    @IBAction func confirmCityButtonPressed() {
        if selectedIndex != -1 {

            let previousSelectedCity: City = selectedCity()
            
            UserDefaults.standard.set(CitiesList[self.selectedIndex].rawValue, forKey: "selected_city")
            UserDefaults.standard.synchronize()
            
            syncCityToIOSApp(replyHandler: { (reply: [String : Any]) -> Void in
                
                self.pop()
                
                }, errorHandler: { (error: Error) -> Void in
                    
                print("watch failed to send city to ios app")
                    
                    UserDefaults.standard.set(previousSelectedCity.rawValue, forKey: "selected_city")
                    UserDefaults.standard.synchronize()
                    
            })
        }
    }
    
    func startWCSession() {
        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
        delegate.startWCSession()
    }
    
    func syncCityToIOSApp(replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)?) {
        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
        delegate.sendCityToIOSApp(replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        var arr = [WKPickerItem]()
        for city in CitiesList {
           let item = WKPickerItem.init()
            item.title = city.rawValue
            arr.append(item)
        }
        cityPicker.setItems(arr)
        selectedIndex = CitiesList.index(of:selectedCity())!
        cityPicker.setSelectedItemIndex(selectedIndex)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        startWCSession()
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

