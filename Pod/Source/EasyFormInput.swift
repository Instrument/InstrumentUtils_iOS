/*
Copyright (c) 2015, Instrument Marketing, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project.
*/

import UIKit

let defaultBlue = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)

/**
- Parameter Text: Can be single or multiline text entry, depending on configuration
- Parameter Email: Validated using configuration's `validationErrorTextColor`, which can be checked using `valueIsValid`
- Parameter Number: Numerical keyboard input with multiple configuration options for currency, commas, decimals, etc
- Parameter Select: Can be configured as a date picker or a standard picker, which can optionally include type-in search and
                    the ability to enter new text. Component `value` will differ based on configuration.
*/
public enum EasyFormInputType
{
    case Text
    case Email
    case Number
    case Select
    case Date
    
    func isPickerType() -> Bool {
        return self == .Select || self == .Date
    }
}

/**
Configuration options.

*Tip: make one config then modify it for each component instance - since it's a struct it will be copied when passed.*

- Parameter maxCharsForTextInput: `0` = unlimited. Default `255`
- Parameter multiline: Default `false`

- Parameter minValueForNumberInput: `.Number` mode.
- Parameter maxValueForNumberInput: `.Number` mode. `0` (default) = unlimited
- Parameter numberShowsCommaSeparators: `.Number` mode. Default `true`
- Parameter decimalPlaces: `.Number` mode. Default `2` places
- Parameter decimalPlacesAreFixed: `.Number` mode. Default `false`. If `true`, places always show and numbers flow in from right to left
- Parameter currencySymbol: `.Number` mode. Left-hand currency symbol

- Parameter typeInSelect: `.Select` mode. Allows type-in filtering of picker values. Default `true`
- Parameter typeInSelectAllowsUnique: When used with `typeInSelect`, shows a Create button and allows user to input text that doesn't match
                                       a picker entry. Default `false`

- Parameter dateStyle: `.Date` mode. Default `NSDateFormatterStyle.ShortStyle`
- Parameter dateFormat: `.Date` mode. May be set to a NSDateFormatter dateFormat string. Overrides `dateStyle` if set

- Parameter textFont: Default system `24.0`
- Parameter textColor: After text entry. Default `grayColor`
- Parameter promptTextColor: Before text entry. Default `lightGrayColor`
- Parameter validationErrorTextColor: Default `redColor`
- Parameter titleLabelFont: Small title label above input text after entry. Default system `12.0`
- Parameter titleLabelColor: Default `lightGrayColor`
- Parameter lineColor: Default `lightGrayColor`
- Parameter lineColorDuringEditing: Default `defaultBlue`
- Parameter backgroundColor: Set on container view. Default `clearColor`. *(Tip: clear allows you to set a temp bg color on
                             the container in IB to make it easier to work with)*

- Parameter pickerTextColor: Default `grayColor`
- Parameter pickerFont: Default system `16.0`
- Parameter pickerSelectButtonTitle: Default `"Select"`
- Parameter pickerCreateButtonTitle: Shows in `.TextAndSelect` mode only. Default `"Create"`
- Parameter pickerResetButtonTitle: Allows user to fully clear the field. Default `"Reset"`
- Parameter pickerButtonColor: Default `defaultBlue`
- Parameter pickerButtonFont: Default system `12.0`

- Parameter margins: Padding around component
- Parameter paddingAboveText: Padding between title and text
- Parameter paddingBelowText: Padding between text and line
- Parameter multilineAdjustments: Tweaks applied to make mutliline text view visually match single-line fields

- Parameter managesInsetsForKeyboard: Reduces containing scrollView's bottom contentInset when keyboard is shown.
*/
public struct EasyFormInputConfig
{
    public var maxCharsForTextInput = 255
    public var multiline = false
    
    public var minValueForNumberInput: Double = 0
    public var maxValueForNumberInput: Double = 0
    public var numberShowsCommaSeparators = true
    public var decimalPlaces = 2
    public var decimalPlacesAreFixed = false
    public var currencySymbol = ""
    
    public var typeInSelect = true
    public var typeInSelectAllowsUnique = false
    
    public var dateStyle = NSDateFormatterStyle.ShortStyle
    public var dateFormat:String?
    
    public var textFont = UIFont.systemFontOfSize(24.0)
    public var textColor = UIColor.grayColor()
    public var promptTextColor = UIColor.lightGrayColor()
    public var validationErrorTextColor = UIColor.redColor()
    public var titleLabelFont = UIFont.systemFontOfSize(12.0)
    public var titleLabelColor = UIColor.lightGrayColor()
    public var lineColor = UIColor.lightGrayColor()
    public var lineColorDuringEditing = defaultBlue
    public var backgroundColor = UIColor.clearColor()
    
