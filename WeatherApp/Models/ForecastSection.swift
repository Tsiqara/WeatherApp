//
//  ForecastSection.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

final class ForecastSection {
    var header: ForecastHeaderModel?
    var forecasts: [Forecast]
    
    var day: String {header?.day ?? ""}
    
    
    init(header: ForecastHeaderModel?, forecasts: [Forecast]) {
        self.header = header
        self.forecasts = forecasts
    }
}


func groupForecastsIntoSections(forecasts: [Forecast]) -> [ForecastSection] {
    let sortedForecasts = forecasts.sorted { forecast1, forecast2 in
        guard let date1 = forecast1.date, let date2 = forecast2.date else {
            return false // Keep original order if dates are missing
        }
        return date1 < date2
    }
    
    var groupedForecasts = [String: [Forecast]]()
    
    for forecast in sortedForecasts {
        groupedForecasts[forecast.day, default: []].append(forecast)
    }
    
    var orderedDays: [String] = []
    for forecast in sortedForecasts {
        if !orderedDays.contains(forecast.day) {
            orderedDays.append(forecast.day)
        }
    }
    
    return orderedDays.map { day in
        let forecastsForDay = groupedForecasts[day] ?? []
        let header = ForecastHeaderModel(day: day)
        return ForecastSection(header: header, forecasts: forecastsForDay)
    }
}
