//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 22.02.25.
//

import UIKit

final class WeatherAtrributeView: UIView {
    private let icon = UIImageView()
    private let nameLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        icon.tintColor = .systemYellow
        nameLabel.textColor = .white
        valueLabel.textColor = .yellow
        
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        valueLabel.font = UIFont.systemFont(ofSize: 20)
        
        self.addSubview(icon)
        self.addSubview(nameLabel)
        self.addSubview(valueLabel)
    }
    
    func configure(with image: UIImage, name: String, value: String) {
        icon.image = image
        nameLabel.text = name
        valueLabel.text = value
    }
    
    func setAttributeValue(to text: String) {
        valueLabel.text = text
    }
    
    private func addConstraints() {
        icon.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            icon.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            icon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
