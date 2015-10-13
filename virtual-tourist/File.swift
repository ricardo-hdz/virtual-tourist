//
//  File.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/11/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

extension NetworkRequestHelper {
    struct Constants {
        
        static let API_KEY = "2b2091159bddff07cefed89c39d11a21"
        static let FLICKR_ENDPOINT = "https://api.flickr.com/services/rest/"
        static let PHOTOS_SEARCH_METHOD = "flickr.photos.search"
        
        struct MethodArguments {
            static let API_KEY = "api_key"
            static let LAT = "lat"
            static let LON = "lon"
            static let RADIUS = "radius"
            static let PER_PAGE = "per_page"
            static let PAGE = "page"
        }
        
        struct ResponseKeys {
            static let PHOTOS = "photos"
            static let PHOTO = "photo"
        }
        
    }

}