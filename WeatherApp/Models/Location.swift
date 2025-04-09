//
//  Location.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import Foundation

struct LocationResponse: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}

struct Location {
    var name: String
    var lat: Double?
    var lon: Double?
    
    init(name: String, lat: Double? = nil, lon: Double? = nil) {
        self.name = name
        self.lat = lat
        self.lon = lon
    }
}

