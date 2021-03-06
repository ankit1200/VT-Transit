//
//  StopsHeaderCollectionReusableView.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/18/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import CloudKitManager

class StopsHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var routeTitle: UILabel!
    var route: Route?
}
