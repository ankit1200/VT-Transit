//
//  AddStopsViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 2/16/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit
import CloudKit

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
}

class AddStopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var filteredStops = Array<Stop>() // stops for search
    @IBOutlet weak var tableView: UITableView!
    var stopsDictionary = Dictionary<String, Array<Stop>>() // dictionary for section index
    var sectionTitles = Array<String>() // section index titles
    let manager = CloudKitManager.sharedInstance
    
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
        
        manager.allStops.sort({$0.name < $1.name})
        createAlphabetArray()
//        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // *************************
    // MARK: Done Button Pressed
    // *************************
    
    @IBAction func donePressed(sender: AnyObject) {
        // Save the tableView Selections
        self.dismissViewControllerAnimated(true, completion: {})
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
        
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell")
        
        let sectionArray = stopsDictionary[sectionTitles[indexPath.section]]!
        var stop = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops[indexPath.row] : sectionArray[indexPath.row]
        
        if manager.favoriteStops.filter({$0.code == stop.code}).count > 0 {
            cell.accessoryType = .Checkmark
        }
        
        cell.textLabel?.text = stop.name
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell.detailTextLabel?.text = "Bus Stop #" + stop.code
        
        return cell
    }
    
    // ***************************
    // MARK: - Table view delegate
    // ***************************
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (tableView == self.searchDisplayController!.searchResultsTableView) ? nil : sectionTitles[section]
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return sectionTitles
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionArray = stopsDictionary[sectionTitles[indexPath.section]]!
        var stop = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredStops[indexPath.row] : sectionArray[indexPath.row]
        let recordID = CKRecordID(recordName: stop.code)
        // Deselect the cell
        if tableView.cellForRowAtIndexPath(indexPath)!.accessoryType == .Checkmark {
            tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .None
            
            // remove data from iCloud database
            manager.favoriteStops = manager.favoriteStops.filter{$0.code != stop.code}
            manager.privateDB.deleteRecordWithID(recordID, completionHandler: { (record, error) -> Void in
                if error != nil {
                    println(error)
                }
            })
        } else { // Select the cell
            tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .Checkmark
            
            // Save data to iCloud database
            manager.favoriteStops.append(stop)
            let record = CKRecord(recordType: "Stop", recordID: recordID)
            record.setValue(stop.name, forKey: "name")
            record.setValue(stop.code, forKey: "code")
            record.setValue(stop.location, forKey: "location")
            record.setValue(manager.favoriteStops.endIndex, forKey: "favoritesIndex")
            manager.privateDB.saveRecord(record, completionHandler: { (record, error) -> Void in
                if error != nil {
                    println(error)
                }
            })
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // ************************
    // MARK: Search Bar Methods
    // ************************
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredStops = manager.allStops.filter({ (stop: Stop) -> Bool in
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
        for stop in manager.allStops {
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