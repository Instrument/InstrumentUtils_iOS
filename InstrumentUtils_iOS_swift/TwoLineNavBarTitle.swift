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

public class TwoLineNavBarTitle: UIView
{
    // Fonts may be customized prior to using component
    public static var titleFont = UIFont.systemFontOfSize(20.0)
    public static var subtitleFont = UIFont.systemFontOfSize(12.0)
    
    public let titleLabel = UILabel()
    public let subtitleLabel = UILabel()
    
    internal static let maxLabelHeight:CGFloat = 35.0 // The standard frame height is 30, this gives a touch more room for 2-line labels
    
    // Implementing this method, even if just size is returned without any changes, is required to get labels to layout
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return CGSizeMake(size.width, TwoLineNavBarTitle.maxLabelHeight)
    }
    
    /**
    * Use this for a large title line and a small subtitle line below it
    */
    public class func updateNavBarTitleFor(viewController:UIViewController, title:String, subtitle:String)
    {
        var titleView = viewController.navigationItem.titleView as? TwoLineNavBarTitle
        if titleView == nil
        {
            let view = TwoLineNavBarTitle()
            titleView = view
            view.titleLabel.font = titleFont
            view.titleLabel.textColor = UIColor.whiteColor()
            view.titleLabel.textAlignment = NSTextAlignment.Center
            view.titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            
            view.subtitleLabel.font = subtitleFont
            view.subtitleLabel.textColor = UIColor.whiteColor()
            view.subtitleLabel.textAlignment = NSTextAlignment.Center
            view.subtitleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            
            view.addSubview(view.titleLabel)
            view.addSubview(view.subtitleLabel)
            view.addEqualConstraintForSubview(view.titleLabel, attribute: NSLayoutAttribute.Width)
            view.addEqualConstraintForSubview(view.titleLabel, attribute: NSLayoutAttribute.CenterX)
            view.addEqualConstraintForSubview(view.titleLabel, attribute: NSLayoutAttribute.CenterY).constant = 10
            view.addEqualConstraintForSubview(view.subtitleLabel, attribute: NSLayoutAttribute.Width)
            view.addEqualConstraintForSubview(view.subtitleLabel, attribute: NSLayoutAttribute.CenterX)
            view.addEqualConstraintForSubview(view.subtitleLabel, attribute: NSLayoutAttribute.CenterY).constant = -8
            
            viewController.navigationItem.titleView = view
        }
        
        titleView!.titleLabel.text = title
        titleView!.subtitleLabel.text = subtitle
    }
    
    /**
    * Use this for a single label that reduces the font size and wraps to 2 lines as needed
    */
    public class func updateNavBarTitleFor(viewController:UIViewController, title:String)
    {
        var titleView = viewController.navigationItem.titleView as? TwoLineNavBarTitle
        if titleView == nil
        {
            let view = TwoLineNavBarTitle()
            titleView = view
            view.titleLabel.numberOfLines = 2
            view.titleLabel.adjustsFontSizeToFitWidth = true
            view.titleLabel.minimumScaleFactor = 0.75 // depending on the font, this may need to be tweaked to fit in the height constraint
            view.titleLabel.textAlignment = NSTextAlignment.Center
            view.titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            view.titleLabel.font = titleFont
            view.titleLabel.textColor = UIColor.whiteColor()
            
            view.addSubview(view.titleLabel)
            view.addEqualConstraintForSubview(view.titleLabel, attribute: NSLayoutAttribute.Width)
            view.titleLabel.addSimpleConstraintForAttribute(NSLayoutAttribute.Height, constant: maxLabelHeight)
            view.addEqualConstraintForSubview(view.titleLabel, attribute: NSLayoutAttribute.CenterX)
            view.addEqualConstraintForSubview(view.titleLabel, attribute: NSLayoutAttribute.CenterY)
            
            viewController.navigationItem.titleView = view
        }
        
        titleView!.titleLabel.text = title
    }
}
