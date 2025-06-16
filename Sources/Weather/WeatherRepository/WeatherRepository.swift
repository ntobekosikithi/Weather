//
//  WeatherRepository.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import Foundation
import Utilities

@available(iOS 13.0.0, *)
public protocol WeatherRepository: Sendable {
    func getWeatherForCoordinates(lat: Double, lon: Double) async throws -> Weather
}

@available(iOS 13.0, *)
public final class WeatherRepositoryImplementation: WeatherRepository {
    private let service: Service
    private let logger: Logger
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let apiKey: String
    
    
    public init(
        service: Service = ServiceImplementation(),
        apiKey: String,
        logger: Logger = LoggerImplementation()
    ) {
        self.service = service
        self.apiKey = apiKey
        self.logger = logger
    }
    
    // MARK: - Public Methods
    
    public func getWeatherForCoordinates(lat: Double, lon: Double) async throws -> Weather {
        logger.info("Fetching weather for coordinates: \(lat), \(lon)")
        
        guard !apiKey.isEmpty else {
            throw WeatherError.apiKeyMissing
        }
        
        let url = "\(baseURL)/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        
        do {
            let response: OpenWeatherResponse = try await service.get(url: url)
            let weather = convertToWeather(response)
            logger.info("Successfully fetched weather")
            return weather
        } catch {
            logger.error("Failed to fetch weather: \(error)")
            throw WeatherError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func convertToWeather(_ response: OpenWeatherResponse) -> Weather {
        let condition = response.weather.first ?? OpenWeatherResponse.WeatherCondition(
            main: "Unknown",
            description: "Unknown",
            icon: "01d"
        )
        
        return Weather(
            temperature: response.main.temp,
            description: condition.description.capitalized,
            cityName: response.name.isEmpty ? "Unknown Location" : response.name,
            humidity: response.main.humidity,
            windSpeed: response.wind.speed,
            icon: condition.icon
        )
    }
}
