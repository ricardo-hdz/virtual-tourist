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
        }
        
        struct SEARCH_PHOTOS_ARG_VALUES {
            static let FORMAT = "json"
            static let JSON_CALLBACK = "1"
        }
        
        struct SEARCH_PHOTOS_RESPONSE_KEYS {
            static let PHOTOS = "photos"
            static let PHOTO = "photo"
            static let TOTAL = "total"
        }
    }
}