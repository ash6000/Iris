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
    private let titleLabel = UILabel()

    // Profile Section
    private let profileView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let memberLabel = UILabel()
    private let profileArrowImageView = UIImageView()

    // Sections Stack View
    private let sectionsStackView = UIStackView()

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
        setupSections()
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(headerView)


        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
    }

    private func setupProfileSection() {
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.backgroundColor = UIColor.white
        profileView.layer.cornerRadius = 12
        contentView.addSubview(profileView)

        // Profile Image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        profileImageView.contentMode = .scaleAspectFit
        profileView.addSubview(profileImageView)

        // Name Label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Sarah Chen"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        profileView.addSubview(nameLabel)

        // Member Label
        memberLabel.translatesAutoresizingMaskIntoConstraints = false
        memberLabel.text = "Member since January 2025"
        memberLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        memberLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        profileView.addSubview(memberLabel)

        // Arrow
        profileArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        profileArrowImageView.image = UIImage(systemName: "chevron.right")
        profileArrowImageView.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        profileView.addSubview(profileArrowImageView)
    }

    private func setupSections() {
        sectionsStackView.translatesAutoresizingMaskIntoConstraints = false
        sectionsStackView.axis = .vertical
        sectionsStackView.spacing = 24
        contentView.addSubview(sectionsStackView)

        // Notifications Section
        let notificationsSection = createSection(title: "Notifications", items: [
            SettingsItem(icon: "bell.fill", title: "Daily Reminders", subtitle: "Meditation and reflection prompts", hasToggle: true, isToggleOn: true),
            SettingsItem(icon: "message.fill", title: "AI Companion Messages", subtitle: "Guidance and wisdom sharing", hasToggle: true, isToggleOn: true),
            SettingsItem(icon: "star.fill", title: "Weekly Insights", subtitle: "Progress and spiritual growth updates", hasToggle: true, isToggleOn: false)
        ])
        sectionsStackView.addArrangedSubview(notificationsSection)

        // Preferences Section
        let preferencesSection = createSection(title: "Preferences", items: [
            SettingsItem(icon: "paintbrush.fill", title: "Theme & Appearance", subtitle: "Customize your visual experience", hasToggle: false),
            SettingsItem(icon: "globe", title: "Language", subtitle: "English (US)", hasToggle: false),
            SettingsItem(icon: "moon.fill", title: "Quiet Hours", subtitle: "10:00 PM - 7:00 AM", hasToggle: false)
        ])
        sectionsStackView.addArrangedSubview(preferencesSection)

        // Account Section
        let accountSection = createSection(title: "Account", items: [
            SettingsItem(icon: "shield.fill", title: "Privacy & Security", subtitle: nil, hasToggle: false),
            SettingsItem(icon: "square.and.arrow.down.fill", title: "Export Data", subtitle: nil, hasToggle: false),
            SettingsItem(icon: "questionmark.circle.fill", title: "Help & Support", subtitle: nil, hasToggle: false),
            SettingsItem(icon: "rectangle.portrait.and.arrow.right.fill", title: "Sign Out", subtitle: nil, hasToggle: false)
        ])
        sectionsStackView.addArrangedSubview(accountSection)

        // Footer
        let footerView = createFooter()
        sectionsStackView.addArrangedSubview(footerView)
    }

    private func createSection(title: String, items: [SettingsItem]) -> UIView {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false

        // Section Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        sectionView.addSubview(titleLabel)

        // Items Container
        let itemsContainer = UIView()
        itemsContainer.translatesAutoresizingMaskIntoConstraints = false
        itemsContainer.backgroundColor = UIColor.white
        itemsContainer.layer.cornerRadius = 12
        sectionView.addSubview(itemsContainer)

        // Create items
        var lastView: UIView = itemsContainer
        for (index, item) in items.enumerated() {
            let itemView = createSettingsItemView(item: item)
            itemsContainer.addSubview(itemView)

            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: itemsContainer.leadingAnchor),
                itemView.trailingAnchor.constraint(equalTo: itemsContainer.trailingAnchor),
                itemView.heightAnchor.constraint(equalToConstant: 60)
            ])

            if index == 0 {
                itemView.topAnchor.constraint(equalTo: itemsContainer.topAnchor).isActive = true
            } else {
                itemView.topAnchor.constraint(equalTo: lastView.bottomAnchor).isActive = true
            }

            if index == items.count - 1 {
                itemView.bottomAnchor.constraint(equalTo: itemsContainer.bottomAnchor).isActive = true
            }

            // Add separator
            if index < items.count - 1 {
                let separator = UIView()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
                itemsContainer.addSubview(separator)

                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: itemsContainer.leadingAnchor, constant: 56),
                    separator.trailingAnchor.constraint(equalTo: itemsContainer.trailingAnchor),
                    separator.bottomAnchor.constraint(equalTo: itemView.bottomAnchor),
                    separator.heightAnchor.constraint(equalToConstant: 1)
                ])
            }

            lastView = itemView
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),

            itemsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            itemsContainer.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            itemsContainer.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),
            itemsContainer.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor)
        ])

        return sectionView
    }

    private func createSettingsItemView(item: SettingsItem) -> UIView {
        let itemView = UIView()
        itemView.translatesAutoresizingMaskIntoConstraints = false

        // Add tap gesture for non-toggle items
        if !item.hasToggle {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(settingsItemTapped(_:)))
            itemView.addGestureRecognizer(tapGesture)
            itemView.isUserInteractionEnabled = true
        }

        // Icon Background
        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        iconBackground.layer.cornerRadius = 8
        itemView.addSubview(iconBackground)

        // Icon
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: item.icon)
        iconImageView.tintColor = UIColor.white
        iconImageView.contentMode = .scaleAspectFit
        iconBackground.addSubview(iconImageView)

        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = item.title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        itemView.addSubview(titleLabel)

        // Subtitle (optional)
        var subtitleLabel: UILabel?
        if let subtitle = item.subtitle {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = subtitle
            label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            itemView.addSubview(label)
            subtitleLabel = label
        }

        // Toggle or Arrow
        if item.hasToggle {
            let toggle = UISwitch()
            toggle.translatesAutoresizingMaskIntoConstraints = false
            toggle.onTintColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
            toggle.isOn = item.isToggleOn
            itemView.addSubview(toggle)

            NSLayoutConstraint.activate([
                toggle.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
                toggle.trailingAnchor.constraint(equalTo: itemView.trailingAnchor, constant: -16)
            ])
        } else {
            let arrowImageView = UIImageView()
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
            arrowImageView.image = UIImage(systemName: "chevron.right")
            arrowImageView.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            itemView.addSubview(arrowImageView)

            NSLayoutConstraint.activate([
                arrowImageView.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
                arrowImageView.trailingAnchor.constraint(equalTo: itemView.trailingAnchor, constant: -16),
                arrowImageView.widthAnchor.constraint(equalToConstant: 12),
                arrowImageView.heightAnchor.constraint(equalToConstant: 12)
            ])
        }

        // Constraints
        NSLayoutConstraint.activate([
            iconBackground.leadingAnchor.constraint(equalTo: itemView.leadingAnchor, constant: 16),
            iconBackground.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 32),
            iconBackground.heightAnchor.constraint(equalToConstant: 32),

            iconImageView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: itemView.trailingAnchor, constant: -60)
        ])

        if let subtitleLabel = subtitleLabel {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: itemView.topAnchor, constant: 12),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
            ])
        } else {
            titleLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor).isActive = true
        }

        return itemView
    }

    private func createFooter() -> UIView {
        let footerView = UIView()
        footerView.translatesAutoresizingMaskIntoConstraints = false

        let appVersionLabel = UILabel()
        appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        appVersionLabel.text = "Spiritual Companion v2.1.0"
        appVersionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        appVersionLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        appVersionLabel.textAlignment = .center
        footerView.addSubview(appVersionLabel)

        let linksStackView = UIStackView()
        linksStackView.translatesAutoresizingMaskIntoConstraints = false
        linksStackView.axis = .horizontal
        linksStackView.spacing = 16
        linksStackView.alignment = .center
        footerView.addSubview(linksStackView)

        let termsLabel = UILabel()
        termsLabel.text = "Terms of Service"
        termsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        termsLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        linksStackView.addArrangedSubview(termsLabel)

        let privacyLabel = UILabel()
        privacyLabel.text = "Privacy Policy"
        privacyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        privacyLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        linksStackView.addArrangedSubview(privacyLabel)

        NSLayoutConstraint.activate([
            appVersionLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 32),
            appVersionLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),

            linksStackView.topAnchor.constraint(equalTo: appVersionLabel.bottomAnchor, constant: 8),
            linksStackView.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            linksStackView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -32)
        ])

        return footerView
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
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

            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),


            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            // Profile View
            profileView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            profileView.heightAnchor.constraint(equalToConstant: 80),

            profileImageView.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: profileView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),

            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: profileArrowImageView.leadingAnchor, constant: -12),

            memberLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            memberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            memberLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            profileArrowImageView.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -16),
            profileArrowImageView.centerYAnchor.constraint(equalTo: profileView.centerYAnchor),
            profileArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            profileArrowImageView.heightAnchor.constraint(equalToConstant: 12),

            // Sections
            sectionsStackView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 32),
            sectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sectionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupActions() {
        // Add tap gesture to profile view
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewTapped))
        profileView.addGestureRecognizer(profileTapGesture)
        profileView.isUserInteractionEnabled = true
    }

    // MARK: - Action Methods
    @objc private func profileViewTapped() {
        let profileViewController = ProfileViewController()
        navigationController?.pushViewController(profileViewController, animated: true)
    }

    @objc private func settingsItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let itemView = gesture.view else { return }

        // Find the title label to identify which item was tapped
        for subview in itemView.subviews {
            if let titleLabel = subview as? UILabel,
               let title = titleLabel.text {
                handleSettingsItemTap(title: title)
                break
            }
        }
    }

    private func handleSettingsItemTap(title: String) {
        switch title {
        case "Sign Out":
            showSignOutConfirmation()
        case "Privacy & Security":
            // Handle privacy settings
            print("Privacy & Security tapped")
        case "Export Data":
            // Handle data export
            print("Export Data tapped")
        case "Help & Support":
            // Handle help
            print("Help & Support tapped")
        case "Theme & Appearance":
            // Handle theme settings
            print("Theme & Appearance tapped")
        case "Language":
            // Handle language settings
            print("Language tapped")
        case "Quiet Hours":
            // Handle quiet hours settings
            print("Quiet Hours tapped")
        default:
            print("Unknown settings item tapped: \(title)")
        }
    }

    private func showSignOutConfirmation() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out? You'll need to go through the onboarding process again.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performSignOut()
        })

        present(alert, animated: true)
    }

    private func performSignOut() {
        // Reset onboarding completion flag
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.synchronize()

        // Navigate back to the first step of onboarding
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let createProfileViewController = CreateProfileViewController()

            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = createProfileViewController
            }, completion: nil)
        }
    }
}

// MARK: - Settings Item Model
struct SettingsItem {
    let icon: String
    let title: String
    let subtitle: String?
    let hasToggle: Bool
    let isToggleOn: Bool

    init(icon: String, title: String, subtitle: String? = nil, hasToggle: Bool = false, isToggleOn: Bool = false) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.hasToggle = hasToggle
        self.isToggleOn = isToggleOn
    }
}