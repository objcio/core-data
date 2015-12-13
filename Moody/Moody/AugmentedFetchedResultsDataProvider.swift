//
//  AugmentedFetchedResultsDataProvider.swift
//  Moody
//
//  Created by Florian on 31/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


protocol AugmentedDataProviderDelegate: DataProviderDelegate {
    func numberOfAdditionalRows() -> Int
    func presentedIndexPathForFetchedIndexPath(indexPath: NSIndexPath) -> NSIndexPath
    func fetchedIndexPathForPresentedIndexPath(indexPath: NSIndexPath) -> NSIndexPath
    func supplementaryObjectAtPresentedIndexPath(indexPath: NSIndexPath) -> Object?
}


/// Note: this class doesn't support working with multiple sections
class AugmentedFetchedResultsDataProvider<Delegate: AugmentedDataProviderDelegate>: DataProvider {

    typealias Object = Delegate.Object

    init(fetchedResultsController: NSFetchedResultsController, delegate: Delegate) {
        self.delegate = delegate
        frcDataProvider = FetchedResultsDataProvider(fetchedResultsController: fetchedResultsController, delegate: self)
    }

    func reconfigureFetchRequest(@noescape block: NSFetchRequest -> ()) {
        frcDataProvider.reconfigureFetchRequest(block)
    }

    func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
        if let o = delegate.supplementaryObjectAtPresentedIndexPath(indexPath) {
            return o
        }
        let frcIndexPath = delegate.fetchedIndexPathForPresentedIndexPath(indexPath)
        return frcDataProvider.objectAtIndexPath(frcIndexPath)
    }

    func numberOfItemsInSection(section: Int) -> Int {
        return frcDataProvider.numberOfItemsInSection(section) + delegate.numberOfAdditionalRows()
    }


    // MARK: Private

    private var frcDataProvider: FetchedResultsDataProvider<AugmentedFetchedResultsDataProvider>!
    private weak var delegate: Delegate!

}


extension AugmentedFetchedResultsDataProvider: DataProviderDelegate {
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Object>]?) {
        let transformedUpdates = updates?.map { $0.updateByTransformingIndexPath(delegate.presentedIndexPathForFetchedIndexPath) }
        delegate.dataProviderDidUpdate(transformedUpdates)
    }
}


extension DataProviderUpdate {
    private func updateByTransformingIndexPath(transformer: NSIndexPath -> NSIndexPath) -> DataProviderUpdate {
        switch self {
        case .Delete(let indexPath): return .Delete(transformer(indexPath))
        case .Update(let indexPath, let o): return .Update(transformer(indexPath), o)
        case .Move(let indexPath, let newIndexPath): return .Move(transformer(indexPath), transformer(newIndexPath))
        case .Insert(let indexPath): return .Insert(transformer(indexPath))
        }
    }
}


extension AugmentedDataProviderDelegate {
    func numberOfAdditionalRows() -> Int {
        return 0
    }

    func presentedIndexPathForFetchedIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: indexPath.row + numberOfAdditionalRows(), inSection: indexPath.section)
    }

    func fetchedIndexPathForPresentedIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: indexPath.row - numberOfAdditionalRows(), inSection: indexPath.section)
    }

    func supplementaryObjectAtPresentedIndexPath(indexPath: NSIndexPath) -> Object? {
        return nil
    }
}

