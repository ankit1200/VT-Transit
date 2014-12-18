//
//  Route.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 9/4/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import Foundation

class Route {
    
    var name, shortName: String
    var sortedStops: Array<Stop> = []
    
    // init new Route object
    init(name: String, shortName: String) {
        self.name = name
        self.shortName = shortName
    }
    
    
//    func allRoutes() -> Array<Route> {
//        
//        
//    }
    
    func routeNameFromShortName() {
        
        switch shortName {

            case "CRCH":
                name = "CRC Hospital"
            case "CRC":
                name = "CRC Shuttle"
            case "HDG":
                name = "Harding Avenue"
            case "HWD":
                name = "Hethwood"
            case "HXP":
                name = "Hokie Express"
            case "MSN":
                name = "Main Street North"
            case "MSS":
                name = "Main Street South"
            case "PH":
                name = "Patrick Henry"
            case "PRG":
                name = "Progress Street"
            case "TC":
                name = "Toms Creek"
            case "TTT":
                name = "Two Town Trolley"
            case "UCB":
                name = "University City Boulevard"
            case "UMS":
                name = "University Mall"
            default:
                name = "Not a Valid Route"
        }
    }
}