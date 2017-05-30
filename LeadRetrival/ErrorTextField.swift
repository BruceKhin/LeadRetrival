//
//  ErrorTextField.swift
//  BadgeGenerator
//
//  Created by Kimani Walters on 24/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import UIKit

class ErrorTextField: UITextField {
    fileprivate let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.red
        
        return label
    }()
    
    var error: String? {
        get {
            return errorLabel.text
        }
        
        set {
            errorLabel.text = newValue
            
            if newValue == nil {
                clearError()
            } else {
                showError()
            }
        }
    }
    
    fileprivate func showError() {
        setBorderColor(UIColor.red)
        
        superview?.addSubview(errorLabel)
        
        superview?.addConstraints(NSLayoutConstraint.simpleVisualConstraints("H:|-128-[label]", views: ["label": errorLabel]))
        superview?.addConstraints(NSLayoutConstraint.simpleVisualConstraints("V:[self]-0-[label]", views: ["self": self, "label": errorLabel]))
    }
    
    fileprivate func clearError() {
        setBorderColor(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1))
        errorLabel.removeFromSuperview()
    }
    
    fileprivate func setBorderColor(_ color: UIColor) {
        layer.cornerRadius = 5
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.masksToBounds = true
        layer.borderColor = color.cgColor
    }
}
