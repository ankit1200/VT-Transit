//
//  DepartureTimeInterfaceController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 5/3/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import WatchKit
import Foundation
import CloudKitManager

class DepartureTimeInterfaceController: WKInterfaceController, IGInterfaceTableDataSource {
    
    //Outlets
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var stopName: WKInterfaceLabel!
    
    // Properties
    var arrivalTimes:[(time: [String], route: Route)] = []
    var routesForSelectedStop = [Route]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let selectedStop = context as! Stop
        stopName.setText(selectedStop.name)
        
        // get routes for the stop code
        routesForSelectedStop = Parser.routesForStop(selectedStop.code)

        // get arrivalTimes for routes
        for route in routesForSelectedStop {
            let time = Parser.arrivalTimesForRoute(route.shortName, stopCode: selectedStop.code)
            arrivalTimes.append(time: time, route: route)
        }
        
        // configure table to to IGInterfaceDataTable
        self.table.ig_dataSource = self
        self.table.reloadData()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: Table Data Source
    
    func numberOfSectionsInTable(table: WKInterfaceTable!) -> Int {
        return routesForSelectedStop.count
    }
    
    func numberOfRowsInTable(table: WKInterfaceTable!, section: Int) -> Int {
        // if no arrival times remain then return 1, for the noArrivalTimesCell else return the count
        // if there are multiple routes, then only return the first 6 arrivalTimes
        let arrivalTimesCount = arrivalTimes[section].time.count
        return (arrivalTimesCount == 0) ?  1 : ((routesForSelectedStop.count > 1 && arrivalTimesCount > 6) ? 6 : arrivalTimesCount)
    }
    
    func table(table: WKInterfaceTable!, configureSectionController sectionRowController: NSObject!, forSection section: Int) {
        let sectionRow = sectionRowController as! SectionTableRowController
        sectionRow.sectionTitle.setText(arrivalTimes[section].route.name)
    }
    
    func table(table: WKInterfaceTable!, configureRowController rowController: NSObject!, forIndexPath indexPath: NSIndexPath!) {
        let row = rowController as! DepartureTimesTableRowController
        
        if arrivalTimes[indexPath.section].time.count == 0 {
            
            row.timeRemainingLabel.setText("No Bus Times")
            row.departureTimeLabel.setText("Remaining")
        } else {
            
            let dateFormatter = NSDateFormatter() // date format
            dateFormatter.dateFormat = "M/dd/yyyy h:mm:ss a" // set date format
            
            // indexPath.section gets the route, then time[indexPath.row] gets arrivalTime
            let arrivalTimeDate = dateFormatter.dateFromString(arrivalTimes[indexPath.section].time[indexPath.row]) // get date from arrival time
            
            var timeDifferenceMinutes = Int((arrivalTimeDate?.timeIntervalSinceNow)! / 60) - 1 // get time difference in (MINUTES) add 1 minute buffer
            var timeDifferenceHours = 0
            var timeRemainingText = String()
            
            // check to see if more than one hour remaining
            if timeDifferenceMinutes > 60 {
                timeDifferenceHours = timeDifferenceMinutes / 60
                timeDifferenceMinutes = timeDifferenceMinutes % 60
                timeRemainingText = "\(timeDifferenceHours) hrs\n\(timeDifferenceMinutes) min"
                
            } else if timeDifferenceMinutes < 0 {
                timeRemainingText = "BUS HAS PASSED"
                
            } else {
                timeRemainingText = "\(timeDifferenceMinutes) min"
            }
            
            row.timeRemainingLabel.setText(timeRemainingText)
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle // short style is just h:mm a
            let arrivalTime = dateFormatter.stringFromDate(arrivalTimeDate!) // get arrival time string from date
            row.departureTimeLabel.setText(arrivalTime)
        }
    }
    
    // MARK: Table Row Identifiers
    
    func table(table: WKInterfaceTable!, rowIdentifierAtIndexPath indexPath: NSIndexPath!) -> String! {
        return "tableRow"
    }
    
    func table(table: WKInterfaceTable!, identifierForSection section: Int) -> String! {
        return "sectionRow"
    }
}
