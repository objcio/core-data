//
//  KeyCodable.swift
//  Moody
//
//  Created by Florian on 17/11/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


public protocol KeyCodable {
    typealias Keys: RawRepresentable
}

extension KeyCodable where Self: ManagedObject, Keys.RawValue == String {
    public func willAccessValueForKey(key: Keys) {
        willAccessValueForKey(key.rawValue)
    }

    public func didAccessValueForKey(key: Keys) {
        didAccessValueForKey(key.rawValue)
    }

    public func accessingValueForKey(key: Keys, @noescape block: () -> ()) {
        willAccessValueForKey(key)
        block()
        didAccessValueForKey(key)
    }

    public func willChangeValueForKey(key: Keys) {
        (self as ManagedObject).willChangeValueForKey(key.rawValue)
    }

    public func didChangeValueForKey(key: Keys) {
        (self as ManagedObject).didChangeValueForKey(key.rawValue)
    }

    public func valueForKey(key: Keys) -> AnyObject? {
        return (self as ManagedObject).valueForKey(key.rawValue)
    }

    public func mutableSetValueForKey(key: Keys) -> NSMutableSet {
        return mutableSetValueForKey(key.rawValue)
    }

    public func changedValueForKey(key: Keys) -> AnyObject? {
        return changedValues()[key.rawValue]
    }

    public func changingValueForKey(key: Keys, @noescape block: () -> ()) {
        willChangeValueForKey(key)
        block()
        didChangeValueForKey(key)
    }

    public func committedValueForKey(key: Keys) -> AnyObject? {
        return committedValuesForKeys([key.rawValue])[key.rawValue]
    }
}

