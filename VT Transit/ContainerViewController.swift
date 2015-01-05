//
//  ContainerViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/26/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var segmentControl: UISegmentedControl!
    var segmentViewController: SegmentViewController?
    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.addTarget(self, action: "valueChanged:", forControlEvents: .ValueChanged)
        
        // set inital view controller as stops table view controller
//        var stopsTableViewController = StopsTableViewController(selectedRoute: selectedRoute, stops: stops)
//        addChildViewController(stopsTableViewController)
    }
    
    
    // ***********************************
    // MARK: Segment Control Value Changed
    // ***********************************
    func valueChanged(sender: AnyObject?) {

        self.segmentViewController!.swap()
    }
    
    
    // *******************
    // MARK: Handle Segues
    // *******************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "embedContainer" {
            segmentViewController = segue.destinationViewController as? SegmentViewController
            segmentViewController?.selectedRoute = selectedRoute
            segmentViewController?.stops = stops
        }
    }
}
