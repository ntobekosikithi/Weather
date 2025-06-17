//
//  MockLocationManager.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/17.
//

import Foundation
import CoreLocation
import Combine
@testable import Weather

final class MockLocationManager: LocationManager, @unchecked Sendable {
    var mockLocation: CLLocation?
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var mockLocationError: Error?
    var requestLocationCallCount = 0
    
    override var location: CLLocation? {
        get { mockLocation }
        set { mockLocation = newValue }
    }
    
    override var authorizationStatus: CLAuthorizationStatus {
        get { mockAuthorizationStatus }
        set { mockAuthorizationStatus = newValue }
    }
    
    override var locationError: Error? {
        get { mockLocationError }
        set { mockLocationError = newValue }
    }
    
    override func requestLocation() {
        requestLocationCallCount += 1
        // Simulate different authorization flows
        switch mockAuthorizationStatus {
        case .notDetermined:
            // Simulate permission granted
            mockAuthorizationStatus = .authorizedWhenInUse
        case .authorizedWhenInUse, .authorizedAlways:
            // Simulate location update if we have a mock location
            if let location = mockLocation {
                // Trigger location update
                Task { @MainActor in
                    self.location = location
                    self.locationError = nil
                }
            }
        case .denied, .restricted:
            // Simulate error
            mockLocationError = LocationError.permissionDenied
        @unknown default:
            break
        }
    }
    
    // Helper methods for testing
    func simulateLocationUpdate(_ location: CLLocation) {
        mockLocation = location
        locationError = nil
    }
    
    func simulateLocationError(_ error: Error) {
        mockLocationError = error
        mockLocation = nil
    }
    
    func simulateAuthorizationChange(_ status: CLAuthorizationStatus) {
        mockAuthorizationStatus = status
    }
}
