//
//  AddStopsViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 2/16/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
}

class AddStopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var stops = Array<Stop>()
    var filteredStops = Array<Stop>()
    @IBOutlet weak var tableView: UITableView!
    var stopsDictionary = Dictionary<String, Array<Stop>>()
    var sectionTitles = Array<String>()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the tableview delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        // set the tableView section Index Color
        self.tableView.sectionIndexColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        
        
        // Query All Stops from parse
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
                self.createAlphabetArray()
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
        self.dismissViewControllerAnimated(true, completion: {
            // Save the tableView Selections
        })
    }
    
    // ******************************
    // MARK: - Table view data source
    // ******************************
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (tableView == self.searchDisplayController!.searchResultsTableView) ? 1 : sectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops.count : stopsDictionary[sectionTitles[section]]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"cell")
        
        let sectionArray = stopsDictionary[sectionTitles[indexPath.section]]!
        var stop = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops[indexPath.row] : sectionArray[indexPath.row]
        
        cell.textLabel?.text = stop.name
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell.detailTextLabel?.text = "Bus Stop #" + stop.code
        
        return cell
    }
    
    // ***************************
    // MARK: - Table view delegate
    // ***************************
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return sectionTitles
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
    
    // ********************
    // MARK: Helper Methods
    // ********************
    func createAlphabetArray() {
        for stop in stops {
            var firstLetter:String = (stop.name)[0]
            // check if first letter is a number
            if let n = firstLetter.toInt() {
                firstLetter = "#"
            }
            if let array = stopsDictionary[firstLetter] {
                stopsDictionary[firstLetter]!.append(stop)
            } else {
                stopsDictionary[firstLetter] = [stop]
            }
        }
        sectionTitles = (stopsDictionary as NSDictionary).allKeys as Array<String>
        sectionTitles.sort({$0 < $1})
    }
}