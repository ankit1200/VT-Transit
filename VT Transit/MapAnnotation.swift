//
//  MapAnnotation.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 1/12/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    var category: String
    var stop: Stop?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, category:String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.category = category
    }
    
    init(stop: Stop) {
        
        self.coordinate = CLLocationCoordinate2D(latitude: (stop.latitude as NSString).doubleValue, longitude: (stop.longitude as NSString).doubleValue)
        self.title = stop.name
        self.subtitle = "Bus Stop #\(stop.code)"
        self.stop = stop
        self.category = "stop"
    }
}