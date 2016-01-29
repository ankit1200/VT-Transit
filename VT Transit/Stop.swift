//
//  Stop.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 9/4/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import Foundation
import CoreLocation

public class Stop : NSObject, NSCoding {
    
    public let name, code: String
    public var location: CLLocation
    
    // init new Stop object
    public init(name: String, code: String, location:CLLocation) {
        self.name = name
        self.code = code
        self.location = location
    }
    
    required public init?(coder decoder:NSCoder) {
        self.name = decoder.decodeObjectForKey("name") as! String
        self.code = decoder.decodeObjectForKey("code") as! String
        self.location = decoder.decodeObjectForKey("location") as! CLLocation
    }
    
    public func encodeWithCoder(encoder:NSCoder) {
        encoder.encodeObject(self.name, forKey: "name")
        encoder.encodeObject(self.code, forKey: "code")
        encoder.encodeObject(self.location, forKey: "location")
    }
}

func == (lhs: Stop, rhs: Stop) -> Bool {
    return (lhs.name == rhs.name) && (lhs.code == rhs.code)
}