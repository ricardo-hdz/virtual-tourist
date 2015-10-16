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
class LocationPhotosController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var photoCollection = [[String: AnyObject]]()
    var currentPhotoPage: Int = 1
    
    var isEditingCollection: Bool = false
    var isLoadingPhotos: Bool = true
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var removePhotosButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var imagesNotFoundLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesNotFoundLabel.hidden = true
        newCollectionButton.enabled = false
        setNavigationItems()
        initializeMap()
        
        initializeCollectionView()

        locationCoordinate = CLLocationCoordinate2D(latitude: 40.7127, longitude: 74.0059)
        //locationCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        displaySelectedLocation()
        //activityIndicator.startAnimating()
        requestPhotosForLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        //
    }
    
    func setNavigationItems() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "backAction:")
        self.navigationBar.backBarButtonItem = backButton
    }
    
    func initializeMap() {
        mapView.delegate = self
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.rotateEnabled = false
    }
    
    func initializeCollectionView() {
        // Set up collection view
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.allowsSelection = true
        photoCollectionView.allowsMultipleSelection = true
        self.view.addSubview(photoCollectionView)
    }
    
    func displaySelectedLocation() {
        let annotation = MKPointAnnotation()
        let mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        annotation.coordinate = locationCoordinate
        let mapRegion = MKCoordinateRegion(center: locationCoordinate, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func newPhotoCollection(sender: AnyObject) {
        currentPhotoPage += 1
        //activityIndicator.startAnimating()
        photoCollectionView.hidden = true
        newCollectionButton.enabled = false
        requestPhotosForLocation()
    }
    
    @IBAction func removePhotosAction(sender: AnyObject) {
        let selectedPhotos = photoCollectionView.indexPathsForSelectedItems()
        for index in selectedPhotos! {
            photoCollection.removeAtIndex(index.row)
        }
        photoCollectionView.performBatchUpdates({self.photoCollectionView.deleteItemsAtIndexPaths(selectedPhotos!)}) { completion in
            print("Photos removed")
        }
        removePhotosButton.hidden = true
        newCollectionButton.hidden = false
        isEditingCollection = false
    }
    
    func requestPhotosForLocation() {
        let pageId = String(currentPhotoPage)

        PhotosHelper.getPhotosByLocation("\(locationCoordinate.latitude)", lon: "\(locationCoordinate.longitude)", page: pageId) { photos, error in
            if let error = error {
                // disply error in collection
                print("Couldn't get photos for this location. Please try again.")
                print("Error: " + error.localizedDescription)
                //self.activityIndicator.stopAnimating()
            } else {
                self.photoCollection = photos!
                print("Retrieved \(photos?.count) photos for lat \(self.locationCoordinate.latitude) and longitude \(self.locationCoordinate.longitude)")
                print("Photos: \(self.photoCollection)")
                dispatch_async(dispatch_get_main_queue(), {
                    if self.photoCollection.count > 0 {
                        self.photoCollectionView.reloadData()
                        self.photoCollectionView.hidden = false
                        self.newCollectionButton.enabled = true
                    } else {
                        self.imagesNotFoundLabel.hidden = false
                    }
                    //self.activityIndicator.stopAnimating()
                })
            }
            self.isLoadingPhotos = false
        }
    }
    
    func backAction() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Collection View Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO pass a placeholder
        var totalPhotos = 5
        if !isLoadingPhotos {
            totalPhotos = photoCollection.count
        }
        return totalPhotos
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoId = "photoId"
        let collectionPhoto = collectionView.dequeueReusableCellWithReuseIdentifier(photoId, forIndexPath: indexPath) as! PhotoCell
        collectionPhoto.backgroundColor = UIColor.grayColor()

        if !isLoadingPhotos {
            let photo = photoCollection[indexPath.row]
            //let title = photo["title"] as! String
            let photoUrlString = photo[NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.EXTRAS] as! String
            let photoUrl = NSURL(string: photoUrlString)
            if let image = NSData(contentsOfURL: photoUrl!) {
                collectionPhoto.activityIndicator.stopAnimating()
                collectionPhoto.photo.image = UIImage(data: image)
            }
        }
        
        return collectionPhoto
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !isEditingCollection {
            isEditingCollection = true
            // display button
            removePhotosButton.hidden = false
            newCollectionButton.hidden = true
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        cell.highlighted = true
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // check for total items selected, if == 0 the hide button
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        cell.highlighted = false
        
        let selectedPhotos = collectionView.indexPathsForSelectedItems()
        if (selectedPhotos?.count < 1) {
            removePhotosButton.hidden = true
            newCollectionButton.hidden = false
            isEditingCollection = false
        }
    }
    
    
    

}