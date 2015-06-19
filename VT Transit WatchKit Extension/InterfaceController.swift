//
//  InterfaceController.swift
//  VT Transit WatchKit Extension
//
//  Created by Ankit Agarwal on 4/25/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import WatchKit
import Foundation
import CloudKitManager

class InterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    var favoriteStops: [Stop] = []
    var filteredStops = [Stop]()
    
    // MARK: WatchKit Delegate Methods
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        println(2)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        println(1)
        favoriteStops = loadFavoriteStops()
        loadTableData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    // MARK: Table Data Method
    func loadTableData() {
        filteredStops = filterFavoriteStops(favoriteStops)
        table.setNumberOfRows(filteredStops.count, withRowType: "tableRow")
        for (index, content) in enumerate(filteredStops) {
            let row = table.rowControllerAtIndex(index) as! FavoriteStopsTableRowController
            row.favoriteStopName.setText(content.name)
        }
    }
    
    
    // MARK: Helper Methods
    func filterFavoriteStops(stops:[Stop]) -> [Stop] {
        var filteredStops = [Stop]()
        for stop in stops {
            let routes = Parser.routesForStop(stop.code)
            if routes.count > 0 {
                filteredStops.append(stop)
            }
        }
        return filteredStops
    }
    
    func loadFavoriteStops() -> [Stop] {
        let sharedDefault = NSUserDefaults(suiteName: "group.VTTransit")
        let data = sharedDefault?.objectForKey("favoriteStops") as! NSData
        let unarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Stop]
        return unarchivedData
    }
    
    // MARK: Segue
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return filteredStops[rowIndex]
    }
}