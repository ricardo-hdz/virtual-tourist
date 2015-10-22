//
//  DataHelper.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/16/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import CoreData

class DataHelper: NSObject {
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    class func getInstance() -> DataHelper {
        struct Singleton {
            static var instance = DataHelper()
        }
        return Singleton.instance
    }
    
    func fetchData(entityName: String) -> [AnyObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            return try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Error while fecthing data for \(entityName): \(error.localizedDescription)")
            return [AnyObject]()
        }
    }
    
    func savePhotosForLocation(location: Pin, photos: [[String: AnyObject]]) {
        for photo in photos {
            let url = photo[NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.EXTRAS] as! String
            let id = photo["id"] as! String
            
            let dictionary: [String: String] = [
                "url": url,
                "id": id
            ]
            
            let newPhoto = Photo(dictionary: dictionary, context: sharedContext)
            
            newPhoto.location = location
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func removePhotos(photos: [Photo]) {
        for photo in photos {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    

}