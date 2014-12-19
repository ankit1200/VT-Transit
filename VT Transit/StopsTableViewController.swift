//
//  StopsTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 11/29/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class StopsTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    var filteredStops = Array<Stop>()
    let parser = Parser()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchDisplayController!.searchResultsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "stopsCell")
        
        // gets stops associated with route
        stops = parser.stopsForRoute(selectedRoute.shortName)
        // sort the stops alphabetically 
        stops.sort({$0.name < $1.name})
        self.title = selectedRoute.name
    }
    
    // ******************************
    // MARK: - Table view data source
    // ******************************
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops.count : stops.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("stopsCell", forIndexPath: indexPath) as UITableViewCell
        
        var stop:Stop
        // Check to see whether the normal table or search results table is being displayed
        stop = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops[indexPath.row] : stops[indexPath.row]
        // configure cell
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.textLabel?.text = stop.name
        cell.detailTextLabel?.text = "Bus Stop #\(stop.code)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showArrivalTimes", sender: tableView)
    }
    
    // ************************
    // MARK: Search Bar Methods
    // ************************
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredStops = self.stops.filter({( stop: Stop) -> Bool in
            let stringNameMatch = stop.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            let stringCodeMatch = stop.code.lowercaseString.rangeOfString(searchText.lowercaseString)
            return (stringNameMatch != nil || stringCodeMatch != nil)
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    // ***********************
    // MARK: Prepare For Segue
    // ***********************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showArrivalTimes" {
            
            let arrivalTimesForRouteCollectionViewController = segue.destinationViewController as ArrivalTimesForRouteCollectionViewController
            
            // handle selected cells in search display controlller
            if sender as UITableView == self.searchDisplayController!.searchResultsTableView {
                let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
                arrivalTimesForRouteCollectionViewController.selectedStop = filteredStops[indexPath.row]
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                arrivalTimesForRouteCollectionViewController.selectedStop = stops[indexPath.row]
            }
            arrivalTimesForRouteCollectionViewController.selectedRoute = selectedRoute
        }
    }
}
