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
import CoreData

//UICollectionViewDelegate, UICollectionViewDataSource
class LocationPhotosController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    
    var currentPhotoPage: Int = 1
    
    var isEditingCollection: Bool = false

    var location: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var removePhotosButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var imagesNotFoundLabel: UILabel!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesNotFoundLabel.hidden = true
        newCollectionButton.enabled = false
        setNavigationItems()
        initializeMap()
        
        initializeCollectionView()

        if (location.photos.count > 0) {
            newCollectionButton.enabled = true
        } else {
            requestPhotosForLocation()
        }
        
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
        
        displaySelectedLocation()
    }
    
    func initializeCollectionView() {
        // Set up collection view
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.allowsSelection = true
        photoCollectionView.allowsMultipleSelection = true
        self.view.addSubview(photoCollectionView)
    }
    
    func fetchPhotos() -> [Photo] {
        return DataHelper.getInstance().fetchData("Photo") as! [Photo]
    }
    
    func displaySelectedLocation() {
        let mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let mapRegion = MKCoordinateRegion(center: location.coordinate, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        mapView.addAnnotation(location!.annotation)
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        // Request images as soon as location is displayed
        loadPhotoData()
    }
    
    func loadPhotoData() {
        let indexVisibleCells = photoCollectionView.indexPathsForVisibleItems()
        
        for indexPath in indexVisibleCells {
            let photo = location.photos[indexPath.row]
            if photo.image == nil {
                print("Requesting images")
                let photoUrl = NSURL(string: photo.url)
                if let image = NSData(contentsOfURL: photoUrl!) {
                    let photoImage = UIImage(data: image)
                    photo.image = photoImage
                }
            }
        }
        CoreDataStackManager.sharedInstance().saveContext()
        photoCollectionView.reloadItemsAtIndexPaths(indexVisibleCells)
    }
    
    @IBAction func newPhotoCollection(sender: AnyObject) {
        currentPhotoPage += 1

        photoCollectionView.hidden = true
        newCollectionButton.enabled = false
        removePhotosFromContext(location.photos)
        requestPhotosForLocation()
    }
    
    @IBAction func removePhotosAction(sender: AnyObject) {
        let selectedPhotos = photoCollectionView.indexPathsForSelectedItems()

        // Remove from location/context
        for index in selectedPhotos! {
            sharedContext.deleteObject(location.photos[index.row])
        }
        CoreDataStackManager.sharedInstance().saveContext()

        // Remove from collection
        photoCollectionView.performBatchUpdates({self.photoCollectionView.deleteItemsAtIndexPaths(selectedPhotos!)}) { completion in
            print("Photos removed")
        }

        removePhotosButton.hidden = true
        newCollectionButton.hidden = false
        isEditingCollection = false
    }
    
    func requestPhotosForLocation() {
        let pageId = String(currentPhotoPage)

        PhotosHelper.getPhotosByLocation("\(location!.latitude)", lon: "\(location!.longitude)", page: pageId) { photos, error in
            if let error = error {
                print("Couldn't get photos for this location. Please try again.")
                print("Error: " + error.localizedDescription)
                //self.activityIndicator.stopAnimating()
            } else {
                if photos?.count > 0 {
                    DataHelper.getInstance().savePhotosForLocation(self.location, photos: photos!)

                    dispatch_async(dispatch_get_main_queue(), {
                        self.photoCollectionView.reloadData()
                        self.photoCollectionView.hidden = false
                        self.newCollectionButton.enabled = true
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.photoCollectionView.hidden = true
                        self.imagesNotFoundLabel.hidden = false
                        self.newCollectionButton.enabled = false
                    })
                }
            }
        }
    }
    
    func removePhotosFromContext(photos: [Photo]) {
        for photo in photos {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func backAction() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Collection View Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return location.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoId = "photoId"
        let collectionPhoto = collectionView.dequeueReusableCellWithReuseIdentifier(photoId, forIndexPath: indexPath) as! PhotoCell
        collectionPhoto.backgroundColor = UIColor.grayColor()
        
        let photo = location.photos[indexPath.row]
        if let photoImage = photo.image {
            collectionPhoto.activityIndicator.stopAnimating()
            collectionPhoto.photo.image = photoImage
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