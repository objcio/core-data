//
//  MoodDetailViewController.swift
//  Moody
//
//  Created by Daniel Eggert on 15/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import MapKit


class MoodDetailViewController: UIViewController {

    @IBOutlet weak var moodView: MoodView!

    fileprivate var observer: ManagedObjectObserver?

    var mood: Mood! {
        didSet {
            observer = ManagedObjectObserver(object: mood) { [weak self] type in
                guard type == .delete else { return }
                _ = self?.navigationController?.popViewController(animated: true)
            }
            updateViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    @IBAction func deleteMood(_ sender: UIBarButtonItem) {
        mood.managedObjectContext?.performChanges {
            self.mood.managedObjectContext?.delete(self.mood)
        }
    }


    // MARK: Private

    fileprivate func updateViews() {
        moodView?.colors = mood.colors
        navigationItem.title = mood.dateDescription
    }

}


private let dateComponentsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.includesApproximationPhrase = true
    formatter.allowedUnits = [.minute, .hour, .weekday, .month, .year]
    formatter.maximumUnitCount = 1
    return formatter
}()

extension Mood {
    var dateDescription: String {
        guard let timeString = dateComponentsFormatter.string(from: abs(date.timeIntervalSinceNow)) else { return "" }
        return localized(.mood_dateComponentFormat, args: [timeString])
    }
}

