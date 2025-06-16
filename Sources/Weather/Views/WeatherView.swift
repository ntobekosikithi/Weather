//
//  WeatherView.swift
//  Weather
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//


import SwiftUI

@available(iOS 115.0, *)
public struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    public init(viewModel: WeatherViewModel){
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Location Permission Status
                LocationStatusView(viewModel: viewModel)
                
                // Current Weather Card
                CurrentWeatherCard(viewModel: viewModel)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Weather")
            .task {
                if viewModel.currentWeather == nil {
                    await viewModel.getCurrentWeather()
                }
            }
        }
    }
}
