//
//  WeatherContentView.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import SwiftUI

@available(iOS 14.0, *)
public struct WeatherContentView: View {
    let weather: Weather

    public var body: some View {
        VStack(spacing: 16) {
            // City and Temperature
            VStack(spacing: 8) {
                Text(weather.cityName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack(spacing: 16) {
                    Image(systemName: weather.systemIconName)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("\(Int(weather.temperature))°C")
                            .font(.system(size: 36, weight: .light))
                        
                        Text("\(Int(weather.temperatureInFahrenheit))°F")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(weather.description)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Details
            HStack(spacing: 40) {
                VStack {
                    Image(systemName: "humidity")
                        .font(.title3)
                        .foregroundColor(.blue)
                    Text("Humidity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(weather.humidity)%")
                        .font(.headline)
                }
                
                VStack {
                    Image(systemName: "wind")
                        .font(.title3)
                        .foregroundColor(.blue)
                    Text("Wind")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", weather.windSpeed)) m/s")
                        .font(.headline)
                }
            }
            
            // Workout Recommendation
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "figure.run")
                        .foregroundColor(.green)
                    Text("Workout Recommendation")
                        .font(.headline)
                }
                
                Text(weather.workoutRecommendation)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        }
    }
}
