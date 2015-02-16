//
//  NearbyStopsTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 1/26/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit
import CloudKit

class NearbyStopsTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    var stops: [(stop: Stop, distance: Double)] = []
    let locationManager = CLLocationManager()
    var nearbyStops: [(stop: Stop, distance: Double)] = []
    var filteredStops: [(stop: Stop, distance: Double)] = []
    var selectedRoutes = [Route]()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        // pull to refresh
        var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh nearby stops")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // start location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        getStopsFromParse()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // *************************************
    // MARK: Pull to Refresh Selector Method
    // *************************************
    
    func refresh(sender:AnyObject) {
        nearbyStops = []
        for tuple in stops {
            var distance = tuple.stop.location.distanceFromLocation(self.locationManager.location) as Double / 1609.34
            self.locationManager.stopUpdatingLocation()
            if distance < 1.61 {
                self.nearbyStops.append(tuple)
            }
            self.nearbyStops.sort({$0.1 < $1.1})
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }


    // ****************************
    // MARK: Table view data source
    // ****************************
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // check to see if you are returning the search tableview or nearby stops tableview
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return filteredStops.count
        } else {
            // Return at most 10 nearby stops
            return (nearbyStops.count > 10) ? 10 : nearbyStops.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            var cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as NearbyStopsTableViewCell!
            if cell == nil {
                cell = NearbyStopsTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "searchCell")
            }
            var tuple: (stop: Stop, distance: Double) = filteredStops[indexPath.row]
            // check to see if if tableview is search or nearbyStops

            // Configure cell
            cell.textLabel?.text = tuple.stop.name
            cell.textLabel?.font = UIFont(name: "System Bold", size: 16)
            let distanceInMiles = tuple.distance / 1609.34
            cell.detailTextLabel?.text = "Bus Stop #\(tuple.stop.code)"
            return cell
            
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("nearbyStops") as NearbyStopsTableViewCell!
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "nearbyStops") as NearbyStopsTableViewCell
            }
        
        var tuple = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops[indexPath.row] : nearbyStops[indexPath.row]
            // check to see if if tableview is search or nearbyStops
            
            // Configure cell
            cell.title?.text = tuple.stop.name
            let distanceInMiles = tuple.distance
            cell.subtitle?.text = "Bus Stop #\(tuple.stop.code)"
            // if location is disabled then make distance label blank
            if locationManager.location != nil || distanceInMiles != 0.00 {
                cell.distance?.text = String(format:"%.2f", distanceInMiles) + " miles"
            } else {
                cell.distance?.text = ""
            }
            
            return cell
        }
    }
    
    // ****************************
    // MARK: Table view delegate
    // ****************************
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var stopCode = (tableView == self.searchDisplayController!.searchResultsTableView!) ? filteredStops[indexPath.row].stop.code : nearbyStops[indexPath.row].stop.code
        selectedRoutes = Parser.routesForStop(stopCode)
        performSegueWithIdentifier("showArrivalTimesForAllRoutes", sender: tableView)
    }
    
    
    // ************************
    // MARK: Search Bar Methods
    // ************************
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredStops = self.stops.filter({(stop: Stop, distance:Double) -> Bool in
            let stringMatchName = stop.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            let stringMatchCode = stop.code.rangeOfString(searchText)
            return (stringMatchName != nil || stringMatchCode != nil)
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    
    // ********************
    // MARK: Helper Methods
    // ********************
    
    func getStopsFromParse() {
        let currentLocation = locationManager.location
        var query = PFQuery(className: "Stops")
        query.limit = 500
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let location = CLLocation(latitude: (object["latitude"] as NSString).doubleValue, longitude: (object["longitude"] as NSString).doubleValue)
                    let stop = Stop(name: object["name"] as String, code: object["code"] as String, location:location)
                    self.getDistancesForStop(stop)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    if self.nearbyStops.count == 0 {
                        let alertView = UIAlertView(title: "No Nearby Stops found", message: "Either location services are not enabled, or no stops are available within a mile.", delegate: nil, cancelButtonTitle: "Ok")
                        alertView.show()
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func getDistancesForStop(stop:Stop) {
        var distance = stop.location.distanceFromLocation(self.locationManager.location) as Double / 1609.34
        self.locationManager.stopUpdatingLocation()
        let tuple = (stop: stop, distance: distance)
        self.stops.append(tuple)
        if distance < 1.61 {
            self.nearbyStops.append(tuple)
        }
        self.nearbyStops.sort({$0.1 < $1.1})
    }
    
    
    // *******************
    // MARK: Handle Segues
    // *******************
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showArrivalTimesForAllRoutes" {
            let arrivalTimesForRouteCollectionViewController = segue.destinationViewController as ArrivalTimesForRouteCollectionViewController
            // handle selected cells in search display controlller
            if sender as UITableView == self.searchDisplayController!.searchResultsTableView {
                let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
                arrivalTimesForRouteCollectionViewController.selectedStop = filteredStops[indexPath.row].stop
                self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                arrivalTimesForRouteCollectionViewController.selectedStop = nearbyStops[indexPath.row].stop
                self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
            arrivalTimesForRouteCollectionViewController.selectedRoutes = selectedRoutes
        }
    }
}