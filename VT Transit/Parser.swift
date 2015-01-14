//
//  Parser.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 11/29/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class Parser: NSObject {
    
    // This method gets the stops that are assoicated with the route shortName
    class func stopsForRoute(shortName: String) -> Array<Stop> {
        
        var tbxmlParser = TBXML()
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
    
    // This method gets the arrival time for specified route at given stop
    class func arrivalTimesForRoute(shortName: String, stopCode: String) -> Array<String> {
        
        var tbxmlParser = TBXML()
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
    
    // This method gets the routes that go to the given stop
    class func routesForStop(stopCode: String) -> Array<Route> {
        
        var tbxmlParser = TBXML()
        var routes = Array<Route>()
        
        let url = NSURL(string: "http://www.bt4u.org/webservices/BT4U_WebService.asmx/GetScheduledRoutes?stopCode=\(stopCode)")
        let data = NSData(contentsOfURL: url!)
        tbxmlParser = TBXML.newTBXMLWithXMLData(data, error: nil)
        var root = tbxmlParser.rootXMLElement
        
        if root != nil {
            var scheduledRoutes = TBXML.childElementNamed("ScheduledRoutes", parentElement: root)
            
            while scheduledRoutes != nil {
                let routeNameElement = TBXML.childElementNamed("RouteName", parentElement: scheduledRoutes)
                let routeShortNameElement = TBXML.childElementNamed("RouteShortName", parentElement: scheduledRoutes)
                let routeNameText = TBXML.textForElement(routeNameElement)
                let routeShortNameText = TBXML.textForElement(routeShortNameElement)
                routes.append(Route(name: routeNameText, shortName: routeShortNameText))
                scheduledRoutes = TBXML.nextSiblingNamed("ScheduledRoutes", searchFromElement: scheduledRoutes)
            }
        }
        return routes
    }
}
