//
//  RegionsTableViewController.swift
//  Moody
//
//  Created by Daniel Eggert on 15/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import CoreData


class RegionsTableViewController: UITableViewController, SegueHandler {
    enum SegueIdentifier: String {
        case showMoods = "showMoods"
    }

    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = localized(.regions_title)
        setupTableView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MoodsTableViewController else { fatalError("Wrong view controller type") }
        vc.managedObjectContext = managedObjectContext
        switch segueIdentifier(for: segue) {
        case .showMoods:
            guard let region = dataSource?.selectedObject else { fatalError("No selection at segue?") }
            vc.moodSource = MoodSource(region: region)
        }
    }


    // MARK: Private

    fileprivate var dataSource: TableViewDataSource<RegionsTableViewController>!

    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        let request = Region.sortedFetchRequest
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: "RegionCell", fetchedResultsController: frc, delegate: self)
    }
}


extension RegionsTableViewController: TableViewDataSourceDelegate {
    func configure(_ cell: RegionTableViewCell, for object: Region) {
        guard let region = object as? LocalizedStringConvertible else { fatalError("Wrong object type") }
        cell.configure(for: region)
    }
}


extension Country: LocalizedStringConvertible {
    var localizedDescription: String {
        return iso3166Code.localizedDescription
    }
}


extension Continent: LocalizedStringConvertible {
    var localizedDescription: String {
        return iso3166Code.localizedDescription
    }
}

