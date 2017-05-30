//
//  LRTextFieldAccessoryView.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 09/11/2015.
//  Copyright © 2015 appsuey. All rights reserved.
//

import UIKit

class LRTextFieldAccessoryView: UIView {
    let instructionLabel = UILabel()
    let doneButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup() {
        self.instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.instructionLabel.text = "Select Lead Type"
        self.instructionLabel.font = UIFont.systemFont(ofSize: 17)
        self.instructionLabel.textColor = UIColor.white
        self.addSubview(instructionLabel)
        
        self.doneButton.translatesAutoresizingMaskIntoConstraints = false
        self.doneButton.setTitle("Done", for: UIControlState())
        self.doneButton.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        self.doneButton.setTitleColor(UIColor.white, for: UIControlState())
        self.addSubview(doneButton)
        
        self.addConstraint(NSLayoutConstraint(
            item: self.instructionLabel,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1,
            constant: 0))
        
        self.addConstraint(NSLayoutConstraint(
            item: self.doneButton,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1,
            constant: 0))
        
        self.addConstraints(NSLayoutConstraint.simpleVisualConstraints("H:|-25-[instruction]", views: ["instruction": self.instructionLabel]))
        self.addConstraints(NSLayoutConstraint.simpleVisualConstraints("H:[done]-25-|", views: ["done": self.doneButton]))
    }
}
