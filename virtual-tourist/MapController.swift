//
//  MapController.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/11/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsButton: UIButton!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    var isEditingPins: Bool = false
    
    var editButton: UIBarButtonItem = UIBarButtonItem()
    var doneButton: UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deletePinsButton.hidden = true
        
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editAction")
        doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneAction")
        
        setNavigationBar()
        setGestureRecognizer()
    }
    
    func setNavigationBar() {
        self.navigationBar.rightBarButtonItem = editButton
    }
    
    func editAction() {
        
        self.navigationBar.rightBarButtonItem = doneButton
        
        isEditingPins = true
        mapView.frame.origin.y -= deletePinsButton.frame.height
        deletePinsButton.hidden = false
    }
    
    func doneAction() {
        self.navigationBar.rightBarButtonItem = editButton
        
        isEditingPins = false
        mapView.frame.origin.y += deletePinsButton.frame.height
        deletePinsButton.hidden = true
    }
    
    func setGestureRecognizer() {
        let recognizer = UILongPressGestureRecognizer(target: self, action: "dropMapPin:")
        recognizer.minimumPressDuration = 1.00
        mapView.addGestureRecognizer(recognizer)
    }
    
    func dropMapPin(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let coordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            pinView?.canShowCallout = false
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if (isEditingPins) {
            mapView.removeAnnotation(view.annotation!)
        } else {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("locationPhotosVC") as! LocationPhotosController
            controller.locationCoordinate = (view.annotation?.coordinate)!
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Map changed to new region")
        print("Latitude: \(mapView.region.center.latitude)")
        print("Longitude: \(mapView.region.center.longitude)")
        print("Latitude Delta: \(mapView.region.span.latitudeDelta)")
        print("Longitude Delta: \(mapView.region.span.longitudeDelta)")
    }
    
}