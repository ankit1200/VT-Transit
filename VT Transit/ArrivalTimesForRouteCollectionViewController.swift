//
//  ArrivalTimesForRouteCollectionViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/18/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class ArrivalTimesForRouteCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var selectedRoutes = [Route]()
    var selectedStop = Stop(name: "", code: "", latitude: "", longitude: "")
    var arrivalTimes:[(time: [String], route: Route)] = []
    let parser = Parser()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor(red: 0.4, green: 0, blue: 0, alpha: 1)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refreshControl)
        
        if selectedRoutes.count == 1 {
            self.title = selectedRoutes[0].name
        } else {
            self.title = selectedStop.name
        }
        
        // get arrivalTimes for routes
        for route in selectedRoutes {
            let time = Parser.arrivalTimesForRoute(route.shortName, stopCode: selectedStop.code)
            arrivalTimes.append(time: time, route: route)
        }
    }

    // *************************************
    // MARK: Pull to Refresh Selector Method
    // *************************************
    
    func refresh(sender:AnyObject) {
        
        // update data
        for route in selectedRoutes {
            let time = Parser.arrivalTimesForRoute(route.shortName, stopCode: selectedStop.code)
            arrivalTimes.append(time: time, route: route)
        }
        self.collectionView?.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // ********************************
    // MARK: UICollectionViewDataSource
    // ********************************

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return selectedRoutes.count;
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (arrivalTimes[section].time.count == 0) ?  1 : arrivalTimes[section].time.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if arrivalTimes[indexPath.section].time.count == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("noArrivalTimesCell", forIndexPath: indexPath) as UICollectionViewCell
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("arrivalTimeCell", forIndexPath: indexPath) as ArrivalTimesCollectionViewCell
            
            let dateFormatter = NSDateFormatter() // date format
            dateFormatter.dateFormat = "M/dd/yyyy h:mm:ss a" // set date format
            // indexPath.section gets the route, then time[indexPath.row] gets arrivalTime
            let arrivalTimeDate = dateFormatter.dateFromString(arrivalTimes[indexPath.section].time[indexPath.row]) // get date from arrival time
            var timeDifferenceMinutes = Int((arrivalTimeDate?.timeIntervalSinceNow)! / 60) + 1 // get time difference in (MINUTES) add 1 minute buffer
            var timeDifferenceHours = 0
            cell.timeRemainingLabel.numberOfLines = 0
            
            // check to see if more than one hour remaining
            if timeDifferenceMinutes > 60 {
                timeDifferenceHours = timeDifferenceMinutes / 60
                timeDifferenceMinutes = timeDifferenceMinutes % 60
                cell.timeRemainingLabel.text = "\(timeDifferenceHours) hrs\n\(timeDifferenceMinutes) min"
                
            } else {
                cell.timeRemainingLabel.text = "\(timeDifferenceMinutes) min"
            }
            
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle // short style is just h:mm a
            let arrivalTime = dateFormatter.stringFromDate(arrivalTimeDate!) // get arrival time string from date
            cell.arrivalTimeLabel.text = arrivalTime
            
            return cell
        }
    }
    
    // function to set up Header
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var reusableview = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as StopsHeaderCollectionReusableView
            
            if selectedRoutes.count == 1 {
                headerView.title.text = selectedStop.name
                headerView.subtitle.text = "Stop #: \(selectedStop.code)    Route Code: \(selectedRoutes[indexPath.section].shortName)"
                headerView.routeTitle.text = ""
            } else {
                let selectedRoute = selectedRoutes[indexPath.section]
                headerView.routeTitle.text = selectedRoute.name
                headerView.title.text = ""
                headerView.subtitle.text = ""
            }
            
            reusableview = headerView;
        }
        
        return reusableview
    }
    
    // function to set the size of the cell appropriately
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return (arrivalTimes[indexPath.section].time.count == 0) ? CGSize(width: 290.0, height: 60.0) : CGSize(width: 90.0, height: 90.0)
    }
}