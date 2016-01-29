//
//  SegmentViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 1/2/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit
import CloudKit
import CloudKitManager

class SegmentViewController: UIViewController {

    var transitionInProgress = false
    var currentSegueID = String()
    var stopsTableViewController:StopsTableViewController?
    var segmentMapViewController:MapViewController?
    let firstSegueID = "showStops"
    let secondSegueID = "showMap"
    
    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    var selectedStop: Stop?
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitionInProgress = false
        currentSegueID = firstSegueID
        var codes = [String]()
        for stop in stops {
            codes.append(stop.code)
        }
        querySelectedStopsFromParse(codes)
        performSegueWithIdentifier(currentSegueID, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ******************
    // MARK: Swap Methods
    // ******************
    
    func swapViewControllers(from:UIViewController, to:UIViewController) {
        
        to.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        from.willMoveToParentViewController(nil)
        addChildViewController(to)
        transitionFromViewController(from, toViewController: to, duration: 0.75, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: nil, completion: {
            (finished: Bool) -> Void in
            from.removeFromParentViewController()
            to.didMoveToParentViewController(self)
            self.transitionInProgress = false
        })
    }
    
    func swap() {
        
        if (!transitionInProgress) {
        
            transitionInProgress = true
            currentSegueID = (currentSegueID == firstSegueID) ? secondSegueID : firstSegueID
            
            if currentSegueID == firstSegueID && stopsTableViewController != nil {
                swapViewControllers(segmentMapViewController!, to: stopsTableViewController!)
                return
            }
            if currentSegueID == secondSegueID && segmentMapViewController != nil {
                swapViewControllers(stopsTableViewController!, to: segmentMapViewController!)
                return
            }
            performSegueWithIdentifier(currentSegueID, sender: nil)
        }
    }
    
    
    // ************************
    // MARK: Query Stops Method
    // ************************
    func querySelectedStopsFromParse(codes:[String]) {
        
        let query = PFQuery(className:"Stops")
        query.whereKey("code", containedIn: codes)
        query.addAscendingOrder("name")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            // The find succeeded.
            if error == nil {
                // Add latitude and longitute to selected Stops
                var counter = 0
                for object in objects {
                    let location = CLLocation(latitude: (object["latitude"] as! NSString).doubleValue, longitude: (object["longitude"] as! NSString).doubleValue)
                    self.stops[counter++].location = location
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
    }
    
    
    // *******************
    // MARK: Handle Segues
    // *******************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // If we're going to the first view controller.
        if segue.identifier == firstSegueID {
            
            stopsTableViewController = segue.destinationViewController as? StopsTableViewController
            
            // If this is not the first time we're loading this.
            if self.childViewControllers.count > 0 {
                swapViewControllers(self.childViewControllers[0] , to: stopsTableViewController!)
            }
            else {
                // If this is the very first time we're loading this we need to do
                // an initial load and not a swap.
                addChildViewController(segue.destinationViewController )
                let destView = (segue.destinationViewController ).view
                destView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
                destView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                self.view.addSubview(destView)
                segue.destinationViewController.didMoveToParentViewController(self)
            }
            stopsTableViewController?.selectedRoute = selectedRoute
            stopsTableViewController?.stops = stops
        }
        // By definition the second view controller will always be swapped with the
        // first one.
        else if segue.identifier == secondSegueID {
            segmentMapViewController = segue.destinationViewController as? MapViewController
            swapViewControllers(self.childViewControllers[0] , to: segmentMapViewController!)
            segmentMapViewController?.stops = stops
            segmentMapViewController?.selectedRoutes = [selectedRoute]
            segmentMapViewController?.selectedStop = selectedStop
        }
    }
}