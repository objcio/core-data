//
//  AppDelegate.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import MoodySync
import MoodyModel
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var syncCoordinator: SyncCoordinator!
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.registerForRemoteNotifications()
        guard let context = createMoodyMainContext() else { fatalError() }
        managedObjectContext = context
        syncCoordinator = SyncCoordinator(mainManagedObjectContext: context)
        guard let vc = window?.rootViewController as? ManagedObjectContextSettable else { fatalError("Wrong view controller type") }
        vc.managedObjectContext = managedObjectContext
        return true
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
        guard let info = userInfo as? [String: NSObject] else { return }
        syncCoordinator.application(application, didReceiveRemoteNotification: info)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        managedObjectContext.batchDeleteObjectsMarkedForLocalDeletion()
        managedObjectContext.refreshAllObjects()
    }

    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        managedObjectContext.refreshAllObjects()
    }

}

