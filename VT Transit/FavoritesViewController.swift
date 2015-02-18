//
//  FavoritesViewController.swift
//  VT Transit
//
//  Created by Joe Fletcher on 1/26/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit
import CloudKit

class FavoritesViewController: UITableViewController {
    
    let database = CKContainer.defaultContainer().privateCloudDatabase // CloudKit database
    var favoriteStops = Array<Stop>() // favoriteStops
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        println("test")
        // Query favorite Stops from CloudKit
        let ckQuery = CKQuery(recordType: "Stop", predicate: NSPredicate(value: true))
        self.database.performQuery(ckQuery, inZoneWithID: nil) {
            results, error in
            if error != nil {
                println(error)
            } else {
              self.favoriteStops = []
                for record in results {
                    let stop = Stop(name: record["name"] as String, code: record["code"] as String, location: record["location"] as CLLocation)
                    self.favoriteStops.append(stop)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ******************************
    // MARK: - Table view data source
    // ******************************

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteStops.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"FavoriteStop")
        var stop = favoriteStops[indexPath.row]
        cell.textLabel?.text = stop.name
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell.detailTextLabel?.text = "Bus Stop #" + stop.code
        return cell
    }

    // ***************************
    // MARK: - Table view delegate
    // ***************************

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let deletedStop = favoriteStops.removeAtIndex(indexPath.row)
            let recordID = CKRecordID(recordName: deletedStop.code)
            database.deleteRecordWithID(recordID, completionHandler: { (record, error) -> Void in
                if error != nil {
                    println(error)
                }
            })
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    
    // ***************************
    // MARK: - Add Button Pressed
    // ***************************
    
    @IBAction func addStops(sender: AnyObject) {
        performSegueWithIdentifier("showAddStopsViewController", sender: self)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showArrivalTimesForAllRoutes", sender: tableView)
    }
    
    // *************************
    // MARK: - Prepare For Segue
    // *************************
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddStopsViewController" {
            let advc = segue.destinationViewController as AddStopsViewController
            advc.favoriteStops = self.favoriteStops
        } else if segue.identifier == "showArrivalTimesForAllRoutes" {
            let arrivalTimesForRouteCollectionViewController = segue.destinationViewController as ArrivalTimesForRouteCollectionViewController
            // handle selected cells in search display controlller
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let stop = favoriteStops[indexPath.row]
            arrivalTimesForRouteCollectionViewController.selectedStop = stop
            arrivalTimesForRouteCollectionViewController.selectedRoutes = Parser.routesForStop(stop.code)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
}
    
    
