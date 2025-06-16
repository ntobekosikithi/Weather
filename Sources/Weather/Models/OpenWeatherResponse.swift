//
//  OpenWeatherResponse.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//
import Foundation

internal struct OpenWeatherResponse: Codable {
    let main: Main
    let weather: [WeatherCondition]
    let wind: Wind
    let name: String
    
    struct Main: Codable {
        let temp: Double
        let humidity: Int
    }
    
    struct WeatherCondition: Codable {
        let main: String
        let description: String
        let icon: String
    }
    
    struct Wind: Codable {
        let speed: Double
    }
}

public enum WeatherError: Error, LocalizedError {
    case locationNotFound
    case apiKeyMissing
    case invalidResponse
    case networkError(String)
    
    public var errorDescription: String? {
        switch self {
        case .locationNotFound:
            return "Location not found"
        case .apiKeyMissing:
            return "Weather API key is missing"
        case .invalidResponse:
            return "Invalid response from weather service"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
