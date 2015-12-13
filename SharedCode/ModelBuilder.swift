import CoreData


extension NSManagedObjectModel {

    public convenience init(builder: () -> [NSEntityDescription]) {
        self.init()
        entities = builder()
    }

}


extension NSManagedObjectContext {

    public convenience init(model: NSManagedObjectModel, databaseName: String = "myStore.db", deleteExistingStore: Bool = true) {
        self.init(concurrencyType: .MainQueueConcurrencyType)
        let storeURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).URLByAppendingPathComponent(databaseName)
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        if deleteExistingStore {
            psc.destroySQLiteStoreAtURL(storeURL)
        }
        try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: [:])
        persistentStoreCoordinator = psc
    }

}


extension NSPersistentStoreCoordinator {

    func destroySQLiteStoreAtURL(storeURL: NSURL) {
        if #available(OSX 10.11, iOS 9.0, *) {
            try! destroyPersistentStoreAtURL(storeURL, withType: NSSQLiteStoreType, options: [:])
        } else {
            // Fallback on earlier versions
            fatalError()
        }
    }

}


extension NSEntityDescription {

    public convenience init<A: NSManagedObject>(cls: A.Type, name: String) {
        self.init()
        let a = NSStringFromClass(cls) as String
        self.managedObjectClassName = a
        self.name = name
    }

    public func addProperty(property: NSPropertyDescription) {
        var p = properties
        p.append(property)
        properties = p
    }

    public func createOneToOneRelationTo(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toOne(toName, destinationEntity: to, deleteRule: .NullifyDeleteRule)
        let inverse = NSRelationshipDescription.toOne(fromName, destinationEntity: self, deleteRule: .NullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }

    public func createOneToManyRelationTo(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toMany(toName, minCount: 0, maxCount: Int.max, destinationEntity: to, deleteRule: .NullifyDeleteRule)
        let inverse = NSRelationshipDescription.toOne(fromName, destinationEntity: self, deleteRule: .NullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }

    public func createOneToOrderedManyRelationTo(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toMany(toName, minCount: 0, maxCount: Int.max, destinationEntity: to, deleteRule: .NullifyDeleteRule, ordered: true)
        let inverse = NSRelationshipDescription.toOne(fromName, destinationEntity: self, deleteRule: .NullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }

    public func createManyToManyRelationTo(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toMany(toName, minCount: 0, maxCount: Int.max, destinationEntity: to, deleteRule: .NullifyDeleteRule)
        let inverse = NSRelationshipDescription.toMany(fromName, minCount: 0, maxCount: Int.max, destinationEntity: self, deleteRule: .NullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }

    public func createManyToOrderedManyRelationTo(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toMany(toName, minCount: 0, maxCount: Int.max, destinationEntity: to, deleteRule: .NullifyDeleteRule, ordered: true)
        let inverse = NSRelationshipDescription.toMany(fromName, minCount: 0, maxCount: Int.max, destinationEntity: self, deleteRule: .NullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }

}


public struct DataTransform<A> {
    public let name: String
    public let forward: A -> NSData?
    public let reverse: NSData? -> A
    public init(name: String, forward: A -> NSData?, reverse: NSData? -> A) {
        self.name = name
        self.forward = forward
        self.reverse = reverse
    }
}

extension NSRelationshipDescription {

    public static func toOne(name: String, destinationEntity: NSEntityDescription?, deleteRule: NSDeleteRule?, indexed: Bool? = nil, optional: Bool? = nil) -> NSRelationshipDescription {
        let relation = NSRelationshipDescription()
        relation.name = name
        relation.setIndexed(indexed, optional: optional, deleteRule: deleteRule)
        relation.destinationEntity = destinationEntity
        relation.minCount = 1
        relation.maxCount = 1
        return relation
    }

    public static func toMany(name: String, minCount: Int, maxCount: Int, destinationEntity: NSEntityDescription?, deleteRule: NSDeleteRule?, indexed: Bool? = nil, optional: Bool? = nil, ordered: Bool = false) -> NSRelationshipDescription {
        let relation = NSRelationshipDescription()
        relation.name = name
        relation.setIndexed(indexed, optional: optional, deleteRule: deleteRule)
        relation.destinationEntity = destinationEntity
        relation.minCount = minCount
        relation.maxCount = maxCount
        relation.ordered = ordered
        return relation
    }

    public static func orderedToMany(name: String, minCount: Int, maxCount: Int, destinationEntity: NSEntityDescription?, deleteRule: NSDeleteRule?, indexed: Bool? = nil, optional: Bool? = nil) -> NSRelationshipDescription {
        let relation = toMany(name, minCount: minCount, maxCount: maxCount, destinationEntity: destinationEntity, deleteRule: deleteRule, indexed: indexed, optional: optional)
        relation.ordered = true
        return relation
    }

    private func setIndexed(indexed: Bool?, optional: Bool?, deleteRule: NSDeleteRule?) {
        if let dr = deleteRule {
            self.deleteRule = dr
        }
        setIndexed(indexed, optional: optional)
    }

}


extension NSAttributeDescription {
    public static func int16Type(name: String, defaultValue: Int16? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .Integer16AttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(integer: Int($0))})
        return attr
    }

    public static func int32Type(name: String, defaultValue: Int32? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .Integer32AttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(integer: Int($0))})
        return attr
    }

    public static func int64Type(name: String, defaultValue: Int64? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .Integer64AttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(longLong: Int64($0))})
        return attr
    }

    public static func doubleType(name: String, defaultValue: Double? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .DoubleAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(double: $0)})
        return attr
    }

    public static func stringType(name: String, defaultValue: String? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .StringAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue)
        return attr
    }

    public static func boolType(name: String, defaultValue: Bool? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .BooleanAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(bool: $0)})
        return attr
    }

    public static func dateType(name: String, defaultValue: NSDate? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .DateAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue)
        return attr
    }

    public static func binaryDataType(name: String, defaultValue: NSData? = nil, indexed: Bool? = nil, optional: Bool? = nil, allowsExternalBinaryDataStorage: Bool?) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .BinaryDataAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue)
        if let e = allowsExternalBinaryDataStorage {
            attr.allowsExternalBinaryDataStorage = e
        }
        return attr
    }

    /// transformerName needs to be unique
    public static func transformableType<A: NSObject>(name: String, transform: DataTransform<A>, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .TransformableAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: nil)

        let t = { (a: A?) -> NSData? in
            a.flatMap { transform.forward($0) }
        }
        let r = { Optional<A>.Some(transform.reverse($0)) }

        ValueTransformer.registerTransformerWithName(transform.name, transform: t, reverseTransform: r)
        attr.valueTransformerName = transform.name

        return attr
    }

    private static func descriptionWithName(name: String, type: NSAttributeType) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        return attr
    }

    private func setIndexed(indexed: Bool?, optional: Bool?, defaultValue: AnyObject?) {
        if let d: AnyObject = defaultValue {
            self.defaultValue = d
        }
        setIndexed(indexed, optional: optional)
    }
}


extension NSPropertyDescription {

    private func setIndexed(indexed: Bool?, optional: Bool?) {
        if let o = optional {
            self.optional = o
        }
        if let i = indexed {
            self.indexed = i
        }
    }

}
