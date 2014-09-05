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
    let latitude, longitude: NSNumber
    
    // init new Stop object
    init(name: String, code: String, latitude:NSNumber, longitude:NSNumber) {
        self.name = name
        self.code = code
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getAllStops -> Array<Stop> {
        
    }
    
    func stopForCode(code:String) -> Stop {
        
        
    }
    
    
}