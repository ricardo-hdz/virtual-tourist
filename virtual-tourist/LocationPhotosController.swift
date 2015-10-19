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
    
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    //var photoCollection = [[String: AnyObject]]()
    var currentPhotoPage: Int = 1
    
    var isEditingCollection: Bool = false
    var isLoadingPhotos: Bool = true
    
    var photoData = [Photo]()
    
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

        locationCoordinate = CLLocationCoordinate2D(latitude: 40.7127, longitude: 74.0059)
        //locationCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        displaySelectedLocation()
        //activityIndicator.startAnimating()
        
        photoData = fetchPhotos()

        if (photoData.count > 0) {
            // Display photos from context
            print("Reloading photos")
            photoCollectionView.reloadData()
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
        let annotation = MKPointAnnotation()
        let mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        annotation.coordinate = locationCoordinate
        let mapRegion = MKCoordinateRegion(center: locationCoordinate, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func newPhotoCollection(sender: AnyObject) {
        currentPhotoPage += 1

        photoCollectionView.hidden = true
        newCollectionButton.enabled = false
        removePhotosFromContext(photoData)
        photoData.removeAll()
        requestPhotosForLocation()
    }
    
    @IBAction func removePhotosAction(sender: AnyObject) {
        let selectedPhotos = photoCollectionView.indexPathsForSelectedItems()
        var photosToRemove = [Photo]()
        for index in selectedPhotos! {
            photosToRemove.append(photoData[index.row])
            photoData.removeAtIndex(index.row)
        }
        photoCollectionView.performBatchUpdates({self.photoCollectionView.deleteItemsAtIndexPaths(selectedPhotos!)}) { completion in
            print("Photos removed")
        }
        removePhotosFromContext(photosToRemove)

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
                if photos?.count > 0 {
                    self.savePhotosInContext(photos!)
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
            self.isLoadingPhotos = false
        }
    }
    
    func savePhotosInContext(photos: [[String: AnyObject]]) {
        print("Saving photos in context: \(photos.count)")
        for photo in photos {
            let url = photo[NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.EXTRAS] as! String
            let id = photo["id"] as! String

            let dictionary: [String: String] = [
                "url": url,
                "id": id
            ]
            
            let newPhoto = Photo(dictionary: dictionary, context: sharedContext)

            photoData.append(newPhoto)
            print("Saved photos : \(photoData.count)")

        }
        CoreDataStackManager.sharedInstance().saveContext()
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
        print("Returning total photos: \(photoData.count)")
        return photoData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoId = "photoId"
        let collectionPhoto = collectionView.dequeueReusableCellWithReuseIdentifier(photoId, forIndexPath: indexPath) as! PhotoCell
        collectionPhoto.backgroundColor = UIColor.grayColor()

        if (indexPath.row < photoData.count) {
            let photo = photoData[indexPath.row]
            
            if let photoImage = photo.image {
                print("Retrieveing from cache")
                collectionPhoto.activityIndicator.stopAnimating()
                collectionPhoto.photo.image = photoImage
            } else {
                print("Requesting images")
                let photoUrl = NSURL(string: photo.url)
                if let image = NSData(contentsOfURL: photoUrl!) {
                    let photoImage = UIImage(data: image)
                    collectionPhoto.photo.image = photoImage
                    collectionPhoto.activityIndicator.stopAnimating()
                    photo.image = photoImage
                    CoreDataStackManager.sharedInstance().saveContext()
                }
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