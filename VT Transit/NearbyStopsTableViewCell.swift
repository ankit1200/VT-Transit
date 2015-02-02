//
//  NearbyStopsTableViewCell.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 1/27/15.
//  Copyright (c) 2015 Appify. All rights reserved.
//

import UIKit

class NearbyStopsTableViewCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
