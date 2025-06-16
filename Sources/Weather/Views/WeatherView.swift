//
//  WeatherView.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//


import SwiftUI

@available(iOS 15.0, *)
public struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    public init(viewModel: WeatherViewModel){
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                LocationStatusView(viewModel: viewModel)

                if viewModel.isLocationAuthorized {
                    CurrentWeatherCard(viewModel: viewModel)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Weather")
            .task {
                // Only auto-fetch if location is already authorized
                if viewModel.isLocationAuthorized && viewModel.currentWeather == nil {
                    await viewModel.getCurrentWeather()
                }
            }
        }
    }
}
