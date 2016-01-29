
//  AppDelegate.swift
//  VT Transit
//
//  Created by Ankit Agarwal on 8/28/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import CloudKitManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Parse keys
        Parse.setApplicationId("Cn8XelDtAQiaT3K899qx1YZj5lvuTJ2yQxxyrgSq", clientKey: "Fi7NygQMW6m11emvGSmfITaMnyZeuQMbNT4byV6J")
        
        // populate all stops list
        CloudKitManager.sharedInstance.queryAllStops({})
        // populate favorite stops list
        if CloudKitManager.sharedInstance.favoriteStops.count == 0 {
            CloudKitManager.sharedInstance.queryFavoriteStops({
                let sharedDefault = NSUserDefaults(suiteName: "group.VTTransit")
                let data = NSKeyedArchiver.archivedDataWithRootObject(CloudKitManager.sharedInstance.favoriteStops)
                sharedDefault?.setObject(data, forKey: "favoriteStops")
                sharedDefault?.synchronize()
            })
        }
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 1, green: 0.4, blue: 0, alpha: 1)]
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.4, green: 0, blue: 0, alpha: 1)
        UITabBar.appearance().tintColor = UIColor(red: 1, green: 0.4, blue: 0, alpha: 1)
        UITabBar.appearance().barTintColor = UIColor(red: 0.4, green: 0, blue: 0, alpha: 1)
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // Notifications

        // Specify the notification types.
        var notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Sound]
        
        // Specify the category related to the above actions.
        var busTimeReminderCategory = UIMutableUserNotificationCategory()
        busTimeReminderCategory.identifier = "busTimeReminderCategory"
        let categoriesForSettings = Set(arrayLiteral: busTimeReminderCategory)
        
        // Register the notification settings.
        let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings)
        UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

