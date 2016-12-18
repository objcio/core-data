//
//  RegionsTableViewController.swift
//  Moody
//
//  Created by Daniel Eggert on 15/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import MoodyModel
import CoreData
import CoreDataHelpers


class RegionsTableViewController: UITableViewController, SegueHandler {

    enum SegueIdentifier: String {
        case showAllMoods = "showAllMoods"
        case showYourMoods = "showYourMoods"
        case showCountryMoods = "showCountryMoods"
        case showContinentMoods = "showContinentMoods"
    }

    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = localized(.regions_title)
        setupTableView()
        prepareDefaultNavigationStack()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MoodsContainerViewController else { fatalError("Wrong view controller type") }
        vc.managedObjectContext = managedObjectContext
        switch segueIdentifier(for: segue) {
        case .showAllMoods:
            vc.moodSource = .all
        case .showYourMoods:
            vc.moodSource = .yours(managedObjectContext.userID)
        case .showCountryMoods:
            guard let country = dataSource?.selectedObject as? Country else { fatalError("Must be a country") }
            vc.moodSource = .country(country)
        case .showContinentMoods:
            guard let continent = dataSource?.selectedObject as? Continent else { fatalError("Must be a continent") }
            vc.moodSource = .continent(continent)
        }
    }

    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        updateDataSource()
    }


    // MARK: Private

    fileprivate var dataSource: TableViewDataSource<NSFetchRequestResult, RegionsTableViewController>!

    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.delegate = self
        setupDataSource()
    }

    fileprivate func prepareDefaultNavigationStack() {
        let vc = MoodsContainerViewController.instantiateFromStoryboard(for: .all, managedObjectContext: managedObjectContext)
        navigationController?.pushViewController(vc, animated: false)
    }

    fileprivate func setupDataSource() {
        let regionType = filterSegmentedControl.regionType
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: regionType.entityName)
        request.sortDescriptors = regionType.defaultSortDescriptors
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: "Region", fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        dataSource.reconfigureFetchRequest { request in
            let regionType = filterSegmentedControl.regionType
            request.entity = regionType.entity
            request.sortDescriptors = regionType.defaultSortDescriptors
        }
    }
}


extension RegionsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let region = dataSource.objectAtIndexPath(indexPath)
        performSegue(withIdentifier: region.segue)
    }
}


extension RegionsTableViewController: TableViewDataSourceDelegate {
    func supplementaryObject(at indexPath: IndexPath) -> DisplayableRegion? {
        switch indexPath.row {
        case 0: return UserRegion.all
        case 1: return UserRegion.yours
        default: return nil
        }
    }

    func configure(_ cell: RegionTableViewCell, for object: DisplayableRegion) {
        cell.configure(for: object)
    }

    var numberOfAdditionalRows: Int {
        return 2
    }

    func fetchedIndexPath(for presentedIndexPath: IndexPath) -> IndexPath? {
        let fetchedRow = presentedIndexPath.row - 2
        guard fetchedRow >= 0 else { return nil }
        return IndexPath(row: fetchedRow, section: presentedIndexPath.section)
    }

    func presentedIndexPath(for fetchedIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: fetchedIndexPath.row + 2, section: fetchedIndexPath.section)
    }
}


protocol DisplayableRegion: LocalizedStringConvertible {
    var segue: RegionsTableViewController.SegueIdentifier { get }
    var localizedDetailDescription: String { get }
}

extension Country: DisplayableRegion {
    var segue: RegionsTableViewController.SegueIdentifier {
        return .showCountryMoods
    }

    var localizedDetailDescription: String {
        return localized(.regions_numberOfMoods, args: [numberOfMoods])
    }

    public var localizedDescription: String {
        return iso3166Code.localizedDescription
    }
}


extension Continent: DisplayableRegion {
    var segue: RegionsTableViewController.SegueIdentifier {
        return .showContinentMoods
    }

    var localizedDetailDescription: String {
        return localized(.regions_numberOfMoodsInCountries, args: [numberOfMoods, numberOfCountries])
    }

    public var localizedDescription: String {
        return iso3166Code.localizedDescription
    }
}


extension UISegmentedControl {
    fileprivate var regionType: Managed.Type {
        switch selectedSegmentIndex {
        case 0: return Region.self
        case 1: return Country.self
        case 2: return Continent.self
        default: fatalError("Invalid filter index")
        }
    }
}


enum UserRegion {
    case all
    case yours
}

extension UserRegion: DisplayableRegion {
    var segue: RegionsTableViewController.SegueIdentifier {
        switch self {
        case .all: return .showAllMoods
        case .yours: return .showYourMoods
        }
    }

    var localizedDescription: String {
        switch self {
        case .all: return localized(.moodSource_all)
        case .yours: return localized(.moodSource_your)
        }
    }

    var localizedDetailDescription: String {
        switch self {
        case .all: return localized(.moodSource_all_detail)
        case .yours: return localized(.moodSource_you_detail)
        }
    }
}


