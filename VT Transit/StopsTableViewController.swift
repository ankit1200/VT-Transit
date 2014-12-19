//
//  StopsTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 11/29/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class StopsTableViewController: UITableViewController {

    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    let parser = Parser()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return stops.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("stopsCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = stops[indexPath.row].name
        cell.detailTextLabel?.text = "Bus Stop #\(stops[indexPath.row].code)"
        
        return cell
    }
    
    // ***********************
    // MARK: Prepare For Segue
    // ***********************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showArrivalTimes" {
            
            let arrivalTimesForRouteCollectionViewController = segue.destinationViewController as ArrivalTimesForRouteCollectionViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            arrivalTimesForRouteCollectionViewController.selectedRoute = selectedRoute
            arrivalTimesForRouteCollectionViewController.selectedStop = stops[indexPath!.row]
        }
    }
}
