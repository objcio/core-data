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
    case List = 0
    case Grid = 1
}


class MoodsContainerViewController: UIViewController, ManagedObjectContextSettable {

    @IBOutlet weak var moodPresentationButton: UIBarButtonItem!
    @IBOutlet weak var presentationStyleButton: UIBarButtonItem!
    var managedObjectContext: NSManagedObjectContext!
    var moodSource: MoodSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = moodSource.localizedDescription
        presentationStyle = NSUserDefaults.standardUserDefaults().moodPresentationStyle
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        for vc in segue.destinationViewController.childViewControllers {
            guard let moodsPresenter = vc as? MoodsPresenterType else { fatalError("expected moods presenter") }
            moodsPresenter.managedObjectContext = managedObjectContext
            moodsPresenter.moodSource = moodSource
        }
    }

    @IBAction func toggleMoodPresentation(sender: AnyObject) {
        presentationStyle = presentationStyle.opposite
    }


    // MARK: Private

    private var tabController: UITabBarController {
        guard let tc = childViewControllers.first as? UITabBarController else { fatalError("expected tab bar controller") }
        return tc
    }

    private var presentationStyle = MoodPresentationStyle.defaultStyle {
        didSet {
            presentationStyleButton.title = presentationStyle.opposite.localizedDescription
            tabController.selectedIndex = presentationStyle.rawValue
            NSUserDefaults.standardUserDefaults().moodPresentationStyle = presentationStyle
        }
    }

}


extension MoodsContainerViewController {
    static func instantiateFromStoryboardForMoodSource(moodSource: MoodSource, managedObjectContext: NSManagedObjectContext) -> MoodsContainerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewControllerWithIdentifier("MoodsContainerViewController") as? MoodsContainerViewController else { fatalError() }
        vc.moodSource = moodSource
        vc.managedObjectContext = managedObjectContext
        return vc
    }
}


extension MoodPresentationStyle: LocalizedStringConvertible {
    private static var defaultStyle: MoodPresentationStyle {
        return .List
    }

    private var opposite: MoodPresentationStyle {
        switch self {
        case .List: return .Grid
        case .Grid: return .List
        }
    }

    private var localizedDescription: String {
        switch self {
        case .List: return localized(.MoodPresentation_list)
        case .Grid: return localized(.MoodPresentation_grid)
        }
    }
}


private let MoodPresentationStyleKey = "moodsPresentationStyle"

extension NSUserDefaults {
    private var moodPresentationStyle: MoodPresentationStyle {
        get {
            let val = integerForKey(MoodPresentationStyleKey)
            return MoodPresentationStyle(rawValue: val) ?? MoodPresentationStyle.defaultStyle
        }
        set {
            setInteger(newValue.rawValue, forKey: MoodPresentationStyleKey)
        }
    }
}