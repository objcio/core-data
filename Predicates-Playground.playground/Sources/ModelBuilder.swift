import CoreData


extension NSManagedObjectModel {

    public convenience init(builder: () -> [NSEntityDescription]) {
        self.init()
        entities = builder()
    }

}


extension NSEntityDescription {

    public convenience init<A: NSManagedObject>(cls: A.Type, name: String) {
        self.init()
        let a = NSStringFromClass(cls) as String
        self.managedObjectClassName = a
        self.name = name
    }

    public func add(_ property: NSPropertyDescription) {
        var p = properties
        p.append(property)
        properties = p
    }

    public func createOneToOneRelation(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription(.toOne, name: toName, destinationEntity: to, deleteRule: .nullifyDeleteRule)
        let inverse = NSRelationshipDescription(.toOne, name: fromName, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.add(relation)
        to.add(inverse)
    }

    public func createOneToManyRelation(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription(.toMany, name: toName, destinationEntity: to, deleteRule: .nullifyDeleteRule)
        let inverse = NSRelationshipDescription(.toOne, name: fromName, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.add(relation)
        to.add(inverse)
    }

    public func createOneToOrderedManyRelation(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription(.toMany, name: toName, destinationEntity: to, deleteRule: .nullifyDeleteRule, propertyOptions: [.ordered])
        let inverse = NSRelationshipDescription(.toOne, name: fromName, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.add(relation)
        to.add(inverse)
    }

    public func createManyToManyRelation(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription(.toMany, name: toName, destinationEntity: to, deleteRule: .nullifyDeleteRule)
        let inverse = NSRelationshipDescription(.toMany, name: fromName, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.add(relation)
        to.add(inverse)
    }

    public func createManyToOrderedManyRelation(to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription(.toMany, name: toName, destinationEntity: to, deleteRule: .nullifyDeleteRule, propertyOptions: [.ordered])
        let inverse = NSRelationshipDescription(.toMany, name: fromName, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.add(relation)
        to.add(inverse)
    }

}


public struct DataTransform<A> {
    public let name: String
    public let forward: (A) -> NSData?
    public let reverse: (NSData?) -> A
    public init(name: String, forward: @escaping (A) -> NSData?, reverse: @escaping (NSData?) -> A) {
        self.name = name
        self.forward = forward
        self.reverse = reverse
    }
}


public extension NSPropertyDescription {
    public struct PropertyOptions : OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public static var indexed: PropertyOptions { return PropertyOptions(rawValue: 1 << 0) }
        public static var optional: PropertyOptions { return PropertyOptions(rawValue: 1 << 1) }
        public static var ordered: PropertyOptions { return PropertyOptions(rawValue: 1 << 2) }
    }
}

extension NSRelationshipDescription {

    public enum Kind {
        case toOne
        case toMany
    }

    public convenience init(_ kind: Kind, name: String, destinationEntity: NSEntityDescription?, deleteRule: NSDeleteRule = .nullifyDeleteRule, propertyOptions: PropertyOptions = [.optional]) {
        self.init()
        self.name = name
        self.propertyOptions = propertyOptions
        self.deleteRule = deleteRule
        self.destinationEntity = destinationEntity
        switch kind {
        case .toOne:
            self.minCount = 1
            self.maxCount = 1
        case .toMany:
            self.minCount = 0
            self.maxCount = Int.max
        }
    }
}

extension NSRelationshipDescription {
    public var propertyOptions: PropertyOptions {
        get {
            var r: PropertyOptions = []
            if isIndexed {
                r.insert(.indexed)
            }
            if isOptional {
                r.insert(.optional)
            }
            if isOrdered {
                r.insert(.ordered)
            }
            return r
        }
        set {
            isIndexed = newValue.contains(.indexed)
            isOptional = newValue.contains(.optional)
            isOrdered = newValue.contains(.ordered)
        }
    }
}

extension NSAttributeDescription {
    public static func int16Type(name: String, defaultValue: Int16? = nil, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .integer16AttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue.map { NSNumber(value: $0) }
        return attr
    }

    public static func int32Type(name: String, defaultValue: Int32? = nil, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .integer32AttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue.map { NSNumber(value: $0) }
        return attr
    }

    public static func int64Type(name: String, defaultValue: Int64? = nil, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .integer64AttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue.map { NSNumber(value: $0) }
        return attr
    }

    public static func doubleType(name: String, defaultValue: Double? = nil, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .doubleAttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue.map { NSNumber(value: $0) }
        return attr
    }

    public static func stringType(name: String, defaultValue: String? = nil, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .stringAttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue
        return attr
    }

    public static func dataType(name: String, defaultValue: NSData? = nil, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .binaryDataAttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue
        return attr
    }

    public static func boolType(name: String, defaultValue: Bool? = nil, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .booleanAttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue.map { NSNumber(value: $0) }
        return attr
    }

    public static func dateType(name: String, defaultValue: NSDate? = nil, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .dateAttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue
        return attr
    }

    public static func binaryDataType(name: String, defaultValue: NSData? = nil, propertyOptions: PropertyOptions = [.optional], allowsExternalBinaryDataStorage: Bool?) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .binaryDataAttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = defaultValue
        if let e = allowsExternalBinaryDataStorage {
            attr.allowsExternalBinaryDataStorage = e
        }
        return attr
    }

    /// transformerName needs to be unique
    public static func transformableType<A: NSObject>(name: String, transform: DataTransform<A>, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .transformableAttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = nil

        let t = { (a: A?) -> NSData? in
            a.flatMap { transform.forward($0) }
        }
        let r = { Optional<A>.some(transform.reverse($0)) }

        ClosureValueTransformer.registerTransformer(withName: transform.name, transform: t, reverseTransform: r)
        attr.valueTransformerName = transform.name

        return attr
    }
    public static func transformableType<A: NSObject>(name: String, transform: DataTransform<A?>, propertyOptions: PropertyOptions = [.optional]) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: .transformableAttributeType)
        attr.propertyOptions = propertyOptions
        attr.defaultValue = nil

        ClosureValueTransformer.registerTransformer(withName: transform.name, transform: transform.forward, reverseTransform: transform.reverse)
        attr.valueTransformerName = transform.name

        return attr
    }

    private convenience init(name: String, type: NSAttributeType) {
        self.init()
        self.name = name
        self.attributeType = type
    }
}

extension NSAttributeDescription {
    public var propertyOptions: PropertyOptions {
        get {
            var r: PropertyOptions = []
            if isIndexed {
                r.insert(.indexed)
            }
            if isOptional {
                r.insert(.optional)
            }
            return r
        }
        set {
            isIndexed = newValue.contains(.indexed)
            isOptional = newValue.contains(.optional)
        }
    }
}


