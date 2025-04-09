//
//  AddCityErrorView.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

final class AddCityErrorView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Error Ocurred"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setErrorDesctiption(_ description: String) {
        self.descriptionLabel.text = description
    }
    
    private func setup() {
        self.addSubview(titleLabel)
        self.addSubview(descriptionLabel)
        
        self.backgroundColor = .systemRed
        self.layer.cornerRadius = 10
    }
    
    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        ])
    }
}
