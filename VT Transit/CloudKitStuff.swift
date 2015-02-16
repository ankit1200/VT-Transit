//
//  CloudKitStuff.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 2/16/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//


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