//
//  String.swift
//  BadgeGenerator
//
//  Created by Kimani Walters on 24/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import Foundation

extension String {
    var isEmail: Bool {
        return self.range(of: "^[\\w._%+-]+@[\\w.-]+\\.[\\w]{2,4}$", options: .regularExpression) != nil
    }
    
    var isPhoneNumber: Bool {
        let intString = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        guard intString.characters.count == 10 else { return false }
        
        return Int(intString) != nil
    }
    
    var isPostalCode: Bool {
        return Int(self) != nil
    }
    
    var isDigit: Bool {
        let digits = CharacterSet.decimalDigits
        let unicodeScalars =  self.unicodeScalars
        for uni in unicodeScalars {
            return digits.contains(UnicodeScalar(uni.value)!)
        }
        
        return false
    }
    
    var cleanPhoneNumber: String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
    
    var formatedPhoneNumber: String? {
        guard self.characters.count > 6 else { return nil }
        
        var newString = self
        newString.insert(Character("-"), at: self.characters.index(self.startIndex, offsetBy: 3))
        newString.insert(Character("-"), at: self.characters.index(self.startIndex, offsetBy: 7))
        
        return newString
    }
}
