//
//  Stop.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 9/4/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import Foundation

class Stop {
    
    let name, code: String
    let latitude, longitude: String
    
    // init new Stop object
    init(name: String, code: String, latitude:String, longitude:String) {
        self.name = name
        self.code = code
        self.latitude = latitude
        self.longitude = longitude
    }
    
//    func getAllStops() -> Array<Stop> {
//        
//        var allStops:Array<Stop> = []
//        
//        // query all objects from parse
//        let query = PFQuery(className: "Stops")
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [AnyObject]!, error: NSError!) -> Void in
//            if error == nil {
//                for object in objects {
//                    
//                    let stopName = (object as PFObject)["name"] as String
//                    let stopCode = (object as PFObject)["code"] as String
//                    let stopLatitude = (object as PFObject)["latitude"] as NSNumber
//                    let stopLongitude = (object as PFObject)["longitude"] as NSNumber
//                    
//                    let stop = Stop(name: stopName, code: stopCode, latitude: stopLatitude, longitude: stopLongitude)
//                    allStops.append(stop)
//                }
//            }
//        }
//    }
//    
//    func stopForCode(code:String) -> Stop {
//        
//        
//    }
}