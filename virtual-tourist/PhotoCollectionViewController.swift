//
//  PhotoCollectionViewController.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/13/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//
/*
import Foundation
import UIKit

extension LocationPhotosController: UICollectionViewDelegate, UICollectionViewDataSource {
    //let cellIdentifier = "photoId"
    //let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

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
        //collectionPhoto.backgroundColor = UIColor.blackColor()
        
        return collectionPhoto
    }

}*/