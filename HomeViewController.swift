//
//  HomeViewController.swift
//  irisOne
//
//  Created by Test User on 7/22/25.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Custom Tab Bar Reference
    weak var customTabBarController: CustomTabBarController?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header components
    private let headerStackView = UIStackView()
    private let iconContainerView = UIView()
    private let heartIconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    // Category cards
    private let categoriesStackView = UIStackView()
    private var categoryCards: [CategoryCardView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHomeUI()
        setupConstraints()
        setupCategoryData()
    }
    
    private func setupHomeUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0) // Warm cream background
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Header Stack View
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .vertical
        headerStackView.alignment = .center
        headerStackView.spacing = 16
        contentView.addSubview(headerStackView)
        
        // Heart Icon Container
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        iconContainerView.layer.cornerRadius = 40
        headerStackView.addArrangedSubview(iconContainerView)
        
        // Heart Icon
        heartIconView.translatesAutoresizingMaskIntoConstraints = false
        heartIconView.image = UIImage(systemName: "heart.fill")
        heartIconView.tintColor = .white
        heartIconView.contentMode = .scaleAspectFit
        iconContainerView.addSubview(heartIconView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Hi, I'm Iris. What's on your\nheart today?"
        titleLabel.font = UIFont(name: "Georgia", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        headerStackView.addArrangedSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Choose a category to begin your\nreflection journey"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        headerStackView.addArrangedSubview(subtitleLabel)
        
        // Categories Stack View
        categoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        categoriesStackView.axis = .vertical
        categoriesStackView.spacing = 16
        categoriesStackView.distribution = .fillEqually
        contentView.addSubview(categoriesStackView)
    }
    
    private func setupCategoryData() {
        let categories = [
            CategoryData(
                title: "Love & Relationships",
                subtitle: "Heal your heart, connect deeper",
                description: "Explore love, healing broken hearts, and building meaningful connections",
                iconName: "heart.fill",
                backgroundColor: UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
            ),
            CategoryData(
                title: "Heal & Grow",
                subtitle: "Transform pain into wisdom",
                description: "Journey through healing, self-discovery, and personal transformation",
                iconName: "sparkles",
                backgroundColor: UIColor(red: 0.75, green: 0.7, blue: 0.85, alpha: 1.0)
            ),
            CategoryData(
                title: "Your Life Goals",
                subtitle: "Manifest your dreams",
                description: "Clarify your purpose, set intentions, and create meaningful change",
                iconName: "target",
                backgroundColor: UIColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0)
            ),
            CategoryData(
                title: "Philosophy & Metaphysics",
                subtitle: "Explore life's deeper meanings",
                description: "Dive into existential questions and spiritual understanding",
                iconName: "brain.head.profile",
                backgroundColor: UIColor(red: 0.88, green: 0.86, blue: 0.84, alpha: 1.0)
            )
        ]
        
        for category in categories {
            let cardView = CategoryCardView(category: category)
            cardView.delegate = self
            categoriesStackView.addArrangedSubview(cardView)
            categoryCards.append(cardView)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header Stack View
            headerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            headerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            headerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Icon Container
            iconContainerView.widthAnchor.constraint(equalToConstant: 80),
            iconContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Heart Icon
            heartIconView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            heartIconView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            heartIconView.widthAnchor.constraint(equalToConstant: 32),
            heartIconView.heightAnchor.constraint(equalToConstant: 32),
            
            // Categories Stack View
            categoriesStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 40),
            categoriesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            categoriesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            categoriesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
}

// MARK: - HomeViewController Category Delegate
//extension HomeViewController: CategoryCardDelegate {
//    func categoryCardTapped(category: CategoryData) {
//        print("Selected category: \(category.title)")
//        
//        // Use custom tab bar controller for navigation
//        if let customTabBar = customTabBarController {
//            customTabBar.navigateToChat(with: category)
//        } else {
//            // Fallback to regular navigation
//            let chatViewController = ChatViewController(category: category)
//            navigationController?.pushViewController(chatViewController, animated: true)
//        }
//    }
//}

import UIKit

// MARK: - HomeViewController Navigation Extensions
extension HomeViewController: CategoryCardDelegate {
    func categoryCardTapped(category: CategoryData) {
        print("Selected category: \(category.title)")
        
        // Convert CategoryData to ChatCategoryData and navigate directly to individual chat
        let chatCategory = category.toChatCategoryData()
        let actualChatVC = ActualChatViewController(category: chatCategory)
        navigationController?.pushViewController(actualChatVC, animated: true)
    }
}

// MARK: - Alternative Navigation (if you want to show category selection first)
extension HomeViewController {
    
    // Use this method if you want to navigate to category selection screen first
    func navigateToCategorySelection() {
        let chatViewController = ChatViewController()
        chatViewController.customTabBarController = self.customTabBarController
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    // Use this method for direct navigation to specific category chat
    func navigateDirectlyToChat(category: CategoryData) {
        let chatCategory = category.toChatCategoryData()
        let actualChatVC = ActualChatViewController(category: chatCategory)
        navigationController?.pushViewController(actualChatVC, animated: true)
    }
}
