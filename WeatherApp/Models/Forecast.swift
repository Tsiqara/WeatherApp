//
//  Forecast.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 22.02.25.
//

import Foundation

struct ForecastResponse : Codable {
    let cod: String
    let message: Int
    let cnt: Int?
    let list: [ForecastResponseData]
    let city: City
}


struct ForecastResponseData : Codable {
    let dt: TimeInterval
    let main: ForecastMain
    let weather: [Weather]
    let clouds: Cloud
    let wind: Wind
    let visibility: Int?
    let pop: Double
    let rain: Rain?
    let snow: Snow?
    let sys: System
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt
        case main
        case weather
        case clouds
        case wind
        case visibility
        case pop
        case rain
        case snow
        case sys
        case dtTxt = "dt_txt"
    }
}

struct ForecastMain : Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double?
    let tempMax: Double?
    let pressure: Int
    let seaLevel: Int?
    let grndLevel: Int?
    let humidity: Int
    let tempKf: Double?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}

struct Weather : Codable {
    let id: Int?
    let main: String
    let description: String?
    let icon: String?
}

struct Cloud : Codable {
    let all: Int?
}

struct Wind : Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Rain : Codable{
    let threeH: Double?
    
    private enum CodingKeys: String, CodingKey {
        case threeH = "3h"
    }
}

struct Snow: Codable {
    let threeH: Double?

    private enum CodingKeys: String, CodingKey {
        case threeH = "3h"
    }
}

struct System : Codable {
    let pod: String?
}

struct City : Codable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population: Int?
    let timezone: Int
    let sunrise: Int?
    let sunset: Int?
}

struct Coord : Codable {
    let lat: Double
    let lon: Double
}


struct Forecast : Codable {
    var description: String = "-"
    var icon: String = "-"
    var temp: Int = 0
    var time: String = "-"
    var day: String = "-"
    var date: Date?
    
    mutating func configure(with response: ForecastResponseData, city: City){
        self.description = response.weather[0].description ?? ""
        self.icon = response.weather[0].icon ?? ""
        self.temp = Int(response.main.temp.rounded())
        if let (date, day, time) = getDayAndTime(from: response.dt, timezoneOffset: city.timezone) {
            self.date = date
            self.day = day
            self.time = time
        }
    }
}

func getDayAndTime(from unixTimestamp: TimeInterval, timezoneOffset: Int) -> (Date, String, String)? {
    let date = Date(timeIntervalSince1970: unixTimestamp)
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
    
    dateFormatter.dateFormat = "EEEE"
    let dayOfWeek = dateFormatter.string(from: date).uppercased()
    
    dateFormatter.dateFormat = "HH:mm"
    let timeString = dateFormatter.string(from: date)
    
    return (date, dayOfWeek, timeString)
}
