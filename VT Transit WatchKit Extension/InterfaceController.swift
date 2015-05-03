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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    func loadTableData() {
        let sharedDefault = NSUserDefaults(suiteName: "group.VTTransit")
        let data = sharedDefault?.objectForKey("favoriteStops") as! NSData
        let favoriteStops = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Stop]
        println(favoriteStops)
//        table.setNumberOfRows(manager.favoriteStops.count, withRowType: "tableRow")
//        
//        for (index, content) in enumerate(manager.favoriteStops) {
//            let row = table.rowControllerAtIndex(index) as! WatchTableRowController
//            row.favoriteStopName.setText(content.name)
//        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        loadTableData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
