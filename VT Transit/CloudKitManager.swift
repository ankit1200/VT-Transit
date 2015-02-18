//
//  CloudKitManager.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 2/18/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//  
//  CloudKit manager is a singleton class that manages the CloudKit Queries

import UIKit
import CloudKit

class CloudKitManager: NSObject {
   
    let privateDB = CKContainer.defaultContainer().privateCloudDatabase // CloudKit database
    var favoriteStops = Array<Stop>() // favoriteStops
    
    class var sharedInstance: CloudKitManager {
        struct Static {
            static var instance: CloudKitManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = CloudKitManager()
        }
        return Static.instance!
    }
    
    func queryFavoriteStops(completionHandler: ()->()) {
        let ckQuery = CKQuery(recordType: "Stop", predicate: NSPredicate(value: true))
        privateDB.performQuery(ckQuery, inZoneWithID: nil) {
            results, error in
            if error != nil {
                println(error)
            } else {
                self.favoriteStops = []
                for record in results {
                    let stop = Stop(name: record["name"] as String, code: record["code"] as String, location: record["location"] as CLLocation)
                    self.favoriteStops.append(stop)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler()
                }
            }
        }
    }
}
