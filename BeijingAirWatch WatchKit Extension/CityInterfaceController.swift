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
    
    @IBOutlet var cityPicker: WKInterfacePicker!
    
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

