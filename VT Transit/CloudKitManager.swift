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
    var favoriteStops:Array<Stop>! = Array<Stop>() // favoriteStops
    var allStops:Array<Stop>! = Array<Stop>() // all stops
    
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
    
    // get favorite stops from iCloud
    func queryFavoriteStops(completionHandler: ()->()) {
        let query = CKQuery(recordType: "Stop", predicate: NSPredicate(value: true))
        let sort = NSSortDescriptor(key: "favoritesIndex", ascending: true)
        query.sortDescriptors = [sort]
        privateDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                println(error)
            } else {
                self.favoriteStops = []
                for record in results {
                    let stop = Stop(name: record["name"] as String, code: record["code"] as String, location: record["location"] as CLLocation)
                    self.favoriteStops!.append(stop)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler()
                }
            }
        }
    }
    
    // update favorite stops to iCloud
    func updateFavoriteStops() {
        for (index, stop) in enumerate(favoriteStops) {
            privateDB.fetchRecordWithID(CKRecordID(recordName: stop.code), completionHandler: { (record, error) -> Void in
                if error != nil {
                    println(error)
                } else {
                    // save the record once fetched
                    dispatch_async(dispatch_get_main_queue(), {
                        record.setValue(index, forKey:"favoritesIndex")
                        self.privateDB.saveRecord(record, completionHandler: { (record, error) -> Void in
                            if error != nil {
                                println(error)
                            }
                        })
                    })
                }
            })
        }
    }
    
    // get all the stops from Parse
    func queryAllStops(completionHandler: ()->()) {
        var query = PFQuery(className: "Stops")
        query.limit = 500
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let location = CLLocation(latitude: (object["latitude"] as NSString).doubleValue, longitude: (object["longitude"] as NSString).doubleValue)
                    let stop = Stop(name: object["name"] as String, code: object["code"] as String, location:location)
                    self.allStops.append(stop)
                }
            }
            completionHandler()
        }
    }
    
    // ************************************
    // MARK: NearbyStopsTableViewController
    // ************************************
    
    // query parse for all the stops
    //        let database = CKContainer.defaultContainer().publicCloudDatabase
    //        if currentLocation == nil {
    //            let alertView = UIAlertView(title: "Cannot Retrieve Nearby Stops", message: "Please enable location services and make sure you are connected to the internet.", delegate: nil, cancelButtonTitle: "Ok")
    //            alertView.show()
    //        } else {
    //            let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location,%@) < 1.61", currentLocation)
    //            let ckQuery = CKQuery(recordType: "Stop", predicate: predicate)
    //            ckQuery.sortDescriptors = [CKLocationSortDescriptor(key: "location", relativeLocation: locationManager.location)]
    //            database.performQuery(ckQuery, inZoneWithID: nil) {
    //                results, error in
    //                if error != nil {
    //                    println(error)
    //                } else {
    //                    println(results.count)
    //                    for record in results {
    //                        let stop = Stop(name: record["name"] as String, code: record["code"] as String, location: record["location"] as CLLocation)
    //                        let distance = self.locationManager.location.distanceFromLocation(stop.location) / 1609.34
    //                        let tuple = (stop: stop, distance: distance)
    //                        println(distance)
    //                        self.nearbyStops.append(tuple)
    //                    }
    //
    //                    dispatch_async(dispatch_get_main_queue(), {
    //                        if self.nearbyStops.count == 0 {
    //                            let alertView = UIAlertView(title: "No Nearby Stops found", message: "Either location services are not enabled, or no stops are available within a mile.", delegate: nil, cancelButtonTitle: "Ok")
    //                            alertView.show()
    //                        }
    //                        self.tableView.reloadData()
    //                        if self.refreshControl!.refreshing {
    //                            self.refreshControl!.endRefreshing()
    //                        }
    //                    })
    //                }
    //            }
    //        }
    
    // *******************************
    // MARK: RoutesTableViewController
    // *******************************
    
    
    //        let database = CKContainer.defaultContainer().publicCloudDatabase
    //        let ckQuery = CKQuery(recordType: "Route", predicate: NSPredicate(value: true))
    //        ckQuery.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    //        database.performQuery(ckQuery, inZoneWithID: nil) {
    //            results, error in
    //            if error != nil {
    //                println(error)
    //            } else {
    //                for record in results {
    //                    let route = Route(name: record.objectForKey("name") as? String, shortName: record.objectForKey("shortName") as String)
    //                    self.routes.append(route)
    //                }
    //                dispatch_async(dispatch_get_main_queue()) {
    //                    self.tableView.reloadData()
    //                }
    //            }
    //        }
    
    
    // ***************************
    // MARK: SegmentViewController
    // ***************************
    
    
    //        let database = CKContainer.defaultContainer().publicCloudDatabase
    //        let predicate = NSPredicate(format: "code IN %@", codes)
    //        let sort = NSSortDescriptor(key: "name", ascending: true)
    //        let ckQuery = CKQuery(recordType: "Stop", predicate: predicate)
    //        ckQuery.sortDescriptors = [sort]
    //        database.performQuery(ckQuery, inZoneWithID: nil) {
    //            results, error in
    //            if error != nil {
    //                println(error)
    //            } else {
    //                var counter = 0
    //                for record in results {
    //                    self.stops[counter++].location = record.objectForKey("location") as CLLocation
    //                }
    //            }
    //        }
}
