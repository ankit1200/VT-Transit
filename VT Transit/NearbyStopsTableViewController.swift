//
//  NearbyStopsTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 1/26/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit
import CloudKit
import CloudKitManager

class NearbyStopsTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    let locationManager = CLLocationManager()
    var nearbyStops: [(stop: Stop, distance: Double)] = []
    var filteredStops: [Stop] = []
    var selectedRoutes = [Route]()
    var resultSearchController = UISearchController()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        // Set up the Search Bar
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search by Stop # or Name"
            controller.searchBar.searchBarStyle = UISearchBarStyle.Minimal
            controller.searchBar.tintColor = UIColor(red: 1, green: 0.4, blue: 0, alpha: 1)
            controller.searchBar.backgroundColor = UIColor.whiteColor()
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh nearby stops")
        refreshControl.addTarget(self, action: #selector(NearbyStopsTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // start location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.refresh(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // *************************************
    // MARK: Pull to Refresh Selector Method
    // *************************************
    
    func refresh(sender:AnyObject) {

        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        nearbyStops = []
        
        // Check to see if location services have been activated
        if locationManager.location == nil {
            let alertView = UIAlertView(title: "Location Service Not Working", message: "Please make sure location services are enabled.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            self.refreshControl?.endRefreshing()
            self.locationManager.stopUpdatingLocation()
        } else {
            self.queryNearbyStops(self.locationManager.location!)
        }
    }

    // ****************************
    // MARK: Table view data source
    // ****************************
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // check to see if you are returning the search tableview or nearby stops tableview
        if self.resultSearchController.active {
            return filteredStops.count
        } else {
            // Return at most 10 nearby stops
            return (nearbyStops.count > 10) ? 10 : nearbyStops.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCellWithIdentifier("nearbyStops") as! NearbyStopsTableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "nearbyStops") as! NearbyStopsTableViewCell
        }
    
        if self.resultSearchController.active {
            let filteredStop = filteredStops[indexPath.row]
            cell.title.text = filteredStop.name
            cell.subtitle?.text = "Bus Stop #\(filteredStop.code)"
            cell.distance.text = ""
            
        } else {
            let tuple = nearbyStops[indexPath.row]
            // Configure cell
            cell.title?.text = tuple.stop.name
            cell.title?.adjustsFontSizeToFitWidth = true
            let distanceInMiles = tuple.distance
            cell.subtitle?.text = "Bus Stop #\(tuple.stop.code)"
            // if location is disabled then make distance label blank
            if locationManager.location != nil || distanceInMiles != 0.00 {
                cell.distance?.text = String(format:"%.2f", distanceInMiles) + " miles"
            } else {
                cell.distance?.text = ""
            }
        }
        
        return cell
    }
    
    // ****************************
    // MARK: Table view delegate
    // ****************************
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stopCode = (self.resultSearchController.active) ? filteredStops[indexPath.row].code : nearbyStops[indexPath.row].stop.code
        selectedRoutes = Parser.routesForStop(stopCode)
        if selectedRoutes.count == 0 {
            // Instantiate an alert view object
            let alertView = UIAlertView(title: "Stop not running!", message: "The selected stop is not running at this time. Please try a different Stop.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        } else {
            performSegueWithIdentifier("showArrivalTimesForAllRoutes", sender: tableView)
        }
    }
    
    
    // ************************
    // MARK: Search Bar Methods
    // ************************
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Filter the array using the filter method
        filteredStops = CloudKitManager.sharedInstance.allStops.filter({(stop: Stop) -> Bool in
            let stringMatchName = stop.name.lowercaseString.rangeOfString(searchController.searchBar.text!.lowercaseString)
            let stringMatchCode = stop.code.rangeOfString(searchController.searchBar.text!)
            return (stringMatchName != nil || stringMatchCode != nil)
        })
        self.tableView.reloadData()
    }
    
    // ********************
    // MARK: Helper Methods
    // ********************
    
    func queryNearbyStops(currentLocation: CLLocation) {
        let database = CKContainer.defaultContainer().publicCloudDatabase
        let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location,%@) < 1.61", currentLocation)
        let ckQuery = CKQuery(recordType: "Stop", predicate: predicate)
        let operation = CKQueryOperation(query: ckQuery)
        
        operation.recordFetchedBlock = { (record) in
            let name = record["name"] as! String
            let code = record["code"] as! String
            let location = record["location"] as! CLLocation
            let stop = Stop(name: name, code: code, location: location)
            let distance = currentLocation.distanceFromLocation(stop.location) / 1609.34
            let tuple = (stop: stop, distance: distance)
            self.nearbyStops.append(tuple)
        }
        
        operation.queryCompletionBlock = {
            [unowned self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.nearbyStops.sortInPlace({$0.1 < $1.1})
                    self.refreshControl?.endRefreshing()
                     self.locationManager.stopUpdatingLocation()
                    self.tableView.reloadData()
                } else {
                    // HANDLE ERROR
                    let alertView = UIAlertView(title: "No Nearby Stops found", message: "No stops were found within a mile.", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            }
        }
        database.addOperation(operation)
    }
    
    
    // *******************
    // MARK: Handle Segues
    // *******************
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showArrivalTimesForAllRoutes" {
            let arrivalTimesForRouteCollectionViewController = segue.destinationViewController as! ArrivalTimesForRouteCollectionViewController
            // handle selected cells in search display controlller
            let indexPath = self.tableView.indexPathForSelectedRow!
            if self.resultSearchController.active {
                arrivalTimesForRouteCollectionViewController.selectedStop = filteredStops[indexPath.row]
                self.resultSearchController.active = false
            } else {
                arrivalTimesForRouteCollectionViewController.selectedStop = nearbyStops[indexPath.row].stop
            }
            arrivalTimesForRouteCollectionViewController.selectedRoutes = selectedRoutes
        }
    }
}