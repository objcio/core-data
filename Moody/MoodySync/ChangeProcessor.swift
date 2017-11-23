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
protocol ChangeProcessor {
    /// Called at startup to give the processor a chance to configure itself.
    func setup(for context: ChangeProcessorContext)

    /// Respond to changes of locally inserted or updated objects.
    func processChangedLocalObjects(_ objects: [NSManagedObject], in context: ChangeProcessorContext)

    /// Upon launch these fetch requests are executed and the resulting objects are passed to `process(changedLocalObjects:)`.
    /// This allows the change processor to resume pending local changes.
    func entityAndPredicateForLocallyTrackedObjects(in context: ChangeProcessorContext) -> EntityAndPredicate<NSManagedObject>?

    /// Respond to changes in remote records.
    func processRemoteChanges<T>(_ changes: [RemoteRecordChange<T>], in context: ChangeProcessorContext, completion: () -> ())

    /// Does the initial fetch from the remote.
    func fetchLatestRemoteRecords(in context: ChangeProcessorContext)
}


// MARK: - Change Processor Context -

/// The `SyncCoordinator` has a list of *change processors* (`ChangeProcessor`) which do the actual work.
/// Whenever a change happens the *sync coordinator* passes itself to the *change processors* as a *context* (`ChangeProcessorContext`). This is the part of the sync coordinator that the change processors should have access to.
protocol ChangeProcessorContext: class {

    /// The managed object context to use
    var context: NSManagedObjectContext { get }

    /// The remote to use for syncing.
    var remote: MoodyRemote { get }

    /// Wraps a block such that it is run on the right queue.
    func perform(_ block: @escaping () -> ())

    /// Wraps a block such that it is run on the right queue.
    func perform<A, B>(_ block: @escaping (A, B) -> ()) -> (A, B) -> ()

    /// Wraps a block such that it is run on the right queue.
    func perform<A, B, C>(_ block: @escaping (A, B, C) -> ()) -> (A, B, C) -> ()

    /// Eventually saves the context. May batch multiple calls into a single call to `saveOrRollback()`.
    func delayedSaveOrRollback()
}


// MARK: - Element Change Processor -

/// This a generic sub-protocol that the change processors implement.
/// It does the type matching and casting in order to keep this *Change Processor* code simple.
/// When implementing `ElementChangeProcessor`, implement
/// ```
/// func processChangedLocalElements(_:,context:)
/// var predicateForLocallyTrackedElements
/// ```
/// as a replacement for
/// ```
/// func process(changedLocalObjects:,context:)
/// func entityAndPredicateForLocallyTrackedObjects(in:)
/// ```
///
/// The `ElementChangeProcessor` makes sure that objects which are already in progress,
/// are not started a second time. And once they finish, it checks if they should be
/// processed a second time at that point in time.
///
/// The contract is that the implementation is such that objects no longer match the `predicateForLocallyTrackedElements` once they're actually complete.
protocol ElementChangeProcessor: ChangeProcessor {

    associatedtype Element: NSManagedObject, Managed

    /// Used to track if elements are already in progress.
    var elementsInProgress: InProgressTracker<Element> {get}

    /// Any objects matching the predicate.
    func processChangedLocalElements(_ elements: [Element], in context: ChangeProcessorContext)

    /// The elements that this change processor is interested in.
    /// Used by `entityAndPredicateForLocallyTrackedObjects(in:)`.
    var predicateForLocallyTrackedElements: NSPredicate { get }
}


extension ElementChangeProcessor {
    func processChangedLocalObjects(_ objects: [NSManagedObject], in context: ChangeProcessorContext) {
        // Filters the `NSManagedObjects` according to the `entityAndPredicateForLocallyTrackedObjects(in:)` and forwards the result to `processChangedLocalElements(_:context:completion:)`.
        let matching = objects.filter(entityAndPredicateForLocallyTrackedObjects(in: context)!)
        if let elements = matching as? [Element] {
            let newElements = elementsInProgress.objectsToProcess(from: elements)
            processChangedLocalElements(newElements, in: context)
        }
    }

    func didComplete(_ elements: [Element], in context: ChangeProcessorContext) {
        elementsInProgress.markObjectsAsComplete(elements)
        // Now check if they still match:
        let p = predicateForLocallyTrackedElements
        let matching = elements.filter(p.evaluate(with:))
        let newElements = elementsInProgress.objectsToProcess(from: matching)
        if newElements.count > 0 {
            processChangedLocalElements(newElements, in: context)
        }
    }

    func entityAndPredicateForLocallyTrackedObjects(in context: ChangeProcessorContext) -> EntityAndPredicate<NSManagedObject>? {
        let predicate = predicateForLocallyTrackedElements
        return EntityAndPredicate(entity: Element.entity(), predicate: predicate)
    }
}

