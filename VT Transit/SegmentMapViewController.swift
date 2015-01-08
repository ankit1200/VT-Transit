//
//  SegmentMapViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/24/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import MapKit

class SegmentMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    @IBOutlet var mapTypeSegmentControl: UISegmentedControl!
    let locationManager = CLLocationManager()
    
    // **************************************
    // MARK: View Controller Delegate Methods
    // **************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start location manager
        locationManager.requestWhenInUseAuthorization()
        
        // set the zoom to burruss hall
        let drillfield = CLLocationCoordinate2D(latitude: 37.228368, longitude: -80.422942)
        let span = MKCoordinateSpanMake(0.015, 0.015)
        let region = MKCoordinateRegion(center: drillfield, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // add the pins to the mapview
        for stop in stops {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: (stop.latitude as NSString).doubleValue, longitude: (stop.longitude as NSString).doubleValue)
            annotation.setCoordinate(coordinate)
            annotation.title = stop.name
            annotation.subtitle = "Bus Stop #\(stop.code)"
            mapView.addAnnotation(annotation)
        }
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
}