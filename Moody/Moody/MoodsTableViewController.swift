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


class MoodsTableViewController: UITableViewController, MoodsPresenter, SegueHandler {

    enum SegueIdentifier: String {
        case showMoodDetail = "showMoodDetail"
    }

    var managedObjectContext: NSManagedObjectContext!
    var countries: [Country]?
    var moodSource: MoodSource! {
        didSet {
            guard let o = moodSource.managedObject as? Managed else { return }
            observer = ManagedObjectObserver(object: o) { [unowned self] type in
                guard type == .delete else { return }
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        countries = moodSource.prefetch(in: managedObjectContext)
        setupTableView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showMoodDetail:
            guard let vc = segue.destination as? MoodDetailViewController else { fatalError("Wrong view controller type") }
            guard let mood = dataSource.selectedObject else { fatalError("Showing detail, but no selected row?") }
            vc.mood = mood
        }
    }


    // MARK: Private

    fileprivate var dataSource: TableViewDataSource<Mood, MoodsTableViewController>!
    fileprivate var observer: ManagedObjectObserver?

    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        let request = Mood.sortedFetchRequest(with: moodSource.predicate)
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: "MoodCell", fetchedResultsController: frc, delegate: self)
    }

}


extension MoodsTableViewController: TableViewDataSourceDelegate {
    func configure(_ cell: MoodTableViewCell, for object: Mood) {
        cell.configure(for: object)
    }
}


