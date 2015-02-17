//
//  AddStopsViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 2/16/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit

class AddStopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var stops = Array<Stop>()
    var filteredStops = Array<Stop>()
    @IBOutlet weak var tableView: UITableView!
    var stopsDictionary = Dictionary<String, Array<Stop>>()
    
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        var query = PFQuery(className: "Stops")
        query.limit = 500
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let location = CLLocation(latitude: (object["latitude"] as NSString).doubleValue, longitude: (object["longitude"] as NSString).doubleValue)
                    let stop = Stop(name: object["name"] as String, code: object["code"] as String, location: location)
                    self.stops.append(stop)
                }
                self.stops.sort({$0.name < $1.name})
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // *************************
    // MARK: Done Button Pressed
    // *************************
    
    @IBAction func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    // ******************************
    // MARK: - Table view data source
    // ******************************
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops.count : stops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"cell")
        
        var stop = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops[indexPath.row] : stops[indexPath.row]
        
        cell.textLabel?.text = stop.name
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell.detailTextLabel?.text = "Bus Stop #" + stop.code
        
        return cell
    }
    
    // ************************
    // MARK: Search Bar Methods
    // ************************
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredStops = self.stops.filter({ (stop: Stop) -> Bool in
            let stringMatchName = stop.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            let stringMatchCode = stop.code.rangeOfString(searchText)
            return (stringMatchName != nil || stringMatchCode != nil)
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
}