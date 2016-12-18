//
//  MoodsContainerViewController.swift
//  Moody
//
//  Created by Florian on 27/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit
import CoreData
import MoodyModel


private enum MoodPresentationStyle: Int {
    case list = 0
    case grid = 1
}


class MoodsContainerViewController: UIViewController {

    @IBOutlet weak var moodPresentationButton: UIBarButtonItem!
    @IBOutlet weak var presentationStyleButton: UIBarButtonItem!
    var managedObjectContext: NSManagedObjectContext!
    var moodSource: MoodSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = moodSource.localizedDescription
        presentationStyle = UserDefaults.standard.moodPresentationStyle
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        for vc in segue.destination.childViewControllers {
            guard let moodsPresenter = vc as? MoodsPresenter else { fatalError("expected moods presenter") }
            moodsPresenter.managedObjectContext = managedObjectContext
            moodsPresenter.moodSource = moodSource
        }
    }

    @IBAction func toggleMoodPresentation(_ sender: AnyObject) {
        presentationStyle = presentationStyle.opposite
    }


    // MARK: Private

    fileprivate var tabController: UITabBarController {
        guard let tc = childViewControllers.first as? UITabBarController else { fatalError("expected tab bar controller") }
        return tc
    }

    fileprivate var presentationStyle = MoodPresentationStyle.standard {
        didSet {
            presentationStyleButton.title = presentationStyle.opposite.localizedDescription
            tabController.selectedIndex = presentationStyle.rawValue
            UserDefaults.standard.moodPresentationStyle = presentationStyle
        }
    }

}


extension MoodsContainerViewController {
    static func instantiateFromStoryboard(for moodSource: MoodSource, managedObjectContext: NSManagedObjectContext) -> MoodsContainerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MoodsContainerViewController") as? MoodsContainerViewController else { fatalError() }
        vc.moodSource = moodSource
        vc.managedObjectContext = managedObjectContext
        return vc
    }
}


extension MoodPresentationStyle {
    fileprivate static var standard: MoodPresentationStyle {
        return .list
    }

    fileprivate var opposite: MoodPresentationStyle {
        switch self {
        case .list: return .grid
        case .grid: return .list
        }
    }
}

extension MoodPresentationStyle: LocalizedStringConvertible {
    fileprivate var localizedDescription: String {
        switch self {
        case .list: return localized(.moodPresentation_list)
        case .grid: return localized(.moodPresentation_grid)
        }
    }
}


private let MoodPresentationStyleKey = "moodsPresentationStyle"

extension UserDefaults {
    fileprivate var moodPresentationStyle: MoodPresentationStyle {
        get {
            let val = integer(forKey: MoodPresentationStyleKey)
            return MoodPresentationStyle(rawValue: val) ?? MoodPresentationStyle.standard
        }
        set {
            set(newValue.rawValue, forKey: MoodPresentationStyleKey)
        }
    }
}

