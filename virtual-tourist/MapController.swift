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
    
    var mapData = [Map]()
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
        
        initializeMap()
    }
    
    func setNavigationBar() {
        self.navigationBar.rightBarButtonItem = editButton
    }
    
    func editAction() {
        self.navigationBar.rightBarButtonItem = doneButton
        mapView.frame.origin.y -= deletePinsButton.frame.height
        isEditingPins = true
        deletePinsButton.hidden = false
    }
    
    func doneAction() {
        self.navigationBar.rightBarButtonItem = editButton
        mapView.frame.origin.y += deletePinsButton.frame.height
        isEditingPins = false
        deletePinsButton.hidden = true
        // Save all changes to context at once
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func fetchMapData() -> [Map] {
        return DataHelper.getInstance().fetchData("Map") as! [Map]
    }
    
    func initializeMap() {
        mapData = fetchMapData()

        if mapData.count > 0 {
            mapView.setRegion(mapData[0].region, animated: true)
            initializePins()
        } else {
            saveMapToContext()
        }
    }
    
    func initializePins() {
        for pin in mapData[0].locations {
            mapView.addAnnotation(pin.annotation)
        }
    }
    
    func setGestureRecognizer() {
        let recognizer = UILongPressGestureRecognizer(target: self, action: "dropMapPin:")
        recognizer.minimumPressDuration = 1.00
        mapView.addGestureRecognizer(recognizer)
    }
    
    func dropMapPin(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Began || isEditingPins {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let coordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        // Add pin to map
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let pin = createNewLocation(coordinate)
        CoreDataStackManager.sharedInstance().saveContext()
        
        prefetchPhotosForLocation(pin)
    }
    
    func createNewLocation(coordinate: CLLocationCoordinate2D) -> Pin {
        let dictionary: [String: Double] = [
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude
        ]
        
        let newPinData = Pin(dictionary: dictionary, context: sharedContext)
        newPinData.map = mapData[0]
        return newPinData
    }
    
    func prefetchPhotosForLocation(location: Pin) {
        PhotosHelper.getPhotosByLocation("\(location.latitude)", lon: "\(location.longitude)", page: "1") { photos, error in
            if let error = error {
                print("Error: " + error.localizedDescription)
            } else {
                if photos?.count > 0 {
                    DataHelper.getInstance().savePhotosForLocation(location, photos: photos!)
                }
            }
        }
    }
    
    func removePinFromContext(annotation: MKPointAnnotation) {
        for pin in mapData[0].locations {
            if
                pin.annotation.coordinate.latitude == annotation.coordinate.latitude &&
                pin.annotation.coordinate.longitude == annotation.coordinate.longitude
            {
                sharedContext.deleteObject(pin)
                break
            }
        }
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
            removePinFromContext(view.annotation as! MKPointAnnotation)
            mapView.removeAnnotation(view.annotation!)
        } else {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("locationPhotosVC") as! LocationPhotosController
            for pin in mapData[0].locations {
                if
                    pin.annotation.coordinate.latitude == view.annotation?.coordinate.latitude &&
                    pin.annotation.coordinate.longitude == view.annotation?.coordinate.longitude
                {
                    controller.location = pin
                    break
                }
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func getCurrentMapValues() -> [String: Double] {
        return [
            "latitude": mapView.region.center.latitude,
            "longitude": mapView.region.center.longitude,
            "latitudeDelta": mapView.region.span.latitudeDelta,
            "longitudeDelta": mapView.region.span.longitudeDelta
        ]
    }
    
    func saveMapToContext() {
        let dictionary = getCurrentMapValues()
        let newMapData = Map(dictionary: dictionary, context: sharedContext)

        mapData = [newMapData]
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func updateMapToContext() {
        mapData[0].region = mapView.region
        sharedContext.refreshObject(mapData[0], mergeChanges: true)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMapToContext()
    }
    
}