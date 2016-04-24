//
//  ContainerViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/26/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import CloudKitManager

class ContainerViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var segmentControl: UISegmentedControl!
    var segmentViewController: SegmentViewController?
    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    var selectedStop:Stop? // stop that is selected in the collection view that will be zoomed to in the map
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.addTarget(self, action: #selector(ContainerViewController.valueChanged(_:)), forControlEvents: .ValueChanged)
        if (segmentControl.selectedSegmentIndex == 1) {
            self.segmentViewController!.swap()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            segmentViewController?.selectedStop = selectedStop
        }
    }
}
