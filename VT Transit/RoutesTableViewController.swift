//
//  RoutesTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 11/26/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import CloudKit
import CloudKitManager

class RoutesTableViewController: UITableViewController, UISearchResultsUpdating {

    var routes = Array<Route>()
    var filteredRoutes = Array<Route>()
    var stops = Array<Stop>()
    var resultSearchController = UISearchController()
    
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the Search Bar
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search by bus name"
            controller.searchBar.searchBarStyle = UISearchBarStyle.Minimal
            controller.searchBar.tintColor = UIColor(red: 1, green: 0.4, blue: 0, alpha: 1)
            controller.searchBar.backgroundColor = UIColor.whiteColor()
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()

        // Query the Routes Array from Parse Database
        let query = PFQuery(className: "Routes")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                for object in objects {
                    let route = Route(name: object["name"] as? String, shortName: object["shortName"] as! String)
                    
                    self.routes.append(route)
                }
                self.routes.sortInPlace({$0.name < $1.name})
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ****************************
    // MARK: Table view data source
    // ****************************
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // check to see if you are returning the search tableview or routes stops tableview
        return (self.resultSearchController.active) ? filteredRoutes.count : routes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("routesCell", forIndexPath: indexPath) 
        var route:Route
        // Check to see whether the normal table or search results table is being displayed
        route = (self.resultSearchController.active) ? filteredRoutes[indexPath.row] : routes[indexPath.row]
        // configure cell
        cell.textLabel?.text = route.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    // handle tableview cell selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.resultSearchController.active {
            // gets stops associated with route
            self.stops = Parser.stopsForRoute(self.filteredRoutes[indexPath.row].shortName)
        } else {
            self.stops = Parser.stopsForRoute(self.routes[indexPath.row].shortName)
        }
        
        if self.stops.count == 0 {
            // Instantiate an alert view object
            let alertView = UIAlertView(title: "Route not running!", message: "The selected route is not running at this time. Please try a different Route", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            // sort the stops alphabetically
            self.stops.sortInPlace({$0.name < $1.name})
            self.performSegueWithIdentifier("showStopsForRoutes", sender: tableView)
        }
    }
    
    
    // ***********************
    // MARK: Search Bar Method
    // ***********************
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredRoutes = self.routes.filter({( route: Route) -> Bool in
            let routeNameMatch = route.name.lowercaseString.rangeOfString(searchController.searchBar.text!.lowercaseString)
            let routeShortNameMatch = route.shortName.lowercaseString.rangeOfString(searchController.searchBar.text!.lowercaseString)
            return (routeNameMatch != nil || routeShortNameMatch != nil)
        })
        self.tableView.reloadData()
    }
    
    
    // *******************
    // MARK: Handle Segues
    // *******************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showStopsForRoutes" {
            
            let containerViewController = segue.destinationViewController as! ContainerViewController
            // handle selected cells in search display controlller
            let indexPath = self.tableView.indexPathForSelectedRow!
            if self.resultSearchController.active {
                containerViewController.selectedRoute = self.filteredRoutes[indexPath.row]
                self.resultSearchController.active = false
            } else {
                containerViewController.selectedRoute = self.routes[indexPath.row]
            }
            containerViewController.stops = stops
        }
    }
}