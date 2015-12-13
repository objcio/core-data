//
//  CoreDataErrors.swift
//  Saving
//
//  Created by Florian on 24/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


struct ManagedObjectValidationError {
    private let error: NSError
    private var userInfo: [String:AnyObject] { return (error.userInfo as? [String:AnyObject]) ?? [:] }

    init(error: NSError) {
        self.error = error
    }

    var key: String? { return userInfo[NSValidationKeyErrorKey] as? String }
    var predicate: NSPredicate? { return userInfo[NSValidationPredicateErrorKey] as? NSPredicate }
    var localizedDescription: String? { return userInfo[NSLocalizedDescriptionKey] as? String }
    var object: NSManagedObject? { return userInfo[NSValidationObjectErrorKey] as? NSManagedObject }
    var code: Int { return error.code }
    var domain: String { return error.domain }

    var errors: [ManagedObjectValidationError]? {
        guard let details = userInfo[NSDetailedErrorsKey] as? [NSError] else { return nil }
        return details.map { ManagedObjectValidationError(error: $0) }
    }
}

extension ManagedObjectValidationError: CustomDebugStringConvertible {
    var debugDescription: String {
        var result = "\n(code: \(code), domain: \(domain)"
        if let e = errors {
            return "Multiple validation errors: \(e)"
        } else {
            if let o = object { result += ", object: \(o)" }
            if let k = key { result += ", key: \(k)" }
            if let p = predicate { result += ", predicate: \(p)" }
            if let d = localizedDescription { result += ", description: \(d)" }
            return "Validation Error: \(result)"
        }
    }
}


extension NSManagedObject {
    func propertyValidationErrorForKey(key: String, localizedDescription: String) -> NSError {
        let userInfo: [NSObject:AnyObject] = [
            NSValidationObjectErrorKey: self,
            NSValidationKeyErrorKey: key,
            NSLocalizedDescriptionKey: localizedDescription
        ]
        let domain = NSBundle(forClass: self.dynamicType).bundleIdentifier ?? "undefined"
        return NSError(domain: domain, code: NSManagedObjectValidationError, userInfo: userInfo)
    }

    func validationErrorWithDescription(localizedDescription: String) -> NSError {
        let userInfo: [NSObject:AnyObject] = [
            NSValidationObjectErrorKey: self,
            NSLocalizedDescriptionKey: localizedDescription
        ]
        let domain = NSBundle(forClass: self.dynamicType).bundleIdentifier ?? "undefined"
        return NSError(domain: domain, code: NSManagedObjectValidationError, userInfo: userInfo)
    }

    func multipleValidationErrorWithDescriptions(localizedDescriptions: [String]) -> NSError {
        let userInfo: [NSObject:AnyObject] = [
            NSDetailedErrorsKey: localizedDescriptions.map(validationErrorWithDescription)
        ]
        let domain = NSBundle(forClass: self.dynamicType).bundleIdentifier ?? "undefined"
        return NSError(domain: domain, code: NSValidationMultipleErrorsError, userInfo: userInfo)
    }
}