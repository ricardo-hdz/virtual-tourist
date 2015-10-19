//
//  Map.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/15/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Map: NSManagedObject {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var latitudeDelta: Double
    @NSManaged var longitudeDelta: Double
    
    //Relationships
    @NSManaged var locations: [Pin]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //latitudeValue: Double, longitudeValue: Double, latitudeDeltaValue: Double, longitudeDeltaValue: Double
    
    init(dictionary: [String: Double], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Map", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        latitude = dictionary["latitude"]!
        longitude = dictionary["longitude"]!
        latitudeDelta = dictionary["latitudeDelta"]!
        longitudeDelta = dictionary["longitudeDelta"]!
    }
    
    var center: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    
    var span: MKCoordinateSpan {
        get {
            return MKCoordinateSpan(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta)
        }
        set {
            self.latitudeDelta = newValue.latitudeDelta
            self.longitudeDelta = newValue.longitudeDelta
        }
    }
    
    var region: MKCoordinateRegion {
        get {
            return MKCoordinateRegion(center: self.center, span: self.span)
        }
        set {
            self.center = newValue.center
            self.span = newValue.span
        }
    }

}