//
//  NetworkRequestHelper.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/11/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

class NetworkRequestHelper: NSObject {
    var session: NSURLSession!
    
    override init() {
        super.init()
        session = NSURLSession.sharedSession()
    }
    
    class func getInstance() -> NetworkRequestHelper {
        struct Singleton {
            static var instance = NetworkRequestHelper()
        }
        return Singleton.instance
    }
    
    func serviceRequest(serviceEndpoint: String, requestMethod: String, headers: NSMutableDictionary, jsonBody: [String:AnyObject]?, postProcessor: ((data: AnyObject) -> NSData)?, callback: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        print("Starting request")
        print("Service endpoint: \(serviceEndpoint)")
        let url = NSURL(string: serviceEndpoint)
        
        print("URL in trequest: \(url!)")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = requestMethod
        
        print("Setting headers")
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for (headerField, headerValue) in headers {
            request.addValue(headerValue as! String, forHTTPHeaderField: headerField as! String)
        }
        
        if (jsonBody != nil) {
            request.HTTPBody = self.parseJSONBody(jsonBody)
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                print("Error while making network request to endpoint : " + serviceEndpoint)
                print("Error: " + error.localizedDescription)
            } else {
                self.parseReponseData(data!, postProcessor: postProcessor, callback: callback)
            }
        }
        
        task.resume()
        return task
    }

}