//
//  ViewController.swift
//  InstrumentUtils_iOS_swift
//
//  Created by Moses Gunesch on 9/16/15.
//  Copyright © 2015 Instrument. All rights reserved.
//

import UIKit
import InstrumentUtils_iOS

class EasyFormInputs_CodeLayout: UIViewController {
    
    var scrollView: UIScrollView = UIScrollView()
    var mainView: UIView = UIView()
    var inputContainerViews = [UIView]()
    var textInput:EasyFormInput!
    var emailInput:EasyFormInput!
    var multilineTextInput:EasyFormInput!
    var roundNumberInput:EasyFormInput!
    var currencyInput:EasyFormInput!
    var dateInput:EasyFormInput!
    var typeInSelectInput:EasyFormInput!
    var typeInSelectWithUniqueInput:EasyFormInput!

    var slider = UISlider()
    var submitButton = UIButton(type: UIButtonType.System)
    
    let innerMargin: CGFloat = 8
    let outerMargin: CGFloat = 20
    let bottomSpaceForTabBar: CGFloat = 50
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // A helper method is used here to set up a scrollView with a content container view inside it.
        // It's important to understand that the contents of the container view need constraints binding each item's
        // top, bottom, and height so that the scroll view can calculate its size.
        let (mainContainerView, scrollView) = self.view.createScrollableContainerView()
        self.mainView = mainContainerView
        self.scrollView = scrollView
        
        // A temp scrollView color can help when building a complex layout in code, so you can see how big the container view actually is.
//        scrollView.backgroundColor = UIColor.redColor()
//        mainView.backgroundColor = UIColor.whiteColor()
        
        // A single config can be reused for all inputs - since it's a struct it will be copied each time it's used.
        var config = EasyFormInputConfig()
        config.margins = UIEdgeInsetsMake(0, outerMargin, 0, outerMargin)
        let nominalInputHeight: CGFloat = 50
        
        // Components and containers are created, and the containers are chained to each other in a stack.
        // Normally the constraints code for doing something like this would be ridiculous, but the ConstraintsHelpers
        // are leveraged for very little added code.
        
        // Single Line Text Input
        mainView.addStackingConstraintsForSubview(makeContainer(), topItem: mainView, top: outerMargin, height: nominalInputHeight)
        self.textInput = EasyFormInput(parentView: lastContainer(), type: .Text, title: "Name", configuration: config)
        
        // Email Input
        mainView.addStackingConstraintsForSubview(makeContainer(), topItem: previousContainer(), top: innerMargin, height: nominalInputHeight)
        self.emailInput = EasyFormInput(parentView: lastContainer(), type: .Email, title: "Email", required: true, configuration: config)
        
        // Multi-line Text Input
        config.multiline = true
        mainView.addStackingConstraintsForSubview(makeContainer(), topItem: previousContainer(), top: innerMargin, height: nominalInputHeight)
        self.multilineTextInput = EasyFormInput(parentView: lastContainer(), type: .Text, title: "Description", initialValue:"This is a multiline text container that will automatically expand as you enter text.", configuration: config)
        
        // Rounded Number Input
        config.multiline = false
        config.decimalPlaces = 0
        config.minValueForNumberInput = 1
        mainView.addStackingConstraintsForSubview(makeContainer(), topItem: previousContainer(), top: innerMargin, height: nominalInputHeight)
        self.roundNumberInput = EasyFormInput(parentView: lastContainer(), type: .Number, title: "Guests - at least 1", required: true, configuration: config)
        
        // Example of adding some other UI component into the vertical stack (the slider doesn't actively do anything in this example)
        
        mainView.addSubview(slider)
        mainView.addEqualConstraintForSubview(slider, attribute: NSLayoutAttribute.Top, otherSubview: lastContainer(), otherAttribute: NSLayoutAttribute.Bottom).constant = innerMargin
        mainView.addEqualConstraintForSubview(slider, attribute: NSLayoutAttribute.CenterX)
        slider.addSimpleConstraintForAttribute(NSLayoutAttribute.Width, constant: 250)
        
        // Currency Input with 2 fixed decimal places (numbers flow from right to left as they're typed in)
        config.minValueForNumberInput = 0
        config.decimalPlaces = 2
        config.decimalPlacesAreFixed = true
        config.currencySymbol = "$"
        mainView.addStackingConstraintsForSubview(makeContainer(), topItem: slider, top: innerMargin, height: nominalInputHeight)
        self.currencyInput = EasyFormInput(parentView: lastContainer(), type: .Number, title: "Price", configuration: config)
        
        // Date Input (you can customize the date style in the config if you want)
        mainView.addStackingConstraintsForSubview(makeContainer(), topItem: previousContainer(), top: innerMargin, height: nominalInputHeight)
        self.dateInput = EasyFormInput(parentView: lastContainer(), type: .Date, title: "Date", initialValue:NSDate(), configuration: config)
        
        // Select input with type-in search filtering (config.typeInSelect can be turned off for a plain select)
        mainView.addStackingConstraintsForSubview(makeContainer(), topItem: previousContainer(), top: innerMargin, height: nominalInputHeight)
        self.typeInSelectInput = EasyFormInput(parentView: lastContainer(), type: .Select, title: "Team", initialValue:"Crush", selectValues: teamData, configuration: config)
        
        // Select with search filtering that also lets you create a new unique value.
        config.typeInSelect = true
        config.typeInSelectAllowsUnique = true
        mainView.addStackingConstraintsForSubview(makeContainer(), topItem: previousContainer(), top: innerMargin, height: nominalInputHeight)
        self.typeInSelectWithUniqueInput = EasyFormInput(parentView: lastContainer(), type: .Select, title: "Client", selectValues: clientData, configuration: config)
        
        // Add a submit button to the bottom of the stack.
        // Constraints: edgeMargins is passed nil so we can float the button to center. Bottom constraint params are passed to finish the stack.
        mainView.addSubview(submitButton)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.addTarget(self, action: "submitTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        mainView.addStackingConstraintsForSubview(submitButton, topItem: lastContainer(), top: outerMargin, edgeMargins:nil, bottomItem:mainView, bottom: outerMargin + bottomSpaceForTabBar, height: 30)
        mainView.addEqualConstraintForSubview(submitButton, attribute: NSLayoutAttribute.CenterX)
    }
    
    func submitTapped(sender:UIButton)
    {
        for container in inputContainerViews {
            if let input = container.subviews.first as? EasyFormInput {
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
        }
        
        // This demos the blocking progress view which is simple to use - passing a string to display is optional.
        BlockingProgressIndicator.show("Working...")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] in
            BlockingProgressIndicator.hide()
            self.showOKAlertFrom(self, title: "Booyah!", message: "You've found success in all things. It's Miller time!")
        }
    }
    
    func makeContainer() -> UIView
    {
        let container = UIView()
        mainView.addSubview(container)
        container.backgroundColor = UIColor.lightGrayColor()
        inputContainerViews.append(container)
        return container
    }
    
    func lastContainer() -> UIView
    {
        return inputContainerViews.last!
    }
    
    func previousContainer() -> UIView
    {
        return inputContainerViews[inputContainerViews.count - 2]
    }
    
    func showOKAlertFrom(controller:UIViewController, title:String?, message:String?, handler:((UIAlertAction) -> Void)? = nil)
    {
        let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:handler))
        controller.presentViewController(alert, animated: true, completion:nil)
    }
}

