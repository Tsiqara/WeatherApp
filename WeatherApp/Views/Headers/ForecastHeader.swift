//
//  ForecastHeader.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

final class ForecastHeader: UITableViewHeaderFooterView {
    let forecastHeaderView = ForecastHeaderView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        forecastHeaderView.backgroundColor = WeatherConstants.weatherBackgroundColor
        self.backgroundView?.backgroundColor = WeatherConstants.weatherBackgroundColor
        
        self.addSubview(forecastHeaderView)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: ForecastHeaderModel) {
        forecastHeaderView.configure(with: model)
    }
    
    private func addConstraints() {
        forecastHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            forecastHeaderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            forecastHeaderView.topAnchor.constraint(equalTo: self.topAnchor),
            forecastHeaderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            forecastHeaderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
