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
            NSUserDefaults.standardUserDefaults().setObject(CitiesList[selectedIndex].rawValue, forKey: "selected_city")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        popController()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        var arr = [WKPickerItem]()
        for city in CitiesList {
           let item = WKPickerItem.init()
            item.title = city.rawValue
            arr.append(item)
        }
        cityPicker.setItems(arr)
        selectedIndex = CitiesList.indexOf(selectedCity())!
        cityPicker.setSelectedItemIndex(selectedIndex)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

