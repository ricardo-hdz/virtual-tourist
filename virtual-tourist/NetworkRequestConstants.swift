//
//  NetworkRequestConstants.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/11/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

extension NetworkRequestHelper {
    struct Constants {
        static let API_KEY = "2b2091159bddff07cefed89c39d11a21"
        static let SEARCH_PHOTOS_METHOD = "flickr.photos.search"
        static let FLICKR_API = "https://api.flickr.com/services/rest/"
        
        struct SEARCH_PHOTOS_ARGUMENTS {
            static let API_KEY = "api_key"
            static let METHOD = "method"
            static let LON = "lon"
            static let LAT = "lat"
            static let FORMAT = "format"
            static let JSON_CALLBACK = "nojsoncallback"
            static let EXTRAS = "extras"
            static let PER_PAGE = "per_page"
            static let PAGE = "page"
        }
        
        struct SEARCH_PHOTOS_ARG_VALUES {
            static let FORMAT = "json"
            static let JSON_CALLBACK = "1"
            static let EXTRAS = "url_m"
            static let PER_PAGE = "20"
        }
        
        struct SEARCH_PHOTOS_RESPONSE_KEYS {
            static let PHOTOS = "photos"
            static let PHOTO = "photo"
            static let TOTAL = "total"
        }
    }
    
    class func getDefaultFlickrParams() -> [String:String] {
        return [
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.METHOD: NetworkRequestHelper.Constants.SEARCH_PHOTOS_METHOD,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.API_KEY: NetworkRequestHelper.Constants.API_KEY,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.FORMAT: NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.FORMAT,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.EXTRAS: NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.EXTRAS,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.JSON_CALLBACK: NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.JSON_CALLBACK,
            NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARGUMENTS.PER_PAGE: NetworkRequestHelper.Constants.SEARCH_PHOTOS_ARG_VALUES.PER_PAGE
        ]
    }
}