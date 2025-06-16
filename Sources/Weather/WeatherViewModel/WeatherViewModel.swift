//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import Foundation
import CoreLocation
import Utilities

@available(iOS 14.0, *)
@MainActor
public final class WeatherViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public private(set) var weatherState: LoadingState<Weather> = .idle
    @Published public private(set) var locationManager = LocationManager()
    @Published public private(set) var isRefreshing = false
    
    // MARK: - Dependencies
    private let weatherRepository: WeatherRepository
    private let logger: Logger
    
    // MARK: - Default coordinates (New York as fallback)
    private let defaultCoordinates = (lat: 40.7128, lon: -74.0060)
    private let defaultCityName = "New York"
    
    // MARK: - Initialization
    
    public init(
        weatherRepository: WeatherRepository,
        logger: Logger = LoggerImplementation()
    ) {
        self.weatherRepository = weatherRepository
        self.logger = logger
        
        setupLocationObserver()
    }
    
    // MARK: - Public Methods

    public func getCurrentWeather() async {
        guard !isRefreshing else { return }
        
        weatherState = .loading
        isRefreshing = true
        
        defer { isRefreshing = false }
        
        do {
            logger.info("Starting weather fetch process")
            
            let coordinates = try await getCurrentCoordinates()
            let weather = try await weatherRepository.getWeatherForCoordinates(
                lat: coordinates.lat,
                lon: coordinates.lon
            )
            
            weatherState = .loaded(weather)
            logger.info("Successfully loaded weather for current location")
            
        } catch {
            logger.error("Failed to get current weather: \(error)")
            weatherState = .error(error)
        }
    }

    public func refreshWeather() async {
        logger.info("Refreshing weather data")
        await getCurrentWeather()
    }

    public func requestLocationPermission() {
        logger.info("Requesting location permission")
        locationManager.requestLocation()
    }
    
    // MARK: - Private Methods
    
    private func setupLocationObserver() {
        // Could be enhanced to automatically refresh weather when location changes significantly
        logger.info("Location observer setup completed")
    }
    
    private func getCurrentCoordinates() async throws -> (lat: Double, lon: Double) {
        // Try to get current location
        if locationManager.location == nil &&
           (locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways) {
            
            locationManager.requestLocation()
            
            // Wait for location update
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        }
        
        if let location = locationManager.location {
            logger.info("Using current location coordinates")
            return (lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        } else {
            logger.info("Using fallback coordinates (\(defaultCityName))")
            return defaultCoordinates
        }
    }
}

// MARK: - Computed Properties

@available(iOS 14.0, *)
public extension WeatherViewModel {

    var isLocationAuthorized: Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse ||
               locationManager.authorizationStatus == .authorizedAlways
    }

    var isLocationDenied: Bool {
        return locationManager.authorizationStatus == .denied ||
               locationManager.authorizationStatus == .restricted
    }

    var isLocationNotDetermined: Bool {
        return locationManager.authorizationStatus == .notDetermined
    }

    var currentWeather: Weather? {
        return weatherState.data
    }

    var currentError: Error? {
        return weatherState.error
    }

    var isLoading: Bool {
        return weatherState.isLoading
    }

    var locationStatusDescription: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Location permission needed for local weather"
        case .denied, .restricted:
            return "Location access denied. Using default location."
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location access granted"
        @unknown default:
            return "Unknown location status"
        }
    }
}

// MARK: - Configuration

@available(iOS 14.0, *)
public extension WeatherViewModel {
    static func configured(with repository: WeatherRepository) -> WeatherViewModel {
        return WeatherViewModel(weatherRepository: repository)
    }
}
