//
//  PhotosHelper.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/11/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

class PhotosHelper: NSObject {

    class func getPhotosByLocation(lat: String, lon: String, callback: (photos: [[String: AnyObject]]?, error: NSError?) -> Void) {
        let requestHelper = NetworkRequestHelper.getInstance()
        
        let requestParams = [
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.METHOD: NetworkRequestHelper.Constants.SEARCH_PHOTOS_METHOD,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.API_KEY: NetworkRequestHelper.Constants.API_KEY,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.LAT: lat,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.LON: lon,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.FORMAT: NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.FORMAT,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.EXTRAS: NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.EXTRAS,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.JSON_CALLBACK: NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.JSON_CALLBACK
        ]
        
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
}