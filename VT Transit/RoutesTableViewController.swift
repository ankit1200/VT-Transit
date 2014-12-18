//
//  RoutesTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 11/26/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class RoutesTableViewController: UITableViewController {

    var routes = Array<Route>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFQuery(className: "Routes")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                for object in objects {
                    let route = Route(name: object["name"] as String, shortName: object["shortName"] as String)
                    self.routes.append(route)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return routes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("routesCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = routes[indexPath.row].name as String
        
        return cell
    }
    
    // MARK: Prepare For Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showStopsForRoutes" {
            
            let stopsTableViewController = segue.destinationViewController as StopsTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            stopsTableViewController.selectedRoute = routes[indexPath!.row]
        }
    }
}
