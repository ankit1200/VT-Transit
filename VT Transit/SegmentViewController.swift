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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitionInProgress = false
        currentSegueID = firstSegueID
        performSegueWithIdentifier(currentSegueID, sender: nil)
    }
    
    func swapViewControllers(from:UIViewController, to:UIViewController) {
        
        to.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        from.willMoveToParentViewController(nil)
        addChildViewController(to)
        transitionFromViewController(from, toViewController: to, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: {
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
            segmentMapViewController?.selectedRoute = selectedRoute
            segmentMapViewController?.stops = stops
        }
    }
}
