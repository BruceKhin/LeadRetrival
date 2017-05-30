//
//  Template+CoreDataProperties.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 25/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Template {

    @NSManaged var dateCreated: Date?
    @NSManaged var dateUpdated: Date?
    @NSManaged var templateBody: String?
    @NSManaged var templateName: String?
    @NSManaged var templateSubject: String?
    @NSManaged var templateType: NSNumber?

}
