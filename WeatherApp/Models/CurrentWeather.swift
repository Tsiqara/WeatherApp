//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import Foundation

struct CurrentWeatherResponse: Decodable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: ForecastMain
    let visibility: Int?
    let wind: Wind
    let rain: CurrentRain?
    let snow: CurrentSnow?
    let clouds: Cloud
    let dt: Int
    let sys: CurrentWeatherSystem
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}


struct CurrentWeatherSystem : Decodable {
    let type: Int
    let id: Int
    let message: String?
    let country: String
    let sunrise: Int?
    let sunset: Int?
}


struct CurrentRain : Decodable {
    let oneH: Double?
    
    private enum CodingKeys: String, CodingKey {
        case oneH = "1h"
    }
}

struct CurrentSnow : Decodable {
    let oneH: Double?
    
    private enum CodingKeys: String, CodingKey {
        case oneH = "1h"
    }
}

struct CurrentWeather : Decodable {
    var city: String = "--"
    var country: String = "--"
    var temperature: String = "--"
    var mainDescription: String = "Unknown"
    var cloudiness: String = "-"
    var humidity: String = "-"
    var windSpeed: String = "-"
    var windDirection: String = "-"
    var icon: String = "-"
    
    mutating func configure(with response: CurrentWeatherResponse){
        self.city = response.name
        self.country = getCountryName(from: response.sys.country) ?? ""
        self.temperature = Int(response.main.temp.rounded()).description + "°C"
        self.mainDescription = response.weather[0].main
        self.cloudiness = (response.clouds.all?.description ?? "-") + "%"
        self.humidity = response.main.humidity.description + "%"
        self.windSpeed = convertToKmh(from:  response.wind.speed)
        self.windDirection = getWindDirection(from: response.wind.deg)
        self.icon = response.weather[0].icon ?? "-"
    }
}


func getCountryName(from countryCode: String) -> String?{
    let locale = Locale(identifier: "en_UK")
    return locale.localizedString(forRegionCode: countryCode)
}

func getWindDirection(from degrees: Int) -> String{
    let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N"]
    
    let index = Int((Double(degrees) / 22.5) + 0.5) % 16
    return directions[index]
}

func convertToKmh(from metersPerSecond: Double) -> String {
    guard metersPerSecond >= 0 else {return "-"}
    let speed = metersPerSecond * 3.6
    let finalValue = (speed * 1000).rounded() / 1000
    return finalValue.description + " km/h"
}
