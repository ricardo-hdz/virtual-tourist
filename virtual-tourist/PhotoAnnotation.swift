//
//  PhotoAnnotation.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/21/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation
import MapKit

class PhotoAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var pin: Pin?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }

    /*
    var pin: Pin?
    @objc var coordinate: CLLocationCoordinate2D
    
    init(pin: Pin) {
        //super.init()
        self.coordinate = CLLocationCoordinate2D()
        self.pin = pin
    }*/

}