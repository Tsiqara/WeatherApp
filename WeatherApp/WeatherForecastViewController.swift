//
//  WeatherForecastViewController.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 22.02.25.
//

import UIKit

final class WeatherForecastViewController: UIViewController {
    private let forecastTable = UITableView()
    private let service = Service()
    private let loader = UIActivityIndicatorView()
    var location: Location!
    
    private var forecastSections: [ForecastSection] = []
    
    private let errorView = ErrorView()
    
    lazy var backButton: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )
        item.tintColor = .yellow
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forecastTable.backgroundColor = WeatherConstants.weatherBackgroundColor
        view.backgroundColor = WeatherConstants.weatherBackgroundColor
        
        navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(loader)
        
        errorView.isHidden = true
        errorView.backgroundColor = .clear
        errorView.delegate = self
        view.addSubview(errorView)
        
        configureTableView()
        addConstraints()
        
        loadForecastData()
    }
    
    private func configureTableView() {
        forecastTable.sectionHeaderTopPadding = 0
        
        forecastTable.dataSource = self
        forecastTable.delegate = self
        
        forecastTable.register(ForecastCell.self, forCellReuseIdentifier: "ForecastCell")
        forecastTable.register(ForecastHeader.self, forHeaderFooterViewReuseIdentifier: "ForecastHeader")
        
        view.addSubview(forecastTable)
    }
    
    private func addConstraints() {
        forecastTable.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            forecastTable.topAnchor.constraint(equalTo: view.topAnchor),
            forecastTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            forecastTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30)
        ])
    }
    
    @objc
    private func handleBack() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension WeatherForecastViewController : ErrorViewDelegate{
    func errorViewDidTapReload(_ errorView: ErrorView) {
        errorView.isHidden = true
        loadForecastData()
    }
}


extension WeatherForecastViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return forecastSections.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return forecastSections[section].forecasts.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath)
        if let forecastCell = cell as? ForecastCell {
            let forecast = forecastSections[indexPath.section].forecasts[indexPath.row]
            forecastCell.configure(with: forecast)
            
            forecastCell.forecastView.icon.kf.indicatorType = .activity
            let urlString = WeatherConstants.weatherIconURLPrefix + forecast.icon + WeatherConstants.weatherIconURLSuffix
            let url = URL(string: urlString)
            forecastCell.forecastView.icon.kf.setImage(with: url)
        }
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ForecastHeader")
        if let forecastHeader = header as? ForecastHeader,
            let model = forecastSections[section].header {
            forecastHeader.configure(with: model)
        }
        return header
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 40
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}


extension WeatherForecastViewController {
    private func loadForecastData() {
        loader.startAnimating()
        forecastTable.isHidden = true
        
        service.load5DayForecastData(latitude: self.location.lat ?? 0, longitude: self.location.lon ?? 0, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                switch result {
                case .success(let forecastSections):
                    self.forecastSections = forecastSections
                    self.loader.stopAnimating()
                    self.loader.isHidden = true
                    self.forecastTable.isHidden = false
                    self.forecastTable.reloadData()
                case .failure(let error):
                    self.showError(error: error)
                }
            }
        })
    }
    
    private func showError(error: WeatherServiceError) {
        loader.stopAnimating()
        loader.isHidden = true
        forecastTable.isHidden = true
        
        errorView.configure(with: error.localizedDescription)
        errorView.isHidden = false
    }
}
