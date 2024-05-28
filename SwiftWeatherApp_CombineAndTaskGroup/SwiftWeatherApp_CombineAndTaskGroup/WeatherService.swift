//
//  WeatherService.swift
//  SwiftWeatherApp_CombineAndTaskGroup
//
//  Created by Andrei Ionescu on 28.05.2024.
//

import Foundation
import Combine

enum HTTPError: LocalizedError {
    case statusCode
    case post
}

struct WeatherItem: Codable {
    let humidity: Int
    let feelsLike: Double
    let temp: Double
    let pressure: Int
    
    enum CodingKeys: String, CodingKey {
        case humidity
        case feelsLike = "feels_like"
        case temp
        case pressure
    }
}

struct WeatherItemData: Codable {
    let name: String
    let main: WeatherItem
}

class WeatherService {
    static let appID = "5bacd6fa07f81fd902ba80dad57201a5"
    private var cancellables = Set<AnyCancellable>()
    var cityWeather = PassthroughSubject<WeatherItemData?, Never>()
    var favoritesWeather = PassthroughSubject<[WeatherItemData?]?, Never>()
    
    func getWeather(for city: String) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(WeatherService.appID)")!
        URLSession.shared.dataTaskPublisher(for: url).tryMap { element -> Data in
            guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            return element.data
        }.decode(type: WeatherItemData.self, decoder: JSONDecoder()).sink {
            print("Received completion \($0)")
        } receiveValue: {[weak self] weatherItemData in
            self?.cityWeather.send(weatherItemData)
        }.store(in: &cancellables)
    }
    
    private func getWeatherAsync(for city: String) async -> WeatherItemData? {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(WeatherService.appID)") else {
            return nil
        }
        let request = URLRequest(url: url)
        
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error == nil {
                    if let incomingData = data {
                        do {
                            let decoder = JSONDecoder()
                            let itemData = try decoder.decode(WeatherItemData.self, from: incomingData)
                            continuation.resume(returning: itemData)
                        } catch {
                            continuation.resume(returning: nil)
                            print(error)
                        }
                    }
                } else {
                    continuation.resume(returning: nil)
                    print(error ?? "")
                }
            }.resume()
        }
    }
    
    private func getWeatherPublisher(for city: String) -> AnyPublisher<WeatherItemData, Never> {
        let pass = PassthroughSubject<WeatherItemData, Never>()
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(WeatherService.appID)")!
        URLSession.shared.dataTaskPublisher(for: url).tryMap() { element -> Data in
            guard let httpResponse = element.response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            return element.data
        }.decode(type: WeatherItemData.self, decoder: JSONDecoder()).sink {
            print("Received completion \($0)")
        } receiveValue: { weatherItemData in
            pass.send(weatherItemData)
            pass.send(completion: .finished)
        }.store(in: &cancellables)
        return pass.eraseToAnyPublisher()
    }
    
    //MARK: Main fetch Function
    func getWeatherForFavorites(names: [String], useCombine: Bool = true) {
        if useCombine {
            getFavoritesWeatherCombine(names: names)
        } else {
            Task { @MainActor in
                do {
                    let weatherItems = await getWeatherForFavoritesTaskGroup(names: names)
                    self.favoritesWeather.send(weatherItems)
                }
            }
        }
    }
    
    
    private func getFavoritesWeatherCombine(names: [String]) {
        names.map { getWeatherPublisher(for: $0).eraseToAnyPublisher() }
            .publisher
            .receive(on: RunLoop.main)
            .flatMap { $0 }
            .collect()
            .sink { [weak self] weatherItemsData in
                self?.favoritesWeather.send(weatherItemsData)
            }.store(in: &cancellables)
    }
    
    private func getWeatherForFavoritesTaskGroup(names: [String]) async -> [WeatherItemData?]? {
        let groupItems: [WeatherItemData?]? = await withTaskGroup(of: WeatherItemData?.self, returning: [WeatherItemData?]?.self) { [weak self] group in
            var groupItems = [WeatherItemData?]()
            
            for name in names {
                group.addTask { [weak self] in
                    await self?.getWeatherAsync(for: name)
                }
            }
            
            for await result in group where result != nil {
                groupItems.append(result)
            }
            
            return groupItems
        }
        return groupItems
    }
}