    public var pickerTextColor = UIColor.grayColor()
    public var pickerFont = UIFont.systemFontOfSize(16.0)
    public var pickerSelectButtonTitle = "Select"
    public var pickerCreateButtonTitle = "Create"
    public var pickerResetButtonTitle = "Reset"
    public var pickerButtonColor = defaultBlue
    public var pickerButtonFont = UIFont.systemFontOfSize(12.0)
    
    public var margins = UIEdgeInsetsMake(0, 0, 0, 0)
    public var paddingAboveText = 8.0
    public var paddingBelowText = 12.0
    public var multilineAdjustments = UIEdgeInsetsMake(-5.0, -5.0, 12.0, 5.0)
    
    public var managesInsetsForKeyboard = true
    
    public init() { }
}

@objc public protocol EasyFormInputDelegate
{
    optional func formInputTextChanged(component:EasyFormInput)
    optional func formInputTextBeganEditing(component:EasyFormInput)
    optional func formInputTextFinishedEditing(component:EasyFormInput)
}

/**
A configurable form entry component with various text, numerical, and select options

- SeeAlso: valueIsValid

- Parameter parentView: An empty container view that you want this component to fill. It must use auto-layout, and for sizing to work inside
                        a scrollView, its height and top & botom edges should be bounded. The view's height constraint will be replaced for
                        resizing purposes, so that constraint shouldn't have a referencing outlet in IB

- Parameter type: A `EasyFormInputType` mode such as `.Text`

- Parameter title: Appears as prompt text in the field when blank and includes "(Required)" if the , then as a small heading above the value
If the field is required, the initial title prior to entry will include the word "(Required)"

- Parameter required: Marks prompt text with "(Required)" and affects validation results

- Parameter initialValue: Initial value, which may be `nil`, `String`, `Double`, `NSDate` or for `.Select` mode either a `[String:String]` with
                          a match in `selectValues` or a `String` that matches a "name" field in `selectValues`.

- Parameter selectValues: For select types, an array of `[String:String]` dictionaries that must each contain "name" and "id" fields

- Parameter configuration: A `EasyFormInputConfig` defining settings. You can modify and reuse a single config, since structs are copied
                           when passed
*/
public class EasyFormInput: UIView, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    /**
    Optional delegate that may be set after instantiation
    */
    public var delegate:EasyFormInputDelegate?
    
    public var type: EasyFormInputType {
        get {
            return _type
        }
    }
    internal var _type:EasyFormInputType = EasyFormInputType.Text
    
    /**
    Usable typed value of the component.
    
    The type of the return value varies depending on its current state:
    - `nil` if the component has no entry
    - `String` for `.Text`, `.Email`, or `.Select` mode with the config `typeInSelectAllowsUnique` and there is a unique entry
    - `Double` for `.Number` mode
    - `[String:String]` for `.Select` mode (except in unique text-entry case which returns `String`)
    - `NSDate` for `.Date` mode
    */
    public var value:Any? {
        get {
            if stateIsEmptyOrDefault() {
                return nil
            }
            
            switch type {
                
            case .Text, .Email:
                return stateIsEmptyOrDefault() ? nil : rawText
                
            case .Number:
                return rawText.extractedDecimalDigits().characters.count == 0 ? nil : rawText.extractedDoubleValue()
                
            case .Select:
                if config.typeInSelect && config.typeInSelectAllowsUnique {
                    if let match = selectValues!.filter({ return $0["name"] == rawText }).first {
                        return match
                    }
                    return stateIsEmptyOrDefault() ? nil : rawText
                }
                return selectValues![(picker as! UIPickerView).selectedRowInComponent(0)]
                
            case .Date:
                return (picker as! UIDatePicker).date
            }
        }
    }
    
    /**
    Always validates .Email if text has been entered, otherwise will only return false if the field is both required and empty
    */
    public var valueIsValid:Bool {
        get {
            switch type {
                
            case .Email:
                if let val = value as? String {
                    return val.isValidEmail()
                }
                return !required
                
            default:
                return value != nil || !required
            }
        }
    }
    
    /**
    For delegate use: the compnonent's current raw text, which is different than calling `value`
    
    This string will be prompt text if the component is in an empty state. Use `value` to check the component's usable, typed value.
    
    - SeeAlso: textViewIsEmptyOrDefault()
    */
    public var rawText:String {
        get {
            return self.textView.valueForKey("text") as! String! ?? ""
        }
        set {
            self.textView.setValue(newValue, forKey: "text")
        }
    }
    
    /**
    For delegate use: indicates whether the component is in an empty state (no text or default prompt text)
    */
    public func stateIsEmptyOrDefault() -> Bool
    {
        let text = self.rawText
        return text.characters.count == 0 || text == defaultTextViewText
    }
    
    /**
    The field's title.
    
    Exposed in case you want to change the title midstream.
    */
    public var title:String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            self.titleLabel.text = newValue
        }
    }
    
    /**
    By default, standard autocorrect is only enabled in multiline `.Text` mode.
    
    Exposed in case you want to change this after the component is instantiated.
    */
    public var autocorrectionType:UITextAutocorrectionType {
        get {
            return self.config.multiline ? (self.textView as! UITextView).autocorrectionType : (self.textView as! UITextField).autocorrectionType
        }
        set {
            if self.config.multiline {
                (self.textView as! UITextView).autocorrectionType = newValue
            }
            else {
                (self.textView as! UITextField).autocorrectionType = newValue
            }
        }
    }
    
    /**
    By default, autocapitalization is disabled in `.Email` mode.
    
    Exposed in case you want to change this after the component is instantiated.
    */
    public var autocapitalizationType:UITextAutocapitalizationType {
        get {
            return self.config.multiline ? (self.textView as! UITextView).autocapitalizationType : (self.textView as! UITextField).autocapitalizationType
        }
        set {
            if self.config.multiline {
                (self.textView as! UITextView).autocapitalizationType = newValue
            }
            else {
                (self.textView as! UITextField).autocapitalizationType = newValue
            }
        }
    }
    
    /**
    By default, `.Text` mode uses default keyboard, `.Email` uses `.EmailAddress` and `.Number` uses a numerical keypad.
    
    Exposed in case you want to change this after the component is instantiated.
    */
    public var keyboardType:UIKeyboardType {
        get {
            return self.config.multiline ? (self.textView as! UITextView).keyboardType : (self.textView as! UITextField).keyboardType
        }
        set {
            if self.config.multiline {
                (self.textView as! UITextView).keyboardType = newValue
            }
            else {
                (self.textView as! UITextField).keyboardType = newValue
            }
        }
    }
    
    internal var parentView:UIView!
    internal var required = false
    internal var _textView:UITextView?
    internal var _textField:UITextField?
    public var textView:UIView {
        get {
            if self.config.multiline {
                if self._textView == nil {
                    self._textView = UITextView()
                }
                return self._textView!
            }
            if self._textField == nil {
                self._textField = UITextField()
            }
            return self._textField!
        }
    }
    
    internal var textViewHeightConstraint:NSLayoutConstraint!
    public var lineView = UIView()
    public var titleLabel = UILabel()
    internal var titleLabelTopConstraint:NSLayoutConstraint!
    internal var defaultTextViewText: String {
        get {
            return required ? "\(title) (required)" : title
        }
    }
    internal var dateFormatter = NSDateFormatter()
    internal var picker: UIView?
    internal var resetButton: UIButton?
    internal var createButton: UIButton?
    internal var selectButton: UIButton?
    internal var _selectValues:[[String:String]]?
    internal var selectValues:[[String:String]]?
    internal var keyboardIsShowing = false
    internal var userTappedCreateButton = false
    internal var config:EasyFormInputConfig!
    
    public convenience init(parentView:UIView, type:EasyFormInputType, title:String, required:Bool = false, initialValue:Any? = nil, selectValues:[[String:String]]? = nil, configuration:EasyFormInputConfig? = nil)
    {
        self.init()
        
        self.parentView = parentView
        self._type = type
        self.config = configuration ?? EasyFormInputConfig()
        self.title = title
        self.required = required
        
        switch type
        {
        case .Text, .Email:
            
            if type == .Email {
                self.keyboardType = UIKeyboardType.EmailAddress
                self.autocapitalizationType = UITextAutocapitalizationType.None
            }
            
            if let initVal = initialValue as? String {
                self.rawText = initVal
            }
            
        case .Number:
            
            self.keyboardType = (config.decimalPlaces == 0 ? UIKeyboardType.NumberPad : UIKeyboardType.DecimalPad)
            
            if let initVal = initialValue as? Double {
                self.rawText = "\(max(initVal, config.minValueForNumberInput))"
            }
            else if let initVal = initialValue as? Int {
                self.rawText = "\(max(Double(initVal), config.minValueForNumberInput))"
            }
            
        case .Select:
            
            let p = UIPickerView()
            self.picker = p
            p.dataSource = self
            p.delegate = self
            
            if let values = selectValues {
                self.selectValues = values.map { $0 }
                if config.typeInSelect {
                    self._selectValues = self.selectValues.map { $0 }
                }
            }
            
            if !isNonTextEntryType()
            {
                if let initVal = initialValue as? String {
                    self.rawText = initVal
                    if let index = selectValues!.indexOf({ return $0["name"] == initVal }) {
                        (picker as! UIPickerView).selectRow(index, inComponent: 0, animated: false)
                    }
                    else { // throw error here maybe?
                        print("Error! EasyFormInput initialValue '\(initVal)' not found in selectValues: \(selectValues!)")
                    }
                }
                else if let initVal = initialValue as? [String:String] {
                    self.rawText = initVal["name"]!
                }
            }
            
        case .Date:
            
            if let dateFormat = config.dateFormat {
                dateFormatter.dateFormat = dateFormat
            }
            else {
                dateFormatter.dateStyle = config.dateStyle
            }
            let p = UIDatePicker()
            self.picker = p
            p.datePickerMode = UIDatePickerMode.Date
            
            if let initVal = initialValue as? NSDate {
                self.rawText = dateFormatter.stringFromDate(initVal)
                (picker as! UIDatePicker).setDate(initVal, animated: false)
            }
        }
        
        // add to parent view and be sure height is flexible for multiline and picker resizing
        parentView.addSubview(self)
        parentView.backgroundColor = config.backgroundColor
        parentView.addSizeMatchingConstraintsForSubview(self, withMargins: config.margins)
        let containerHeight = parentView.frame.size.height
        if let existingHeightConstraint = parentView.getConstraintForOtherView(parentView, withAttribute: NSLayoutAttribute.Height) {
            parentView.removeConstraint(existingHeightConstraint)
        }
        let parentViewHeightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: containerHeight)
         parentView.addConstraint(parentViewHeightConstraint)
        if let parentSuperView = parentView.superview {
            if config.multiline && parentSuperView.getConstraintForOtherView(parentView, withAttribute: NSLayoutAttribute.Bottom) == nil {
                // Solves a tricky problem that comes up when inputs are being generated and added in code instead of in IB,
                // where a bottom constraint is needed now for the resizing to work, but it hasn't been installed yet.
                let extraBottomConstraint = NSLayoutConstraint(item: parentSuperView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal,
                    toItem: parentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
                extraBottomConstraint.priority = 1
                parentSuperView.addConstraint(extraBottomConstraint)
            }
        }
        
        // line
        self.addSubview(lineView)
        lineView.backgroundColor = config.lineColor
        lineView.addSimpleConstraintForAttribute(NSLayoutAttribute.Height, constant: 1.0)
        self.addEqualConstraintForSubview(lineView, attribute: NSLayoutAttribute.Leading)
        self.addEqualConstraintForSubview(lineView, attribute: NSLayoutAttribute.Trailing)
        self.addEqualConstraintForSubview(lineView, attribute: NSLayoutAttribute.Bottom)
        
        // title label
        titleLabel.font = config.titleLabelFont
        titleLabel.textColor = config.titleLabelColor
        self.addSubview(titleLabel)
        self.titleLabelTopConstraint = self.addEqualConstraintForSubview(titleLabel, attribute: NSLayoutAttribute.Top)
        self.addEqualConstraintForSubview(titleLabel, attribute: NSLayoutAttribute.Leading)
        self.addEqualConstraintForSubview(titleLabel, attribute: NSLayoutAttribute.Trailing)
        titleLabel.sizeToFit()
        
        // textView
        let textView = self.textView
        if config.multiline {
            let tv = textView as! UITextView
            tv.contentInset = UIEdgeInsetsMake(config.multilineAdjustments.top, config.multilineAdjustments.left, 0, config.multilineAdjustments.right)
            tv.delegate = self
            tv.font = config.textFont
            if isNonTextEntryType() {
                tv.inputView = UIView() // suppress keyboard
            }
            else if type != .Text {
                tv.autocorrectionType = UITextAutocorrectionType.No
            }
        }
        else {
            let tf = textView as! UITextField
            tf.delegate = self
            tf.font = config.textFont
            tf.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
            if isNonTextEntryType() {
                tf.inputView = UIView() // suppress keyboard
            }
        }
        textView.backgroundColor = UIColor.clearColor() // For testing multiline edge tolerances: textView.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 0.1)
        self.insertSubview(textView, belowSubview: titleLabel)
        let bottomOfTitleLabel: CGFloat = titleLabel.frame.origin.y + titleLabel.frame.size.height
        self.addEqualConstraintForSubview(textView, attribute: NSLayoutAttribute.Top)!.constant = -(bottomOfTitleLabel + CGFloat(config.paddingAboveText))
        self.addEqualConstraintForSubview(textView, attribute: NSLayoutAttribute.Leading)
        self.addEqualConstraintForSubview(textView, attribute: NSLayoutAttribute.Trailing)
        let textToLineConstraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: lineView, attribute: NSLayoutAttribute.Top, multiplier: 1.0,
            constant: -CGFloat(config.paddingBelowText) + (config.multiline ? config.multilineAdjustments.bottom : 0))
        textToLineConstraint.priority = 1
        self.addConstraint(textToLineConstraint)
        if config.multiline {
            self.textViewHeightConstraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual,
                toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0)
            textViewHeightConstraint.priority = 1
            textView.addConstraint(textViewHeightConstraint)
        }
        
        // now adjust outer frame size, which is a >= constraint, so ignore multiple lines of text
        self.layoutIfNeeded()
        let f = textView.frame
        parentViewHeightConstraint.constant = f.origin.y + (config.multiline ? config.textFont.pointSize : f.size.height) + CGFloat(config.paddingBelowText) + 1.0
        
        if type.isPickerType() {
            makeButtons()
        }
        
        textViewDidChange()
        updateEntryState(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func becomeFirstResponder() -> Bool
    {
        return self.textView.becomeFirstResponder()
    }
    
    
    // MARK: - Internal methods
    
    internal func isNonTextEntryType() -> Bool
    {
        return type == .Date || (type == .Select && !config.typeInSelect)
    }
    
    internal func layoutWithinSuperview()
    {
        if let parentSuperView = parentView.superview {
            parentSuperView.layoutIfNeeded()
        }
    }
    
    internal func makeButtons()
    {
        if selectButton != nil {
            return
        }
        
        for i in 0...2 {
            var button: UIButton!
            if i == 0 {
                button = makeButtonTitled(config.pickerResetButtonTitle, action: "resetButtonTapped:")
                self.resetButton = button
                self.addEqualConstraintForSubview(lineView, otherSubview: button, attribute: NSLayoutAttribute.Leading)
            }
            else if i == 1 {
                button = makeButtonTitled(config.pickerCreateButtonTitle, action: "createButtonTapped:")
                self.createButton = button
            }
            else {
                button = makeButtonTitled(config.pickerSelectButtonTitle, action: "selectButtonTapped:")
                self.selectButton = button
                self.addEqualConstraintForSubview(lineView, otherSubview: button, attribute: NSLayoutAttribute.Trailing)
                self.addEqualConstraintForSubview(createButton!, attribute: NSLayoutAttribute.Trailing, otherSubview: button, otherAttribute: NSLayoutAttribute.Leading)!.constant = -20
            }
            self.addEqualConstraintForSubview(lineView, attribute: NSLayoutAttribute.Top, otherSubview: button, otherAttribute: NSLayoutAttribute.Bottom)
            button.setTitleColor(config.pickerButtonColor, forState: UIControlState.Normal)
            button.titleLabel!.font = config.pickerButtonFont
            button.hidden = true
        }
    }
    
    internal func makeButtonTitled(title:String, action:Selector) -> UIButton
    {
        let button = UIButton(type: UIButtonType.Custom)
        button.setTitle(title, forState: UIControlState.Normal)
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        button.sizeToFit()
        self.addSubview(button)
        return button
    }
    
    internal func updateEntryState(isInitialSetup:Bool = false)
    {
        let textView = self.textView
        let duration = isInitialSetup ? 0 : 0.25
        if textView.isFirstResponder() // begin editing
        {
            if rawText == defaultTextViewText {
                self.rawText = ""
                textView.setValue(self.config.textColor, forKey: "textColor")
            }
            UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                [unowned self] in
                textView.setValue(self.config.textColor, forKey: "textColor")
                self.lineView.backgroundColor = self.config.lineColorDuringEditing
                self.titleLabel.alpha = 1.0
                self.titleLabelTopConstraint.constant = 0
                if self.type.isPickerType() {
                    if self.isNonTextEntryType() {
                        textView.alpha = 0
                    }
                    self.insertSubview(self.picker!, belowSubview:textView)
                    let topConstraint = self.addEqualConstraintForSubview(self.picker!, attribute: NSLayoutAttribute.Top, otherSubview: textView, otherAttribute: NSLayoutAttribute.Bottom)
                    topConstraint!.constant = -(25.0 + (self.isNonTextEntryType() ? textView.frame.size.height : 0))
                    self.addEqualConstraintForSubview(self.picker!, attribute: NSLayoutAttribute.Width)
                    self.addEqualConstraintForSubview(self.picker!, attribute: NSLayoutAttribute.CenterX)
                    self.addEqualConstraintForSubview(self.lineView, attribute: NSLayoutAttribute.Top, otherSubview: self.picker!, otherAttribute: NSLayoutAttribute.Bottom)
                    self.bringSubviewToFront(self.resetButton!)
                    self.bringSubviewToFront(self.createButton!)
                    self.bringSubviewToFront(self.selectButton!)
                }
                self.layoutWithinSuperview()
            },
            completion: {
                (completed:Bool) -> Void in
                self.scrollToVisible()
            })
        }
        else if rawText.characters.count == 0 { // end editing & return to default state (no content)
            self.rawText = defaultTextViewText
            UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                [unowned self] in
                textView.setValue(self.config.promptTextColor, forKey: "textColor")
                self.lineView.backgroundColor = self.config.lineColor
                self.titleLabelTopConstraint.constant = -20.0
                self.titleLabel.alpha = 0
                textView.alpha = 1.0
                if self.type.isPickerType() {
                    self.removePickerView(isInitialSetup)
                }
                self.layoutWithinSuperview()
            },
            completion: {
                (completed:Bool) -> Void in
            })
        }
        else // end editing with content
        {
            UIView.animateWithDuration(duration) {
                [unowned self] in
                self.titleLabel.alpha = 1.0
                self.titleLabelTopConstraint.constant = 0
                self.lineView.backgroundColor = self.config.lineColor
                if self.type.isPickerType() {
                    self.removePickerView(isInitialSetup)
                }
                if self.type == .Email {
                    self.validateEmail()
                }
                else {
                    textView.setValue(self.config.textColor, forKey: "textColor")
                }
                self.layoutWithinSuperview()
            }
        }
    }
    
    internal func removePickerView(isInitialSetup:Bool)
    {
        self.resetButton!.hidden = true
        self.createButton!.hidden = true
        self.selectButton!.hidden = true
        if self.picker!.superview == nil {
            return
        }
        
        UIView.animateWithDuration(isInitialSetup ? 0 : 0.25) {
            [unowned self] in
            self.removeConstraintsForOtherView(self.picker!)
            self.picker!.removeFromSuperview()
        }
        textView.alpha = 1.0
    }
    
    internal func updateTextToPickerValue()
    {
        if type.isPickerType() {
            if let p = self.picker as? UIPickerView {
                self.rawText = self.selectValues![p.selectedRowInComponent(0)]["name"]!
            }
            else if let p = self.picker as? UIDatePicker {
                self.rawText = self.dateFormatter.stringFromDate(p.date)
            }
            if config.multiline {
                sizeToText()
            }
        }
    }
    
    internal func pickerCanCreateUniqueEntry() -> Bool
    {
        if type == .Select && config.typeInSelect && config.typeInSelectAllowsUnique && !stateIsEmptyOrDefault() {
            let selectedName = selectValues![(picker as! UIPickerView).selectedRowInComponent(0)]["name"]!
            return (rawText.characters.count > selectedName.characters.count || rawText.lowercaseString != selectedName.lowercaseString)
        }
        return false
    }
    
    internal func resetButtonTapped(sender:UIButton)
    {
        self.rawText = ""
        textView.resignFirstResponder()
    }
    
    internal func createButtonTapped(sender:UIButton)
    {
        userTappedCreateButton = true
        textView.resignFirstResponder()
    }
    
    internal func selectButtonTapped(sender:UIButton)
    {
        updateTextToPickerValue()
        textView.resignFirstResponder()
    }
    
    internal func updatePickerActiveStates(isBeingShown:Bool = false)
    {
        if picker == nil {
            return
        }
        
        if type == .Date
        {
            selectButton!.hidden = false
            resetButton!.hidden = false
            return
        }
        
        // .Select
        selectButton!.hidden = false
        selectButton!.enabled = selectValues!.count > 0
        selectButton!.alpha = (selectButton!.enabled ? 1.0 : 0.5)
        resetButton!.hidden = false
        
        // Searchable Select
        if config.typeInSelect
        {
            let p = (picker as! UIPickerView)
            let s = rawText.lowercaseString
            
            var postReloadSelectionId:String?
            if isBeingShown || stateIsEmptyOrDefault() {
                selectValues = _selectValues.map { $0 }
            }
            else {
                let searchResults = _selectValues!.filter { ($0["name"]!.lowercaseString.rangeOfString(s) != nil) }
                
                if searchResults.count == 1
                {
                    // Once whittled down to a single value, it's nicer to show all with the match selected than just show the one
                    postReloadSelectionId = searchResults[0]["id"]
                    selectValues = _selectValues.map { $0 }
                }
                else if searchResults.count > 0 {
                    selectValues = searchResults
                    
                    // Refine the selection using a first-letter-in-word match, since the search results match anywhere within all words
                    let regex = try! NSRegularExpression(pattern: "\\b\(s.characters.first!)", options: [NSRegularExpressionOptions.CaseInsensitive])
                    let regexSearchResults = selectValues!.filter {
                        regex.matchesInString($0["name"]!, options: [], range: NSMakeRange(0, $0["name"]!.characters.count)).count > 0
                    }
                    if regexSearchResults.count > 0 {
                        postReloadSelectionId = regexSearchResults.first!["id"]
                    }
                }
            }
            
            p.reloadAllComponents()
            
            // post-reload
            if let selectId = postReloadSelectionId {
                p.selectRow(selectValues!.indexOf({ ($0["id"]! == selectId) })!, inComponent: 0, animated: false)
            }
        }
        
        if config.typeInSelectAllowsUnique {
            createButton!.hidden = !pickerCanCreateUniqueEntry()
        }
    }
    
    internal func keyboardWillShow(notification:NSNotification)
    {
        if config.managesInsetsForKeyboard {
            // Reduce visible area so keyboard doesn't cover screen. This is pretty coarse since there's no top-down management of with multiple inputs
            // on a page, so every input will do this. That also means that insets can't be easily cached/restored, so zeros are assumed.
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                if let scv = parentScrollView() {
                    UIView.animateWithDuration(0.3) {
                        scv.contentInset = contentInsets
                        scv.scrollIndicatorInsets = contentInsets
                        scv.layoutIfNeeded()
                    }
                }
            }
        }
        
        keyboardIsShowing = true
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] in
            if self.textView.isFirstResponder() {
                self.scrollToVisible()
            }
        }
    }
    
    internal func keyboardWillHide(notification:NSNotification)
    {
        if config.managesInsetsForKeyboard {
            if let scv = parentScrollView() { // See note in keyboardDidShow
                //scv.layer.removeAllAnimations()
                UIView.animateWithDuration(0.3) {
                    scv.contentInset = UIEdgeInsetsZero
                    scv.scrollIndicatorInsets = UIEdgeInsetsZero
                    scv.layoutIfNeeded()
                }
            }
        }
        keyboardIsShowing = false
   }
    
    public func scrollToVisible()
    {
        if !textView.isFirstResponder() {
            return
        }
        
        parentView.layoutIfNeeded()
        let f = parentView.frame
        if f.origin.y > 0 {
            if let scv = parentScrollView() {
                scv.scrollRectToVisible(CGRectMake(0, f.origin.y + f.size.height - 10.0, f.size.width, 30.0), animated: true)
            }
        }
    }
    
    internal func parentScrollView() -> UIScrollView?
    {
        var sv = parentView.superview
        repeat {
            if let scv = sv as? UIScrollView {
                return scv
            }
            else {
                sv = sv?.superview
            }
        }
        while sv != nil
        return nil
    }
    
    internal func sizeToText()
    {
        if config.multiline {
            textViewHeightConstraint.constant = textView.sizeThatFits(CGSizeMake(textView.frame.size.width, 10000)).height
            setNeedsUpdateConstraints()
            layoutWithinSuperview()
            (self.textView as! UITextView).scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
    
    internal func validateEmail()
    {
        if type == .Email {
            self.textView.setValue((rawText.isValidEmail() ? config.textColor : config.validationErrorTextColor), forKey: "textColor")
        }
    }
    
    
    // MARK: - Genericized delegate methods
    
    public func textViewDidBeginEditing()
    {
        updateEntryState()
        
        if type.isPickerType() {
            updatePickerActiveStates(true)
        }
        
        delegate?.formInputTextBeganEditing?(self)
    }
    
    public func textViewDidChange()
    {
        if type == .Number && self.rawText != "-" {
            if self.value == nil && self.rawText != "." {
                self.rawText = "" // allows a full delete/reset of the field, instead of getting stuck with 0
            }
            else {
                self.rawText = config.currencySymbol
                    + self.rawText.extractedNumberString(decimalPlaces: config.decimalPlaces,
                        decimalPlacesAreFixed: config.decimalPlacesAreFixed,
                        includeCommas: config.numberShowsCommaSeparators)
            }
        }
        else if type == .Email {
            validateEmail()
        }
        else if type.isPickerType() {
            updatePickerActiveStates()
        }
        
        if config.multiline {
            sizeToText()
            scrollToVisible()
        }
       
        delegate?.formInputTextChanged?(self)
    }
    
    public func textViewDidEndEditing()
    {
        updateEntryState()
        if type.isPickerType()
        {
            if !userTappedCreateButton && !isNonTextEntryType() && !stateIsEmptyOrDefault() {
                if (pickerCanCreateUniqueEntry() && config.typeInSelect) {
                    // For unique entry mode with search enabled, assume a partial word match indicates a search result and fill it. Otherwise it's a unique entry.
                    // (In the less likely case where they want a unique entry that's a partial word match, they can tap the Create button.)
                    if selectValues![(picker as! UIPickerView).selectedRowInComponent(0)]["name"]!.lowercaseString.rangeOfString(rawText.lowercaseString) != nil {
                        updateTextToPickerValue()
                    }
                }
                else {
                    updateTextToPickerValue()
                }
            }
            self.userTappedCreateButton = false
            
            if type == .Select && config.typeInSelect {
                selectValues = _selectValues.map { $0 }
                (picker as! UIPickerView).reloadAllComponents()
            }
        }
        
        delegate?.formInputTextFinishedEditing?(self)
    }
    
    public func textViewShouldChangeTextInRange(range: NSRange, replacementText string: String) -> Bool
    {
        // Order-sensitive!
        
        if string == "\n" { // Accept return key to finish editing.
            
            // Note that currently the Return key exits editing even when in multiline mode, since there's no other UI to select it.
            // If line break inputs are needed we could add a next/done button bar to the keyboard or expose the picker reset/select buttons.
            // If that is done I'd suggest adding a config option for that to keep things simple in cases where line breaks aren't needed.
            
            self.textView.resignFirstResponder()
            return false
        }
        
        if isNonTextEntryType() {
            return false
        }
        
        let isNumber = (type == .Number)
        let isFixedDecimal = isNumber && config.decimalPlacesAreFixed && config.decimalPlaces > 0
        let isDelete = range.location < self.rawText.characters.count
        if isDelete && !isFixedDecimal { // fixed-width fractions handled below
            return true
        }
        
        if !isNumber && config.maxCharsForTextInput == 0 {
            return true
        }
        
        let nextText = (self.rawText as NSString).stringByReplacingCharactersInRange(range, withString: string) as String
        if type != .Number {
            return !(config.maxCharsForTextInput > 0 && nextText.characters.count > config.maxCharsForTextInput)
        }
        
        // .Number
        if string == "." {
            return (config.decimalPlaces > 0 && self.rawText.rangeOfString(".") == nil)
        }
        
        let nextNumber = (nextText as String).extractedDoubleValue()
        if !isDelete && config.maxValueForNumberInput > 0 && nextNumber > config.maxValueForNumberInput {
            return false
        }
        
        if isFixedDecimal
        {
            // special decimal-format functionality for inserting & deleting new numbers from right and shifting existing digits
            
            if isDelete {
                var newValue = nextText.extractedDoubleValue()
                if newValue == 0 {
                    self.rawText = ""
                }
                else if range.length == 1 && range.location + range.length == rawText.characters.count {
                    newValue /= pow(10.0, Double(range.length))
                }
                else if range.length == rawText.characters.count {
                    newValue = string.extractedDoubleValue() / pow(10.0, Double(config.decimalPlaces))
                }
                self.rawText = "\(max(config.minValueForNumberInput, newValue))"
            }
            else {
                let incomingValue = string.extractedDoubleValue() / pow(10.0, Double(config.decimalPlaces))
                var currentValue = (value as? Double ?? 0)
                currentValue *= pow(10.0, Double(string.characters.count))
                self.rawText = "\( max(config.minValueForNumberInput, currentValue + incomingValue) )"
            }
            textViewDidChange()
            return false
        }
        
        if config.minValueForNumberInput != 0 && nextNumber < config.minValueForNumberInput {
            return false
        }
        
        return true
    }
    
    // MARK: - UITextViewDelegate hooks
    
    public func textViewDidBeginEditing(textView: UITextView)
    {
        self.textViewDidBeginEditing()
    }
    
    public func textViewDidChange(textView: UITextView)
    {
        self.textViewDidChange()
    }
    
    public func textViewDidEndEditing(textView: UITextView)
    {
        self.textViewDidEndEditing()
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        return textViewShouldChangeTextInRange(range, replacementText: text)
    }
    
    // MARK: - UITextFieldDelegate hooks
    
    public func textFieldDidBeginEditing(textField: UITextField)
    {
       self.textViewDidBeginEditing()
    }
    
    public func textFieldDidChange(textView: UITextField)
    {
        self.textViewDidChange()
    }
    
    public func textFieldDidEndEditing(textField: UITextField)
    {
        self.textViewDidEndEditing()
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return textViewShouldChangeTextInRange(range, replacementText: string)
    }
    
   
    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.rawText = selectValues![row]["name"]!
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return selectValues!.count
    }
    
    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.text = selectValues![row]["name"]
        pickerLabel.font = config.pickerFont
        pickerLabel.textColor = config.pickerTextColor
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
}
