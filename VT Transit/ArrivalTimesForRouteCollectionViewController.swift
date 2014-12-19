//
//  ArrivalTimesForRouteCollectionViewController.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 12/18/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class ArrivalTimesForRouteCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var selectedRoute = Route(name:"", shortName:"")
    var selectedStop = Stop(name: "", code: "", latitude: "", longitude: "")
    var arrivalTimes = [String]()
    let parser = Parser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrivalTimes = parser.arrivalTimesForRoute(selectedRoute.shortName, stopCode: selectedStop.code)
    }

    // ********************************
    // MARK: UICollectionViewDataSource
    // ********************************

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return (arrivalTimes.count == 0) ?  1 : arrivalTimes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if arrivalTimes.count == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("noArrivalTimesCell", forIndexPath: indexPath) as UICollectionViewCell
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("arrivalTimeCell", forIndexPath: indexPath) as ArrivalTimesCollectionViewCell
            cell.arrivalTimeLabel.text = arrivalTimes[indexPath.row]
            return cell
        }
    }
    
    // function to set up Header
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var reusableview = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as StopsHeaderCollectionReusableView
            
            headerView.title.text = selectedStop.name
            headerView.subtitle.text = "Stop #: \(selectedStop.code)    Route Code: \(selectedRoute.shortName)"
            
            reusableview = headerView;
        }
        
        return reusableview
    }
    
    // function to set the size of the cell appropriately
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return (arrivalTimes.count == 0) ? CGSize(width: 290.0, height: 60.0) : CGSize(width: 90.0, height: 90.0)
    }
}
