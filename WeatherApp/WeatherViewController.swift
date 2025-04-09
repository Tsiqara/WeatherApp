//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 24.02.25.
//

import UIKit
import Kingfisher
import CoreLocation

final class WeatherViewController: UIViewController {
    private let dbContext = DBManager.shared.persistentContainer.viewContext
    private let locationManager = CLLocationManager()
    
    private let loader = UIActivityIndicatorView()
    private let errorView = ErrorView()
    
    private var currentWeathers: [CurrentWeather] = []
    private var locations: [Location] = []
    private let service = Service()
    
    private let minimumScale: CGFloat = WeatherConstants.minimumScale
    private let maximumScale: CGFloat = WeatherConstants.maximumScale
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .yellow
        control.pageIndicatorTintColor = .white
        return control
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = WeatherConstants.minimumLineSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: WeatherConstants.horizontalInset, bottom: 0, right: WeatherConstants.horizontalInset)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    lazy var refreshButton: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(handleRefresh)
        )
        item.tintColor = .yellow
        return item
    }()
    
    lazy var addCityButton: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(handleAddCity)
        )
        item.tintColor = .yellow
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = WeatherConstants.weatherBackgroundColor
        
        setupLocationManager()
        setupErrorView()

        if UserDefaults.standard.bool(forKey: "userAllowedGetLocation") && (locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse){
            setupAppearance()
            fetchCities()
            loadWeathers()
        } else if locationManager.authorizationStatus != .notDetermined{
            showLocationShareError(error: .locationNotShared)
        }
       
    }
    
    private func showLocationShareError(error: WeatherServiceError) {
        errorView.configure(with: error.localizedDescription)
        errorView.isHidden = false
    }
    
    private func hideLocationShareErrorView() {
        errorView.isHidden = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupAppearance() {
        title = "Today"
        
        navigationItem.leftBarButtonItem = refreshButton
        navigationItem.rightBarButtonItem = addCityButton
        
        setupCollectionView()
        view.addSubview(loader)
        setupPageControl()
        
        addConstraints()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: "WeatherCollectionViewCell")
        
        collectionView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress)
            )
        )
        
        view.addSubview(collectionView)
    }
    
    private func setupErrorView() {
        errorView.isHidden = true
        errorView.backgroundColor = .clear
        errorView.delegate = self
        view.addSubview(errorView)
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30)
        ])
    }
    
    private func setupPageControl() {
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        view.addSubview(pageControl)
    }
}

// MARK: - CLLocationManager Functions
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedAlways, .authorizedWhenInUse :
            UserDefaults.standard.set(true, forKey: "userAllowedGetLocation")
            hideLocationShareErrorView()
            setupAppearance()
            fetchCities()
            loadWeathers()
        case .denied, .restricted:
            UserDefaults.standard.set(false, forKey: "userAllowedGetLocation")
            showLocationShareError(error: .locationNotShared)
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
}

