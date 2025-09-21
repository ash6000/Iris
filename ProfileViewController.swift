//
//  ProfileViewController.swift
//  irisOne
//
//  Created by Test User on 9/21/25.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let menuButton = UIButton()

    // Profile Section
    private let profileImageView = UIImageView()
    private let profileEditButton = UIButton()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()

    // Spiritual Persona Section
    private let spiritualPersonaView = UIView()
    private let spiritualPersonaTitleLabel = UILabel()
    private let personaIconView = UIView()
    private let personaIconImageView = UIImageView()
    private let personaNameLabel = UILabel()
    private let personaDescriptionLabel = UILabel()
    private let personaDetailLabel = UILabel()

    // Preferences Section
    private let preferencesView = UIView()
    private let preferencesTitleLabel = UILabel()
    private let preferencesStackView = UIStackView()

    // AI Companion Section
    private let aiCompanionView = UIView()
    private let aiCompanionTitleLabel = UILabel()
    private let companionContainerView = UIView()
    private let companionAvatarView = UIView()
    private let companionNameLabel = UILabel()
    private let companionDescriptionLabel = UILabel()
    private let companionDetailLabel = UILabel()
    private let startConversationButton = UIButton()

    // Journey Section
    private let journeyView = UIView()
    private let journeyTitleLabel = UILabel()
    private let journeyStatsView = UIView()
    private let daysActiveLabel = UILabel()
    private let daysActiveValueLabel = UILabel()
    private let conversationsLabel = UILabel()
    private let conversationsValueLabel = UILabel()

    // Edit Profile Button
    private let editProfileButton = UIButton()

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

        // Ensure tab bar remains visible
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }

        // For CustomTabBarController, ensure tab bar is visible
        if let customTabBarController = findCustomTabBarController() {
            // The tab bar should remain visible when navigating within the navigation stack
        }
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        setupHeader()
        setupProfileSection()
        setupSpiritualPersonaSection()
        setupPreferencesSection()
        setupAICompanionSection()
        setupJourneySection()
        setupEditProfileButton()
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(headerView)

        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        headerView.addSubview(backButton)

        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Your Profile"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        // Menu Button
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        headerView.addSubview(menuButton)
    }

    private func setupProfileSection() {
        // Profile Image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        profileImageView.contentMode = .scaleAspectFit
        contentView.addSubview(profileImageView)

        // Profile Edit Button
        profileEditButton.translatesAutoresizingMaskIntoConstraints = false
        profileEditButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        profileEditButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        profileEditButton.backgroundColor = UIColor.white
        profileEditButton.layer.cornerRadius = 12
        contentView.addSubview(profileEditButton)

        // Name Label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Sarah Chen"
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)

        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Seeker of Inner Peace"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        contentView.addSubview(subtitleLabel)
    }

    private func setupSpiritualPersonaSection() {
        spiritualPersonaView.translatesAutoresizingMaskIntoConstraints = false
        spiritualPersonaView.backgroundColor = UIColor.white
        spiritualPersonaView.layer.cornerRadius = 12
        contentView.addSubview(spiritualPersonaView)

        // Title
        spiritualPersonaTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        spiritualPersonaTitleLabel.text = "Your Spiritual Persona"
        spiritualPersonaTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        spiritualPersonaTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        spiritualPersonaView.addSubview(spiritualPersonaTitleLabel)

        // Persona Icon
        personaIconView.translatesAutoresizingMaskIntoConstraints = false
        personaIconView.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        personaIconView.layer.cornerRadius = 20
        spiritualPersonaView.addSubview(personaIconView)

        personaIconImageView.translatesAutoresizingMaskIntoConstraints = false
        personaIconImageView.image = UIImage(systemName: "leaf.fill")
        personaIconImageView.tintColor = UIColor.white
        personaIconImageView.contentMode = .scaleAspectFit
        personaIconView.addSubview(personaIconImageView)

        // Persona Name
        personaNameLabel.translatesAutoresizingMaskIntoConstraints = false
        personaNameLabel.text = "Nature Mystic"
        personaNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        personaNameLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        spiritualPersonaView.addSubview(personaNameLabel)

        // Persona Description
        personaDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        personaDescriptionLabel.text = "Connected to earth's wisdom"
        personaDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        personaDescriptionLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        spiritualPersonaView.addSubview(personaDescriptionLabel)

        // Persona Detail
        personaDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        personaDetailLabel.text = "You find deep connection through nature and mindfulness practices. Your spiritual path is grounded in the natural world."
        personaDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        personaDetailLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        personaDetailLabel.numberOfLines = 0
        spiritualPersonaView.addSubview(personaDetailLabel)
    }

    private func setupPreferencesSection() {
        preferencesView.translatesAutoresizingMaskIntoConstraints = false
        preferencesView.backgroundColor = UIColor.white
        preferencesView.layer.cornerRadius = 12
        contentView.addSubview(preferencesView)

        // Title
        preferencesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        preferencesTitleLabel.text = "Your Preferences"
        preferencesTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        preferencesTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        preferencesView.addSubview(preferencesTitleLabel)

        // Preferences Stack
        preferencesStackView.translatesAutoresizingMaskIntoConstraints = false
        preferencesStackView.axis = .vertical
        preferencesStackView.spacing = 16
        preferencesView.addSubview(preferencesStackView)

        // Add preference items
        let preferences = [
            (icon: "leaf.fill", title: "Nature & Mindfulness", isActive: true),
            (icon: "hands.pray.fill", title: "Prayer & Meditation", isActive: true),
            (icon: "heart.fill", title: "Love & Compassion", isActive: false)
        ]

        for preference in preferences {
            let preferenceItem = createPreferenceItem(icon: preference.icon, title: preference.title, isActive: preference.isActive)
            preferencesStackView.addArrangedSubview(preferenceItem)
        }
    }

    private func createPreferenceItem(icon: String, title: String, isActive: Bool) -> UIView {
        let itemView = UIView()
        itemView.translatesAutoresizingMaskIntoConstraints = false

        // Icon
        let iconView = UIView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        iconView.layer.cornerRadius = 16
        itemView.addSubview(iconView)

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = UIColor.white
        iconImageView.contentMode = .scaleAspectFit
        iconView.addSubview(iconImageView)

        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        itemView.addSubview(titleLabel)

        // Active indicator
        let activeIndicator = UIView()
        activeIndicator.translatesAutoresizingMaskIntoConstraints = false
        activeIndicator.backgroundColor = isActive ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        activeIndicator.layer.cornerRadius = 4
        itemView.addSubview(activeIndicator)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: itemView.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),

            activeIndicator.trailingAnchor.constraint(equalTo: itemView.trailingAnchor),
            activeIndicator.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
            activeIndicator.widthAnchor.constraint(equalToConstant: 8),
            activeIndicator.heightAnchor.constraint(equalToConstant: 8),

            itemView.heightAnchor.constraint(equalToConstant: 32)
        ])

        return itemView
    }

    private func setupAICompanionSection() {
        aiCompanionView.translatesAutoresizingMaskIntoConstraints = false
        aiCompanionView.backgroundColor = UIColor.white
        aiCompanionView.layer.cornerRadius = 12
        contentView.addSubview(aiCompanionView)

        // Title
        aiCompanionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        aiCompanionTitleLabel.text = "AI Companion"
        aiCompanionTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        aiCompanionTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        aiCompanionView.addSubview(aiCompanionTitleLabel)

        // Companion Container
        companionContainerView.translatesAutoresizingMaskIntoConstraints = false
        companionContainerView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        companionContainerView.layer.cornerRadius = 12
        companionContainerView.layer.borderWidth = 1
        companionContainerView.layer.borderColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor
        aiCompanionView.addSubview(companionContainerView)

        // Companion Avatar
        companionAvatarView.translatesAutoresizingMaskIntoConstraints = false
        companionAvatarView.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        companionAvatarView.layer.cornerRadius = 20
        companionContainerView.addSubview(companionAvatarView)

        // Companion Name
        companionNameLabel.translatesAutoresizingMaskIntoConstraints = false
        companionNameLabel.text = "Sage"
        companionNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        companionNameLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        companionContainerView.addSubview(companionNameLabel)

        // Companion Description
        companionDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        companionDescriptionLabel.text = "Your spiritual guide"
        companionDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        companionDescriptionLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        companionContainerView.addSubview(companionDescriptionLabel)

        // Companion Detail
        companionDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        companionDetailLabel.text = "Attuned to your nature-centered path. Ready to guide your journey with wisdom and compassion."
        companionDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        companionDetailLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        companionDetailLabel.numberOfLines = 0
        companionContainerView.addSubview(companionDetailLabel)

        // Start Conversation Button
        startConversationButton.translatesAutoresizingMaskIntoConstraints = false
        startConversationButton.setTitle("💬 Start Conversation", for: .normal)
        startConversationButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        startConversationButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal)
        startConversationButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        startConversationButton.layer.cornerRadius = 8
        companionContainerView.addSubview(startConversationButton)
    }

    private func setupJourneySection() {
        journeyView.translatesAutoresizingMaskIntoConstraints = false
        journeyView.backgroundColor = UIColor.white
        journeyView.layer.cornerRadius = 12
        contentView.addSubview(journeyView)

        // Title
        journeyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        journeyTitleLabel.text = "Your Journey"
        journeyTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        journeyTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        journeyView.addSubview(journeyTitleLabel)

        // Journey Stats
        journeyStatsView.translatesAutoresizingMaskIntoConstraints = false
        journeyView.addSubview(journeyStatsView)

        // Days Active
        daysActiveValueLabel.translatesAutoresizingMaskIntoConstraints = false
        daysActiveValueLabel.text = "12"
        daysActiveValueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        daysActiveValueLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        daysActiveValueLabel.textAlignment = .center
        journeyStatsView.addSubview(daysActiveValueLabel)

        daysActiveLabel.translatesAutoresizingMaskIntoConstraints = false
        daysActiveLabel.text = "Days Active"
        daysActiveLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        daysActiveLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        daysActiveLabel.textAlignment = .center
        journeyStatsView.addSubview(daysActiveLabel)

        // Conversations
        conversationsValueLabel.translatesAutoresizingMaskIntoConstraints = false
        conversationsValueLabel.text = "38"
        conversationsValueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        conversationsValueLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        conversationsValueLabel.textAlignment = .center
        journeyStatsView.addSubview(conversationsValueLabel)

        conversationsLabel.translatesAutoresizingMaskIntoConstraints = false
        conversationsLabel.text = "Conversations"
        conversationsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        conversationsLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        conversationsLabel.textAlignment = .center
        journeyStatsView.addSubview(conversationsLabel)
    }

    private func setupEditProfileButton() {
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.setTitle("Edit Profile", for: .normal)
        editProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        editProfileButton.setTitleColor(UIColor.white, for: .normal)
        editProfileButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        editProfileButton.layer.cornerRadius = 12
        contentView.addSubview(editProfileButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            menuButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            menuButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 24),
            menuButton.heightAnchor.constraint(equalToConstant: 24),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            // Profile Edit Button
            profileEditButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 4),
            profileEditButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 4),
            profileEditButton.widthAnchor.constraint(equalToConstant: 24),
            profileEditButton.heightAnchor.constraint(equalToConstant: 24),

            // Name Label
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Spiritual Persona Section
            spiritualPersonaView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            spiritualPersonaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            spiritualPersonaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            spiritualPersonaTitleLabel.topAnchor.constraint(equalTo: spiritualPersonaView.topAnchor, constant: 16),
            spiritualPersonaTitleLabel.leadingAnchor.constraint(equalTo: spiritualPersonaView.leadingAnchor, constant: 16),

            personaIconView.topAnchor.constraint(equalTo: spiritualPersonaTitleLabel.bottomAnchor, constant: 16),
            personaIconView.leadingAnchor.constraint(equalTo: spiritualPersonaView.leadingAnchor, constant: 16),
            personaIconView.widthAnchor.constraint(equalToConstant: 40),
            personaIconView.heightAnchor.constraint(equalToConstant: 40),

            personaIconImageView.centerXAnchor.constraint(equalTo: personaIconView.centerXAnchor),
            personaIconImageView.centerYAnchor.constraint(equalTo: personaIconView.centerYAnchor),
            personaIconImageView.widthAnchor.constraint(equalToConstant: 20),
            personaIconImageView.heightAnchor.constraint(equalToConstant: 20),

            personaNameLabel.leadingAnchor.constraint(equalTo: personaIconView.trailingAnchor, constant: 12),
            personaNameLabel.topAnchor.constraint(equalTo: personaIconView.topAnchor, constant: 2),

            personaDescriptionLabel.leadingAnchor.constraint(equalTo: personaNameLabel.leadingAnchor),
            personaDescriptionLabel.topAnchor.constraint(equalTo: personaNameLabel.bottomAnchor, constant: 2),

            personaDetailLabel.topAnchor.constraint(equalTo: personaIconView.bottomAnchor, constant: 16),
            personaDetailLabel.leadingAnchor.constraint(equalTo: spiritualPersonaView.leadingAnchor, constant: 16),
            personaDetailLabel.trailingAnchor.constraint(equalTo: spiritualPersonaView.trailingAnchor, constant: -16),
            personaDetailLabel.bottomAnchor.constraint(equalTo: spiritualPersonaView.bottomAnchor, constant: -16),

            // Preferences Section
            preferencesView.topAnchor.constraint(equalTo: spiritualPersonaView.bottomAnchor, constant: 24),
            preferencesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            preferencesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            preferencesTitleLabel.topAnchor.constraint(equalTo: preferencesView.topAnchor, constant: 16),
            preferencesTitleLabel.leadingAnchor.constraint(equalTo: preferencesView.leadingAnchor, constant: 16),

            preferencesStackView.topAnchor.constraint(equalTo: preferencesTitleLabel.bottomAnchor, constant: 16),
            preferencesStackView.leadingAnchor.constraint(equalTo: preferencesView.leadingAnchor, constant: 16),
            preferencesStackView.trailingAnchor.constraint(equalTo: preferencesView.trailingAnchor, constant: -16),
            preferencesStackView.bottomAnchor.constraint(equalTo: preferencesView.bottomAnchor, constant: -16),

            // AI Companion Section
            aiCompanionView.topAnchor.constraint(equalTo: preferencesView.bottomAnchor, constant: 24),
            aiCompanionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            aiCompanionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            aiCompanionTitleLabel.topAnchor.constraint(equalTo: aiCompanionView.topAnchor, constant: 16),
            aiCompanionTitleLabel.leadingAnchor.constraint(equalTo: aiCompanionView.leadingAnchor, constant: 16),

            companionContainerView.topAnchor.constraint(equalTo: aiCompanionTitleLabel.bottomAnchor, constant: 16),
            companionContainerView.leadingAnchor.constraint(equalTo: aiCompanionView.leadingAnchor, constant: 16),
            companionContainerView.trailingAnchor.constraint(equalTo: aiCompanionView.trailingAnchor, constant: -16),
            companionContainerView.bottomAnchor.constraint(equalTo: aiCompanionView.bottomAnchor, constant: -16),

            companionAvatarView.topAnchor.constraint(equalTo: companionContainerView.topAnchor, constant: 16),
            companionAvatarView.leadingAnchor.constraint(equalTo: companionContainerView.leadingAnchor, constant: 16),
            companionAvatarView.widthAnchor.constraint(equalToConstant: 40),
            companionAvatarView.heightAnchor.constraint(equalToConstant: 40),

            companionNameLabel.leadingAnchor.constraint(equalTo: companionAvatarView.trailingAnchor, constant: 12),
            companionNameLabel.topAnchor.constraint(equalTo: companionAvatarView.topAnchor, constant: 2),

            companionDescriptionLabel.leadingAnchor.constraint(equalTo: companionNameLabel.leadingAnchor),
            companionDescriptionLabel.topAnchor.constraint(equalTo: companionNameLabel.bottomAnchor, constant: 2),

            companionDetailLabel.topAnchor.constraint(equalTo: companionAvatarView.bottomAnchor, constant: 16),
            companionDetailLabel.leadingAnchor.constraint(equalTo: companionContainerView.leadingAnchor, constant: 16),
            companionDetailLabel.trailingAnchor.constraint(equalTo: companionContainerView.trailingAnchor, constant: -16),

            startConversationButton.topAnchor.constraint(equalTo: companionDetailLabel.bottomAnchor, constant: 16),
            startConversationButton.leadingAnchor.constraint(equalTo: companionContainerView.leadingAnchor, constant: 16),
            startConversationButton.trailingAnchor.constraint(equalTo: companionContainerView.trailingAnchor, constant: -16),
            startConversationButton.heightAnchor.constraint(equalToConstant: 44),
            startConversationButton.bottomAnchor.constraint(equalTo: companionContainerView.bottomAnchor, constant: -16),

            // Journey Section
            journeyView.topAnchor.constraint(equalTo: aiCompanionView.bottomAnchor, constant: 24),
            journeyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            journeyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            journeyTitleLabel.topAnchor.constraint(equalTo: journeyView.topAnchor, constant: 16),
            journeyTitleLabel.leadingAnchor.constraint(equalTo: journeyView.leadingAnchor, constant: 16),

            journeyStatsView.topAnchor.constraint(equalTo: journeyTitleLabel.bottomAnchor, constant: 16),
            journeyStatsView.leadingAnchor.constraint(equalTo: journeyView.leadingAnchor, constant: 16),
            journeyStatsView.trailingAnchor.constraint(equalTo: journeyView.trailingAnchor, constant: -16),
            journeyStatsView.bottomAnchor.constraint(equalTo: journeyView.bottomAnchor, constant: -16),
            journeyStatsView.heightAnchor.constraint(equalToConstant: 80),

            // Journey Stats Layout
            daysActiveValueLabel.leadingAnchor.constraint(equalTo: journeyStatsView.leadingAnchor),
            daysActiveValueLabel.topAnchor.constraint(equalTo: journeyStatsView.topAnchor),
            daysActiveValueLabel.widthAnchor.constraint(equalTo: journeyStatsView.widthAnchor, multiplier: 0.5),

            daysActiveLabel.leadingAnchor.constraint(equalTo: daysActiveValueLabel.leadingAnchor),
            daysActiveLabel.topAnchor.constraint(equalTo: daysActiveValueLabel.bottomAnchor, constant: 4),
            daysActiveLabel.widthAnchor.constraint(equalTo: daysActiveValueLabel.widthAnchor),

            conversationsValueLabel.trailingAnchor.constraint(equalTo: journeyStatsView.trailingAnchor),
            conversationsValueLabel.topAnchor.constraint(equalTo: journeyStatsView.topAnchor),
            conversationsValueLabel.widthAnchor.constraint(equalTo: journeyStatsView.widthAnchor, multiplier: 0.5),

            conversationsLabel.trailingAnchor.constraint(equalTo: conversationsValueLabel.trailingAnchor),
            conversationsLabel.topAnchor.constraint(equalTo: conversationsValueLabel.bottomAnchor, constant: 4),
            conversationsLabel.widthAnchor.constraint(equalTo: conversationsValueLabel.widthAnchor),

            // Edit Profile Button
            editProfileButton.topAnchor.constraint(equalTo: journeyView.bottomAnchor, constant: 32),
            editProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            editProfileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            editProfileButton.heightAnchor.constraint(equalToConstant: 50),
            editProfileButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        profileEditButton.addTarget(self, action: #selector(profileEditButtonTapped), for: .touchUpInside)
        startConversationButton.addTarget(self, action: #selector(startConversationButtonTapped), for: .touchUpInside)
        editProfileButton.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func menuButtonTapped() {
        print("Menu button tapped")
    }

    @objc private func profileEditButtonTapped() {
        print("Profile edit button tapped")
    }

    @objc private func startConversationButtonTapped() {
        print("Start conversation button tapped")
        // Navigate to chat
    }

    @objc private func editProfileButtonTapped() {
        print("Edit profile button tapped")
    }

    // MARK: - Helper Methods
    private func findCustomTabBarController() -> CustomTabBarController? {
        var currentController: UIViewController? = self
        while let controller = currentController {
            if let customTabBarController = controller as? CustomTabBarController {
                return customTabBarController
            }
            currentController = controller.parent
        }
        return nil
    }
}