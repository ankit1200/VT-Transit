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
    init(name: String?, shortName: String) {
        self.shortName = shortName
        // initialize name and then set the correct value
        self.name = String()
        self.name = (name == nil) ? routeNameFromShortName(shortName) : name!
    }
    
    
    func routeNameFromShortName(shortName:String) -> String {
        
        switch shortName {

            case "CRCH":
                return "CRC Hospital"
            case "CRC":
                return "CRC Shuttle"
            case "HDG":
                return "Harding Avenue"
            case "HWD":
                return "Hethwood"
            case "HXP":
                return "Hokie Express"
            case "MSN":
                return "Main Street North"
            case "MSS":
                return "Main Street South"
            case "PH":
                return "Patrick Henry"
            case "PRG":
                return "Progress Street"
            case "TC":
                return "Toms Creek"
            case "TTT":
                return "Two Town Trolley"
            case "UCB":
                return "University City Boulevard"
            case "UMS":
                return "University Mall"
            default:
                return "Not a Valid Route"
        }
    }
}