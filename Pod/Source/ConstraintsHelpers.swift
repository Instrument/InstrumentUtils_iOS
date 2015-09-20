/*
Copyright (c) 2015, Moses Gunesch
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

let MissingSubviewCrashMessage = "Subview not found in view."

extension UIView
{
    // MARK: - Retrieval
    
    /**
    Retrieves a self-bound simple constraint like .Width or .Height on this view.
    */
    public func getSimpleConstraintWithAttribute(attribute: NSLayoutAttribute) -> NSLayoutConstraint?
    {
        for constraint in self.constraints
        {
            if (constraint.firstItem as? UIView == self
                && constraint.firstAttribute == attribute
                && constraint.secondItem == nil)
            {
                return constraint
            }
        }
        return nil
    }
    
    /**
    Retrieves all constraints on this view that connect to another view.
    */
    public func getConstraintsForOtherView(view: UIView) -> [NSLayoutConstraint]?
    {
        if self.constraints.count == 0 {
            return nil
        }
        
        var matches = [NSLayoutConstraint]()
        for constraint in self.constraints
        {
            if (constraint.firstItem as? UIView == view && constraint.secondItem as? UIView == self)
                || (constraint.firstItem as? UIView == self && constraint.secondItem as? UIView == view)
            {
                matches.append(constraint)
            }
        }
        return matches
    }
    
    /**
    Retrieves a constraint on this view that includes a specific attribute.
    
    The attribute declared for the other view will be used if not found for this view. (For example if you
    search for .Trailing and no match is found, but the other view binds its .Trailing to this view's .Leading,
    that constraint will be matched and returned.)
    
    Constraints between two separate subviews within this view won't be matched.
    */
    public func getConstraintForOtherView(view: UIView, withAttribute attribute: NSLayoutAttribute) -> NSLayoutConstraint?
    {
        if let matches = self.getConstraintsForOtherView(view) {
            if let matchIndex = matches.indexOf({ $0.firstAttribute == attribute }) {
                return matches[matchIndex]
            }
            
            // Do a second pass to inspect secondAttribute only if no firstAttribute match was found.
            if let matchIndex = matches.indexOf({ $0.secondAttribute == attribute }) {
                return matches[matchIndex]
            }
        }
        
        return nil
    }
    
    
    // MARK: - Removal
    
    /**
    Remove all constraints on this view.
    */
    public func removeAllConstraints()
    {
        if self.constraints.count > 0
        {
            self.removeConstraints(self.constraints)
        }
    }
    
    /**
    Remove any constraints on this view that relate to the other view indicated.
    - Returns:  Array of the constraints removed
    */
    public func removeConstraintsForOtherView(view: UIView) -> [NSLayoutConstraint]?
    {
        if let matches = self.getConstraintsForOtherView(view) {
            if matches.count > 0 {
                self.removeConstraints(matches)
                return matches
            }
        }
        return nil
    }
    
    
    // MARK: - Generation
    
    /**
    Shorthand method for adding visual-format constraints with no metrics or options.
    - Returns:  Constraints added
    */
    public func addConstraintsWithVisualFormat(format: String, views: [String : UIView]) -> [NSLayoutConstraint]?
    {
        return self.addConstraintsWithVisualFormats([format], views: views)
    }
    
    /**
    Shorthand method for adding visual-format constraints from multiple visual-format strings and no metrics or options.
    - Returns:  Constraints added
    */
    public func addConstraintsWithVisualFormats(formats: [String], views: [String : UIView]) -> [NSLayoutConstraint]?
    {
        var constraints = [NSLayoutConstraint]()
        for view in views.values {
            view.translatesAutoresizingMaskIntoConstraints = false // mandatory to make constraints work
        }
        for format in formats {
            constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        }
        if constraints.count == 0 {
            return nil
        }
        self.addConstraints(constraints)
        return constraints
    }
    
    /**
    Shorthand method for adding a constraint with no metrics, options, and assuming a views dictionary containing only references "subview", and (the subview passed in) and "|" or "self" (this view).
    - Returns:  Constraint added
    */
    public func addConstraintForSubview(subview: UIView, withVisualFormat format: String) -> NSLayoutConstraint?
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["subview": subview])
        if let constraint = constraints.first {
            subview.translatesAutoresizingMaskIntoConstraints = false // mandatory to make constraints work
            self.addConstraint(constraint)
            return constraint
        }
        return nil
    }
    
    /**
    Adds constraints to the subview that make it match this view's bounds.
    - Returns:  Constraints added
    */
    public func addSizeMatchingConstraintsForSubview(subview: UIView) -> [NSLayoutConstraint]
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        return self.addConstraintsWithVisualFormats(["H:|-0-[subview]-0-|", "V:|-0-[subview]-0-|"], views:["subview": subview])!
    }
    
    /**
    Adds constraints to the subview that make it inset from this view's bounds by the margins provided.
    - Returns:  Constraints added
    */
    public func addSizeMatchingConstraintsForSubview(subview: UIView, withMargins margins: UIEdgeInsets) -> [NSLayoutConstraint]
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        subview.translatesAutoresizingMaskIntoConstraints = false // mandatory to make constraints work
        let viewsDict = ["subview": subview]
        var constraints = [NSLayoutConstraint]()
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-left-[subview]-right-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:["left": margins.left, "right": margins.right], views:viewsDict))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-top-[subview]-bottom-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:["top": margins.top, "bottom": margins.bottom], views:viewsDict))
        self.addConstraints(constraints)
        return constraints
    }
    
    /**
    Adds constraints to the subview that keep it centered in this view.
    - Returns:  Constraints added
    */
    public func addCenteringConstraintsForSubview(subview: UIView) -> [NSLayoutConstraint]
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        subview.translatesAutoresizingMaskIntoConstraints = false // mandatory to make constraints work
        return [self.addEqualConstraintForSubview(subview, attribute: .CenterX),
            self.addEqualConstraintForSubview(subview, attribute: .CenterY)]
    }
    
    /**
    Adds a simple constraint with only an attribute and constant value, no related item.
    (This will only work for very simple attributes like width and height that don't require a related item.)
    - Returns:  Constraint added
    */
    public func addSimpleConstraintForAttribute(attribute: NSLayoutAttribute, constant: CGFloat) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false // mandatory to make constraints work
        let constraint = NSLayoutConstraint(item: self, attribute:attribute, relatedBy:NSLayoutRelation.Equal, toItem:nil, attribute:.NotAnAttribute, multiplier:1.0, constant:constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    /**
    Full-featured syntax replacement shortcut for adding a constraint to a subview with a different attribute than self (targetView) and a custom constant value.
    - Returns:  Constraint added
    */
    public func addConstraintForSubview(subview: UIView, subviewAttribute attribute: NSLayoutAttribute, toTargetViewAttribute targetViewAttribute: NSLayoutAttribute, constant: CGFloat) -> NSLayoutConstraint
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        subview.translatesAutoresizingMaskIntoConstraints = false // mandatory to make constraints work
        let constraint = NSLayoutConstraint(item: self, attribute:targetViewAttribute, relatedBy:NSLayoutRelation.Equal, toItem:subview, attribute:attribute, multiplier:1.0, constant:constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    /**
    Adds an equivalency constraint for a particular attribute.
    - Returns: Constraint added
    */
    public func addEqualConstraintForSubview(subview: UIView, attribute: NSLayoutAttribute) -> NSLayoutConstraint
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        return self.addConstraintForSubview(subview, subviewAttribute:attribute, toTargetViewAttribute:attribute, constant:0)
    }
    
    /**
    Adds an equivalency constraint for a particular set of attributes.
    - Returns:  Constraints added
    */
    public func addEqualConstraintsForSubview(subview: UIView, attributes: [NSLayoutAttribute]) -> [NSLayoutConstraint]?
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        var constraints = [NSLayoutConstraint]()
        for attribute in attributes {
            constraints.append(self.addEqualConstraintForSubview(subview, attribute: attribute))
        }
        return (constraints.count == 0 ? nil : constraints)
    }
    
    /**
    Adds an equivalency constraint for a different attribute of self (targetView) and subview.
    - Returns:  Constraint added
    */
    public func addEqualConstraintForSubview(subview: UIView, subviewAttribute attribute: NSLayoutAttribute, toAttribute targetViewAttribute: NSLayoutAttribute) -> NSLayoutConstraint?
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        return self.addConstraintForSubview(subview, subviewAttribute:attribute, toTargetViewAttribute:targetViewAttribute, constant:0)
    }
    
    /**
    Adds an equivalency constraint between two sibling subviews for a particular attribute.
    - Returns:  Constraint added
    */
    public func addEqualConstraintForSubview(subview: UIView, otherSubview: UIView, attribute: NSLayoutAttribute) -> NSLayoutConstraint
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        precondition(subviews.contains(otherSubview), MissingSubviewCrashMessage)
        return self.addEqualConstraintForSubview(subview, attribute:attribute, otherSubview:otherSubview, otherAttribute:attribute)
    }
    
    /**
    Adds an equivalency constraint between two sibling subviews for a particular set of attributes.
    - Returns:  Constraints added
    */
    public func addEqualConstraintsForSubview(subview: UIView, otherSubview: UIView, attributes: [NSLayoutAttribute]) -> [NSLayoutConstraint]
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        precondition(subviews.contains(otherSubview), MissingSubviewCrashMessage)
        var constraints = [NSLayoutConstraint]()
        for attribute in attributes {
            constraints.append(self.addEqualConstraintForSubview(subview, attribute: attribute, otherSubview:otherSubview, otherAttribute:attribute))
        }
        return constraints
    }
    
    /**
    Adds an equivalency constraint for different attributes of two sibling subviews.
    - Returns:  Constraint added
    */
    public func addEqualConstraintForSubview(subview: UIView, attribute: NSLayoutAttribute, otherSubview: UIView, otherAttribute: NSLayoutAttribute) -> NSLayoutConstraint
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        precondition(subviews.contains(otherSubview), MissingSubviewCrashMessage)
        subview.translatesAutoresizingMaskIntoConstraints = false // mandatory to make constraints work
        otherSubview.translatesAutoresizingMaskIntoConstraints = false // mandatory to make constraints work
        let constraint = NSLayoutConstraint(item: subview, attribute:attribute, relatedBy:NSLayoutRelation.Equal, toItem:otherSubview, attribute:otherAttribute, multiplier:1.0, constant:0)
        self.addConstraint(constraint)
        return constraint
    }
    
    // MARK: - Scroll View Constraints Helpers
    
    /**
    Creates a content container view inside a scroll view with optional margins.
    
    Using a single container view makes working with child views a lot simpler, since the constraints between the
    scroll view's direct child views are treated as margins for sizing its contentSize. All children added inside the
    container view need to have constraints binding top, bottom, and height in order for the scroll view to be able to
    automatically calculate its content size.
    */
    public func createScrollableContainerViewInScrollView(scrollView:UIScrollView, margins: UIEdgeInsets? = nil) -> UIView
    {
        let containerView = UIView()
        scrollView.addSubview(containerView)
        scrollView.addSizeMatchingConstraintsForSubview(containerView, withMargins: margins ?? UIEdgeInsetsZero)
        scrollView.addEqualConstraintForSubview(containerView, attribute: .CenterX)
        return containerView
    }
    
    /**
    Adds a new scroll view with a content container view inside it, with optional margins on the content view.
    
    Using a single container view makes working with child views a lot simpler, since the constraints between the
    scroll view's direct child views are treated as margins for sizing its contentSize. All children added inside the
    container view need to have constraints binding top, bottom, and height in order for the scroll view to be able to
    automatically calculate its content size.
    */
    public func createScrollableContainerView(margins: UIEdgeInsets? = nil) -> (UIView, UIScrollView)
    {
        let scrollView = UIScrollView()
        self.addSubview(scrollView)
        self.addSizeMatchingConstraintsForSubview(scrollView)
        let containerView = createScrollableContainerViewInScrollView(scrollView, margins: margins)
        return (containerView, scrollView)
    }
    
    /**
    Helper for vertically 'stacking' items, such as form input elements.
    
    - SeeAlso: createScrollableContainerView:, createScrollableContainerViewInScrollView:margins:
    
    This is particularly useful when adding multiple children inside a container view within a scroll view, since each
    child needs top, bottom and height constraints in order for the scroll view to be able to automatically calculate its content size.
    
    Using this method can reduce the complex task of organizing many child elements to a single line of constraints setup per view.
    However, you'll only need it if you're creating the entire view in code, instead of laying out your views in IB.
    
    All constant values passed should be positive - constants that need to be negative are automatically inverted.
    
    **Usage:**
    
    - *The first item* should pass the container view as the topItem, and the last item can pass the container view as its bottomItem.
    - *Subsequent items* should pass the previous child view added as their topItem, which 'stacks' the items together.
    - *All items* should pass a height, since that's needed for the scroll view to calculate its content size.
    - *Only the last item* should pass bottomItem/bottom, since other items in the stack can bind to each other using their top constraint.
    
    - Parameter subview: view to receive constraints
    - Parameter topItem: the first child should pass the container view, then subsequent children should pass the child preceding them in the stack.
    - Parameter top: constant for top constraint
    - Parameter edgeMargins: defaults to 0, binds edges to superview. Pass nil to avoid adding edge bindings.
    - Parameter bottomItem: optional, should only be passed for the last item in the stack, and should be the container view
    - Parameter bottom: constant for the bottom constraint
    - Parameter height: should be passed for every child view if you're adding children within a scroll view container, to facilitate the scroll
                        view's calculation of content size.
    */
    public func addStackingConstraintsForSubview(subview: UIView, topItem: UIView, top: CGFloat, edgeMargins: CGFloat? = 0, bottomItem: UIView? = nil, bottom: CGFloat? = nil, height: CGFloat? = nil)
    {
        precondition(subviews.contains(subview), MissingSubviewCrashMessage)
        if topItem == self {
            self.addEqualConstraintForSubview(subview, attribute: .Top).constant = top * -1.0
        }
        else {
            self.addEqualConstraintForSubview(subview, attribute: .Top, otherSubview: topItem, otherAttribute: .Bottom).constant = top
        }
        if let edgeMargins = edgeMargins {
            self.addEqualConstraintForSubview(subview, attribute: .Leading).constant = edgeMargins * -1.0
            self.addEqualConstraintForSubview(subview, attribute: .Trailing).constant = edgeMargins
        }
        if let bottomItem = bottomItem, bottom = bottom {
            if bottomItem == self {
                self.addEqualConstraintForSubview(subview, attribute: .Bottom).constant = bottom
            }
            else {
                self.addEqualConstraintForSubview(subview, attribute: .Bottom, otherSubview: bottomItem, otherAttribute: .Top).constant = bottom * -1.0
            }
        }
        if let height = height {
            subview.addSimpleConstraintForAttribute(.Height, constant: height)
        }
    }
}
