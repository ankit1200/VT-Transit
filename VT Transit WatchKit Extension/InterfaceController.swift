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
    
    let favoriteStops: [Stop] = {
        let sharedDefault = NSUserDefaults(suiteName: "group.VTTransit")
        let data = sharedDefault?.objectForKey("favoriteStops") as! NSData
        let unarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Stop]
        return unarchivedData
    }()
    
    // MARK: WatchKit Delegate Methods
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
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
        table.setNumberOfRows(favoriteStops.count, withRowType: "tableRow")
        for (index, content) in enumerate(favoriteStops) {
            let row = table.rowControllerAtIndex(index) as! FavoriteStopsTableRowController
            row.favoriteStopName.setText(content.name)
        }
    }
    
    // MARK: Segue
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return favoriteStops[rowIndex]
    }
}
