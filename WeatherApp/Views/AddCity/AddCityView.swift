//
//  AddCityView.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

final class AddCityView: UIView {
    private let service = Service()
    
    private var addCityButtonTappedSuccess: ((String) -> Void)?
    private var addCityButtonTappedFailure: ((String) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add City"
        label.font = UIFont.systemFont(ofSize: 19)
        label.textColor = .white
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter City name you wish to add"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .white
        return label
    }()
    
    private let cityTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "City name"
        textField.backgroundColor = .white
        textField.textAlignment = .center
        textField.layer.cornerRadius = 6
        return textField
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        let config = UIImage(systemName: "plus.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: WeatherConstants.addButtonSize))
        button.setImage(config, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAddCityButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.isHidden = true
        loader.backgroundColor = .white
        loader.layer.cornerRadius = WeatherConstants.addButtonSize / 2
        return loader
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(success addAction: @escaping (String) -> Void,
                   failure errorAction: @escaping (String) -> Void) {
        addCityButtonTappedSuccess = addAction
        addCityButtonTappedFailure = errorAction
    }
    
    private func setup() {
        self.addSubview(titleLabel)
        self.addSubview(descriptionLabel)
        self.addSubview(cityTextField)
        self.addSubview(addButton)
        self.addSubview(loader)
        
        self.backgroundColor = WeatherConstants.addCityBackgroundColor
        self.layer.cornerRadius = 30
    }
    
    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cityTextField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            cityTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            cityTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 60),
            cityTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -60),
            cityTextField.heightAnchor.constraint(equalToConstant: 35),
            
            addButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            addButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            addButton.heightAnchor.constraint(equalToConstant: WeatherConstants.addButtonSize),
            addButton.widthAnchor.constraint(equalToConstant: WeatherConstants.addButtonSize),
            
            loader.leadingAnchor.constraint(equalTo: addButton.leadingAnchor),
            loader.trailingAnchor.constraint(equalTo: addButton.trailingAnchor),
            loader.topAnchor.constraint(equalTo: addButton.topAnchor),
            loader.bottomAnchor.constraint(equalTo: addButton.bottomAnchor),
            loader.heightAnchor.constraint(equalTo: addButton.heightAnchor),
            loader.widthAnchor.constraint(equalTo: addButton.widthAnchor)
        ])
    }
    
    @objc
    private func handleAddCityButtonTapped() {
        if let cityName = cityTextField.text {
            addButton.isHidden = true
            loader.startAnimating()
            loader.isHidden = false
            cityTextField.text = ""
            if cityName == "" {
                showError(error: "Please Enter City Name")
                loader.stopAnimating()
                loader.isHidden = true
                addButton.isHidden = false
            }else if !DBManager.shared.containsCity(city: cityName){
                loadWeatherBasedOnCity(city: cityName)
            } else {
                showError(error: "\(cityName) is already added")
                loader.stopAnimating()
                loader.isHidden = true
                addButton.isHidden = false
            }
        }
    }
}

extension AddCityView {
    private func showError(error: String) {
        loader.stopAnimating()
        loader.isHidden = true
        addButton.isHidden = false
        self.addCityButtonTappedFailure?(error)
    }
    
    private func loadWeatherBasedOnCity(city: String) {
        service.loadLocationData(city: city, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let location):
                    loadWeatherData(latitude: location[0].lat, longitude: location[0].lon, city: location[0].name)
                case .failure(let error):
                    self.showError(error: error.localizedDescription)
                }
            }
        })
    }
    
    private func loadWeatherData(latitude: Double, longitude: Double, city: String) {
        service.loadCurrentWeatherData(latitude: latitude, longitude:longitude, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success:
                    loader.stopAnimating()
                    loader.isHidden = true
                    addButton.isHidden = false
                    self.addCityButtonTappedSuccess?(city)
                case .failure(let error):
                    self.showError(error: error.localizedDescription)
                }
            }
        })
    }
}
