//
//  Photo.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/15/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {
    @NSManaged var url: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: String], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        url = dictionary["url"]!
    }
    
    
}