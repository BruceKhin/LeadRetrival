//
//  Lead.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 21/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import Foundation
import CoreData


class Lead: NSManagedObject {
    
    // MARK: - CSV
    
    fileprivate func toCSV() -> String {
        return "\(cleanField(firstName)), \(cleanField(lastName)), \(cleanField(email)), \(cleanField(phoneNumber)), \(cleanField(postalCode)), \(cleanField(leadType)), \(cleanField(compnayName))\n"
    }
    
    class func toCSV(_ leads: [Lead]) -> String {
        var csvString = "First Name, Last Name, Email, Phone Number, Postal Code, Lead Type, Company"
        
        for lead in leads {
            csvString += lead.toCSV()
        }
        
        return csvString
    }
    
    // MARK: - Other
    
    fileprivate func cleanField(_ field: String?) -> String {
        return field ?? ""
    }
}
