//
//  AppDelegate.swift
//  InstrumentUtils_iOS_swift
//
//  Created by Moses Gunesch on 9/16/15.
//  Copyright © 2015 Instrument. All rights reserved.
//

import UIKit

// Global select data. Note that selectValues must be in [[String:String]] format and include keys for "name" and "id" in each item.
let teamData = [["name": "Fun", "id": "0"], ["name": "Crush", "id": "1"], ["name": "Wizard Wizard", "id": "2"], ["name": "Garage", "id": "3"], ["name": "Spirit", "id": "4"], ["name": "Brand Team", "id": "5"], ["name": "Operations", "id": "6"]]

let clientData = [["name": "Nike", "id": "0"], ["name": "Google", "id": "1"], ["name": "Stumptown Coffee", "id": "2"], ["name": "eBay", "id": "3"], ["name": "Specialized", "id": "4"]]

// Global alert helper
func showOKAlertFrom(controller:UIViewController, title:String?, message:String?, handler:((UIAlertAction) -> Void)? = nil)
{
    let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:handler))
    controller.presentViewController(alert, animated: true, completion:nil)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}

