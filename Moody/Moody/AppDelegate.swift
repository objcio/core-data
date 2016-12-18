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

    var persistentContainer: NSPersistentContainer!
    var syncCoordinator: SyncCoordinator!
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications()
        createMoodyContainer { container in
            self.persistentContainer = container
            self.syncCoordinator = SyncCoordinator(container: container)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "RootViewController") as? RootViewController
                else { fatalError("Wrong view controller type") }
            vc.managedObjectContext = container.viewContext
            self.window?.rootViewController = vc
        }
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        guard let info = userInfo as? [String: NSObject] else { return }
        syncCoordinator.application(application, didReceiveRemoteNotification: info)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        persistentContainer.viewContext.batchDeleteObjectsMarkedForLocalDeletion()
        persistentContainer.viewContext.refreshAllObjects()
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        persistentContainer.viewContext.refreshAllObjects()
    }

}


