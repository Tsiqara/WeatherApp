//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 22.02.25.
//

import UIKit

final class WeatherCollectionViewCell: UICollectionViewCell {
    let icon = UIImageView()
    private let locationLabel = UILabel()
    private let temperatureLabel = UILabel()
    
    private let attributesStack = UIStackView()
    private let cloudinessView = WeatherAtrributeView()
    private let humidityView = WeatherAtrributeView()
    private let windSpeedView = WeatherAtrributeView()
    private let windDirectionView = WeatherAtrributeView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = WeatherConstants.weatherViewBackgroundColor
        self.layer.cornerRadius = 30
        
        setup()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        icon.tintColor = .systemYellow
        icon.backgroundColor = .clear
        icon.contentMode = .scaleAspectFill
        
        locationLabel.textColor = .white
        locationLabel.font = UIFont.systemFont(ofSize: 24)
        
        temperatureLabel.textColor = .yellow
        temperatureLabel.font = UIFont.systemFont(ofSize: 26)
    
        self.addSubview(icon)
        self.addSubview(locationLabel)
        self.addSubview(temperatureLabel)
        
        cloudinessView.configure(with: UIImage(systemName: "cloud") ?? UIImage(), name: "Cloudiness", value: "-")
        humidityView.configure(with: UIImage(systemName: "humidity") ?? UIImage(), name: "Humidity", value: "-")
        windSpeedView.configure(with: UIImage(systemName: "wind") ?? UIImage(), name: "Wind Speed", value: "-")
        windDirectionView.configure(with: UIImage(systemName: "safari") ?? UIImage(), name: "Wind Direction", value: "-")
        
        attributesStack.addArrangedSubview(cloudinessView)
        attributesStack.addArrangedSubview(humidityView)
        attributesStack.addArrangedSubview(windSpeedView)
        attributesStack.addArrangedSubview(windDirectionView)
        
        attributesStack.axis = .vertical
        attributesStack.spacing = 8
        attributesStack.distribution = .fillEqually
        
        self.addSubview(attributesStack)
    }
    
    
    func configure(image: UIImage, city: String, country: String, temperature: String, description: String){
        icon.image = image
        locationLabel.text = "\(city), \(country)"
        temperatureLabel.text = "\(temperature) | \(description)"
    }
    
    func configure(with weather: CurrentWeather){
        locationLabel.text = "\(weather.city), \(weather.country)"
        temperatureLabel.text = "\(weather.temperature) | \(weather.mainDescription)"
        
        cloudinessView.setAttributeValue(to: weather.cloudiness)
        humidityView.setAttributeValue(to: weather.humidity)
        windSpeedView.setAttributeValue(to: weather.windSpeed)
        windDirectionView.setAttributeValue(to: weather.windDirection)
    }
    
    func getLocation() -> String? {
        return self.locationLabel.text
    }
}



extension WeatherCollectionViewCell {
    private func addConstraints() {
        icon.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        attributesStack.translatesAutoresizingMaskIntoConstraints = false
        cloudinessView.translatesAutoresizingMaskIntoConstraints = false
        humidityView.translatesAutoresizingMaskIntoConstraints = false
        windSpeedView.translatesAutoresizingMaskIntoConstraints = false
        windDirectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            icon.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.15),
            icon.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            
            locationLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),
            
            attributesStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            attributesStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            attributesStack.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3),
            attributesStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -80)
        ])
    }
}
