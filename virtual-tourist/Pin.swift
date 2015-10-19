//
//  Pin.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/15/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    //Relationships
    @NSManaged var map: Map
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: Double], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        latitude = dictionary["latitude"]!
        longitude = dictionary["longitude"]!
    }
    
    var annotation: MKPointAnnotation {
        get {
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let annotationInstance = MKPointAnnotation()
            annotationInstance.coordinate = coordinate
            return annotationInstance
        }
        set {
            latitude = newValue.coordinate.latitude
            longitude = newValue.coordinate.longitude
        }
    }
}