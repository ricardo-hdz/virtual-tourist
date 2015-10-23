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
    var pin: Pin?
    var annotation: MKPointAnnotation?
    var editButton: UIBarButtonItem = UIBarButtonItem()
    var doneButton: UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editAction")
        doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneAction")
        
        setNavigationBar()
        setGestureRecognizer()
        
        initializeMap()
    }
    
    override func viewDidLayoutSubviews() {
        if let button = deletePinsButton {
            button.center.y += self.view.bounds.height
        }
    }
    
    func showDeletePinsButton() {
        UIView.animateWithDuration(0.3, animations: {
            self.deletePinsButton.center.y -= self.view.bounds.height
        })
    }
    
    func hideDeletePinsButton() {
        UIView.animateWithDuration(0.3, animations: {
            self.deletePinsButton.center.y += self.view.bounds.height
        })
    }
    
    func setNavigationBar() {
        self.navigationBar.rightBarButtonItem = editButton
    }
    
    func editAction() {
        self.navigationBar.rightBarButtonItem = doneButton
        showDeletePinsButton()
        isEditingPins = true
    }
    
    func doneAction() {
        self.navigationBar.rightBarButtonItem = editButton
        hideDeletePinsButton()
        isEditingPins = false
        
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
        switch gestureRecognizer.state {
            case UIGestureRecognizerState.Began:
                if !isEditingPins {
                    let coordinate = getCoordinateFromPoint(gestureRecognizer.locationInView(self.mapView))
                    insertAnnotation(coordinate)
                    pin = createNewLocation(coordinate)
                }
                break
            case UIGestureRecognizerState.Changed:
                if mapView.annotations.count > 0 {
                    mapView.removeAnnotation(annotation!)
                    let coordinate = getCoordinateFromPoint(gestureRecognizer.locationInView(self.mapView))
                    insertAnnotation(coordinate)
                    pin!.coordinate = coordinate
                }
            break
            case UIGestureRecognizerState.Ended:
                CoreDataStackManager.sharedInstance().saveContext()
                prefetchPhotosForLocation(pin!)
            break
            default: break
        }
    }
    
    func getCoordinateFromPoint(point: CGPoint) -> CLLocationCoordinate2D {
        return self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
    }
    
    func insertAnnotation(coordinate: CLLocationCoordinate2D) {
        annotation = MKPointAnnotation()
        annotation!.coordinate = coordinate
        mapView.addAnnotation(annotation!)
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
                    dispatch_async(dispatch_get_main_queue(), {
                        DataHelper.getInstance().savePhotosForLocation(location, photos: photos!)
                    })
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