//
//  RoutesTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 11/26/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class RoutesTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    var routes = Array<Route>()
    var filteredRoutes = Array<Route>()
    let parser = Parser()
    var stops = Array<Stop>()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchDisplayController!.searchResultsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "routesCell")
        
        var query = PFQuery(className: "Routes")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                for object in objects {
                    let route = Route(name: object["name"] as String, shortName: object["shortName"] as String)
                    self.routes.append(route)
                }
                self.routes.sort({$0.name < $1.name})
                self.tableView.reloadData()
            }
        }
    }
    
    // ****************************
    // MARK: Table view data source
    // ****************************
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredRoutes.count : routes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("routesCell", forIndexPath: indexPath) as UITableViewCell
        
        var route:Route
        // Check to see whether the normal table or search results table is being displayed
        route = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredRoutes[indexPath.row] : routes[indexPath.row]
        // configure cell
        cell.textLabel?.text = route.name as String
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    // handle tableview cell selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            // gets stops associated with route
            stops = parser.stopsForRoute(self.filteredRoutes[indexPath.row].shortName)
        } else {
            stops = parser.stopsForRoute(self.routes[indexPath.row].shortName)
        }
        if stops.count == 0 {
            
            // Instantiate an alert view object
            var alertView = UIAlertView()
            alertView.title = "Route not running!"
            alertView.message = "The selected route is not running at this time. Please try a different Route"
            alertView.delegate = nil
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else {
            // sort the stops alphabetically
            stops.sort({$0.name < $1.name})
            self.performSegueWithIdentifier("showStopsForRoutes", sender: tableView)
        }
    }
    
    
    // ************************
    // MARK: Search Bar Methods
    // ************************
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredRoutes = self.routes.filter({( route: Route) -> Bool in
            let stringMatch = route.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            return (stringMatch != nil)
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    
    // *******************
    // MARK: Handle Segues
    // *******************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showStopsForRoutes" {
            
            let stopsTableViewController = segue.destinationViewController as StopsTableViewController
            // handle selected cells in search display controlller
            if sender as UITableView == self.searchDisplayController!.searchResultsTableView {
                let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
                stopsTableViewController.selectedRoute = self.filteredRoutes[indexPath.row]
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                stopsTableViewController.selectedRoute = self.routes[indexPath.row]
            }
            stopsTableViewController.stops = stops
        }
    }
}
