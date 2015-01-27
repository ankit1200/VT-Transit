//
//  NearbyStopsTableViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 1/26/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit

class NearbyStopsTableViewController: UITableViewController {

    var stops = Array<(stop: Stop, distance: Double)>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // ****************************
    // MARK: Table view data source
    // ****************************
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("nearbyStops", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    
    
    // ********************
    // MARK: Helper Methods
    // ********************
    
    func getDistancesForAllStops() {
        // query parse for all the stops
        var query = PFQuery(className: "Stops")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let stop = Stop(name: object["name"] as String, code: object["code"] as String, latitude: object["latitude"] as String, longitude: object["longitude"] as String)
                    self.stops.append(stop: stop, distance: 2.3)
                }
            }
        }
    }
    
    
    // *******************
    // MARK: Handle Segues
    // *******************
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
}
