//
//  ForecastCellView.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

final class ForecastCellView: UIView {
    let icon = UIImageView()
    private let timeLabel = UILabel()
    private let desctiptionLabel = UILabel()
    private let stackView = UIStackView()
    private let temperatureLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addConstraints()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        timeLabel.textColor = .white
        desctiptionLabel.textColor = .white
        temperatureLabel.textColor = .yellow
        
        timeLabel.font = UIFont.systemFont(ofSize: 16)
        desctiptionLabel.font = UIFont.systemFont(ofSize: 16)
        temperatureLabel.font = UIFont.systemFont(ofSize: 24)
        
        icon.backgroundColor = .clear
        icon.contentMode = .scaleAspectFill
        
        self.addSubview(icon)
        
        stackView.axis = .vertical
        stackView.spacing = 0
        
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(desctiptionLabel)
        
        self.addSubview(stackView)
        self.addSubview(temperatureLabel)
    }
    
    func configure(with forecast: Forecast){
        timeLabel.text = forecast.time
        desctiptionLabel.text = forecast.description
        temperatureLabel.text = forecast.temp.description + "°C"
    }
    
    private func addConstraints() {
        icon.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        desctiptionLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            icon.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            icon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 20),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            desctiptionLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            
            temperatureLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            temperatureLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
