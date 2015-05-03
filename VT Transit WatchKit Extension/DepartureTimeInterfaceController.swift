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

class DepartureTimeInterfaceController: WKInterfaceController {
    
    //Outlets
    @IBOutlet var table: WKInterfaceTable!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let stopSelected = context as! Stop
        
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
    
    // MARK: Table Data Method
    
    func loadTableData() {
        table.setNumberOfRows(3, withRowType: "tableRow")
//        for (index, content) in enumerate(favoriteStops) {
//            let row = table.rowControllerAtIndex(index) as! DepartureTimesTableRowController
//            row.favoriteStopName.setText(content.name)
//        }
    }
}
