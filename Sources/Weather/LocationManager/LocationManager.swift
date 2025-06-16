//
//  LocationManager.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import Foundation
import CoreLocation

@available(iOS 14.0, *)
public class LocationManager: NSObject, ObservableObject {
    @Published public private(set) var location: CLLocation?
    @Published public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public private(set) var locationError: Error?
    
    private let locationManager = CLLocationManager()
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
    }
    public func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            locationError = LocationError.permissionDenied
        @unknown default:
            break
        }
    }
}


// MARK: - CLLocationManagerDelegate
@available(iOS 14.0, *)
extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
        self.locationError = nil
    }

    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       self.locationError = error
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}


enum LocationError: Error, LocalizedError {
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied. Please enable location access in Settings."
        }
    }
}


