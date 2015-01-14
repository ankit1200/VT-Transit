//
//  SegmentViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 1/2/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit

class SegmentViewController: UIViewController {

    var transitionInProgress = false
    var currentSegueID = String()
    var stopsTableViewController:StopsTableViewController?
    var segmentMapViewController:SegmentMapViewController?
    let firstSegueID = "showStops"
    let secondSegueID = "showMap"
    
    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitionInProgress = false
        currentSegueID = firstSegueID
        var names = [String]()
        for stop in stops {
            names.append(stop.name)
        }
        querySelectedStopsFromParse(names)
        performSegueWithIdentifier(currentSegueID, sender: nil)
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
    func querySelectedStopsFromParse(names:[String]) {
        
        var query = PFQuery(className:"Stops")
        query.whereKey("name", containedIn: names)
        query.addAscendingOrder("name")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            // The find succeeded.
            if error == nil {
                // Add latitude and longitute to selected Stops
                var counter = 0
                for object in objects {
                    self.stops[counter].latitude = object["latitude"] as String
                    self.stops[counter++].longitude = object["longitude"] as String
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
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
                swapViewControllers(self.childViewControllers[0] as UIViewController, to: stopsTableViewController!)
            }
            else {
                // If this is the very first time we're loading this we need to do
                // an initial load and not a swap.
                addChildViewController(segue.destinationViewController as UIViewController)
                var destView = (segue.destinationViewController as UIViewController).view
                destView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
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
            segmentMapViewController = segue.destinationViewController as? SegmentMapViewController
            swapViewControllers(self.childViewControllers[0] as UIViewController, to: segmentMapViewController!)
            segmentMapViewController?.stops = stops
        }
    }
}