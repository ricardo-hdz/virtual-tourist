//
//  Photo.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/15/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    @NSManaged var url: String
    @NSManaged var id: String
    @NSManaged var documentPath: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: String], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        url = dictionary["url"]!
        id = dictionary["id"]!
        documentPath = ""
    }
    
    var image: UIImage? {
        get {
            if !documentPath.isEmpty {
                return CacheHelper.getInstance().getImage(self.id)
            }
            return nil
        }
        set {
            documentPath = CacheHelper.getInstance().pathForObject(id)
            CacheHelper.getInstance().saveImage(newValue!, id: self.id)
        }
    }
    
}