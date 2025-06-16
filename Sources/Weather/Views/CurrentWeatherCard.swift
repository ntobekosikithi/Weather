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
            header

            // MARK: - Content
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let weather = viewModel.currentWeather {
                    WeatherContentView(weather: weather)
                } else if let error = viewModel.currentError {
                    ErrorView(error: error) {
                        Task { await viewModel.getCurrentWeather() }
                    }
                } else {
                    emptyStateView
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Text("Current Weather")
                .font(.headline)

            Spacer()

            Button(action: {
                Task { await viewModel.refreshWeather() }
            }) {
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
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Getting weather...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Weather Data")
                .font(.headline)
                .foregroundColor(.secondary)

            Button("Get Weather") {
                Task { await viewModel.getCurrentWeather() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
