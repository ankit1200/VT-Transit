//
//  SegmentMapViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/24/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit
import CloudKitManager

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapTypeSegmentControl: UISegmentedControl!
    @IBOutlet var mapSearchBar: UISearchBar!
    @IBOutlet var dismissKeyboardButton: UIButton!
    var selectedRoutes = [Route]()
    var stops = Array<Stop>()
    var selectedStop: Stop?
    let locationManager = CLLocationManager()
    var timer = NSTimer()
    var currentBusAnnotations = [MapAnnotation]()
    var mapItems = [String]()
    let manager = CloudKitManager.sharedInstance
    
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        locationManager.delegate = self
        
        // start location manager
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        addStopsToMap()
        
//        // get current bus locations in background
//        var currentBusLocations = Array<(route:Route, coordinate:CLLocationCoordinate2D)>()
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            if self.selectedRoutes.count == 0 {
//                currentBusLocations = Parser.getCurrentBusLocations(nil)
//            } else {
//                currentBusLocations = Parser.getCurrentBusLocations(self.selectedRoutes[0].shortName)
//            }
//            // add current bus location in background
//            dispatch_async(dispatch_get_main_queue(), {
//                for location in currentBusLocations {
//                    let annotation = MapAnnotation(coordinate: location.coordinate, title: location.route.name, subtitle: location.route.shortName, category: "current bus")
//                    self.currentBusAnnotations.append(annotation)
//                    self.mapView.addAnnotation(annotation)
//                }
//            })
//        })
//        
//        // set a nstimer
//        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("getCurrentBusLocation"), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.mapView.removeAnnotations(self.mapView.annotations)
//        timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // **************************
    // MARK: Current Bus Location
    // **************************
    
    func getCurrentBusLocation() {
        // remove all current bus annotations and empty the list
        self.mapView.removeAnnotations(currentBusAnnotations)
        currentBusAnnotations = [MapAnnotation]()
        
        // get current bus locations in background
        var currentBusLocations = Array<(route:Route, coordinate:CLLocationCoordinate2D)>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if self.selectedRoutes.count == 0 {
                currentBusLocations = Parser.getCurrentBusLocations(nil)
            } else {
                currentBusLocations = Parser.getCurrentBusLocations(self.selectedRoutes[0].shortName)
            }
            // add current bus location in background
            dispatch_async(dispatch_get_main_queue(), {
                for location in currentBusLocations {
                    let annotation = MapAnnotation(coordinate: location.coordinate, title: location.route.name, subtitle: location.route.shortName, category: "current bus")
                    self.currentBusAnnotations.append(annotation)
                    self.mapView.addAnnotation(annotation)
                }
            })
        })
    }
    
    // *******************************
    // MARK: Location Manager Delegate
    // *******************************
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get current distance from VT campus
        let burrussHall = CLLocationCoordinate2D(latitude: 37.228368, longitude: -80.422942)
        let distanceInMiles = manager.location!.distanceFromLocation(CLLocation(latitude: burrussHall.latitude, longitude: burrussHall.longitude)) / 1609.34
        
        // zoom to current location if < 20 away, else zoom to VT Campus
        if CLLocationManager.locationServicesEnabled() && distanceInMiles < 20 && selectedStop == nil {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        } else {
            // set the zoom to burruss hall
            let span = MKCoordinateSpanMake(0.015, 0.015)
            let region = MKCoordinateRegion(center: burrussHall, span: span)
            mapView.setRegion(region, animated: false)
        }
        manager.stopUpdatingLocation()
    }
    
    // ********************************
    // MARK: MKMapView Delegate Methods
    // ********************************
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        annotationView!.canShowCallout = true
        
        let category = (annotation as! MapAnnotation).category
        switch category {
        case "stop":
            annotationView!.pinColor = MKPinAnnotationColor.Red
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
        case "current bus":
            annotationView!.pinColor = MKPinAnnotationColor.Purple
            annotationView!.rightCalloutAccessoryView = nil
        case "search":
            annotationView!.pinColor = MKPinAnnotationColor.Green
            annotationView!.rightCalloutAccessoryView = nil
        default:
            annotationView!.pinColor = MKPinAnnotationColor.Red
            annotationView!.rightCalloutAccessoryView = nil
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.setCenterCoordinate(view.annotation!.coordinate, animated: true)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let stop = (view.annotation as! MapAnnotation).stop!
        selectedRoutes = Parser.routesForStop(stop.code)
        performSegueWithIdentifier("showArrivalTimesForAllRoutes", sender: view)
    }
    
    // ************************
    // MARK: Map Search Methods
    // ************************
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // get the MKLocalRequest from searchbar text
        let request : MKLocalSearchRequest = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region;
        let search : MKLocalSearch = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({ response, error in
            // remove search pins already in place
            self.mapItems.removeAll(keepCapacity: false)
            for ann in self.mapView.annotations {
                if ann is MKUserLocation {
                    continue
                }
                if (ann as! MapAnnotation).category == "search" {
                    self.mapView.removeAnnotation((ann as! MapAnnotation))
                }
            }
            // add response items
            if response != nil {
                for item in response!.mapItems {
                    let mapItem: MKMapItem = item
                    let point: MapAnnotation = MapAnnotation(coordinate: mapItem.placemark.coordinate, title: mapItem.placemark.name!, subtitle:  mapItem.placemark.title!, category: "search")
                    self.mapView.addAnnotation(point)
                    self.mapItems.append(item.description)
                    let searchResultName: String = ""
                    mapItem.name = searchResultName
                    self.mapView.showAnnotations([point], animated: true)
                }
            }
            
        })
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        dismissKeyboardButton.hidden = false
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        mapSearchBar.resignFirstResponder()
        dismissKeyboardButton.hidden = true
    }
    // *************************
    // MARK: Map Toolbar Methods
    // *************************
    
    @IBAction func showCurrentLocation(sender: AnyObject) {
        if locationManager.location == nil {
            let alertView = UIAlertView(title: "Location Service Not Working", message: "Please make sure location services are enabled.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        } else {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        }
    }
    
    @IBAction func mapType(sender: AnyObject) {
        if mapTypeSegmentControl.selectedSegmentIndex == 0 {
            mapView.mapType = MKMapType.Standard
        } else if mapTypeSegmentControl.selectedSegmentIndex == 1 {
            mapView.mapType = MKMapType.Hybrid
        } else if mapTypeSegmentControl.selectedSegmentIndex == 2 {
            mapView.mapType = MKMapType.Satellite
        }
    }
    
    
    // ********************
    // MARK: Helper Methods
    // ********************
    func addStopsToMap() {
        if stops.count == 0 {
            // if we are adding all stops to the map
            for stop in manager.allStops {
                let annotation = MapAnnotation(stop: stop)
                self.mapView.addAnnotation(annotation)
            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: false)
            self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        } else {
            // if pins are coming from specified route
            for stop in stops {
                let annotation = MapAnnotation(stop: stop)
                mapView.addAnnotation(annotation)
                if selectedStop != nil && selectedStop! == stop {
                    mapView.selectAnnotation(annotation, animated: false)
                    mapView.showAnnotations([annotation], animated: false)
                }
            }
            if selectedStop == nil {
                mapView.showAnnotations(mapView.annotations, animated: false)
            }
        }
    }
    
    
    // ***********************
    // MARK: Prepare For Segue
    // ***********************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showArrivalTimesForAllRoutes" {
            let arrivalTimesForRoute = segue.destinationViewController as! ArrivalTimesForRouteCollectionViewController
            arrivalTimesForRoute.selectedStop = ((sender as! MKAnnotationView).annotation as! MapAnnotation).stop!
            arrivalTimesForRoute.selectedRoutes = selectedRoutes
        }
    }
}