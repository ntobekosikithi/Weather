//
//  LocationStatusView.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import SwiftUI

@available(iOS 15.0, *)
struct LocationStatusView: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        Group {
            if viewModel.isLocationNotDetermined {
                notDeterminedView
            } else if viewModel.isLocationDenied {
                deniedView
            }
        }
        .padding()
        .cornerRadius(12)
    }

    // MARK: - Not Determined View
    private var notDeterminedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.circle")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Location Permission Needed")
                .font(.headline)

            Text("Enable location access to get current weather conditions for your workouts")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Enable Location") {
                Task {
                    await viewModel.requestLocationAndFetchWeather()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .background(Color.blue.opacity(0.1))
    }

    // MARK: - Denied View
    private var deniedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.slash")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Location Access Denied")
                .font(.headline)
                .foregroundColor(.orange)

            Text("Please enable location access in Settings to get local weather conditions")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            .buttonStyle(.bordered)
        }
        .background(Color.orange.opacity(0.1))
    }
}
