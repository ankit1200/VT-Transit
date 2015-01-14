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

class SegmentMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    var selectedRoutes = [Route]()
    var stops = Array<Stop>()
    @IBOutlet var mapTypeSegmentControl: UISegmentedControl!
    let locationManager = CLLocationManager()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        locationManager.delegate = self
        // start location manager
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
//        if locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization:")) {
            locationManager.requestWhenInUseAuthorization()
//        }
        
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // add the pins to the mapview
        for stop in stops {
            let annotation = MapAnnotation(stop: stop)
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // get current distance from VT campus
        let burrussHall = CLLocationCoordinate2D(latitude: 37.228368, longitude: -80.422942)
        let distanceInMiles = manager.location.distanceFromLocation(CLLocation(latitude: burrussHall.latitude, longitude: burrussHall.longitude)) / 1609.34
        
        // zoom to current location if < 20 away, else zoom to VT Campus
        if CLLocationManager.locationServicesEnabled() && distanceInMiles < 20 {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        } else {
            // set the zoom to burruss hall
            let span = MKCoordinateSpanMake(0.015, 0.015)
            let region = MKCoordinateRegion(center: burrussHall, span: span)
            mapView.setRegion(region, animated: true)
        }
        manager.stopUpdatingLocation()
    }
    
    // **************************************
    // MARK: MKMapView Delegate Methods
    // **************************************
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        annotationView!.canShowCallout = true
        annotationView!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIView
        
        let category = (annotation as MapAnnotation).category
        switch category {
        case "stop":
            annotationView!.pinColor = MKPinAnnotationColor.Red
        case "current bus":
            annotationView!.pinColor = MKPinAnnotationColor.Purple
        case "search":
            annotationView!.pinColor = MKPinAnnotationColor.Green
        default:
            annotationView!.pinColor = MKPinAnnotationColor.Red
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let stop = (view.annotation as MapAnnotation).stop!
        selectedRoutes = Parser.routesForStop(stop.code)
        performSegueWithIdentifier("showArrivalTimesForAllRoutes", sender: view)
    }
    
    // *************************
    // MARK: Map Toolbar Methods
    // *************************
    
    @IBAction func showCurrentLocation(sender: AnyObject) {
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
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
    
    // ***********************
    // MARK: Prepare For Segue
    // ***********************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showArrivalTimesForAllRoutes" {
            let arrivalTimesForRoute = segue.destinationViewController as ArrivalTimesForRouteCollectionViewController
            arrivalTimesForRoute.selectedStop = ((sender as MKAnnotationView).annotation as MapAnnotation).stop!
            arrivalTimesForRoute.selectedRoutes = selectedRoutes
        }
    }
}