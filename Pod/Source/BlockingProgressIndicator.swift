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

/**
Standalone component with a spinner, label, and overlay scrim.

Dependencies: INConstraintsHelpers
*/
public class BlockingProgressIndicator
{
    /**
    Font for the optional message shown under the spinner
    
    Set `BlockingProgressIndicator.labelFont` once at the beginning of your program to customize.
    */
    public static var labelFont = UIFont.systemFontOfSize(14.0)
    
    /**
    Text color for the optional message shown under the spinner
    
    Set `BlockingProgressIndicator.labelColor` once at the beginning of your program to customize.
    */
    public static var labelColor = UIColor.whiteColor()
    
    /**
    Color of the full-screen scrim behind the spinner and text
    
    Set `BlockingProgressIndicator.scrimColor` once at the beginning of your program to customize.
    */
    public static var scrimColor = UIColor.blackColor()
    
    /**
    Alpha for the full-screen scrim behind the spinner and text
    
    Set `BlockingProgressIndicator.scrimAlpha` once at the beginning of your program to customize.
    */
    public static var scrimAlpha:CGFloat = 0.5
    
    /**
    The UIActivityIndicatorViewStyle for the spinner
    
    Set `BlockingProgressIndicator.spinnerStyle` once at the beginning of your program to customize.
    */
    public static var spinnerStyle = UIActivityIndicatorViewStyle.White
    
    /**
    Whether the blocking indicator is currently being displayed
    
    Call `BlockingProgressIndicator.isShowing()` to retrieve this value.
    */
    public class func isShowing() -> Bool {
        return _blockingProgressIndicatorSpinner != nil && _blockingProgressIndicatorSpinner!.superview != nil
    }
    
    private static var _blockingProgressIndicatorSpinner:UIActivityIndicatorView?
    private static var _blockingProgressIndicatorLabel:UILabel?
    private static var _blockingProgressIndicatorBackingView:UIView?
    
    /**
    Shows the blocking spinner with an optional message.
    
    You may call `BlockingProgressIndicator.show()` again while the spinner is showing to update or remove the message.
    */
    public class func show(message:String? = nil)
    {
        if UIApplication.sharedApplication().keyWindow == nil {
            print("Error - BlockingProgressIndicator.show(): The Application's window is not ready. Try listening for UIApplicationDidFinishLaunchingNotification first.")
            return
        }
        
        let window: UIWindow = UIApplication.sharedApplication().keyWindow!
        
        if !self.isShowing() {
            var spinner: UIActivityIndicatorView!
            var backingView: UIView!
            if _blockingProgressIndicatorBackingView == nil {
                backingView = UIView(frame: window.frame)
                backingView.backgroundColor = scrimColor
                backingView.alpha = scrimAlpha
                _blockingProgressIndicatorBackingView = backingView
            }
            backingView = _blockingProgressIndicatorBackingView!
            if _blockingProgressIndicatorSpinner == nil {
                spinner = UIActivityIndicatorView(frame: window.frame)
                spinner.activityIndicatorViewStyle = spinnerStyle
                _blockingProgressIndicatorSpinner = spinner
            }
            spinner = _blockingProgressIndicatorSpinner!
            
            window.addSubview(backingView)
            window.addSubview(spinner)
            window.addSizeMatchingConstraintsForSubview(backingView)
            window.addCenteringConstraintsForSubview(spinner)
            spinner.startAnimating()
        }
        
        if message != nil {
            var label: UILabel!
            if _blockingProgressIndicatorLabel == nil {
                label = UILabel()
                label.font = labelFont
                label.textColor = labelColor
                label.textAlignment = NSTextAlignment.Center
                _blockingProgressIndicatorLabel = label
            }
            label = _blockingProgressIndicatorLabel!
            label.text = message!
            
            if let labelSuperview = label.superview {
                labelSuperview.bringSubviewToFront(label)
            }
            else {
                window.addSubview(label)
                window.addEqualConstraintForSubview(label, attribute: .CenterX)
                window.addEqualConstraintForSubview(label, attribute: .CenterY).constant = 40
            }
        }
        else if let label = _blockingProgressIndicatorLabel {
            label.text = nil
        }
    }
    
    /**
    Hides the blocking view.
    
    Call `BlockingProgressIndicator.hide()` to use this method.
    */
    public class func hide() {
        if !self.isShowing() {
            return;
        }
        
        let window = UIApplication.sharedApplication().keyWindow!
        if let spinner = _blockingProgressIndicatorSpinner {
            spinner.stopAnimating()
            window.removeConstraintsForOtherView(spinner)
            spinner.removeConstraints(spinner.constraints)
            spinner.removeFromSuperview()
            _blockingProgressIndicatorSpinner = nil
        }
        if let view = _blockingProgressIndicatorBackingView {
            window.removeConstraintsForOtherView(view)
            view.removeConstraints(view.constraints)
            view.removeFromSuperview()
            _blockingProgressIndicatorBackingView = nil
        }
        if let label = _blockingProgressIndicatorLabel {
            window.removeConstraintsForOtherView(label)
            label.removeConstraints(label.constraints)
            label.text = nil
            label.removeFromSuperview()
            _blockingProgressIndicatorLabel = nil
        }
    }
}
