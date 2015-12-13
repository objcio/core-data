//
//  GeoLocationController.swift
//  Moody
//
//  Created by Florian on 18/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import CoreLocation


protocol GeoLocationControllerDelegate: class {
    func geoLocationDidChangeAuthorizationStatus(authorized: Bool)
}


class GeoLocationController: NSObject {

    var authorized: Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .AuthorizedAlways || status == .AuthorizedWhenInUse
    }

    required init(delegate: GeoLocationControllerDelegate) {
        super.init()
        self.delegate = delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            start()
        }
    }

    func retrieveCurrentLocation(completion: (CLLocation?, CLPlacemark?) -> ()) {
        guard let location = locationManager.location else {
            completion(nil, nil)
            return
        }
        guard previousLocation == nil || previousLocation?.distanceFromLocation(location) > 1000 || previousPlacemark == nil else {
            return completion(location, previousPlacemark)
        }
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            self.previousPlacemark = placemarks?.first
            completion(location, placemarks?.first)
        }
    }


    // MARK: Private

    private weak var delegate: GeoLocationControllerDelegate!
    private var locationManager: CLLocationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    private var previousLocation: CLLocation?
    private var previousPlacemark: CLPlacemark?

    private func start() {
        delegate.geoLocationDidChangeAuthorizationStatus(authorized)
        if authorized {
            locationManager.startUpdatingLocation()
        }
    }

}

extension GeoLocationController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        start()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}
