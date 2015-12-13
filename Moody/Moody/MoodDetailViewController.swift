//
//  MoodDetailViewController.swift
//  Moody
//
//  Created by Daniel Eggert on 15/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import MapKit
import MoodyModel
import CoreDataHelpers


class MoodDetailViewController: UIViewController {

    @IBOutlet weak var moodView: MoodView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trashButton: UIBarButtonItem!

    private var observer: ManagedObjectObserver?

    var mood: Mood! {
        didSet {
            observer = ManagedObjectObserver(object: mood) { [unowned self] type in
                guard type == .Delete else { return }
                self.navigationController?.popViewControllerAnimated(true)
            }
            updateViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    @IBAction func deleteMood(sender: UIBarButtonItem) {
        mood.managedObjectContext?.performChanges {
            self.mood.markForRemoteDeletion()
        }
    }


    // MARK: Private

    private func updateViews() {
        moodView?.colors = mood.colors
        mapView?.alpha = 1
        navigationItem.title = mood.dateDescription
        trashButton.enabled = mood.belongsToCurrentUser
        updateMapView()
    }

    private func updateMapView() {
        guard let map = mapView, let annotation = MoodAnnotation(mood: mood) else { return }
        map.removeAnnotations(mapView!.annotations)
        map.addAnnotation(annotation)
        map.selectAnnotation(annotation, animated: false)
        map.setCenterCoordinate(annotation.coordinate, animated: false)
        map.setRegion(MKCoordinateRegionMakeWithDistance(annotation.coordinate, 2e6, 2e6), animated: false)
    }

}


private let dateComponentsFormatter: NSDateComponentsFormatter = {
    let formatter = NSDateComponentsFormatter()
    formatter.unitsStyle = .Full
    formatter.includesApproximationPhrase = true
    formatter.allowedUnits = NSCalendarUnit.Minute.union(.Hour).union(.Day).union(.Month).union(.Year)
    formatter.maximumUnitCount = 1
    return formatter
}()

extension Mood {
    var dateDescription: String {
        guard let timeString = dateComponentsFormatter.stringFromTimeInterval(abs(date.timeIntervalSinceNow)) else { return "" }
        return localized(.Mood_dateComponentFormat, args: [timeString])
    }
}


class MoodAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?

    private init?(mood: Mood) {
        coordinate = mood.location?.coordinate ?? CLLocationCoordinate2D()
        title = mood.country?.localizedDescription
        super.init()
        guard let _ = mood.location, let _ = title else { return nil }
    }
}

