//
//  ChangeProcessor.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreDataHelpers
import MoodyModel


// MARK: - Change Processor -

/// A change processor performs a specific sync task, e.g. "upload Mood objects".
/// This is the (non-generic) interface that the `SyncCoordinator` sees.
protocol ChangeProcessorType {
    /// Called at startup to give the processor a chance to configure itself.
    func setupForContext(context: ChangeProcessorContextType)

    /// Respond to changes of locally inserted or updated objects.
    func processChangedLocalObjects(objects: [NSManagedObject], context: ChangeProcessorContextType)

    /// Upon launch these fetch requests are executed and the resulting objects are passed to `processChangedLocalObjects()`.
    /// This allows the change processor to resume pending local changes.
    func entityAndPredicateForLocallyTrackedObjectsInContext(context: ChangeProcessorContextType) -> EntityAndPredicate?

    /// Respond to changes in remote records.
    func processChangedRemoteObjects<T: RemoteRecordType>(changes: [RemoteRecordChange<T>], context: ChangeProcessorContextType, completion: () -> ())

    /// Does the initial fetch from the remote.
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType)
}


// MARK: - Change Processor Context -

/// The `SyncCoordinator` has a list of *change processors* (`ChangeProcessorType`) which do the actual work.
/// Whenever a change happens the *sync coordinator* passes itself to the *change processors* as a *context* (`ChangeProcessorContextType`). This is the part of the sync coordinator that the change processors should have access to.
protocol ChangeProcessorContextType: class {

    /// The background context
    var managedObjectContext: NSManagedObjectContext { get }

    /// The remote to use for syncing.
    var remote: MoodyRemoteType { get }

    /// Wraps a block such that it is run on the right queue.
    func performGroupedBlock(block: () -> ())

    /// Wraps a block such that it is run on the right queue.
    func performGroupedBlock<A,B>(block: (A,B) -> ()) -> (A,B) -> ()

    /// Wraps a block such that it is run on the right queue.
    func performGroupedBlock<A,B,C>(block: (A,B,C) -> ()) -> (A,B,C) -> ()

    /// Eventually saves the context. May batch multiple calls into a single call to `saveOrRollback()`.
    func delayedSaveOrRollback()
}


// MARK: - Element Change Processor -

/// This a generic sub-protocol that the change processors implement.
/// It does the type matching and casting in order to keep this *Change Processor* code simple.
/// When implementing `ElementChangeProcessorType`, implement
/// ```
/// func processChangedLocalElements(_:,context:)
/// var predicateForLocallyTrackedElements
/// ```
/// as a replacement for
/// ```
/// func processChangedLocalObjects(_:,context:)
/// func entityAndPredicateForLocallyTrackedObjectsInContext(_:)
/// ```
///
/// The `ElementChangeProcessorType` makes sure that objects which are already in progress,
/// are not started a second time. And once they finish, it checks if they should be
/// processed a second time at that point in time.
///
/// The contract is that the implementation is such that objects no longer match the `predicateForLocallyTrackedElements` once they're actually complete.
protocol ElementChangeProcessorType: ChangeProcessorType {

    associatedtype Element: ManagedObject, ManagedObjectType

    /// Used to track if elements are already in progress.
    var elementsInProgress: InProgressTracker<Element> {get}

    /// Any objects matching the predicate.
    func processChangedLocalElements(objects: [Element], context: ChangeProcessorContextType)

    /// The elements that this change processor is interested in.
    /// Used by `entityAndPredicateForLocallyTrackedObjectsInContext(_:)`.
    var predicateForLocallyTrackedElements: NSPredicate { get }
}


extension ElementChangeProcessorType {
    func processChangedLocalObjects(objects: [NSManagedObject], context: ChangeProcessorContextType) {
        // Filters the `NSManagedObjects` according to the `entityAndPredicateForLocallyTrackedObjectsInContext()` and forwards the result to `processChangedLocalElements(_:context:completion:)`.
        let matching = objects.objectsMatching(entityAndPredicateForLocallyTrackedObjectsInContext(context)!)
        if let elements = matching as? [Element] {
            let newElements = elementsInProgress.objectsToProcessFromObjects(elements)
            processChangedLocalElements(newElements, context:context)
        }
    }

    func didCompleteElements(objects: [Element], context: ChangeProcessorContextType) {
        elementsInProgress.markObjectsAsComplete(objects)
        // Now check if they still match:
        let p = predicateForLocallyTrackedElements
        let matching = objects.filter(p.evaluateWithObject)
        let newElements = elementsInProgress.objectsToProcessFromObjects(matching)
        if newElements.count > 0 {
            processChangedLocalElements(newElements, context:context)
        }
    }

    func entityAndPredicateForLocallyTrackedObjectsInContext(context: ChangeProcessorContextType) -> EntityAndPredicate? {
        let predicate = predicateForLocallyTrackedElements
        return EntityAndPredicate(entityName: Element.entityName, predicate: predicate, context: context)
    }
}
