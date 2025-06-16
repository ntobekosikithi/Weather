//
//  WeatherContentView.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import SwiftUI

@available(iOS 14.0, *)
struct WeatherContentView: View {
    let weather: Weather

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - City & Temperature
            cityAndTemperatureView

            // MARK: - Weather Details
            weatherDetailsView

            // MARK: - Workout Recommendation
            workoutRecommendationView
        }
        .padding()
    }

    // MARK: - City & Temperature
    private var cityAndTemperatureView: some View {
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
    }

    // MARK: - Weather Details
    private var weatherDetailsView: some View {
        HStack(spacing: 40) {
            weatherDetail(icon: "humidity", label: "Humidity", value: "\(weather.humidity)%")
            weatherDetail(icon: "wind", label: "Wind", value: "\(String(format: "%.1f", weather.windSpeed)) m/s")
        }
    }

    private func weatherDetail(icon: String, label: String, value: String) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }

    // MARK: - Workout Recommendation
    private var workoutRecommendationView: some View {
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
