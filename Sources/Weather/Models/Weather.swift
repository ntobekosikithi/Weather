//
//  Weather.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import Foundation

public struct Weather: Codable, Equatable, Sendable {
    public let temperature: Double
    public let description: String
    public let cityName: String
    public let humidity: Int
    public let windSpeed: Double
    public let icon: String
    
    public init(
        temperature: Double,
        description: String,
        cityName: String,
        humidity: Int,
        windSpeed: Double,
        icon: String
    ) {
        self.temperature = temperature
        self.description = description
        self.cityName = cityName
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.icon = icon
    }
    
    public var temperatureInFahrenheit: Double {
        return (temperature * 9/5) + 32
    }
    
    public var systemIconName: String {
        switch icon {
        case "01d", "01n": return "sun.max"
        case "02d", "02n": return "cloud.sun"
        case "03d", "03n", "04d", "04n": return "cloud"
        case "09d", "09n": return "cloud.drizzle"
        case "10d", "10n": return "cloud.rain"
        case "11d", "11n": return "cloud.bolt"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog"
        default: return "questionmark"
        }
    }
    
    public var workoutRecommendation: String {
        switch icon.prefix(2) {
        case "01": return "Perfect weather for outdoor workouts!"
        case "02", "03": return "Good conditions for outdoor activities"
        case "04": return "Cloudy but suitable for outdoor exercise"
        case "09", "10": return "Consider indoor workouts today"
        case "11": return "Stay indoors - thunderstorm conditions"
        case "13": return "Great for winter sports or indoor training"
        case "50": return "Limited visibility - indoor workouts recommended"
        default: return "Check conditions before heading out"
        }
    }
}
