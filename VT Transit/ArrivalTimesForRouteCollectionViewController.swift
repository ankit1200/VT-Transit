//
//  ArrivalTimesForRouteCollectionViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/18/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class ArrivalTimesForRouteCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

    var selectedRoutes = [Route]()
    var selectedStop = Stop(name: "", code: "", location:CLLocation())
    var arrivalTimes:[(time: [String], route: Route)] = []
    let parser = Parser()
    var refreshControl:UIRefreshControl!
    var navBarHidden = false
    let locationManager = CLLocationManager()
    var stopsForRoute = Array<Stop>() // stops list for when info button is pressed
    let manager = CloudKitManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if manager.favoriteStops.filter({$0.code == self.selectedStop.code}).count == 0 {
            // Add the Add Favorites button
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Bordered, target: self, action: "addToFavorites:")
        }
        
        // pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor(red: 0.4, green: 0, blue: 0, alpha: 1)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refreshControl)
        
        // differentiate between whether one route is displayed with all times or 6 times displayed for multiple routes
        if selectedRoutes.count == 1 {
            self.title = selectedRoutes[0].name
        } else {
            self.title = selectedStop.name
        }
        
        locationManager.delegate = self
        // start location manager
        locationManager.requestWhenInUseAuthorization()
        
        // get arrivalTimes for routes
        for route in selectedRoutes {
            let time = Parser.arrivalTimesForRoute(route.shortName, stopCode: selectedStop.code)
            arrivalTimes.append(time: time, route: route)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navBarHidden = (self.navigationController?.navigationBarHidden)!
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = navBarHidden
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // **********************
    // MARK: Selector Methods
    // **********************
    
    func refresh(sender:AnyObject?) {
        // update data
        for route in selectedRoutes {
            let time = Parser.arrivalTimesForRoute(route.shortName, stopCode: selectedStop.code)
            arrivalTimes.append(time: time, route: route)
        }
        self.collectionView?.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func addToFavorites(sender:UIBarButtonItem) {
        let record = CKRecord(recordType: "Stop", recordID: CKRecordID(recordName: selectedStop.code))
        record.setValue(selectedStop.name, forKey: "name")
        record.setValue(selectedStop.code, forKey: "code")
        record.setValue(selectedStop.location, forKey: "location")
        manager.privateDB.saveRecord(record, completionHandler: { (record, error) -> Void in
            if error != nil {
                println(error)
            }
        })
        manager.favoriteStops.append(selectedStop)
        self.navigationItem.rightBarButtonItem = nil
        showAlert("Stop Added To Favorites", message: "\(selectedStop.name) has been added to favorites!")
    }
    
    // ********************************
    // MARK: UICollectionViewDataSource
    // ********************************

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return selectedRoutes.count;
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // if no arrival times remain then return 1, for the noArrivalTimesCell else return the count
        // if there are multiple routes, then only return the first 6 arrivalTimes
        let arrivalTimesCount = arrivalTimes[section].time.count
        return (arrivalTimesCount == 0) ?  1 : ((selectedRoutes.count > 1 && arrivalTimesCount > 6) ? 6 : arrivalTimesCount)
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
            var timeDifferenceMinutes = Int((arrivalTimeDate?.timeIntervalSinceNow)! / 60) - 1 // get time difference in (MINUTES) add 1 minute buffer
            var timeDifferenceHours = 0
            cell.timeRemainingLabel.numberOfLines = 0
            var timeRemainingText = String()
            // check to see if more than one hour remaining
            if timeDifferenceMinutes > 60 {
                timeDifferenceHours = timeDifferenceMinutes / 60
                timeDifferenceMinutes = timeDifferenceMinutes % 60
                 timeRemainingText = "\(timeDifferenceHours) hrs\n\(timeDifferenceMinutes) min"
                
            } else if timeDifferenceMinutes < 0 {
                timeRemainingText = "BUS HAS PASSED"
                
            } else {
                timeRemainingText = "\(timeDifferenceMinutes) min"
            }
            
            cell.timeRemainingLabel.text = timeRemainingText
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle // short style is just h:mm a
            let arrivalTime = dateFormatter.stringFromDate(arrivalTimeDate!) // get arrival time string from date
            cell.arrivalTimeLabel.text = arrivalTime
            
            return cell
        }
    }
    
    // ******************************
    // MARK: UICollectionViewDelegate
    // ******************************
    
    // function to set up Header
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var reusableview = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as StopsHeaderCollectionReusableView
            
            let selectedRoute = selectedRoutes[indexPath.section]
            if selectedRoutes.count == 1 {
                headerView.title.text = selectedStop.name
                headerView.title.adjustsFontSizeToFitWidth = true
                headerView.subtitle.text = "Stop #: \(selectedStop.code)    Route Code: \(selectedRoute.shortName)"
                headerView.routeTitle.text = ""
                headerView.route = selectedRoute
            } else {
                headerView.routeTitle.text = selectedRoute.name
                headerView.routeTitle.adjustsFontSizeToFitWidth = true
                headerView.title.text = ""
                headerView.subtitle.text = ""
                headerView.route = selectedRoute
            }
            reusableview = headerView;
        }
        return reusableview
    }
    
    // function to set the size of the cell appropriately
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return (arrivalTimes[indexPath.section].time.count == 0) ? CGSize(width: 290.0, height: 60.0) : CGSize(width: 90.0, height: 90.0)
    }
    
    // function used to show reminder alert view
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            
            let dateFormatter = NSDateFormatter() // date format
            dateFormatter.dateFormat = "M/dd/yyyy h:mm:ss a" // set date format
            let arrivalTimeDate = dateFormatter.dateFromString(arrivalTimes[indexPath.section].time[indexPath.row]) // get date from arrival time
            
            var timeDifferenceMinutes = Int((arrivalTimeDate?.timeIntervalSinceNow)! / 60) - 1 // get time difference in (MINUTES)
            
            let alertController = UIAlertController(title: "Set Reminder", message: nil, preferredStyle: .ActionSheet)
            locationManager.startUpdatingLocation()
            if (timeDifferenceMinutes > 5) {
                let fiveMinutes = UIAlertAction(title: "5 Minutes", style: .Default, handler: {(UIAlertAction) in self.fireNotification(5, indexPath: indexPath)})
                alertController.addAction(fiveMinutes)
            }
            if (timeDifferenceMinutes > 10) {
                let tenMinutes = UIAlertAction(title: "10 Minutes", style: .Default, {(UIAlertAction) in self.fireNotification(10, indexPath: indexPath)})
                alertController.addAction(tenMinutes)
            }
            if (timeDifferenceMinutes > 15) {
                let fifteenMinutes = UIAlertAction(title: "15 Minutes", style: .Default, {(UIAlertAction) in self.fireNotification(15, indexPath: indexPath)})
                alertController.addAction(fifteenMinutes)
            }
            if (timeDifferenceMinutes > 2) {
                let smartAlert = UIAlertAction(title: "When I Need to Leave", style: .Default, handler: {(UIAlertAction) in self.fireNotification(0, indexPath: indexPath)})
                alertController.addAction(smartAlert)
            }
            
            if (alertController.actions.count == 0) {
                showAlert("Leave Now!", message: "You should probably stop reading this and leave.")
            } else {
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancel)
                presentViewController(alertController, animated: true, completion: nil)
            }
    }
    
    // ***************************
    // MARK: Detail Button Pressed
    // ***************************
    
    @IBAction func detailButtonPressed(sender: UIButton) {
        
        let route = (sender.superview as StopsHeaderCollectionReusableView).route
        self.stopsForRoute = Parser.stopsForRoute(route!.shortName)
        // sort the stops alphabetically
        self.stopsForRoute.sort({$0.name < $1.name})
        performSegueWithIdentifier("showStopsForRoute", sender:sender)
    }
    
    
    // ********************
    // MARK: Helper Methods
    // ********************
    
    func fireNotification(minutes: Int, indexPath: NSIndexPath) {
        if (minutes == 0) {
            var request : MKDirectionsRequest  = MKDirectionsRequest()
            var start : MKMapItem = MKMapItem.mapItemForCurrentLocation()
            var coordinate : CLLocationCoordinate2D = selectedStop.location.coordinate
            
            var stopPlacemark : MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            var end : MKMapItem = MKMapItem(placemark: stopPlacemark)
            request.setSource(start)
            request.setDestination(end)
            request.transportType = MKDirectionsTransportType.Walking
            
            var directions : MKDirections = MKDirections(request: request)
            directions.calculateDirectionsWithCompletionHandler({
                (response:MKDirectionsResponse!, error:NSError!) in
                
                if (error != nil) {
                    self.showAlert("Could Not Calculate Walking Time", message: "Please make sure location services and network connection are available.")
                }
                else {
                    var route: MKRoute = response.routes[0] as MKRoute
                    var timeToBeAdded = 240.0;
                    
                    if (route.expectedTravelTime > 60) {
                        timeToBeAdded = timeToBeAdded - 0.2 * route.expectedTravelTime
                    }
                    if (timeToBeAdded <= 0) {
                        timeToBeAdded = 0
                    }
                    var timeInSeconds = route.expectedTravelTime + timeToBeAdded
                    
                    
                    var localNotification = UILocalNotification()
                    let dateFormatter = NSDateFormatter() // date format
                    dateFormatter.dateFormat = "M/dd/yyyy h:mm:ss a" // set date format
                    
                    // indexPath.section gets the route, then time[indexPath.row] gets arrivalTime
                    let arrivalTimeDate = dateFormatter.dateFromString(self.arrivalTimes[indexPath.section].time[indexPath.row]) // get date from arrival time
                    let fireDate = arrivalTimeDate?.dateByAddingTimeInterval(-1 * timeInSeconds)
                    
                    if (fireDate?.compare(NSDate()) == NSComparisonResult.OrderedDescending) {
                        localNotification.fireDate = fireDate
                        println("time right now \(NSDate())")
                        println("time notification will come \(fireDate)")
                        println("time buss will come \(arrivalTimeDate)")
                        var alertMessage = "\(self.selectedRoutes[indexPath.section].name) will arrive at \(self.selectedStop.name) in \(Int(timeInSeconds/60)) minutes"
                        
                        localNotification.alertBody = alertMessage
                        localNotification.alertAction = "View Updated Times"
                        localNotification.category = "busTimeReminderCategory"
                        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                        
                        let dateFormaterJustTime = NSDateFormatter()
                        dateFormaterJustTime.dateFormat = "hh:mm a"
                        
                        
                        let minutesBeforeArrivalTime = arrivalTimeDate?.dateByAddingTimeInterval(-1 * timeInSeconds)
                        let message = "You will be reminded at " + dateFormaterJustTime.stringFromDate(minutesBeforeArrivalTime!)
                        self.showAlert("Reminder Set!", message: message)
                    }
                    else {
                        self.showAlert("Uh Oh!", message: "You're running late!")
                    }
                }
            })
        }
        else {
            var localNotification = UILocalNotification()
            let dateFormatter = NSDateFormatter() // date format
            dateFormatter.dateFormat = "M/dd/yyyy h:mm:ss a" // set date format
            // indexPath.section gets the route, then time[indexPath.row] gets arrivalTime
            let arrivalTimeDate = dateFormatter.dateFromString(arrivalTimes[indexPath.section].time[indexPath.row]) // get date from arrival time
            let fireDate = arrivalTimeDate?.dateByAddingTimeInterval(Double(-60*(minutes + 1)))
            
            if (fireDate?.compare(NSDate()) == NSComparisonResult.OrderedDescending) {
                localNotification.fireDate = fireDate
                
                var alertMessage = "\(selectedRoutes[indexPath.section].name) will arrive at \(selectedStop.name) in \(minutes) minutes"
                
                localNotification.alertBody = alertMessage
                localNotification.alertAction = "View Updated Times"
                localNotification.category = "busTimeReminderCategory"
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                
                let dateFormaterJustTime = NSDateFormatter()
                dateFormaterJustTime.dateFormat = "hh:mm a"
                
                let minutesBeforeArrivalTime = arrivalTimeDate?.dateByAddingTimeInterval(Double(-60*(minutes)))
                let message = "You will be reminded at " + dateFormaterJustTime.stringFromDate(minutesBeforeArrivalTime!)
                showAlert("Reminder Set!", message: message)
            }
            else {
                showAlert("Uh Oh!", message: "You're running late!")
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    func showAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // *******************
    // MARK: Handle Segues
    // *******************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showStopsForRoute" {
            let containerViewController = segue.destinationViewController as ContainerViewController
            containerViewController.selectedRoute = ((sender as UIButton).superview as StopsHeaderCollectionReusableView).route!
            containerViewController.stops = stopsForRoute
            if (selectedRoutes.count == 1) {
                containerViewController.segmentControl.selectedSegmentIndex = 1
                containerViewController.selectedStop = selectedStop
            }
        }
    }
}