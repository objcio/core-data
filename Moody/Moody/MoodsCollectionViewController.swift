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


class MoodsCollectionViewController: UICollectionViewController, MoodsPresenter, SegueHandler {

    enum SegueIdentifier: String {
        case showMoodDetail = "showMoodDetail"
    }

    var managedObjectContext: NSManagedObjectContext!
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
        setupCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
        let length = view.bounds.width/4
        layout.itemSize = CGSize(width: length, height: length)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showMoodDetail:
            guard let vc = segue.destination as? MoodDetailViewController
                else { fatalError("Wrong view controller type") }
            guard let mood = dataSource.selectedObject
                else { fatalError("Showing detail, but no selected row?") }
            vc.mood = mood
        }
    }


    // MARK: Private

    fileprivate var dataSource: CollectionViewDataSource<MoodsCollectionViewController>!
    fileprivate var observer: ManagedObjectObserver?

    fileprivate func setupCollectionView() {
        let request = Mood.sortedFetchRequest(with: moodSource.predicate)
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 40
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        guard let cv = collectionView else { fatalError("must have collection view") }
        dataSource = CollectionViewDataSource(collectionView: cv, cellIdentifier: "MoodCell", fetchedResultsController: frc, delegate: self)
    }

}

extension MoodsCollectionViewController: CollectionViewDataSourceDelegate {
    func configure(_ cell: MoodCollectionViewCell, for object: Mood) {
        cell.configure(for: object)
    }
}


