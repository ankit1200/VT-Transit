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
   
    public let publicDB = CKContainer.defaultContainer().publicCloudDatabase // Public CloudKit Database
    public let privateDB = CKContainer.defaultContainer().privateCloudDatabase // Private CloudKit Database
    public var favoriteStops:Array<Stop>! = Array<Stop>() // favoriteStops
    public var allStops:Array<Stop>! = Array<Stop>() // all stops
    public var allRoutes:Array<Route>! = Array<Route>() // all routes
    
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
    
    // *****************
    // MARK: All Records
    // *****************
    
    // get all the routes from iCloud
    public func queryAllRoutes(completionHandler: ()->()) {
        let ckQuery = CKQuery(recordType: "Route", predicate: NSPredicate(value: true))
        ckQuery.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let operation = CKQueryOperation(query: ckQuery)
        
        operation.recordFetchedBlock = { (record) in
            let name = record["name"] as! String
            let shortName = record["shortName"] as! String
            let route = Route(name: name, shortName: shortName)
            if self.allRoutes.last?.name != name {
                self.allRoutes.append(route)
            }
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    completionHandler()
                } else {
                    // HANDLE ERROR
                    print("An error occured: \(error)")
                }
            }
        }
        publicDB.addOperation(operation)
    }
    
    // get all the stops from iCloud
    public func queryAllStops(completionHandler: ()->()) {
        let ckQuery = CKQuery(recordType: "Stop", predicate: NSPredicate(value: true))
        ckQuery.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let operation = CKQueryOperation(query: ckQuery)
        operation.qualityOfService = .UserInitiated
        operation.recordFetchedBlock = populateStopsArray
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil {
                if cursor != nil {
                    self.fetchRecords(cursor!)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler()
                    }
                }
            } else {
                // HANDLE ERROR
                print("An error occured: \(error)")
            }
        }
        
        publicDB.addOperation(operation)
    }
    
    func fetchRecords(cursor: CKQueryCursor?) {
        
        let operation = CKQueryOperation(cursor: cursor!)
        operation.qualityOfService = .UserInitiated
        operation.recordFetchedBlock = populateStopsArray
        
        operation.queryCompletionBlock = { cursor, error in
            
            if cursor != nil {
                self.fetchRecords(cursor!)
                
            } else {
            }
        }
        
        publicDB.addOperation(operation)
    }
    
    func populateStopsArray(record: CKRecord) {
        
        let name = record["name"] as! String
        let code = record["code"] as! String
        let location = record["location"] as! CLLocation

        let mainQueue = NSOperationQueue.mainQueue()
        mainQueue.addOperationWithBlock() {
            let stop = Stop(name: name, code: code, location: location)
            self.allStops.append(stop)
        }
    }
    
    // ********************
    // MARK: Ingest Records
    // ********************
    
    public func ingestRoutes() {
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
            publicDB.saveRecord(routeRecord, completionHandler: { (record, error) in
                if error != nil {
                    print("An error occured: \(error)")
                } else {
                    print("Record was saved \(record!["shortName"])")
                }
            })
        }
    }
    
    public func ingestStops() {
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
            
            publicDB.saveRecord(stopRecord, completionHandler: { (record, error) in
                if error != nil {
                    print("An error occured: \(error)")
                } else {
                    print("Record was saved \(record!["code"])")
                }
            })
        }
    }
}
