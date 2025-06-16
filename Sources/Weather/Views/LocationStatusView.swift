//
//  LocationStatusView.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import SwiftUI

@available(iOS 15.0, *)
public struct LocationStatusView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    public var body: some View {
        if viewModel.isLocationNotDetermined {
            VStack(spacing: 8) {
                Text("Location Permission Needed")
                    .font(.headline)
                Text("Allow location access to get weather for your area")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Enable Location") {
                    viewModel.requestLocationPermission()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
        } else if viewModel.isLocationDenied {
            VStack(spacing: 8) {
                Text("Location Access Denied")
                    .font(.headline)
                    .foregroundColor(.orange)
                Text("Enable location in Settings to get local weather. Using default location.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
