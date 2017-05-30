//
//  Template.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 22/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import Foundation
import CoreData


enum TemplateType: UInt16 {
    case email, sms
}

class Template: NSManagedObject {
    
    // MARK: - Query Methods
    
    class func findAll(_ context: NSManagedObjectContext) -> [AnyObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Template", in: context)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return nil
        }
    }
}
