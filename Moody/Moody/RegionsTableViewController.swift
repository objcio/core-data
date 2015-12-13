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


class RegionsTableViewController: UITableViewController, ManagedObjectContextSettable, SegueHandlerType {

    enum SegueIdentifier: String {
        case ShowAllMoods = "showAllMoods"
        case ShowYourMoods = "showYourMoods"
        case ShowCountryMoods = "showCountryMoods"
        case ShowContinentMoods = "showContinentMoods"
    }

    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = localized(.Regions_title)
        setupTableView()
        prepareDefaultNavigationStack()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? MoodsContainerViewController else { fatalError("Wrong view controller type") }
        vc.managedObjectContext = managedObjectContext
        switch segueIdentifierForSegue(segue) {
        case .ShowAllMoods:
            vc.moodSource = .All
        case .ShowYourMoods:
            vc.moodSource = .Yours(managedObjectContext.userID)
        case .ShowCountryMoods:
            guard let c = dataSource?.selectedObject as? Country else { fatalError("Must be a country") }
            vc.moodSource = .Country(c)
        case .ShowContinentMoods:
            guard let c = dataSource?.selectedObject as? Continent else { fatalError("Must be a continent") }
            vc.moodSource = .Continent(c)
        }
    }

    @IBAction func filterChanged(sender: UISegmentedControl) {
        updateDataSource()
    }


    // MARK: Private

    private typealias RegionsDataProvider = AugmentedFetchedResultsDataProvider<RegionsTableViewController>
    private var dataProvider: RegionsDataProvider!
    private var dataSource: TableViewDataSource<RegionsTableViewController, RegionsDataProvider, RegionTableViewCell>!


    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.delegate = self
        setupDataSource()
    }

    private func prepareDefaultNavigationStack() {
        let vc = MoodsContainerViewController.instantiateFromStoryboardForMoodSource(.All, managedObjectContext: managedObjectContext)
        navigationController?.pushViewController(vc, animated: false)
    }


    private func setupDataSource() {
        let request = filterSegmentedControl.regionFilter.fetchRequest
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataProvider = AugmentedFetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }

    private func updateDataSource() {
        let newRequest = filterSegmentedControl.regionFilter.fetchRequest
        dataProvider.reconfigureFetchRequest { request in
            guard let entityName = newRequest.entityName else { fatalError("Must have entity name") }
            request.entity = managedObjectContext.entityForName(entityName)
            request.sortDescriptors = newRequest.sortDescriptors
        }
    }

}


extension RegionsTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let region = dataProvider.objectAtIndexPath(indexPath)
        performSegue(region.segue)
    }
}


enum NonRegionCategory {
    case All
    case Yours
}


extension RegionsTableViewController: AugmentedDataProviderDelegate {
    func numberOfAdditionalRows() -> Int {
        return 2
    }

    func supplementaryObjectAtPresentedIndexPath(indexPath: NSIndexPath) -> DisplayableRegion? {
        switch indexPath.row {
        case 0: return NonRegionCategory.All
        case 1: return NonRegionCategory.Yours
        default: return nil
        }
    }

    func dataProviderDidUpdate(updates: [DataProviderUpdate<DisplayableRegion>]?) {
        dataSource.processUpdates(updates)
    }
}


extension RegionsTableViewController: DataSourceDelegate {
    func cellIdentifierForObject(object: DisplayableRegion) -> String {
        return object.reuseIdentifier
    }
}


private enum RegionFilter: Int {
    case Both = 0
    case Countries = 1
    case Continents = 2
}


extension RegionFilter {
    var fetchRequest: NSFetchRequest {
        var request: NSFetchRequest
        switch self {
        case .Both: request = GeographicRegion.sortedFetchRequest
        case .Countries: request = Country.sortedFetchRequest
        case .Continents: request = Continent.sortedFetchRequest
        }
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 20
        return request
    }
}


extension UISegmentedControl {
    private var regionFilter: RegionFilter {
        guard let rf = RegionFilter(rawValue: selectedSegmentIndex) else { fatalError("Invalid filter index") }
        return rf
    }
}


protocol DisplayableRegion: LocalizedStringConvertible {
    var reuseIdentifier: String { get }
    var localizedDetailDescription: String { get }
    var segue: RegionsTableViewController.SegueIdentifier { get }
}


extension DisplayableRegion {
    var reuseIdentifier: String { return "Region" }
}

extension Country: DisplayableRegion {
    var localizedDetailDescription: String {
        return localized(.Regions_numberOfMoods, args: [numberOfMoods])
    }
    var segue: RegionsTableViewController.SegueIdentifier {
        return .ShowCountryMoods
    }
}

extension Continent: DisplayableRegion {
    var localizedDetailDescription: String {
        return localized(.Regions_numberOfMoodsInCountries, args: [numberOfMoods, numberOfCountries])
    }
    var segue: RegionsTableViewController.SegueIdentifier {
        return .ShowContinentMoods
    }
}


extension NonRegionCategory: DisplayableRegion {
    var segue: RegionsTableViewController.SegueIdentifier {
        switch self {
        case .All: return .ShowAllMoods
        case .Yours: return .ShowYourMoods
        }
    }

    var localizedDescription: String {
        switch self {
        case .All: return localized(.MoodSource_all)
        case .Yours: return localized(.MoodSource_your)
        }
    }

    var localizedDetailDescription: String {
        switch self {
        case .All: return localized(.MoodSource_all_detail)
        case .Yours: return localized(.MoodSource_you_detail)
        }
    }
}