// MARK: - CollectionView Functions
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let count = self.currentWeathers.count
        pageControl.numberOfPages = count
        return count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionViewCell", for: indexPath) as! WeatherCollectionViewCell
        let weather = self.currentWeathers[indexPath.item]
        cell.configure(with: weather)
        
        cell.icon.kf.indicatorType = .activity
        let urlString = WeatherConstants.weatherIconURLPrefix + weather.icon + WeatherConstants.weatherIconURLSuffix
        let url = URL(string: urlString)
        cell.icon.kf.setImage(with: url)
        
        cell.transform = CGAffineTransform(scaleX: maximumScale, y: maximumScale)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let forecastVC = WeatherForecastViewController()
        let location = locations[indexPath.item]
        if let _ = location.lat, let _ = location.lon {
            forecastVC.title = location.name
            forecastVC.location = location
            navigationController?.pushViewController(forecastVC, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cellWidth = collectionView.frame.width - WeatherConstants.horizontalInset * 2
        let centerX = collectionView.contentOffset.x + (collectionView.bounds.width / 2)
        
        for cell in collectionView.visibleCells {
            let cellCenterX = cell.convert(cell.bounds, to: collectionView).midX
            let distance = abs(cellCenterX - centerX)
        
            let scale: CGFloat
            if distance < 1 {
                scale = WeatherConstants.maximumScale
            } else {
                scale = max(WeatherConstants.minimumScale, WeatherConstants.maximumScale - (distance / (cellWidth * 2)) * (WeatherConstants.maximumScale - WeatherConstants.minimumScale))
            }
            
            UIView.animate(withDuration: 0.1) {
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        
        let page = round(scrollView.contentOffset.x / (cellWidth + WeatherConstants.minimumLineSpacing))
        pageControl.currentPage = Int(max(0, min(page, CGFloat(currentWeathers.count - 1))))
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let cellWidth = collectionView.frame.width - WeatherConstants.horizontalInset * 2
        let targetOffset = targetContentOffset.pointee.x
        let totalWidth = cellWidth + WeatherConstants.minimumLineSpacing

        let page = round(targetOffset / totalWidth)
        let newTargetOffset = page * totalWidth
        
        targetContentOffset.pointee.x = newTargetOffset
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width - WeatherConstants.horizontalInset * 2
        let height = collectionView.frame.height - 20
        
        return CGSize(width: width, height: height)
    }
}

extension WeatherViewController {
    private func deleteItem(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete?",
            message: "Are you sure you want to delete City \(self.locations[indexPath.item].name) from your notes?",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive,
                handler: { [unowned self] _ in
                    deleteCity(at: indexPath)
                }
            )
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - Action Handler Functions
extension WeatherViewController {
    @objc
    private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            deleteItem(at: indexPath)
        }
    }
    
    @objc
    private func handleRefresh() {
        loadWeathers()
    }
    
    @objc
    private func handleAddCity() {
        let addCityView = AddCityBlurView()
        
        addCityView.configure(success: { [weak self] city in
            self?.storeCity(city: city)
            self?.loadWeathers()
        }, dissmiss: { [weak self] in
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
            self?.reloadCollectionView()
        })
        addCityView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addCityView)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NSLayoutConstraint.activate([
            addCityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addCityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addCityView.topAnchor.constraint(equalTo: view.topAnchor),
            addCityView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc
    private func pageControlChanged() {
        let page = pageControl.currentPage
        let indexPath = IndexPath(item: page, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - DB Functions
extension WeatherViewController {
    private func fetchCities() {
        let request = CityStored.fetchRequest()
        
        do {
            DBManager.shared.cities = try dbContext.fetch(request)
        } catch {
            print(error)
        }
    }
    
    private func storeCity(city: String) {
        let newCity = CityStored(context: dbContext)
        newCity.name = city
    
        do {
            try dbContext.save()
            fetchCities()
        } catch {
            print(error)
        }
    }
    
    private func deleteCity(at indexPath: IndexPath) {
//        print(indexPath.item)
        if indexPath.item > 0 {
            let cityToDelete = DBManager.shared.cities[indexPath.item - 1]
            
            dbContext.delete(cityToDelete)
            
            do {
                try dbContext.save()
                DBManager.shared.cities.remove(at: indexPath.item - 1)
            } catch {
                print("Failed to delete note: \(error)")
            }
        }
        
        currentWeathers.remove(at: indexPath.item)
        locations.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        reloadCollectionView()
    }
}

// MARK: - Networking Functions
extension WeatherViewController {
    private func loadWeathers() {
        guard let location = locationManager.location?.coordinate else {
            showError(error: .currentLocationNotAvailable)
            return
        }
        let count = DBManager.shared.cities.count + 1
        self.currentWeathers = Array(repeating: CurrentWeather(), count: count)
        self.locations = [Location(name: "Current Location", lat: location.latitude, lon: location.longitude)]
        loader.startAnimating()
        collectionView.isHidden = true
        pageControl.isHidden = true
        loadWeatherData(latitude: location.latitude, longitude: location.longitude, index: 0)
        
        for index in 0..<DBManager.shared.cities.count {
            loadWeatherBasedOnCity(city: DBManager.shared.cities[index].name ?? "", index: index+1)
        }
    }
    
    private func reloadCollectionView() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        self.scrollViewDidScroll(self.collectionView)
    }
}

extension WeatherViewController : ErrorViewDelegate{
    func errorViewDidTapReload(_ errorView: ErrorView) {
        if !errorView.isLocationSharingOff() {
            errorView.isHidden = true
            self.loadWeathers()
        } else {
            locationManagerDidChangeAuthorization(locationManager)
        }
    }
}

extension WeatherViewController {
    
    private func showError(error: WeatherServiceError) {
        loader.stopAnimating()
        errorView.configure(with: error.localizedDescription)
        loader.isHidden = true
        collectionView.isHidden = true
        pageControl.isHidden = true
        
        errorView.isHidden = false
    }
    
    private func loadWeatherBasedOnCity(city: String, index: Int) {
//        if index == 0 {
//            loader.startAnimating()
//            collectionView.isHidden = true
//            pageControl.isHidden = true
//        }
        
        service.loadLocationData(city: city, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let location):
                    let newLocation = Location(name: city, lat: location[0].lat, lon: location[0].lon)
                    locations.append(newLocation)
                    loadWeatherData(latitude: location[0].lat, longitude: location[0].lon, index: index)
                case .failure(let error):
                    self.showError(error: error)
                }
            }
        })
    }
    
    private func loadWeatherData(latitude: Double, longitude: Double, index: Int) {

        service.loadCurrentWeatherData(latitude: latitude, longitude:longitude, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                loader.stopAnimating()
                switch result {
                case .success(var weather):
                    let city = self.locations[index].name
                    if city != "Current Location" {
                        weather.city = city
                    } else {
                        self.locations[index].name = weather.city
                    }
                    self.currentWeathers[index] = weather
                    
                    if self.currentWeathers.count == DBManager.shared.cities.count + 1{
                        loader.isHidden = true
                        collectionView.isHidden = false
                        pageControl.isHidden = false
                        self.reloadCollectionView()
                    }
                case .failure(let error):
                    self.showError(error: error)
                }
            }
        })
    }
}

extension WeatherViewController {
    private func addConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 25),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70),
            
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
