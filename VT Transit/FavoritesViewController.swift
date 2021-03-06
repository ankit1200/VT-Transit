//
//  FavoritesViewController.swift
//  VT Transit
//
//  Created by Joe Fletcher on 1/26/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit
import CloudKit
import CloudKitManager

class FavoritesViewController: UITableViewController {
    
    let database = CKContainer.defaultContainer().privateCloudDatabase // CloudKit database
    let manager = CloudKitManager.sharedInstance
    var selectedRoutes = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        // if favorite stops are 0 then query the database
        if manager.favoriteStops.count == 0 {
            manager.favoriteStops = []
            manager.queryFavoriteStops({})
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ******************************
    // MARK: - Table view data source
    // ******************************

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.favoriteStops.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"FavoriteStop")
        let stop = manager.favoriteStops[indexPath.row]
        cell.textLabel?.text = stop.name
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell.detailTextLabel?.text = "Bus Stop #" + stop.code
        cell.accessoryType = .DisclosureIndicator
        return cell
    }

    // ***************************
    // MARK: - Table view delegate
    // ***************************

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let deletedStop = manager.favoriteStops.removeAtIndex(indexPath.row)
            let recordID = CKRecordID(recordName: deletedStop.code)
            database.deleteRecordWithID(recordID, completionHandler: { (record, error) -> Void in
                if error != nil {
                    print(error)
                }
            })
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // update cloudKit
            manager.updateFavoriteStops()
        }
    }

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        // update the favorite stops list
        let fromStop = manager.favoriteStops[fromIndexPath.row]

        manager.favoriteStops[fromIndexPath.row] = manager.favoriteStops[toIndexPath.row]
        manager.favoriteStops[toIndexPath.row] = fromStop
        
        // update cloudKit
        manager.updateFavoriteStops()
    }
    
    // ***************************
    // MARK: - Add Button Pressed
    // ***************************
    
    @IBAction func addStops(sender: AnyObject) {
        performSegueWithIdentifier("showAddStopsViewController", sender: self)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stop = manager.favoriteStops[indexPath.row]
        selectedRoutes = Parser.routesForStop(stop.code)
        if selectedRoutes.count == 0 {
            // Instantiate an alert view object
            let alertView = UIAlertView(title: "Stop not running!", message: "The selected stop is not running at this time. Please try a different Stop.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        } else {
            performSegueWithIdentifier("showArrivalTimesForAllRoutes", sender: tableView)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // *************************
    // MARK: - Prepare For Segue
    // *************************
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddStopsViewController" {
        } else if segue.identifier == "showArrivalTimesForAllRoutes" {
            let arrivalTimesForRouteCollectionViewController = segue.destinationViewController as! ArrivalTimesForRouteCollectionViewController
            // handle selected cells in search display controlller
            let indexPath = self.tableView.indexPathForSelectedRow!
            let stop = manager.favoriteStops[indexPath.row]
            arrivalTimesForRouteCollectionViewController.selectedStop = stop
            arrivalTimesForRouteCollectionViewController.selectedRoutes = selectedRoutes
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
}
    
    
