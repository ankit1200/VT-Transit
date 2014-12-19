//
//  Parser.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 11/29/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class Parser: NSObject {
   
    var tbxmlParser = TBXML()
    
    
    
    // This method gets the stops that are assoicated with the route shortName
    func stopsForRoute(shortName: String) -> Array<Stop> {
        
        var stops = Array<Stop>()
        
        let url = NSURL(string: "http://www.bt4u.org/webservices/BT4U_WebService.asmx/GetScheduledStopCodes?routeShortName=\(shortName)")
        let data = NSData(contentsOfURL: url!)
        tbxmlParser = TBXML.newTBXMLWithXMLData(data, error: nil)
        
        var root = tbxmlParser.rootXMLElement
        
        if root != nil {
            var scheduledStops = TBXML.childElementNamed("ScheduledStops", parentElement: root)
            
            while scheduledStops != nil {
                let stopCodeElement = TBXML.childElementNamed("StopCode", parentElement: scheduledStops)
                let stopNameElement = TBXML.childElementNamed("StopName", parentElement: scheduledStops)
                let stopCodeText = TBXML.textForElement(stopCodeElement)
                let stopNameText = TBXML.textForElement(stopNameElement)
                stops.append(Stop(name: stopNameText, code: stopCodeText, latitude: "", longitude: ""))
                scheduledStops = TBXML.nextSiblingNamed("ScheduledStops", searchFromElement: scheduledStops)
            }
        }
        
        return stops
    }
    
    
    // This method gets the stops that are assoicated with the route shortName
    func arrivalTimesForRoute(shortName: String, stopCode: String) -> Array<String> {
        
        var arrivalTimes = Array<String>()
        
        let url = NSURL(string: "http://www.bt4u.org/webservices/BT4U_WebService.asmx/GetNextDepartures?routeShortName=\(shortName)&stopCode=\(stopCode)")
        let data = NSData(contentsOfURL: url!)
        tbxmlParser = TBXML.newTBXMLWithXMLData(data, error: nil)
        var root = tbxmlParser.rootXMLElement
        
        if root != nil {
            var nextDepartures = TBXML.childElementNamed("NextDepartures", parentElement: root)
            
            while nextDepartures != nil {
                let arrivalTimeElement = TBXML.childElementNamed("AdjustedDepartureTime", parentElement: nextDepartures)
                let arrivalTimeText = TBXML.textForElement(arrivalTimeElement)
                arrivalTimes.append(arrivalTimeText)
                nextDepartures = TBXML.nextSiblingNamed("NextDepartures", searchFromElement: nextDepartures)
            }
        }
        
        return arrivalTimes
    }
}
