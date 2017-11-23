//
//  CoreDataErrors.swift
//  Saving
//
//  Created by Florian on 24/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


struct ManagedObjectValidationError {
    fileprivate let error: NSError
    fileprivate var userInfo: [AnyHashable:Any] { return error.userInfo }

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
    func propertyValidationError(forKey key: String, localizedDescription: String) -> NSError {
        let userInfo: [String:Any] = [
            NSValidationObjectErrorKey: self,
            NSValidationKeyErrorKey: key as AnyObject,
            NSLocalizedDescriptionKey: localizedDescription as AnyObject
        ]
        let domain = Bundle(for: type(of: self)).bundleIdentifier ?? "undefined"
        return NSError(domain: domain, code: NSManagedObjectValidationError, userInfo: userInfo)
    }

    func validationError(withLocalizedDescription description: String) -> NSError {
        let userInfo: [String:Any] = [
            NSValidationObjectErrorKey: self,
            NSLocalizedDescriptionKey: description as AnyObject
        ]
        let domain = Bundle(for: type(of: self)).bundleIdentifier ?? "undefined"
        return NSError(domain: domain, code: NSManagedObjectValidationError, userInfo: userInfo)
    }

    func multipleValidationError(withLocalizedDescriptions descriptions: [String]) -> NSError {
        let userInfo: [String:Any] = [
            NSDetailedErrorsKey: descriptions.map(validationError)
        ]
        let domain = Bundle(for: type(of: self)).bundleIdentifier ?? "undefined"
        return NSError(domain: domain, code: NSValidationMultipleErrorsError, userInfo: userInfo)
    }
}

