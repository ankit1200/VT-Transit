//
//  StopsTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 11/29/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import CloudKitManager

class StopsTableViewController: UITableViewController, UISearchResultsUpdating {

    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    var filteredStops = Array<Stop>()
    var resultSearchController = UISearchController()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
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
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // deselect all rows in tableView
        let indexPath:NSIndexPath? = self.tableView.indexPathForSelectedRow
        if indexPath != nil {
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ******************************
    // MARK: - Table view data source
    // ******************************
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.resultSearchController.active) ? filteredStops.count : stops.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("stopsCell") as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "stopsCell")
        }
        
        var stop:Stop
        // Check to see whether the normal table or search results table is being displayed
        stop = (self.resultSearchController.active) ? filteredStops[indexPath.row] : stops[indexPath.row]
        // configure cell
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell!.textLabel?.text = stop.name
        cell!.textLabel?.adjustsFontSizeToFitWidth = true
        cell!.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell!.detailTextLabel?.text = "Bus Stop #\(stop.code)"
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showArrivalTimes", sender: tableView)
    }
    
    
    // ************************
    // MARK: Search Bar Methods
    // ************************
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Filter the array using the filter method
        filteredStops = self.stops.filter({( stop: Stop) -> Bool in
            let stringNameMatch = stop.name.lowercaseString.rangeOfString(searchController.searchBar.text!.lowercaseString)
            let stringCodeMatch = stop.code.lowercaseString.rangeOfString(searchController.searchBar.text!)
            return (stringNameMatch != nil || stringCodeMatch != nil)
        })
        self.tableView.reloadData()
    }
    
    // ***********************
    // MARK: Prepare For Segue
    // ***********************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showArrivalTimes" {
            
            let arrivalTimesForRouteCollectionViewController = segue.destinationViewController as! ArrivalTimesForRouteCollectionViewController
            
            // handle selected cells in search display controlller
            let indexPath = self.tableView.indexPathForSelectedRow!
            if self.resultSearchController.active {
                arrivalTimesForRouteCollectionViewController.selectedStop = filteredStops[indexPath.row]
                self.resultSearchController.active = false
            } else {
                arrivalTimesForRouteCollectionViewController.selectedStop = stops[indexPath.row]
            }
            arrivalTimesForRouteCollectionViewController.selectedRoutes = [selectedRoute]
        }
        if segue.identifier == "showMap" {
            //let segmentMapViewController = segue.destinationViewController as! MapViewController
        }
    }
}