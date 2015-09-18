//
//  ViewController.swift
//  InstrumentUtils_iOS_swift
//
//  Created by Moses Gunesch on 9/16/15.
//  Copyright © 2015 Instrument. All rights reserved.
//

import UIKit
import InstrumentUtils_iOS

class EasyFormInputs_IBLayout: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var container4: UIView!
    @IBOutlet weak var container5: UIView!
    @IBOutlet weak var container6: UIView!
    @IBOutlet weak var container7: UIView!
    @IBOutlet weak var container8: UIView!
    @IBOutlet weak var slider: UISlider! // the slider doesn't actively do anything in this example, just included to show a more custom layout
    @IBOutlet weak var submitButton: UIButton!
    
    var textInput:EasyFormInput!
    var emailInput:EasyFormInput!
    var multilineTextInput:EasyFormInput!
    var roundNumberInput:EasyFormInput!
    var currencyInput:EasyFormInput!
    var dateInput:EasyFormInput!
    var typeInSelectInput:EasyFormInput!
    var typeInSelectWithUniqueInput:EasyFormInput!
    
    let outerMargin: CGFloat = 20
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // IB notes:
        //
        // To set up a scroll view properly, add edge constraints of 0 to the superview, add a single content view inside it,
        // then add edge constraints to the scrollView and a horizontal centering contstraint to the scrollView.
        // (When doing this from scratch, IB will show a red error at this point, but that's just because the container is empty.)
        //
        // It's important to understand that the contents of the container view need constraints binding each item's
        // top, bottom, and height so that the scroll view can calculate its size. Once there's a solid chain from top to bottom,
        // the error will disappear and all sizing functionality will work. If you miss any of these steps, things like multiline
        // text resizing won't work right.

        // A single config can be reused for all inputs - since it's a struct it will be copied each time it's used.
        var config = EasyFormInputConfig()

        // Components are now added to each container...
        
        // Single Line Text Input
        self.textInput = EasyFormInput(parentView: container1, type: EasyFormInputType.Text, title: "Name", configuration: config)
        
        // Email Input
        self.emailInput = EasyFormInput(parentView: container2, type: EasyFormInputType.Email, title: "Email", required: true, configuration: config)
        
        // Multi-line Text Input
        config.multiline = true
        self.multilineTextInput = EasyFormInput(parentView: container3, type: EasyFormInputType.Text, title: "Description", initialValue:"This is a multiline text container that will automatically expand as you enter text.", configuration: config)
        
        // Rounded Number Input
        config.multiline = false
        config.decimalPlaces = 0
        config.minValueForNumberInput = 1
        self.roundNumberInput = EasyFormInput(parentView: container4, type: EasyFormInputType.Number, title: "Guests - at least 1", required: true, configuration: config)
        
        // Currency Input with 2 fixed decimal places (numbers flow from right to left as they're typed in)
        config.minValueForNumberInput = 0
        config.decimalPlaces = 2
        config.decimalPlacesAreFixed = true
        config.currencySymbol = "$"
        self.currencyInput = EasyFormInput(parentView: container5, type: EasyFormInputType.Number, title: "Price", configuration: config)
        
        // Date Input (you can customize the date style in the config if you want)
        self.dateInput = EasyFormInput(parentView: container6, type: EasyFormInputType.Date, title: "Date", initialValue:NSDate(), configuration: config)
        
        // Select input with type-in search filtering (config.typeInSelect can be turned off for a plain select)
        self.typeInSelectInput = EasyFormInput(parentView: container7, type: EasyFormInputType.Select, title: "Team", initialValue:"Crush", selectValues: teamData, configuration: config)
        
        // Select with search filtering that also lets you create a new unique value.
        config.typeInSelect = true
        config.typeInSelectAllowsUnique = true
        self.typeInSelectWithUniqueInput = EasyFormInput(parentView: container8, type: EasyFormInputType.Select, title: "Client", selectValues: clientData, configuration: config)
    }
    
    @IBAction func submitTapped(sender:UIButton)
    {
        let inputs = [textInput, emailInput, multilineTextInput, roundNumberInput, currencyInput, dateInput, typeInSelectInput, typeInSelectWithUniqueInput]
        for input in inputs {
            input.resignFirstResponder()
            
            if !input.valueIsValid {
                var message:String!
                switch input {
                case roundNumberInput:
                    message = "Please enter the number of guests."
                case emailInput:
                    message = "Please enter a valid email."
                default:
                    message = "A required field isn't filled out yet."
                }
                
                showOKAlertFrom(self, title: "Oops!", message: message) { (action:UIAlertAction) -> Void in
                    input.becomeFirstResponder()
                }
                return
            }
        }
        
        // This demos the blocking progress view which is simple to use - passing a string to display is optional.
        BlockingProgressIndicator.show("Working...")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] in
            
            BlockingProgressIndicator.hide()
            showOKAlertFrom(self, title: "Booyah!", message: "You've found success in all things. It's Miller time!")
        }
    }
}

