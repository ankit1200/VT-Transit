//
//  SegmentMapViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/24/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import MapKit

class SegmentMapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    var selectedRoute = Route(name:"", shortName:"")
    var stops = Array<Stop>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}