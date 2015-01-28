//
//  Stop.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 9/4/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import Foundation

class Stop {
    
    let name, code: String
    var latitude, longitude: String
    
    // init new Stop object
    init(name: String, code: String, latitude:String, longitude:String) {
        self.name = name
        self.code = code
        self.latitude = latitude
        self.longitude = longitude
    }
}