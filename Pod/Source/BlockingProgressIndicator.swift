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

var _blockingProgressIndicatorSpinner:UIActivityIndicatorView?
var _blockingProgressIndicatorLabel:UILabel?
var _blockingProgressIndicatorBackingView:UIView?

/**
Standalone component with a spinner, label, and overlay scrim.

Dependencies: INConstraintsHelpers
*/
public class BlockingProgressIndicator
{
    public static var labelFont = UIFont.systemFontOfSize(14.0)
    public static var labelColor = UIColor.whiteColor()
    public static var scrimColor = UIColor.blackColor()
    public static var scrimAlpha:CGFloat = 0.5
    public static var spinnerStyle = UIActivityIndicatorViewStyle.White
    
    public class func isShowing() -> Bool {
        return _blockingProgressIndicatorSpinner != nil && _blockingProgressIndicatorSpinner!.superview != nil
    }
    
    /**
    Shows the blocking spinner with an optional message.
    
    You may call this method again while the spinner is showing to update the message.
    */
    public class func show(message:String? = nil)
    {
        if !self.isShowing() {
            let targetView = UIApplication.sharedApplication().keyWindow!
            if _blockingProgressIndicatorBackingView == nil {
                _blockingProgressIndicatorBackingView = UIView(frame: targetView.frame)
                _blockingProgressIndicatorBackingView!.backgroundColor = scrimColor
                _blockingProgressIndicatorBackingView!.alpha = scrimAlpha
            }
            if _blockingProgressIndicatorSpinner == nil {
                _blockingProgressIndicatorSpinner = UIActivityIndicatorView(frame: targetView.frame)
                _blockingProgressIndicatorSpinner!.activityIndicatorViewStyle = spinnerStyle
            }
            
            targetView.addSubview(_blockingProgressIndicatorBackingView!)
            targetView.addSubview(_blockingProgressIndicatorSpinner!)
            targetView.addSizeMatchingConstraintsForSubview(_blockingProgressIndicatorBackingView!)
            targetView.addCenteringConstraintsForSubview(_blockingProgressIndicatorSpinner!)
            _blockingProgressIndicatorSpinner!.startAnimating()
        }
        
        if message != nil {
            if _blockingProgressIndicatorLabel == nil {
                _blockingProgressIndicatorLabel = UILabel()
                _blockingProgressIndicatorLabel!.font = labelFont
                _blockingProgressIndicatorLabel!.textColor = labelColor
                _blockingProgressIndicatorLabel!.textAlignment = NSTextAlignment.Center
            }
            _blockingProgressIndicatorLabel!.text = message!
            
            if let labelSuperview = _blockingProgressIndicatorLabel!.superview {
                labelSuperview.bringSubviewToFront(_blockingProgressIndicatorLabel!)
            }
            else {
                let targetView = UIApplication.sharedApplication().keyWindow!
                targetView.addSubview(_blockingProgressIndicatorLabel!)
                targetView.addEqualConstraintForSubview(_blockingProgressIndicatorLabel!, attribute: NSLayoutAttribute.CenterX)
                targetView.addEqualConstraintForSubview(_blockingProgressIndicatorLabel!, attribute: NSLayoutAttribute.CenterY)!.constant = -40
            }
        }
    }
    
    /**
    Hides the blocking view.
    */
    public class func hide() {
        if !self.isShowing() {
            return;
        }
        
        let targetView = UIApplication.sharedApplication().keyWindow!
        if let spinner = _blockingProgressIndicatorSpinner {
            spinner.stopAnimating()
            targetView.removeConstraintsForOtherView(spinner)
            spinner.removeConstraints(spinner.constraints)
            spinner.removeFromSuperview()
            _blockingProgressIndicatorSpinner = nil
        }
        if let view = _blockingProgressIndicatorBackingView {
            targetView.removeConstraintsForOtherView(view)
            view.removeConstraints(view.constraints)
            view.removeFromSuperview()
            _blockingProgressIndicatorBackingView = nil
        }
        if let label = _blockingProgressIndicatorLabel {
            targetView.removeConstraintsForOtherView(label)
            label.removeConstraints(label.constraints)
            label.text = nil
            label.removeFromSuperview()
            _blockingProgressIndicatorLabel = nil
        }
    }
}
