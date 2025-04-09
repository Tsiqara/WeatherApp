//
//  Service.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 22.02.25.
//

import Foundation

final class Service {
    typealias ForecastDataCompletion = (Result<[ForecastSection], WeatherServiceError>) -> Void
    
    private func createWeatherURL(path: String, lat: Double, lon: Double) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = path
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: lat.description),
            URLQueryItem(name: "lon", value: lon.description),
            URLQueryItem(name: "appid", value: WeatherConstants.apiKey),
            URLQueryItem(name: "units", value: WeatherConstants.units),
        ]
        return urlComponents.url!
    }
    
    func load5DayForecastData(
        latitude: Double = 51.5073219,
        longitude: Double = -0.1276474,
        completion: @escaping ForecastDataCompletion
    ) {
        let url = createWeatherURL(path: "/data/2.5/forecast", lat: latitude, lon: longitude)
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(.badConnection))
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200, let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(ForecastResponse.self, from: data)
                            var forecastSections: [ForecastSection] = []
                            var forecasts: [Forecast] = []
                            for responseData in result.list {
                                var forecast = Forecast()
                                forecast.configure(with: responseData, city: result.city)
                                forecasts.append(forecast)
                            }
                            forecastSections = groupForecastsIntoSections(forecasts: forecasts)
                            if forecastSections.isEmpty {
                                completion(.failure(.cityNotFound))
                            } else {
                                completion(.success(forecastSections))
                            }
                        } catch let error as DecodingError{
                            switch error {
                            case .keyNotFound(let key, _):
                                completion(.failure(.decodingError("Missing key: \(key.stringValue)")))
                            case .typeMismatch(let type, _):
                                completion(.failure(.decodingError("Type mismatch for \(type)")))
                            case .valueNotFound(let value, _):
                                completion(.failure(.decodingError("Missing value for \(value)")))
                            case .dataCorrupted:
                                completion(.failure(.decodingError("Corrupted data")))
                            @unknown default:
                                completion(.failure(.decodingError("Unknown decoding error")))
                            }
                        }catch {
                            completion(.failure(.invalidResponse))
                        }
                    } else if httpResponse.statusCode == 401 {
                        completion(.failure(.notAuthorized))
                    } else if httpResponse.statusCode == 404 {
                        completion(.failure(.pageNotFound))
                    } else {
                        completion(.failure(.invalidRequest))
                    }
                } else {
                    completion(.failure(.invalidResponse))
                }
            }
        }
        task.resume()
    }
}


extension Service {
    typealias WeatherDataCompletion = (Result<CurrentWeather, WeatherServiceError>) -> Void
    
    func loadCurrentWeatherData(
        latitude: Double = 51.5073219,
        longitude: Double = -0.1276474,
        completion: @escaping WeatherDataCompletion
    ) {
        let url = createWeatherURL(path: "/data/2.5/weather", lat: latitude, lon: longitude)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(.badConnection))
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200, let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(CurrentWeatherResponse.self, from: data)
                            var weather = CurrentWeather()
                            weather.configure(with: result)
                            completion(.success(weather))
                        } catch let error as DecodingError{
                            switch error {
                            case .keyNotFound(let key, _):
                                completion(.failure(.decodingError("Missing key: \(key.stringValue)")))
                            case .typeMismatch(let type, _):
                                completion(.failure(.decodingError("Type mismatch for \(type)")))
                            case .valueNotFound(let value, _):
                                completion(.failure(.decodingError("Missing value for \(value)")))
                            case .dataCorrupted:
                                completion(.failure(.decodingError("Corrupted data")))
                            @unknown default:
                                completion(.failure(.decodingError("Unknown decoding error")))
                            }
                        }catch {
                            completion(.failure(.invalidResponse))
                        }
                    } else if httpResponse.statusCode == 401 {
                        completion(.failure(.notAuthorized))
                    } else if httpResponse.statusCode == 404 {
                        completion(.failure(.pageNotFound))
                    } else {
                        completion(.failure(.invalidRequest))
                    }
                } else {
                    completion(.failure(.invalidResponse))
                }
            }
        }
        task.resume()
    }
}

extension Service {
    typealias LocationDataCompletion = (Result<[LocationResponse], WeatherServiceError>) -> Void
    
    private func createGeocodingURL(city: String) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/geo/1.0/direct"
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: WeatherConstants.apiKey),
        ]
        return urlComponents.url!
    }
    
    func loadLocationData(
        city: String,
        completion: @escaping LocationDataCompletion
    ) {
        let url = createGeocodingURL(city: city)
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(.badConnection))
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200, let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode([LocationResponse].self, from: data)
                            if result.isEmpty {
                                completion(.failure(.cityNotFound))
                            } else {
                                completion(.success(result))
                            }
                        } catch let error as DecodingError{
                            switch error {
                            case .keyNotFound(let key, _):
                                completion(.failure(.decodingError("Missing key: \(key.stringValue)")))
                            case .typeMismatch(let type, _):
                                completion(.failure(.decodingError("Type mismatch for \(type)")))
                            case .valueNotFound(let value, _):
                                completion(.failure(.decodingError("Missing value for \(value)")))
                            case .dataCorrupted:
                                completion(.failure(.decodingError("Corrupted data")))
                            @unknown default:
                                completion(.failure(.decodingError("Unknown decoding error")))
                            }
                        }catch {
                            completion(.failure(.invalidResponse))
                        }
                    } else if httpResponse.statusCode == 401 {
                        completion(.failure(.notAuthorized))
                    } else if httpResponse.statusCode == 404 {
                        completion(.failure(.pageNotFound))
                    } else {
                        completion(.failure(.invalidRequest))
                    }
                } else {
                    completion(.failure(.invalidResponse))
                }
            }
        }
        task.resume()
    }
}


//extension Service {
//    private func getCachePolicy() -> URLRequest.CachePolicy {
//        var cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
//        let lastDate = UserDefaults.standard.object(forKey: "lastCacheDate") as? Date ?? Date()
//        let currentDate = Date()
//        let timeInterval = currentDate.timeIntervalSince(lastDate)
//        let hoursPassed = timeInterval / 3600
//        
//        if hoursPassed >= 1 {
//            UserDefaults.standard.set(currentDate, forKey: "lastCacheDate")
//            cachePolicy = .reloadIgnoringLocalCacheData
//        }
//        print(cachePolicy.rawValue.description)
//        return cachePolicy
//    }
//}

enum WeatherServiceError: LocalizedError {
    case invalidResponse
    case badConnection
    case invalidRequest
    case notAuthorized
    case cityNotFound
    case pageNotFound
    case locationNotShared
    case currentLocationNotAvailable
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid Response"
        case .badConnection:
            return "Bad Connection"
        case .invalidRequest:
            return "Invalid Request"
        case .notAuthorized:
            return "Not Authorized"
        case .cityNotFound:
            return "City with this name was not found"
        case .pageNotFound:
            return "Page not found"
        case .locationNotShared:
            return "Location not shared."
        case .currentLocationNotAvailable:
            return "Current location not available."
        case .decodingError(let message):
            return "Decoding Error \(message)"
        }
    }
}
