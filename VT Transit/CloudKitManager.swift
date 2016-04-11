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
import Foundation

public class CloudKitManager: NSObject {
   
    public let privateDB = CKContainer.defaultContainer().privateCloudDatabase // CloudKit database
    public var favoriteStops:Array<Stop>! = Array<Stop>() // favoriteStops
    public var allStops:Array<Stop>! = Array<Stop>() // all stops
    
    // ***********************
    // MARK: Singleton Pattern
    // ***********************
    
    public class var sharedInstance: CloudKitManager {
        struct Static {
            static var instance: CloudKitManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = CloudKitManager()
            Static.instance!.queryFavoriteStops({})
        }
        return Static.instance!
    }
    
    // ********************
    // MARK: Favorite Stops
    // ********************
    
    // get favorite stops from iCloud
    public func queryFavoriteStops(completionHandler: ()->()) {
        let query = CKQuery(recordType: "Stop", predicate: NSPredicate(value: true))
        let sort = NSSortDescriptor(key: "favoritesIndex", ascending: true)
        query.sortDescriptors = [sort]
        privateDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                print(error)
            } else {
                self.favoriteStops = []
                for record in results! {
                    let stop = Stop(name: (record["name"] as! String), code: (record["code"] as! String), location: (record["location"] as! CLLocation))
                    self.favoriteStops!.append(stop)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler()
                }
            }
        }
    }
    
    // update favorite stops to iCloud
    public func updateFavoriteStops() {
        for (index, stop) in favoriteStops.enumerate() {
            privateDB.fetchRecordWithID(CKRecordID(recordName: stop.code), completionHandler: { (record, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    // save the record once fetched
                    dispatch_async(dispatch_get_main_queue(), {
                        record!.setValue(index, forKey:"favoritesIndex")
                        self.privateDB.saveRecord(record!, completionHandler: { (record, error) -> Void in
                            if error != nil {
                                print(error)
                            } else {
                                let sharedDefault = NSUserDefaults(suiteName: "group.VTTransit")
                                let data = NSKeyedArchiver.archivedDataWithRootObject(self.favoriteStops)
                                sharedDefault?.setObject(data, forKey: "favoriteStops")
                                sharedDefault?.synchronize()
                            }
                        })
                    })
                }
            })
        }
    }
    
    // ***************
    // MARK: All Stops
    // ***************
    
    // get all the stops from Parse
    public func queryAllStops(completionHandler: ()->()) {
        
        let database = CKContainer.defaultContainer().publicCloudDatabase
        let ckQuery = CKQuery(recordType: "Stop", predicate: NSPredicate(value: true))
        ckQuery.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        database.performQuery(ckQuery, inZoneWithID: nil) {
            results, error in
            if error != nil {
                print("\(error)")
            } else {
                for record in results! {
                    let name = record["name"] as! String
                    let code = record["code"] as! String
                    let location = record["location"] as! CLLocation
                    let stop = Stop(name: name, code: code, location: location)
                    self.allStops.append(stop)
                }
                completionHandler();
            }
        }

        
        
        
        
        
        let query = PFQuery(className: "Stops")
        query.limit = 500
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let location = CLLocation(latitude: (object["latitude"] as! NSString).doubleValue, longitude: (object["longitude"] as! NSString).doubleValue)
                    let stop = Stop(name: object["name"] as! String, code: object["code"] as! String, location:location)
                    self.allStops.append(stop)
                }
            }
            completionHandler()
        }
    }
    
    // ********************
    // MARK: Ingest Records
    // ********************
    
    public func ingestRoutes() {
        let database = CKContainer.defaultContainer().publicCloudDatabase
        guard let
            path = NSBundle.mainBundle().pathForResource("Routes", ofType: "json"),
            jsonData = try? NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe),
            jsonResult = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? NSDictionary
        
        else {
            print("Error occured reading file")
            return
        }
        
        for route in jsonResult!["results"] as! NSArray {
            // upload to cloudkit
            let routeName = route["name"] as! String
            let routeShortName = route["shortName"] as! String
            let routeRecordID = CKRecordID(recordName: routeShortName)
            let routeRecord = CKRecord(recordType: "Route", recordID: routeRecordID)
            routeRecord["name"] = routeName
            routeRecord["shortName"] = routeShortName
            database.saveRecord(routeRecord, completionHandler: { (record, error) in
                if error != nil {
                    print("An error occured: \(error)")
                } else {
                    print("Record was saved \(record!["shortName"])")
                }
            })
        }
    }
    
    public func ingestStops() {
        let database = CKContainer.defaultContainer().publicCloudDatabase
        guard let
            path = NSBundle.mainBundle().pathForResource("Stops", ofType: "json"),
            jsonData = try? NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe),
            jsonResult = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? NSDictionary
            
        else {
            print("Error occured reading file")
            return
        }
        
        for stop in jsonResult!["results"] as! NSArray {
            // upload to cloudkit
            let stopName = stop["name"] as! String
            let stopCode = stop["code"] as! String
            let stopLocation = CLLocation(latitude: Double(stop["latitude"] as! String)!, longitude: Double(stop["longitude"] as! String)!)
            
            let stopRecordID = CKRecordID(recordName: stopName)
            let stopRecord = CKRecord(recordType: "Stop", recordID: stopRecordID)
            
            stopRecord["name"] = stopName
            stopRecord["code"] = stopCode
            stopRecord["location"] = stopLocation
            
            database.saveRecord(stopRecord, completionHandler: { (record, error) in
                if error != nil {
                    print("An error occured: \(error)")
                } else {
                    print("Record was saved \(record!["code"])")
                }
            })
        }
    }
    
    // *******************************
    // MARK: RoutesTableViewController
    // *******************************
    
    
//            let database = CKContainer.defaultContainer().publicCloudDatabase
//            let ckQuery = CKQuery(recordType: "Route", predicate: NSPredicate(value: true))
//            ckQuery.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//            database.performQuery(ckQuery, inZoneWithID: nil) {
//                results, error in
//                if error != nil {
//                    println(error)
//                } else {
//                    for record in results {
//                        let route = Route(name: record.objectForKey("name") as? String, shortName: record.objectForKey("shortName") as String)
//                        self.routes.append(route)
//                    }
//                    dispatch_async(dispatch_get_main_queue()) {
//                        self.tableView.reloadData()
//                    }
//                }
//            }
    
    
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
