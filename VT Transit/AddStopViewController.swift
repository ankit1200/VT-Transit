//
//  AddStopViewController.swift
//  VT Transit
//
//  Created by Joe Fletcher on 1/26/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit

class AddStopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var stops = Array<Stop>()
    
    @IBOutlet weak var tableView: UITableView!
    
    var stopsDictionary = Dictionary<String, Array<Stop>>()
    
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
                    let stop = Stop(name: object["name"] as String, code: object["code"] as String, latitude: object["latitude"] as String, longitude: object["longitude"] as String)
                    self.stops.append(stop)
                    
                }
                self.stops.sort({$0.name < $1.name})
                
                self.tableView.reloadData()
                
            }
        }
        
    }


    @IBAction func donePressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: {})
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return self.stops.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"cell")
        
        cell.textLabel?.text = stops[indexPath.row].name
        
        cell.detailTextLabel?.text = "Bus Stop #" + stops[indexPath.row].code
        
        
        return cell
    }

}