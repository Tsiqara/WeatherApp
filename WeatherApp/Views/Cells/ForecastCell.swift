//
//  ForecastCell.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

final class ForecastCell: UITableViewCell {
    let forecastView = ForecastCellView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        forecastView.backgroundColor = WeatherConstants.weatherBackgroundColor
        self.backgroundColor = WeatherConstants.weatherBackgroundColor
        
        self.addSubview(forecastView)
        
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with forecast: Forecast){
        forecastView.configure(with: forecast)
    }
    
    private func addConstraints() {
        forecastView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            forecastView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            forecastView.topAnchor.constraint(equalTo: self.topAnchor),
            forecastView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            forecastView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
        ])
    }
}
