//
//  MoodsTableViewController.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import CoreData
import MoodyModel
import CoreDataHelpers


class MoodsTableViewController: UITableViewController, MoodsPresenterType, SegueHandlerType {

    enum SegueIdentifier: String {
        case ShowMoodDetail = "showMoodDetail"
    }

    var managedObjectContext: NSManagedObjectContext!
    var countries: [Country]?
    var moodSource: MoodSource! {
        didSet {
            guard let o = moodSource.managedObject else { return }
            observer = ManagedObjectObserver(object: o) { [unowned self] type in
                guard type == .Delete else { return }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        countries = moodSource.prefetchInContext(managedObjectContext)
        setupTableView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowMoodDetail:
            guard let vc = segue.destinationViewController as? MoodDetailViewController else { fatalError("Wrong view controller type") }
            guard let mood = dataSource.selectedObject else { fatalError("Showing detail, but no selected row?") }
            vc.mood = mood
        }
    }


    // MARK: Private

    private typealias Data = FetchedResultsDataProvider<MoodsTableViewController>
    private var dataSource: TableViewDataSource<MoodsTableViewController, Data, MoodTableViewCell>!
    private var observer: ManagedObjectObserver?

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        let request = Mood.sortedFetchRequestWithPredicate(moodSource.predicate)
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }

}


extension MoodsTableViewController: DataProviderDelegate {
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Mood>]?) {
        dataSource.processUpdates(updates)
    }
}

extension MoodsTableViewController: DataSourceDelegate {
    func cellIdentifierForObject(object: Mood) -> String {
        return "MoodCell"
    }
}

