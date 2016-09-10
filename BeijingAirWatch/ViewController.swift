//
//  ViewController.swift
//  BeijingAirWatch
//
//  Created by Di Wu on 10/15/15.
//  Copyright © 2015 Beijing Air Watch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.wcSession?.isComplicationEnabled == true {
            delegate.test(completionHandler: { (result: UIBackgroundFetchResult) -> Void in
                
            })
        }
    }

}

