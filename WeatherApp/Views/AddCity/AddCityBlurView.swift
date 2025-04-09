//
//  AddCityBlurView.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

final class AddCityBlurView : UIView {
    private var storeCity : ((String) -> Void)?
    private var onDismissPopup : (() -> Void)?
    private let errorView: AddCityErrorView = {
        let errorView = AddCityErrorView()
        errorView.isHidden = true
        return errorView
    }()
    
    private lazy var blurryBackgroundView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blur)
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPopup)))
        return visualEffectView
    }()
    
    private lazy var addCityPopup: AddCityView = {
        let popup = AddCityView()
        popup.configure { [weak self] city in
            guard let self = self else { return }
            storeCity?(city)
            errorView.isHidden = true
            dismissPopup()
        } failure: { [weak self] error in
            guard let self = self else { return }
            showErrorView(for: error)
        }
        return popup
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(success storeCity: @escaping (String) -> Void, dissmiss onDismissPopup: @escaping () -> Void) {
        self.storeCity = storeCity
        self.onDismissPopup = onDismissPopup
    }
    
    private func setup() {
        self.addSubview(blurryBackgroundView)
        self.addSubview(addCityPopup)
        self.addSubview(errorView)
    }
    
    private func addConstraints() {
        errorView.translatesAutoresizingMaskIntoConstraints = false
        blurryBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addCityPopup.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 30),
            errorView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            errorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            errorView.heightAnchor.constraint(equalToConstant: 80),
            
            blurryBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurryBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            blurryBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            blurryBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            addCityPopup.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            addCityPopup.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            addCityPopup.topAnchor.constraint(equalTo: self.topAnchor, constant: 300),
            addCityPopup.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -300)
        ])
    }
    
    @objc
    private func dismissPopup() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            blurryBackgroundView.alpha = 0
            addCityPopup.alpha = 0
            errorView.alpha = 0
        } completion: { _ in
            self.onDismissPopup?()
            self.removeFromSuperview()
        }
    }
    
    private func showErrorView(for error: String) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            blurryBackgroundView.alpha = 1
            addCityPopup.alpha = 1
            errorView.alpha = 1
            errorView.setErrorDesctiption(error)
            errorView.isHidden = false
        }
    }
}
