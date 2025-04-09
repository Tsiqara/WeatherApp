//
//  ForecastHeaderView.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

final class ForecastHeaderView: UIView {
    private let dayLabel = UILabel()
    private var model: ForecastHeaderModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        dayLabel.text = "-"
        dayLabel.textColor = .yellow
        self.addSubview(dayLabel)
    }
    
    func configure(with model: ForecastHeaderModel){
        self.model = model
        dayLabel.text = model.day.uppercased()
    }
    
    private func addConstraints() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            dayLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}
