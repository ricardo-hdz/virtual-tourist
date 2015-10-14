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

//UICollectionViewDelegate, UICollectionViewDataSource
class LocationPhotosController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var photoCollection = [[String: AnyObject]]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        mapView.delegate = self
        
        // Set up collection view
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        self.view.addSubview(photoCollectionView)

        locationCoordinate = CLLocationCoordinate2D(latitude: 51.0944149223099, longitude: -104.715497760314)
        displaySelectedLocation()
        activityIndicator.startAnimating()
        requestPhotosForLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        //
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
                // disply error in collection
                print("Couldn't get photos for this location. Please try again.")
                print("Error: " + error.localizedDescription)
                self.activityIndicator.stopAnimating()
            } else {
                self.photoCollection = photos!
                print("Retrieved \(photos?.count) photos for lat \(self.locationCoordinate.latitude) and longitude \(self.locationCoordinate.longitude)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.photoCollectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.photoCollectionView.hidden = false
                })

            }
        }
    }
    
    func backAction() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoCollection.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoId = "photoId"
        let collectionPhoto = collectionView.dequeueReusableCellWithReuseIdentifier(photoId, forIndexPath: indexPath) as! PhotoCell
        let photo = photoCollection[indexPath.row]
        //let title = photo["title"] as! String
        let photoUrlString = photo[NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.EXTRAS] as! String
        let photoUrl = NSURL(string: photoUrlString)
        print("Photo URL: \(photoUrlString)")
        if let image = NSData(contentsOfURL: photoUrl!) {
            collectionPhoto.photo.image = UIImage(data: image)
        }

        
        
        return collectionPhoto
    }
    
    

}