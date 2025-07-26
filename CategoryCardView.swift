//
//  CategoryCardView.swift
//  irisOne
//
//  Created by Test User on 7/24/25.
//

import Foundation
import UIKit

struct CategoryData {
    let title: String
    let subtitle: String
    let description: String
    let iconName: String
    let backgroundColor: UIColor
}

// MARK: - Category Card Delegate Protocol
protocol CategoryCardDelegate: AnyObject {
    func categoryCardTapped(category: CategoryData)
}

// MARK: - Category Card View
class CategoryCardView: UIView {
    
    weak var delegate: CategoryCardDelegate?
    private let category: CategoryData
    
    private let containerView = UIView()
    private let iconContainerView = UIView()
    private let iconView = UIImageView()
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    init(category: CategoryData) {
        self.category = category
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(red: 0.92, green: 0.90, blue: 0.88, alpha: 1.0)
        containerView.layer.cornerRadius = 20
        containerView.layer.cornerCurve = .continuous
        addSubview(containerView)
        
        // Icon Container
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.backgroundColor = category.backgroundColor
        iconContainerView.layer.cornerRadius = 25
        containerView.addSubview(iconContainerView)
        
        // Icon
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: category.iconName)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconContainerView.addSubview(iconView)
        
        // Content Stack
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .leading
        contentStackView.spacing = 4
        containerView.addSubview(contentStackView)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = category.title
        titleLabel.font = UIFont(name: "Georgia", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        contentStackView.addArrangedSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = category.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 0.7, green: 0.5, blue: 0.6, alpha: 1.0)
        contentStackView.addArrangedSubview(subtitleLabel)
        
        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = category.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        descriptionLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 120),
            
            // Icon Container
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 50),
            iconContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Icon
            iconView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            // Content Stack
            contentStackView.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func cardTapped() {
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform.identity
            }
        }
        
        delegate?.categoryCardTapped(category: category)
    }
}
