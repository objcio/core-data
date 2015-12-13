//
//  MoodsCollectionViewController.swift
//  Moody
//
//  Created by Florian on 27/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit
import CoreData
import CoreDataHelpers
import MoodyModel


class MoodsCollectionViewController: UICollectionViewController, MoodsPresenterType, SegueHandlerType {

    enum SegueIdentifier: String {
        case ShowMoodDetail = "showMoodDetail"
    }

    var managedObjectContext: NSManagedObjectContext!
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
        setupCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
        let length = view.bounds.width/4
        layout.itemSize = CGSize(width: length, height: length)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowMoodDetail:
            guard let vc = segue.destinationViewController as? MoodDetailViewController
                else { fatalError("Wrong view controller type") }
            guard let mood = dataSource.selectedObject
                else { fatalError("Showing detail, but no selected row?") }
            vc.mood = mood
        }
    }


    // MARK: Private

    private typealias MoodsDataProvider = FetchedResultsDataProvider<MoodsCollectionViewController>
    private var dataSource: CollectionViewDataSource<MoodsCollectionViewController, MoodsDataProvider, MoodCollectionViewCell>!
    private var observer: ManagedObjectObserver?

    private func setupCollectionView() {
        let request = Mood.sortedFetchRequestWithPredicate(moodSource.predicate)
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 40
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        guard let cv = collectionView else { fatalError("must have collection view") }
        dataSource = CollectionViewDataSource(collectionView: cv, dataProvider: dataProvider, delegate: self)
    }

}

extension MoodsCollectionViewController: DataSourceDelegate {
    func cellIdentifierForObject(object: Mood) -> String {
        return "MoodCell"
    }
}

extension MoodsCollectionViewController: DataProviderDelegate {
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Mood>]?) {
        dataSource.processUpdates(updates)
    }
}

