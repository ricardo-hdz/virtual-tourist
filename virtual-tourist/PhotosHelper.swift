//
//  PhotosHelper.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/11/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation
import UIKit

class PhotosHelper: NSObject {

    class func getPhotosByLocation(lat: String, lon: String, page: String, callback: (photos: [[String: AnyObject]]?, error: NSError?) -> Void) {
        let requestHelper = NetworkRequestHelper.getInstance()
        
        var requestParams = NetworkRequestHelper.getDefaultFlickrParams()
        requestParams[NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.LAT] = lat
        requestParams[NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.LON] = lon
        requestParams[NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.PAGE] = page

        let urlString: String = NetworkRequestHelper.Constants.FLICKR_API + requestHelper.escapeParams(requestParams)
        
        let headers: NSMutableDictionary = [:]

        let _ = requestHelper.serviceRequest(urlString, requestMethod: "GET", headers: headers, jsonBody: nil, postProcessor: nil) { result, error in
            if let error = error {
                print("Error while searching for photos by location: " + error.localizedDescription)
                callback(photos: nil, error: error)
            } else {
                let photos = result!.valueForKey(NetworkRequestHelper.Constants.SEARCH_PHOTOS_RESPONSE_KEYS.PHOTOS) as! NSDictionary
                var totalPhotos = 0
                if let numPhotos = photos[NetworkRequestHelper.Constants.SEARCH_PHOTOS_RESPONSE_KEYS.TOTAL] as? String {
                    totalPhotos = (numPhotos as NSString).integerValue
                }
                
                var photoCollection = [[String: AnyObject]]()
                if (totalPhotos > 0) {
                    photoCollection = photos.valueForKey(NetworkRequestHelper.Constants.SEARCH_PHOTOS_RESPONSE_KEYS.PHOTO) as! [[String: AnyObject]]
                }
                callback(photos: photoCollection, error: nil)
            }
        }
    }
    
    class func getImage(url: String, callback: (image: UIImage?, error: NSError?) -> Void) {
        let requestHelper = NetworkRequestHelper.getInstance()
        let _ = requestHelper.dataRequest(url) {data, error in
            if let error = error {
                print("Error while requesting image at URL: \(url)")
                callback(image: nil, error: error)
            } else {
                let image = UIImage(data: data!)
                callback(image: image, error: nil)
            }
        }
    }
}