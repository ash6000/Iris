//
//  SettingsViewController.swift
//  irisOne
//
//  Created by Test User on 8/4/25.
//
import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    
    // Cards Stack View
    private let cardsStackView = UIStackView()
    
    // Individual Cards
    private let welcomeCard = UIView()
    private let aboutIrisCard = UIView()
    private let termsCard = UIView()
    private let upgradeCard = UIView()
    private let privacyCard = UIView()
    private let supportCard = UIView()
    private let ambassadorCard = UIView()  // Combined ambassador card
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0) :
                UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        }
        
        setupScrollView()
        setupHeader()
        setupCardsStackView()
        setupCards()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0) :
                UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        }
        contentView.addSubview(headerView)
        
        // Title (centered, no back button)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Settings & More"
        titleLabel.font = UIFont(name: "Georgia", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .semibold)
        titleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
    }
    
    private func setupCardsStackView() {
        cardsStackView.translatesAutoresizingMaskIntoConstraints = false
        cardsStackView.axis = .vertical
        cardsStackView.spacing = 12  // Reduced spacing to match original
        cardsStackView.distribution = .fill
        cardsStackView.alignment = .fill
        contentView.addSubview(cardsStackView)
    }
    
    private func setupCards() {
        setupWelcomeCard()
        setupAboutIrisCard()
        setupTermsCard()
        setupUpgradeCard()
        setupPrivacyCard()
        setupSupportCard()
        setupAmbassadorCard()  // Full ambassador card at the end
        
        // Add cards to stack view
        cardsStackView.addArrangedSubview(welcomeCard)
        cardsStackView.addArrangedSubview(aboutIrisCard)
        cardsStackView.addArrangedSubview(termsCard)
        cardsStackView.addArrangedSubview(upgradeCard)
        cardsStackView.addArrangedSubview(privacyCard)
        cardsStackView.addArrangedSubview(supportCard)
        cardsStackView.addArrangedSubview(ambassadorCard)  // Last card
    }
    
    private func setupWelcomeCard() {
        welcomeCard.translatesAutoresizingMaskIntoConstraints = false
        welcomeCard.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) :
                UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        }
        welcomeCard.layer.cornerRadius = 20
        welcomeCard.layer.shadowColor = UIColor.black.cgColor
        welcomeCard.layer.shadowOpacity = 0.08
        welcomeCard.layer.shadowRadius = 8
        welcomeCard.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Icon background (lavender circle)
        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = UIColor(red: 0.8, green: 0.75, blue: 0.9, alpha: 1.0)
        iconBackground.layer.cornerRadius = 25
        welcomeCard.addSubview(iconBackground)
        
        // Heart icon
        let heartIcon = UIImageView()
        heartIcon.translatesAutoresizingMaskIntoConstraints = false
        heartIcon.image = UIImage(systemName: "heart.fill")
        heartIcon.tintColor = UIColor(red: 0.6, green: 0.5, blue: 0.8, alpha: 1.0)
        iconBackground.addSubview(heartIcon)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Welcome back"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        }
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        welcomeCard.addSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Free tier • 3 tokens remaining today"
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        welcomeCard.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            welcomeCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),  // Allow dynamic height
            
            iconBackground.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 16),  // Reduced padding
            iconBackground.centerYAnchor.constraint(equalTo: welcomeCard.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 50),
            iconBackground.heightAnchor.constraint(equalToConstant: 50),
            
            heartIcon.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            heartIcon.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            heartIcon.widthAnchor.constraint(equalToConstant: 24),
            heartIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: welcomeCard.topAnchor, constant: 16),  // Reduced padding
            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),  // Reduced spacing
            titleLabel.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: welcomeCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupAboutIrisCard() {
        aboutIrisCard.translatesAutoresizingMaskIntoConstraints = false
        createStandardCard(
            card: aboutIrisCard,
            iconName: "info.circle",
            iconColor: UIColor(red: 0.9, green: 0.6, blue: 0.7, alpha: 1.0),
            title: "About Iris",
            subtitle: "Learn about your AI companion"
        )
    }
    
    private func setupTermsCard() {
        termsCard.translatesAutoresizingMaskIntoConstraints = false
        createStandardCard(
            card: termsCard,
            iconName: "doc.text",
            iconColor: UIColor(red: 0.9, green: 0.6, blue: 0.7, alpha: 1.0),
            title: "Terms of Use & Disclaimer",
            subtitle: "Important information about using Iris"
        )
    }
    
    private func setupUpgradeCard() {
        upgradeCard.translatesAutoresizingMaskIntoConstraints = false
        upgradeCard.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.25, green: 0.2, blue: 0.25, alpha: 1.0) :
                UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        }
        upgradeCard.layer.cornerRadius = 20
        upgradeCard.layer.shadowColor = UIColor.black.cgColor
        upgradeCard.layer.shadowOpacity = 0.08
        upgradeCard.layer.shadowRadius = 8
        upgradeCard.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Add subtle gradient overlay for premium feel
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1000, height: 80) // Will be adjusted
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.85, blue: 0.9, alpha: 0.3).cgColor,
            UIColor(red: 0.9, green: 0.8, blue: 0.85, alpha: 0.1).cgColor
        ]
        gradientLayer.cornerRadius = 20
        upgradeCard.layer.insertSublayer(gradientLayer, at: 0)
        
        // Icon background (lavender circle)
        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = UIColor(red: 0.8, green: 0.75, blue: 0.9, alpha: 1.0)
        iconBackground.layer.cornerRadius = 25
        upgradeCard.addSubview(iconBackground)
        
        // Crown icon
        let crownIcon = UIImageView()
        crownIcon.translatesAutoresizingMaskIntoConstraints = false
        crownIcon.image = UIImage(systemName: "crown.fill")
        crownIcon.tintColor = UIColor(red: 0.6, green: 0.5, blue: 0.8, alpha: 1.0)
        iconBackground.addSubview(crownIcon)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Upgrade to Premium"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.75, green: 0.5, blue: 0.7, alpha: 1.0) // Pink title
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        upgradeCard.addSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Unlock unlimited conversations & features"
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        upgradeCard.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            upgradeCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),  // Allow dynamic height
            
            iconBackground.leadingAnchor.constraint(equalTo: upgradeCard.leadingAnchor, constant: 16),  // Reduced padding
            iconBackground.centerYAnchor.constraint(equalTo: upgradeCard.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 50),
            iconBackground.heightAnchor.constraint(equalToConstant: 50),
            
            crownIcon.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            crownIcon.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            crownIcon.widthAnchor.constraint(equalToConstant: 24),
            crownIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: upgradeCard.topAnchor, constant: 16),  // Reduced padding
            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),  // Reduced spacing
            titleLabel.trailingAnchor.constraint(equalTo: upgradeCard.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: upgradeCard.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: upgradeCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupAmbassadorCard() {
        ambassadorCard.translatesAutoresizingMaskIntoConstraints = false
        ambassadorCard.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) :
                UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        }
        ambassadorCard.layer.cornerRadius = 20
        ambassadorCard.layer.shadowColor = UIColor.black.cgColor
        ambassadorCard.layer.shadowOpacity = 0.08
        ambassadorCard.layer.shadowRadius = 8
        ambassadorCard.layer.shadowOffset = CGSize(width: 0, height: 3)
        ambassadorCard.clipsToBounds = true
        
        // Icon background (lavender circle)
        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = UIColor(red: 0.8, green: 0.75, blue: 0.9, alpha: 1.0)
        iconBackground.layer.cornerRadius = 25
        ambassadorCard.addSubview(iconBackground)
        
        // People icon
        let peopleIcon = UIImageView()
        peopleIcon.translatesAutoresizingMaskIntoConstraints = false
        peopleIcon.image = UIImage(systemName: "person.2")
        peopleIcon.tintColor = UIColor(red: 0.6, green: 0.5, blue: 0.8, alpha: 1.0)
        iconBackground.addSubview(peopleIcon)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Ambassador Program"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        }
        ambassadorCard.addSubview(titleLabel)
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Share the healing power of Iris with your community and earn rewards:"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) :
                UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        }
        descriptionLabel.numberOfLines = 0
        ambassadorCard.addSubview(descriptionLabel)
        
        // Benefits list
        let benefitsStackView = UIStackView()
        benefitsStackView.translatesAutoresizingMaskIntoConstraints = false
        benefitsStackView.axis = .vertical
        benefitsStackView.spacing = 8
        benefitsStackView.alignment = .leading
        ambassadorCard.addSubview(benefitsStackView)
        
        let benefits = [
            "Get premium access for successful referrals",
            "Help others on their healing journey",
            "Build a supportive spiritual community",
            "Earn tokens and exclusive features"
        ]
        
        for benefit in benefits {
            let bulletLabel = createBulletPoint(text: benefit)
            benefitsStackView.addArrangedSubview(bulletLabel)
        }
        
        // Join Button
        let joinButton = UIButton()
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.setTitle("Join Ambassador Program", for: .normal)
        joinButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.backgroundColor = UIColor(red: 0.8, green: 0.75, blue: 0.9, alpha: 1.0)
        joinButton.layer.cornerRadius = 16
        joinButton.layer.shadowColor = UIColor.black.cgColor
        joinButton.layer.shadowOpacity = 0.1
        joinButton.layer.shadowRadius = 6
        joinButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        joinButton.addTarget(self, action: #selector(joinAmbassadorProgram), for: .touchUpInside)
        ambassadorCard.addSubview(joinButton)
        
        NSLayoutConstraint.activate([
            iconBackground.topAnchor.constraint(equalTo: ambassadorCard.topAnchor, constant: 24),
            iconBackground.leadingAnchor.constraint(equalTo: ambassadorCard.leadingAnchor, constant: 20),
            iconBackground.widthAnchor.constraint(equalToConstant: 50),
            iconBackground.heightAnchor.constraint(equalToConstant: 50),
            
            peopleIcon.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            peopleIcon.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            peopleIcon.widthAnchor.constraint(equalToConstant: 24),
            peopleIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: ambassadorCard.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: ambassadorCard.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: ambassadorCard.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: ambassadorCard.trailingAnchor, constant: -20),
            
            benefitsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            benefitsStackView.leadingAnchor.constraint(equalTo: ambassadorCard.leadingAnchor, constant: 40),
            benefitsStackView.trailingAnchor.constraint(equalTo: ambassadorCard.trailingAnchor, constant: -20),
            
            joinButton.topAnchor.constraint(equalTo: benefitsStackView.bottomAnchor, constant: 24),
            joinButton.leadingAnchor.constraint(equalTo: ambassadorCard.leadingAnchor, constant: 20),
            joinButton.trailingAnchor.constraint(equalTo: ambassadorCard.trailingAnchor, constant: -20),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            joinButton.bottomAnchor.constraint(equalTo: ambassadorCard.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupPrivacyCard() {
        privacyCard.translatesAutoresizingMaskIntoConstraints = false
        createStandardCard(
            card: privacyCard,
            iconName: "shield",
            iconColor: UIColor(red: 0.9, green: 0.6, blue: 0.7, alpha: 1.0),
            title: "Privacy & Data",
            subtitle: "How we protect your information"
        )
    }
    
    private func setupSupportCard() {
        supportCard.translatesAutoresizingMaskIntoConstraints = false
        createStandardCard(
            card: supportCard,
            iconName: "envelope",
            iconColor: UIColor(red: 0.9, green: 0.6, blue: 0.7, alpha: 1.0),
            title: "Support & Feedback",
            subtitle: "Get help or share your thoughts"
        )
    }
    
    private func createStandardCard(card: UIView, iconName: String, iconColor: UIColor, title: String, subtitle: String) {
        card.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) :
                UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        }
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Icon background (soft beige circle)
        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1.0)
        iconBackground.layer.cornerRadius = 25
        card.addSubview(iconBackground)
        
        // Icon
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: iconName)
        icon.tintColor = iconColor
        iconBackground.addSubview(icon)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        }
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        card.addSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),  // Allow dynamic height for multi-line text
            
            iconBackground.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),  // Reduced padding
            iconBackground.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 50),
            iconBackground.heightAnchor.constraint(equalToConstant: 50),
            
            icon.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),  // Reduced padding
            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),  // Reduced spacing
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -16)
        ])
    }
    
    
    private func createBulletPoint(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• \(text)"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) :
                UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
        label.numberOfLines = 0
        return label
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header (no back button)
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Cards Stack View
            cardsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    private func setupActions() {
        // Add tap gestures to cards (removed back button action)
        let aboutTap = UITapGestureRecognizer(target: self, action: #selector(aboutIrisTapped))
        aboutIrisCard.addGestureRecognizer(aboutTap)
        aboutIrisCard.isUserInteractionEnabled = true
        
        let termsTap = UITapGestureRecognizer(target: self, action: #selector(termsTapped))
        termsCard.addGestureRecognizer(termsTap)
        termsCard.isUserInteractionEnabled = true
        
        let upgradeTap = UITapGestureRecognizer(target: self, action: #selector(upgradeTapped))
        upgradeCard.addGestureRecognizer(upgradeTap)
        upgradeCard.isUserInteractionEnabled = true
        
        let privacyTap = UITapGestureRecognizer(target: self, action: #selector(privacyTapped))
        privacyCard.addGestureRecognizer(privacyTap)
        privacyCard.isUserInteractionEnabled = true
        
        let supportTap = UITapGestureRecognizer(target: self, action: #selector(supportTapped))
        supportCard.addGestureRecognizer(supportTap)
        supportCard.isUserInteractionEnabled = true
    }
    
    
    @objc private func joinAmbassadorProgram() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Find the join button in the ambassador card
        if let joinButton = ambassadorCard.subviews.compactMap({ $0 as? UIButton }).first {
            UIView.animate(withDuration: 0.1, animations: {
                joinButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                joinButton.alpha = 0.8
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    joinButton.transform = .identity
                    joinButton.alpha = 1.0
                }
            }
        }
        
        // Handle join ambassador program action
        let alert = UIAlertController(
            title: "Welcome to the Ambassador Program!",
            message: "Thank you for your interest in sharing Iris with your community. We'll be in touch with more details soon.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Great!", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func aboutIrisTapped() {
        animateCardTap(card: aboutIrisCard)
        // Handle About Iris navigation
        print("About Iris tapped")
    }
    
    @objc private func termsTapped() {
        animateCardTap(card: termsCard)
        // Handle Terms navigation
        print("Terms tapped")
    }
    
    @objc private func upgradeTapped() {
        animateCardTap(card: upgradeCard)
        // Handle Upgrade navigation
        print("Upgrade tapped")
    }
    
    @objc private func privacyTapped() {
        animateCardTap(card: privacyCard)
        // Handle Privacy navigation
        print("Privacy tapped")
    }
    
    @objc private func supportTapped() {
        animateCardTap(card: supportCard)
        // Handle Support navigation
        print("Support tapped")
    }
    
    private func animateCardTap(card: UIView) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Animate card tap
        UIView.animate(withDuration: 0.1, animations: {
            card.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                card.transform = .identity
            }
        }
    }
    
    // MARK: - Dark Mode Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Update any custom layers or colors that don't automatically adapt
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        // Update shadow colors for dark mode
        let shadowColor = UIColor.black.cgColor
        
        welcomeCard.layer.shadowColor = shadowColor
        aboutIrisCard.layer.shadowColor = shadowColor
        termsCard.layer.shadowColor = shadowColor
        upgradeCard.layer.shadowColor = shadowColor
        ambassadorCard.layer.shadowColor = shadowColor
        privacyCard.layer.shadowColor = shadowColor
        supportCard.layer.shadowColor = shadowColor
    }
}
