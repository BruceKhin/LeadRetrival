//
//  UITextFieldExtension.swift
//  BadgeGenerator
//
//  Created by Kimani Walters on 24/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import UIKit

extension UITextField {
    var isEmpty: Bool {
        guard let text = text else { return true }
        return text.isEmpty
    }
    
    func strip() {
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
