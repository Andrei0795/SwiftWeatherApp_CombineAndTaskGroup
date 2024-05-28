//
//  WeatherTableViewModel.swift
//  SwiftWeatherApp_CombineAndTaskGroup
//
//  Created by Andrei Ionescu on 28.05.2024.
//

import Foundation
import Combine

enum WeatherScreenType {
    case favorites
    case single
}

class WeatherTableViewModel {
    var cancellables = Set<AnyCancellable>()
    var weatherService: WeatherService!
    var updateTable = PassthroughSubject<Void, Never>()
    var weatherItems = [WeatherItemData]()
    var shouldUseCombine: Bool
    
    var status: String {
        if type == .favorites {
            return "Your favorites"
        } else {
            return "Weather for " + (cityName ?? "")
        }
    }
    
    private var favoriteNames: [String] {
        let ns = UserDefaults.standard
        guard let savedArray = ns.array(forKey: "favorites") as? [String] else {
            return []
        }
        return savedArray
    }
    
    var type: WeatherScreenType
    var cityName: String?
    
    init(type: WeatherScreenType, shouldUseCombine: Bool = true) {
        self.shouldUseCombine = shouldUseCombine
        self.weatherService = WeatherService()
        self.type = type
        
        weatherService.favoritesWeather.receive(on: DispatchQueue.main).sink { [weak self] items in
            self?.weatherItems = items?.compactMap({
                $0
            }) ?? []
            self?.updateTable.send()
        }.store(in: &cancellables)
        
        weatherService.cityWeather.receive(on: DispatchQueue.main).sink { [weak self] item in
            if let item = item {
                self?.weatherItems.append(item)
            }
            self?.updateTable.send()
        }.store(in: &cancellables)
    }
    
    func getWeather() {
        if type == .single {
            if let name = cityName {
                weatherService.getWeather(for: name)
            }
        } else {
            weatherService.getWeatherForFavorites(names: favoriteNames, useCombine: shouldUseCombine)
        }
    }
    
    func weatherTempForItem(at indexPath: IndexPath) -> String {
        return String(format:"%.1f", weatherItems[indexPath.row].main.temp - 273.15)
    }
    
    func weatherFeelsLikeTempForItem(at indexPath: IndexPath) -> String {
        return String(format:"%.1f", weatherItems[indexPath.row].main.feelsLike - 273.15)
    }
    
    func itemIsInFavorites(name: String) -> Bool {
        return favoriteNames.contains(name)
    }
}
