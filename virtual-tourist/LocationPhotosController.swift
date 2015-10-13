//
//  LocationPhotosController.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/11/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationPhotosController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        mapView.delegate = self

        locationCoordinate = CLLocationCoordinate2D(latitude: 51.0944149223099, longitude: -104.715497760314)
        displaySelectedLocation()
        requestPhotosForLocation()
    }
    
    func setNavigationItems() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "backAction:")
        self.navigationBar.backBarButtonItem = backButton
    }
    
    func displaySelectedLocation() {
        let annotation = MKPointAnnotation()
        let mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        annotation.coordinate = locationCoordinate
        let mapRegion = MKCoordinateRegion(center: locationCoordinate, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func requestPhotosForLocation() {
        PhotosHelper.getPhotosByLocation("\(locationCoordinate.latitude)", lon: "\(locationCoordinate.longitude)") { photos, error in
            if let error = error {
                // disply erro in collection
                print("Couldn't get photos for this location. Please try again.")
                print("Error: " + error.localizedDescription)
            } else {
                print("Retrieved \(photos?.count) photos for lat \(self.locationCoordinate.latitude) and longitude \(self.locationCoordinate.longitude)")
            }
        }
    }
    
    func backAction() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoId = "photoId"
        let collectionPhoto = collectionView.dequeueReusableCellWithReuseIdentifier(photoId, forIndexPath: indexPath)
        return collectionPhoto
    }
    
    

}