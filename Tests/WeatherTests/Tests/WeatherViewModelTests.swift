//
//  WeatherViewModelTests.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/17.
//

import Testing
import CoreLocation
@testable import Weather
@testable import Utilities

@Suite("WeatherViewModel Tests")

@MainActor
struct WeatherViewModelTests {
    
    // MARK: - Test Properties
    
    private var mockRepository: MockWeatherRepository
    private var mockLocationManager: MockLocationManager
    private var mockLogger: MockLogger
    private var viewModel: WeatherViewModel

    init() {
        self.mockRepository = MockWeatherRepository()
        self.mockLocationManager = MockLocationManager()
        self.mockLogger = MockLogger()
        self.viewModel = WeatherViewModel(
            weatherRepository: mockRepository,
            locationManager: mockLocationManager,
            logger: mockLogger
        )
    }
    
    
    // MARK: - Location Authorization Tests
    
    @Test("Location authorization properties work correctly")
    func testLocationAuthorizationProperties() {
        // Test not determined
        mockLocationManager.authorizationStatus = .notDetermined
        #expect(viewModel.isLocationNotDetermined)
        #expect(!viewModel.isLocationAuthorized)
        #expect(!viewModel.isLocationDenied)
        
        // Test authorized when in use
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        #expect(!viewModel.isLocationNotDetermined)
        #expect(viewModel.isLocationAuthorized)
        #expect(!viewModel.isLocationDenied)
        
        // Test authorized always
        mockLocationManager.authorizationStatus = .authorizedAlways
        #expect(!viewModel.isLocationNotDetermined)
        #expect(viewModel.isLocationAuthorized)
        #expect(!viewModel.isLocationDenied)
        
        // Test denied
        mockLocationManager.authorizationStatus = .denied
        #expect(!viewModel.isLocationNotDetermined)
        #expect(!viewModel.isLocationAuthorized)
        #expect(viewModel.isLocationDenied)
        
        // Test restricted
        mockLocationManager.authorizationStatus = .restricted
        #expect(!viewModel.isLocationNotDetermined)
        #expect(!viewModel.isLocationAuthorized)
        #expect(viewModel.isLocationDenied)
    }
    
    @Test("Location status description returns correct messages")
    func testLocationStatusDescription() {
        mockLocationManager.authorizationStatus = .notDetermined
        #expect(viewModel.locationStatusDescription == "Location permission needed for local weather")
        
        mockLocationManager.authorizationStatus = .denied
        #expect(viewModel.locationStatusDescription == "Location access denied. Enable location to get weather.")
        
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        #expect(viewModel.locationStatusDescription == "Location access granted")
        
        mockLocationManager.authorizationStatus = .authorizedAlways
        #expect(viewModel.locationStatusDescription == "Location access granted")
    }
    
    // MARK: - Weather Fetching Tests
    
    @Test("Get current weather with no location authorization fails")
    func testGetCurrentWeatherNoAuthorization() async {
        // Given
        mockLocationManager.authorizationStatus = .denied
        
        // When
        await viewModel.getCurrentWeather()
        
        // Then
        #expect(viewModel.weatherState.error != nil)
        #expect(viewModel.currentWeather == nil)
        #expect(!viewModel.isRefreshing)
        #expect(!viewModel.isLoading)
        #expect(mockRepository.getWeatherCallCount == 0)
    }
    
    @Test("Get current weather with no location available fails")
    func testGetCurrentWeatherNoLocationAvailable() async {
        // Given
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        mockLocationManager.location = nil
        
        // When
        await viewModel.getCurrentWeather()
        
        // Then
        #expect(viewModel.weatherState.error != nil)
        #expect(viewModel.currentWeather == nil)
        #expect(!viewModel.isRefreshing)
        #expect(mockRepository.getWeatherCallCount == 0)
    }
    
    @Test("Get current weather with location succeeds")
    func testGetCurrentWeatherWithLocationSucceeds() async {
        // Given
        let mockLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        let mockWeather = Weather(
            temperature: 25.0,
            description: "Clear sky",
            cityName: "New York",
            humidity: 60,
            windSpeed: 5.0,
            icon: "01d"
        )
        
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        mockLocationManager.location = mockLocation
        mockRepository.mockWeather = mockWeather
        
        // When
        await viewModel.getCurrentWeather()
        
        // Then
        #expect(viewModel.currentWeather == mockWeather)
        #expect(viewModel.weatherState.error == nil)
        #expect(!viewModel.isRefreshing)
        #expect(mockRepository.getWeatherCallCount == 1)
        #expect(mockRepository.lastCoordinates?.lat == 40.7128)
        #expect(mockRepository.lastCoordinates?.lon == -74.0060)
    }
    
    @Test("Get current weather with repository error fails gracefully")
    func testGetCurrentWeatherWithRepositoryError() async {
        // Given
        let mockLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        mockLocationManager.location = mockLocation
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.getCurrentWeather()
        
        // Then
        #expect(viewModel.currentWeather == nil)
        #expect(viewModel.weatherState.error != nil)
        #expect(!viewModel.isRefreshing)
        #expect(mockRepository.getWeatherCallCount == 1)
    }
    
    @Test("Prevent multiple concurrent weather requests")
    func testPreventConcurrentRequests() async {
        // Given
        let mockLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        mockLocationManager.location = mockLocation
        mockRepository.shouldDelay = true
        
        // When - Start two concurrent requests
        async let firstRequest: () = viewModel.getCurrentWeather()
        async let secondRequest: () = viewModel.getCurrentWeather()
        
        await firstRequest
        await secondRequest
        
        // Then - Only one request should have been made
        #expect(mockRepository.getWeatherCallCount == 1)
    }
    
    // MARK: - Refresh Weather Tests
    
    @Test("Refresh weather calls getCurrentWeather")
    func testRefreshWeather() async {
        // Given
        let mockLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        let mockWeather = Weather(
            temperature: 25.0,
            description: "Clear sky",
            cityName: "New York",
            humidity: 60,
            windSpeed: 5.0,
            icon: "01d"
        )
        
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        mockLocationManager.location = mockLocation
        mockRepository.mockWeather = mockWeather
        
        // When
        await viewModel.refreshWeather()
        
        // Then
        #expect(viewModel.currentWeather == mockWeather)
        #expect(mockRepository.getWeatherCallCount == 1)
        #expect(mockLogger.infoMessages.contains {$0.contains("Refreshing weather data")})
    }
    
    // MARK: - Request Location and Fetch Weather Tests
    
    @Test("Request location and fetch weather triggers location request")
    func testRequestLocationAndFetchWeather() async {
        // Given
        let mockLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        let mockWeather = Weather(
            temperature: 25.0,
            description: "Clear sky",
            cityName: "New York",
            humidity: 60,
            windSpeed: 5.0,
            icon: "01d"
        )
        
        // Set up for successful flow
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        mockRepository.mockWeather = mockWeather
        
        // When
        await viewModel.requestLocationAndFetchWeather()
        
        // Then
        #expect(mockLogger.infoMessages.contains {$0.contains("Requesting location permission and fetching weather")})
        
        // Simulate location being set after request
        mockLocationManager.location = mockLocation
        await viewModel.getCurrentWeather()
        
        #expect(viewModel.currentWeather == mockWeather)
    }

}

