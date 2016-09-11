//
//  InterfaceController.swift
//  BeijingAirWatch WatchKit Extension
//
//  Created by Di Wu on 10/15/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var refreshButton: WKInterfaceButton!
    @IBOutlet var cityButton: WKInterfaceButton!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var aqiLabel: WKInterfaceLabel!
    @IBOutlet var sourceLabel: WKInterfaceLabel!
    @IBOutlet var concentrationLabel: WKInterfaceLabel!
    
    private var aqi: Int = -1
    private var concentration: Double = -1.0
    private var time: String? = "Invalid"
    private var session: URLSession?
    private var previousCity: City = .Beijing
    private var task: URLSessionDataTask?
    
    @IBAction func cityButtonPressed() {

    }
    @IBAction func refreshButtonPressed() {
        guard let delegate = WKExtension.shared().delegate as? ExtensionDelegate else {
            return
        }
        delegate.scheduleDownloadTask()
    }
    
    func didReceiveNotification(notif: Notification) {
        print("InterfaceController did receive notification")
        guard let _ = AirQuality() else {
            return
        }
        print("Air Quality did construct")
        populateLabels()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("-----> InterfaceController awake")
        let action = #selector(InterfaceController.didReceiveNotification(notif:))
        NotificationCenter.default.addObserver(self, selector: action, name: Notification.Name(LATEST_DATA_READY_NOTIFICATION_NAME), object: nil)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("-----> InterfaceController willActivate")
        if task != nil {
            task?.cancel()
        }
        if previousCity != selectedCity() {
            refreshButtonPressed()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("-----> InterfaceController didDeactivate")
        previousCity = selectedCity()
        if let unwrapped = task {
            unwrapped.cancel()
            task = nil
            toggleAllButtons(enable: true)
        }
    }
    
    func populateLabels() {
        guard let airQuality = AirQuality() else {
            timeLabel.setText("--")
            aqiLabel.setText("--")
            concentrationLabel.setText("--")
            return
        }
        timeLabel.setText(airQuality.time)
        aqiLabel.setText("AQI: \(airQuality.aqi)")
        concentrationLabel.setText("PM2.5: \(airQuality.concentration)")
    }
    
    func toggleAllButtons(enable: Bool) {
        refreshButton.setEnabled(enable)
        cityButton.setEnabled(enable)
    }
}
