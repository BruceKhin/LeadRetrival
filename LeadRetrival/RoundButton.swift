//
//  RoundButton.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 26/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        layer.cornerRadius = 5
    }
}
