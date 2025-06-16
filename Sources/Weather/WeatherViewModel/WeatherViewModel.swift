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
            
            guard let coordinates = try await getCurrentCoordinates() else {
                weatherState = .error(WeatherError.locationNotFound)
                return
            }
            
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
    
    public func requestLocationAndFetchWeather() async {
        logger.info("Requesting location permission and fetching weather")
        locationManager.requestLocation()
        
        // Wait for location update
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        await getCurrentWeather()
    }

    // MARK: - Private Methods
    
    private func setupLocationObserver() {
        // Could be enhanced to automatically refresh weather when location changes significantly
        logger.info("Location observer setup completed")
    }
    
    private func getCurrentCoordinates() async throws -> (lat: Double, lon: Double)? {
        guard isLocationAuthorized else {
            logger.info("Location not authorized")
            return nil
        }
        
        if locationManager.location == nil {
            locationManager.requestLocation()
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        }
        
        guard let location = locationManager.location else {
            logger.info("No location available")
            return nil
        }
        
        logger.info("Using current location coordinates")
        return (lat: location.coordinate.latitude, lon: location.coordinate.longitude)
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
            return "Location access denied. Enable location to get weather."
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
