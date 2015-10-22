//
//  NetworkUtilities.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/11/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

extension NetworkRequestHelper {
    
    func parseJSONBody(body: [String:AnyObject]?) -> NSData? {
        do {
            return try NSJSONSerialization.dataWithJSONObject(body!, options: [])
        } catch let error as NSError {
            print("Error while parsing JSON Body: " + error.localizedDescription)
            return NSData()
        }
    }
    
    func parseReponseData(response: NSData, postProcessor: ((data: AnyObject) -> NSData)?, callback: (result: AnyObject?, error: NSError?) -> Void) {
        var postProcessedResponse: NSData = response
        
        if (postProcessor != nil) {
            postProcessedResponse = postProcessor!(data: response)
        }
        
        do {
            let parsedData: AnyObject? = try NSJSONSerialization.JSONObjectWithData(postProcessedResponse, options: .AllowFragments)
            callback(result: parsedData, error: nil)
        } catch let error as NSError {
            print("Error while parsing service response: " + error.localizedDescription)
            callback(result: nil, error: error)
        }
    }
    
    func escapeParams(parameters: [String: AnyObject]) -> String {
        var urlParams = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlParams += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlParams.isEmpty ? "?" : "") + urlParams.joinWithSeparator("&")
    }
}