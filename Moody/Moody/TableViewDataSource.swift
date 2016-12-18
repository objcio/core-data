//
//  TableViewDataSource.swift
//  Moody
//
//  Created by Florian on 31/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit
import CoreData


protocol TableViewDataSourceDelegate: class {
    associatedtype Object
    associatedtype Cell: UITableViewCell
    func configure(_ cell: Cell, for object: Object)
    var numberOfAdditionalRows: Int { get }
    func supplementaryObject(at indexPath: IndexPath) -> Object?
    func presentedIndexPath(for fetchedIndexPath: IndexPath) -> IndexPath
    func fetchedIndexPath(for presentedIndexPath: IndexPath) -> IndexPath?
}

extension TableViewDataSourceDelegate {
    var numberOfAdditionalRows: Int {
        return 0
    }

    func supplementaryObject(at indexPath: IndexPath) -> Object? {
        return nil
    }

    func presentedIndexPath(for fetchedIndexPath: IndexPath) -> IndexPath {
        return fetchedIndexPath
    }

    func fetchedIndexPath(for presentedIndexPath: IndexPath) -> IndexPath? {
        return presentedIndexPath
    }
}


/// Note: this class doesn't support working with multiple sections
class TableViewDataSource<Result: NSFetchRequestResult, Delegate: TableViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell

    required init(tableView: UITableView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Result>, delegate: Delegate) {
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        tableView.dataSource = self
        tableView.reloadData()
    }

    var selectedObject: Object? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        return objectAtIndexPath(indexPath)
    }

    func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
        guard let fetchedIndexPath = delegate.fetchedIndexPath(for: indexPath) else {
            return delegate.supplementaryObject(at: indexPath)!
        }
        return (fetchedResultsController.object(at: fetchedIndexPath) as! Object)
    }

    func reconfigureFetchRequest(_ configure: (NSFetchRequest<Result>) -> ()) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
        configure(fetchedResultsController.fetchRequest)
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        tableView.reloadData()
    }


    // MARK: Private

    fileprivate let tableView: UITableView
    fileprivate let fetchedResultsController: NSFetchedResultsController<Result>
    fileprivate weak var delegate: Delegate!
    fileprivate let cellIdentifier: String

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects + delegate.numberOfAdditionalRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = objectAtIndexPath(indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell
            else { fatalError("Unexpected cell type at \(indexPath)") }
        delegate.configure(cell, for: object)
        return cell
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            tableView.insertRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let object = objectAtIndexPath(indexPath)
            guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { break }
            delegate.configure(cell, for: object)
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

