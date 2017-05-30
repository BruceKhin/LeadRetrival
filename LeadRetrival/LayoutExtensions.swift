//
//  Layout.swift
//  Imgur
//
//  Created by Kimani Walters on 23/12/2015.
//  Copyright © 2015 Encircle. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    class func simpleVisualConstraints(_ format: String, views: [String: AnyObject], options: NSLayoutFormatOptions? = NSLayoutFormatOptions(), metrics: [String : AnyObject]? = nil) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(
            withVisualFormat: format,
            options: options!,
            metrics: metrics,
            views: views)
    }
    
    class func simpleConstraint(_ toItem: UIView, item: UIView, attribute: NSLayoutAttribute, multiplier: CGFloat? = 1, constant: CGFloat? = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: item,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: toItem,
            attribute: NSLayoutAttribute.centerY,
            multiplier: multiplier!,
            constant: constant!)
    }
}
