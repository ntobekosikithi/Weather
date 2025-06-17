//
//  MockWeatherRepository.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/17.
//
import Testing
@testable import Weather

@MainActor
final class MockWeatherRepository: WeatherRepository, @unchecked Sendable {
    var mockWeather: Weather?
    var shouldThrowError = false
    var shouldDelay = false
    var getWeatherCallCount = 0
    var lastCoordinates: (lat: Double, lon: Double)?
    
    func getWeatherForCoordinates(lat: Double, lon: Double) async throws -> Weather {
        getWeatherCallCount += 1
        lastCoordinates = (lat: lat, lon: lon)
        
        if shouldDelay {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        if shouldThrowError {
            throw WeatherError.networkError("Mock error")
        }
        
        guard let weather = mockWeather else {
            throw WeatherError.invalidResponse
        }
        
        return weather
    }
}
