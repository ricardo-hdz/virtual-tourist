//
//  CacheHelper.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/18/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import CoreData
import UIKit

class CacheHelper: NSObject {

    private var cache = NSCache()
    
    class func getInstance() -> CacheHelper {
        struct Singleton {
            static var instance = CacheHelper()
        }
        return Singleton.instance
    }
    
    func pathForObject(id: String) -> String {
        let applicationsDir = CoreDataStackManager.sharedInstance().applicationDocumentsDirectory
        let url = applicationsDir.URLByAppendingPathComponent(id)
        return url.path!
    }
    
    func saveObjectToCache(path: String, object: AnyObject) {
        cache.setObject(object, forKey: path)
    }
    
    func removeObjectFromCache(path: String) {
        cache.removeObjectForKey(path)
    }
    
    func getObjectFromCache(path: String) -> AnyObject? {
        if let object = cache.objectForKey(path) {
            return object
        }
        return nil
    }
    
    func saveImage(image: UIImage, id: String) {
        let path = pathForObject(id)
        
        saveObjectToCache(path, object: image)
        
        let data = UIImagePNGRepresentation(image)
        data?.writeToFile(path, atomically: true)
    }
    
    func removeImage(id: String) {
        let path = pathForObject(id)
        removeObjectFromCache(path)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch _ {
            print("Unable to remove image at path: \(path)")
        }
    }
    
    func getImage(id: String) -> UIImage? {
        
        let path = pathForObject(id)
        
        if let image = getObjectFromCache(path) as? UIImage {
            return image
        }
        
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
}