//
//  CurrentWeatherCard.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import SwiftUI

@available(iOS 15.0, *)
struct CurrentWeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Weather")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.refreshWeather()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(viewModel.isRefreshing ? 360 : 0))
                        .animation(
                            viewModel.isRefreshing ?
                                .linear(duration: 1).repeatForever(autoreverses: false) :
                                .default,
                            value: viewModel.isRefreshing
                        )
                }
                .disabled(viewModel.isLoading)
            }
            
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Getting weather...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            } else if let weather = viewModel.currentWeather {
                WeatherContentView(weather: weather)
            } else if let error = viewModel.currentError {
                ErrorView(error: error) {
                    Task {
                        await viewModel.getCurrentWeather()
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "cloud.sun")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No Weather Data")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("Get Weather") {
                        Task {
                            await viewModel.getCurrentWeather()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
