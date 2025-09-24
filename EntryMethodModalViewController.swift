//
//  EntryMethodModalViewController.swift
//  irisOne
//
//  Created by Test User on 9/21/25.
//

import UIKit

protocol EntryMethodModalDelegate: AnyObject {
    func didSelectEntryMethod(type: EntryMethodType)
}

enum EntryMethodType {
    case voice
    case text
    case guided
}

class EntryMethodModalViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: EntryMethodModalDelegate?

    // MARK: - UI Components
    private let containerView = UIView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    private let separatorView = UIView()

    private let optionsStackView = UIStackView()
    private let footerLabel = UILabel()

    // Entry method options
    private let entryMethods: [(icon: String, title: String, subtitle: String)] = [
        ("mic.fill", "Voice Entry", "Speak your thoughts naturally"),
        ("pencil", "Text Entry", "Write freely with prompts"),
        ("bubble.left.and.bubble.right.fill", "Guided Entry", "AI-assisted reflection")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        containerView.layer.cornerRadius = 20
        containerView.layer.cornerCurve = .continuous
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 16
        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        containerView.alpha = 0
        view.addSubview(containerView)

        setupHeader()
        setupOptions()
        setupFooter()
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerView)

        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Choose Entry Method"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .left
        headerView.addSubview(titleLabel)

        // Close Button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        closeButton.backgroundColor = UIColor.clear
        headerView.addSubview(closeButton)

        // Separator
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        containerView.addSubview(separatorView)
    }

    private func setupOptions() {
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 16
        optionsStackView.alignment = .fill
        containerView.addSubview(optionsStackView)

        for (index, method) in entryMethods.enumerated() {
            let optionView = createEntryMethodOption(
                icon: method.icon,
                title: method.title,
                subtitle: method.subtitle,
                tag: index
            )
            optionsStackView.addArrangedSubview(optionView)
        }
    }

    private func createEntryMethodOption(icon: String, title: String, subtitle: String, tag: Int) -> UIView {
        let optionView = UIView()
        optionView.translatesAutoresizingMaskIntoConstraints = false
        optionView.backgroundColor = UIColor.white
        optionView.layer.cornerRadius = 12
        optionView.layer.borderWidth = 1
        optionView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        optionView.tag = tag

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(entryMethodTapped(_:)))
        optionView.addGestureRecognizer(tapGesture)
        optionView.isUserInteractionEnabled = true

        // Icon
        let iconView = UIView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        iconView.layer.cornerRadius = 20
        optionView.addSubview(iconView)

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconView.addSubview(iconImageView)

        // Text Container
        let textStackView = UIStackView()
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .leading
        optionView.addSubview(textStackView)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        textStackView.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        textStackView.addArrangedSubview(subtitleLabel)

        // Arrow
        let arrowImageView = UIImageView()
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        arrowImageView.contentMode = .scaleAspectFit
        optionView.addSubview(arrowImageView)

        // Constraints
        NSLayoutConstraint.activate([
            optionView.heightAnchor.constraint(equalToConstant: 80),

            iconView.leadingAnchor.constraint(equalTo: optionView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: optionView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            textStackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            textStackView.centerYAnchor.constraint(equalTo: optionView.centerYAnchor),
            textStackView.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -16),

            arrowImageView.trailingAnchor.constraint(equalTo: optionView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: optionView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12)
        ])

        return optionView
    }

    private func setupFooter() {
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.text = "Choose the method that feels right for your current mood and available time"
        footerLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        footerLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        containerView.addSubview(footerLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            // Header View
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            // Close Button
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            // Separator
            separatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            // Options Stack View
            optionsStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            optionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            // Footer Label
            footerLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 24),
            footerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            footerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            footerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        // Add tap gesture to background to dismiss
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(backgroundTap)
    }

    // MARK: - Animation Methods
    private func animateIn() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.containerView.transform = CGAffineTransform.identity
            self.containerView.alpha = 1
        }
    }

    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.containerView.alpha = 0
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        } completion: { _ in
            completion()
        }
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismissModal()
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            dismissModal()
        }
    }

    @objc private func entryMethodTapped(_ gesture: UITapGestureRecognizer) {
        guard let optionView = gesture.view else { return }
        let methodIndex = optionView.tag

        // Add visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            optionView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                optionView.transform = CGAffineTransform.identity
            }
        }

        // Handle selection
        handleEntryMethodSelection(index: methodIndex)
    }

    private func handleEntryMethodSelection(index: Int) {
        let methodNames = ["Voice Entry", "Text Entry", "Guided Entry"]
        let selectedMethod = methodNames[index]

        print("Selected entry method: \(selectedMethod)")

        let entryType: EntryMethodType
        switch index {
        case 0:
            entryType = .voice
        case 1:
            entryType = .text
        case 2:
            entryType = .guided
        default:
            return
        }

        // Dismiss modal and handle navigation
        animateOut {
            self.dismiss(animated: false) {
                // Try delegate first, then fallback to direct navigation
                if let delegate = self.delegate {
                    delegate.didSelectEntryMethod(type: entryType)
                } else {
                    // Fallback to direct navigation
                    switch entryType {
                    case .voice:
                        DispatchQueue.main.async {
                            self.navigateToVoiceEntry()
                        }
                    case .text:
                        DispatchQueue.main.async {
                            self.navigateToTextEntry()
                        }
                    case .guided:
                        DispatchQueue.main.async {
                            self.navigateToGuidedEntry()
                        }
                    }
                }
            }
        }
    }

    private func navigateToVoiceEntry() {
        // Find the presenting view controller and its navigation controller
        var currentVC = self.presentingViewController

        // If the presenting VC is a navigation controller, use it directly
        if let navController = currentVC as? UINavigationController {
            let voiceEntryVC = VoiceEntryViewController_MVVM()
            navController.pushViewController(voiceEntryVC, animated: true)
            return
        }

        // Otherwise, find the navigation controller in the hierarchy
        while currentVC != nil {
            if let navController = currentVC?.navigationController {
                let voiceEntryVC = VoiceEntryViewController_MVVM()
                navController.pushViewController(voiceEntryVC, animated: true)
                return
            }
            currentVC = currentVC?.parent
        }

        // Fallback: If no navigation controller found, try to find one through the window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {

            // Navigate through the CustomTabBarController structure
            if let customTabBar = rootVC as? CustomTabBarController {
                // Find the journal navigation controller (index 3 based on CustomTabBarController setup)
                if let journalNavController = customTabBar.reflectNavigationController {
                    let voiceEntryVC = VoiceEntryViewController_MVVM()
                    journalNavController.pushViewController(voiceEntryVC, animated: true)
                }
            }
        }
    }

    private func navigateToTextEntry() {
        // Find the presenting view controller and its navigation controller
        var currentVC = self.presentingViewController

        // If the presenting VC is a navigation controller, use it directly
        if let navController = currentVC as? UINavigationController {
            let textEntryVC = TextEntryViewController_MVVM()
            navController.pushViewController(textEntryVC, animated: true)
            return
        }

        // Otherwise, find the navigation controller in the hierarchy
        while currentVC != nil {
            if let navController = currentVC?.navigationController {
                let textEntryVC = TextEntryViewController_MVVM()
                navController.pushViewController(textEntryVC, animated: true)
                return
            }
            currentVC = currentVC?.parent
        }

        // Fallback: If no navigation controller found, try to find one through the window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {

            // Navigate through the CustomTabBarController structure
            if let customTabBar = rootVC as? CustomTabBarController {
                // Find the journal navigation controller (index 3 based on CustomTabBarController setup)
                if let journalNavController = customTabBar.reflectNavigationController {
                    let textEntryVC = TextEntryViewController_MVVM()
                    journalNavController.pushViewController(textEntryVC, animated: true)
                }
            }
        }
    }

    private func navigateToGuidedEntry() {
        // Find the presenting view controller and its navigation controller
        var currentVC = self.presentingViewController

        // If the presenting VC is a navigation controller, use it directly
        if let navController = currentVC as? UINavigationController {
            let guidedEntryVC = GuidedEntryViewController_MVVM()
            navController.pushViewController(guidedEntryVC, animated: true)
            return
        }

        // Otherwise, find the navigation controller in the hierarchy
        while currentVC != nil {
            if let navController = currentVC?.navigationController {
                let guidedEntryVC = GuidedEntryViewController_MVVM()
                navController.pushViewController(guidedEntryVC, animated: true)
                return
            }
            currentVC = currentVC?.parent
        }

        // Fallback: If no navigation controller found, try to find one through the window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {

            // Navigate through the CustomTabBarController structure
            if let customTabBar = rootVC as? CustomTabBarController {
                // Find the journal navigation controller (index 3 based on CustomTabBarController setup)
                if let journalNavController = customTabBar.reflectNavigationController {
                    let guidedEntryVC = GuidedEntryViewController_MVVM()
                    journalNavController.pushViewController(guidedEntryVC, animated: true)
                }
            }
        }
    }

    private func dismissModal() {
        animateOut {
            self.dismiss(animated: false)
        }
    }
}