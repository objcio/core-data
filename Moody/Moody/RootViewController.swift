//
//  RootViewController.swift
//  Moody
//
//  Created by Florian on 18/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MoodyModel


class RootViewController: UIViewController, ManagedObjectContextSettable, SegueHandlerType {

    enum SegueIdentifier: String {
        case EmbedNavigation = "embedNavigationController"
        case EmbedCamera = "embedCamera"
    }

    @IBOutlet weak var hideCameraConstraint: NSLayoutConstraint!
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        geoLocationController = GeoLocationController(delegate: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue,
        sender: AnyObject?)
    {
        switch segueIdentifierForSegue(segue) {
        case .EmbedNavigation:
            guard let nc = segue.destinationViewController as? UINavigationController,
                let vc = nc.viewControllers.first as? ManagedObjectContextSettable
                else { fatalError("wrong view controller type") }
            vc.managedObjectContext = managedObjectContext
            nc.delegate = self
        case .EmbedCamera:
            guard let cameraVC = segue.destinationViewController as? CameraViewController else { fatalError("must be camera view controller") }
            cameraViewController = cameraVC
            cameraViewController?.delegate = self
        }
    }


    // MARK: Private

    private var geoLocationController: GeoLocationController!
    private var cameraViewController: CameraViewController?

    private func setCameraVisibility(visible: Bool) {
        hideCameraConstraint.active = !visible
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func saveMoodWithImage(image: UIImage) {
        geoLocationController.retrieveCurrentLocation { location, placemark in
            self.managedObjectContext.performChanges {
                Mood.insertIntoContext(self.managedObjectContext, image: image, location: location, placemark: placemark)
            }
        }
    }

}

extension RootViewController: UINavigationControllerDelegate {

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if viewController is MoodDetailViewController {
            setCameraVisibility(false)
        }
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if !(viewController is MoodDetailViewController) {
            setCameraVisibility(true)
        }
    }

}

extension RootViewController: GeoLocationControllerDelegate {

    func geoLocationDidChangeAuthorizationStatus(authorized: Bool) {
        cameraViewController?.locationAuthorized = authorized
    }

}

extension RootViewController: CameraViewControllerDelegate {

    func didTakeImage(image: UIImage) {
        saveMoodWithImage(image)
    }


}

