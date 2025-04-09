//
//  ErrorView.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//

import UIKit

protocol ErrorViewDelegate: AnyObject {
    func errorViewDidTapReload(_ errorView: ErrorView)
}

final class ErrorView : UIView {
    let errorImage = UIImageView()
    let errorLabel = UILabel()
    let tryAgainButton = UIButton()
    
    weak var delegate: ErrorViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = WeatherConstants.weatherViewBackgroundColor
        
        setup()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        errorImage.image = UIImage(systemName: "exclamationmark.icloud")
        errorImage.tintColor = .systemYellow
        
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 22)
        
        errorLabel.text = "Error"
        
        tryAgainButton.setTitle("Reload", for: .normal)
        tryAgainButton.tintColor = .systemYellow
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        tryAgainButton.configuration = configuration
        tryAgainButton.layer.cornerRadius = 12
        tryAgainButton.isUserInteractionEnabled = true
        
        tryAgainButton.addTarget(self, action: #selector(handleReload), for: .touchUpInside)
        
        self.addSubview(errorImage)
        self.addSubview(errorLabel)
        self.addSubview(tryAgainButton)
    }
    
    func configure(with error: String){
        errorLabel.text = error
    }
    
    func isLocationSharingOff() -> Bool {
        return errorLabel.text == WeatherServiceError.locationNotShared.localizedDescription
    }
    
    @objc
    private func handleReload() {
        delegate?.errorViewDidTapReload(self)
    }
    
    private func addConstraints() {
        errorImage.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        tryAgainButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorImage.topAnchor.constraint(equalTo: self.topAnchor),
            errorImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            errorImage.heightAnchor.constraint(equalToConstant: 70),
            errorImage.widthAnchor.constraint(equalToConstant: 80),
            
            errorLabel.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 20),
            errorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            tryAgainButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tryAgainButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            tryAgainButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
