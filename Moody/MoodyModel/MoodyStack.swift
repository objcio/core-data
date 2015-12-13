//
//  MoodyStack.swift
//  Moody
//
//  Created by Florian on 18/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreDataHelpers

private let ubiquityToken: String = {
    guard let token = NSFileManager.defaultManager().ubiquityIdentityToken else { return "unknown" }
    return NSKeyedArchiver.archivedDataWithRootObject(token).base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
}()
private let StoreURL = NSURL.documentsURL.URLByAppendingPathComponent("\(ubiquityToken).moody")


public func createMoodyMainContext(progress: NSProgress? = nil, migrationCompletion: NSManagedObjectContext -> () = { _ in }) -> NSManagedObjectContext? {
    Mood.registerValueTransformers()
    let version = MoodyModelVersion(storeURL: StoreURL)
    guard version == nil || version == MoodyModelVersion.CurrentVersion else {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, modelVersion: MoodyModelVersion.CurrentVersion, storeURL: StoreURL, progress: progress)
            dispatch_async(dispatch_get_main_queue()) {
                migrationCompletion(context)
            }
        }
        return nil
    }
    let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, modelVersion: MoodyModelVersion.CurrentVersion, storeURL: StoreURL)
    context.mergePolicy = MoodyMergePolicy(mode: .Local)
    return context
}

