//
//  Lead+CoreDataProperties.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 21/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Lead {

    @NSManaged var dateCreated: Date?
    @NSManaged var dateUpdated: Date?
    @NSManaged var email: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var postalCode: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var leadType: String?
    @NSManaged var compnayName: String?

}
