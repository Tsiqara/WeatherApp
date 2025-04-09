//
//  WeatherConstants.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

enum WeatherConstants {
    static let weatherBackgroundColor: UIColor = UIColor(red: 75/255, green: 115/255, blue: 171/255, alpha: 1.0)
    static let weatherViewBackgroundColor = UIColor(red: 112/255, green: 162/255, blue: 226/255, alpha: 1.0)
    static let addCityBackgroundColor = UIColor(red: 125 / 255, green: 223 / 255, blue: 175 / 255, alpha: 1.0)
    //    UIColor(red: 97/255, green: 147/255, blue: 211/255, alpha: 1.0)
    //    UIColor(red: 56/255, green: 73/255, blue: 110/255, alpha: 1.0)
    static let weatherIconURLPrefix: String = "https://openweathermap.org/img/wn/"
    static let weatherIconURLSuffix: String = "@2x.png"
    
    static let addButtonSize: Double = 60
    
    static let minimumScale: CGFloat = 0.85
    static let maximumScale: CGFloat = 1.0
    static let minimumLineSpacing: CGFloat = 10
    static let horizontalInset: CGFloat = 40
    
    static let units: String = "metric"
    static let apiKey: String = ""
    
    //    TODO: write urls here
}
