import Foundation
import UIKit

// MARK: - Custom Tab Bar Controller
class CustomTabBarController: UIViewController {
    
    // Tab Bar UI
    private let tabBarView = UIView()
    private let tabStackView = UIStackView()
    private var tabButtons: [UIButton] = []
    
    // Content container
    private let contentContainerView = UIView()
    private var currentViewController: UIViewController?
    
    // View Controllers - Updated: ChatViewController is now Home, Reflect is placeholder
    var homeNavigationController: UINavigationController!
    var moodNavigationController: UINavigationController!
    var relaxNavigationController: UINavigationController!
    var reflectNavigationController: UINavigationController!
    var moreNavigationController: UINavigationController!
    
    private var selectedTabIndex = 0
    
    // Computed property to match extension usage
    var selectedViewController: UIViewController? {
        return currentViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupUI()
        setupConstraints()
        
        // Initialize the chat tab immediately after setup
        DispatchQueue.main.async {
            self.selectTab(at: 2)
        }
    }
    
    private func setupViewControllers() {
        // Home tab - New Home Screen Design
        let homeVC = HomeViewController()
        homeVC.customTabBarController = self
        homeNavigationController = UINavigationController(rootViewController: homeVC)
        homeNavigationController.isNavigationBarHidden = true

        // Library tab - Music/Relax functionality
        let libraryVC = RelaxViewController()
        moodNavigationController = UINavigationController(rootViewController: libraryVC)
        moodNavigationController.isNavigationBarHidden = true

        // Chat tab - PersonalizedChatViewController
        let chatVC = PersonalizedChatViewController()
        relaxNavigationController = UINavigationController(rootViewController: chatVC)
        relaxNavigationController.isNavigationBarHidden = true

        // Journal tab - JournalViewController_MVVM
        let journalVC = JournalViewController_MVVM()
        reflectNavigationController = UINavigationController(rootViewController: journalVC)
        reflectNavigationController.isNavigationBarHidden = true

        // Profile tab - Settings
        let profileVC = SettingsViewController()
        moreNavigationController = UINavigationController(rootViewController: profileVC)
        moreNavigationController.isNavigationBarHidden = true
    }
    
    private func createPlaceholderVC(title: String, color: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = color
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        // Content Container
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainerView)
        
        // Tab Bar
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.backgroundColor = UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 0.95)
        tabBarView.layer.cornerRadius = 20
        tabBarView.layer.cornerCurve = .continuous
        tabBarView.isUserInteractionEnabled = true
        view.addSubview(tabBarView)
        
        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        tabStackView.axis = .horizontal
        tabStackView.distribution = .fillEqually
        tabStackView.alignment = .center
        tabStackView.isUserInteractionEnabled = true
        tabBarView.addSubview(tabStackView)
        
        // Updated tab items to match image design more closely
        let tabItems = [
            ("house", "Home"),
            ("text.book.closed", "Library"),
            ("message", "Chat"),   // Center circular button
            ("book", "Journal"),
            ("person", "Profile")
        ]
        
        for (index, (icon, title)) in tabItems.enumerated() {
            let isCenterButton = index == 2 // Chat button is at index 2

            // Use standard UIButton for reliable touch handling
            let tabButton = UIButton(type: .custom)
            tabButton.tag = index
            tabButton.isUserInteractionEnabled = true
            tabButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)

            // Clean styling - no debug colors
            tabButton.backgroundColor = UIColor.clear

            if isCenterButton {
                // Center circular button
                let circularBackground = UIView()
                circularBackground.translatesAutoresizingMaskIntoConstraints = false
                circularBackground.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
                circularBackground.layer.cornerRadius = 30
                circularBackground.isUserInteractionEnabled = false
                tabButton.addSubview(circularBackground)

                let iconImageView = UIImageView()
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                iconImageView.image = UIImage(systemName: icon)
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.tintColor = UIColor.white
                iconImageView.isUserInteractionEnabled = false
                circularBackground.addSubview(iconImageView)

                NSLayoutConstraint.activate([
                    circularBackground.centerXAnchor.constraint(equalTo: tabButton.centerXAnchor),
                    circularBackground.centerYAnchor.constraint(equalTo: tabButton.centerYAnchor),
                    circularBackground.widthAnchor.constraint(equalToConstant: 60),
                    circularBackground.heightAnchor.constraint(equalToConstant: 60),

                    iconImageView.centerXAnchor.constraint(equalTo: circularBackground.centerXAnchor),
                    iconImageView.centerYAnchor.constraint(equalTo: circularBackground.centerYAnchor),
                    iconImageView.widthAnchor.constraint(equalToConstant: 24),
                    iconImageView.heightAnchor.constraint(equalToConstant: 24)
                ])
            } else {
                // Regular tab button
                let stackView = UIStackView()
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.axis = .vertical
                stackView.alignment = .center
                stackView.spacing = 4
                stackView.isUserInteractionEnabled = false
                tabButton.addSubview(stackView)

                let iconImageView = UIImageView()
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                iconImageView.image = UIImage(systemName: icon)
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
                stackView.addArrangedSubview(iconImageView)

                let titleLabel = UILabel()
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.text = title
                titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                titleLabel.textAlignment = .center
                titleLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
                stackView.addArrangedSubview(titleLabel)

                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: tabButton.centerXAnchor),
                    stackView.centerYAnchor.constraint(equalTo: tabButton.centerYAnchor),
                    iconImageView.widthAnchor.constraint(equalToConstant: 20),
                    iconImageView.heightAnchor.constraint(equalToConstant: 20)
                ])
            }

            // Ensure proper touch area size
            tabButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tabButton.heightAnchor.constraint(equalToConstant: 54),
                tabButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
            ])

            tabStackView.addArrangedSubview(tabButton)
            tabButtons.append(tabButton)
            print("🔧 Added tab button \(index): \(title)")
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content Container
            contentContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: tabBarView.topAnchor, constant: -16),
            
            // Tab Bar
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            tabBarView.heightAnchor.constraint(equalToConstant: 70),
            
            // Tab Stack View
            tabStackView.topAnchor.constraint(equalTo: tabBarView.topAnchor, constant: 8),
            tabStackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor, constant: 16),
            tabStackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor, constant: -16),
            tabStackView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor, constant: -8)
        ])
    }
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        print("🔥 Tab button tapped: \(sender.tag)")
        selectTab(at: sender.tag)
    }
    
    func selectTab(at index: Int) {
        // If immersive view is showing, dismiss it first
        dismissImmersiveChat()
        
        // Handle tab re-selection to go back to root view controller
        if index == selectedTabIndex && currentViewController != nil {
            switch index {
            case 0: // Home tab
                homeNavigationController?.popToRootViewController(animated: true)
            case 1: // Library tab
                moodNavigationController?.popToRootViewController(animated: true)
            case 2: // Chat tab
                relaxNavigationController?.popToRootViewController(animated: true)
            case 3: // Journal tab
                reflectNavigationController?.popToRootViewController(animated: true)
            case 4: // Profile tab
                moreNavigationController?.popToRootViewController(animated: true)
            default:
                break
            }
            return
        }
        
        selectedTabIndex = index
        
        // Update tab button states
        for (i, button) in tabButtons.enumerated() {
            updateTabButtonAppearance(button: button, index: i, isSelected: i == index)
        }
        
        // Switch view controller - Updated mapping for new tab layout
        let viewControllerToShow: UIViewController?
        switch index {
        case 0: viewControllerToShow = homeNavigationController      // Home - Today's Mode
        case 1: viewControllerToShow = moodNavigationController      // Library - Music/Relax
        case 2: viewControllerToShow = relaxNavigationController     // Chat - PersonalizedChatViewController
        case 3: viewControllerToShow = reflectNavigationController   // Journal
        case 4: viewControllerToShow = moreNavigationController      // Profile - Settings
        default: return
        }

        guard let controllerToShow = viewControllerToShow else {
            print("Warning: Navigation controller is nil for tab index \(index)")
            return
        }

        switchToViewController(controllerToShow)
    }

    private func updateTabButtonAppearance(button: UIButton, index: Int, isSelected: Bool) {
        let selectedColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        let unselectedColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)

        if index == 2 { // Center button
            // Center button appearance doesn't change - it's always the pink circular button
            return
        } else {
            // Update regular tab button colors
            if let stackView = button.subviews.first as? UIStackView {
                if let iconImageView = stackView.arrangedSubviews.first as? UIImageView {
                    iconImageView.tintColor = isSelected ? selectedColor : unselectedColor
                }
                if let titleLabel = stackView.arrangedSubviews.last as? UILabel {
                    titleLabel.textColor = isSelected ? selectedColor : unselectedColor
                }
            }
        }
    }
    
    func switchToViewController(_ newViewController: UIViewController, newViewController newVC: UIViewController? = nil) {
        let controllerToShow = newVC ?? newViewController
        
        // Remove current view controller
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        // Add new view controller
        addChild(controllerToShow)
        contentContainerView.addSubview(controllerToShow.view)
        controllerToShow.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            controllerToShow.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            controllerToShow.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            controllerToShow.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            controllerToShow.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
        
        controllerToShow.didMove(toParent: self)
        currentViewController = controllerToShow
    }
}

// MARK: - Custom Tab Button
class TabButton: UIButton {

    private let iconImageView = UIImageView()
    private let customTitleLabel = UILabel()
    private let stackView = UIStackView()
    private let circularBackground = UIView()
    private let overlayView = UIView()

    private let selectedColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
    private let unselectedColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    private let isCenterButton: Bool

    init(icon: String, title: String, isSelected: Bool = false, isCenterButton: Bool = false) {
        self.isCenterButton = isCenterButton
        super.init(frame: .zero)
        setupUI(icon: icon, title: title)
        setSelected(isSelected)

        // Debug: Add visible background to see touch area
        self.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.red.cgColor

        // Add touch event handlers for overlay effect
        if isCenterButton {
            addTarget(self, action: #selector(buttonPressed), for: .touchDown)
            addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }

    @objc private func buttonPressed() {
        if isCenterButton {
            UIView.animate(withDuration: 0.1) {
                self.overlayView.alpha = 1
            }
        }
    }

    @objc private func buttonReleased() {
        if isCenterButton {
            UIView.animate(withDuration: 0.2) {
                self.overlayView.alpha = 0
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(icon: String, title: String) {
        if isCenterButton {
            // Center button with circular background
            circularBackground.translatesAutoresizingMaskIntoConstraints = false
            circularBackground.backgroundColor = selectedColor
            circularBackground.layer.cornerRadius = 30
            addSubview(circularBackground)

            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.image = UIImage(systemName: icon)
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.tintColor = UIColor.white
            circularBackground.addSubview(iconImageView)

            // Add overlay view for visual feedback
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            overlayView.layer.cornerRadius = 30
            overlayView.isUserInteractionEnabled = false
            overlayView.alpha = 0
            circularBackground.addSubview(overlayView)

            NSLayoutConstraint.activate([
                circularBackground.centerXAnchor.constraint(equalTo: centerXAnchor),
                circularBackground.centerYAnchor.constraint(equalTo: centerYAnchor),
                circularBackground.widthAnchor.constraint(equalToConstant: 60),
                circularBackground.heightAnchor.constraint(equalToConstant: 60),

                iconImageView.centerXAnchor.constraint(equalTo: circularBackground.centerXAnchor),
                iconImageView.centerYAnchor.constraint(equalTo: circularBackground.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 24),
                iconImageView.heightAnchor.constraint(equalToConstant: 24),

                // Overlay constraints - same as circular background
                overlayView.centerXAnchor.constraint(equalTo: circularBackground.centerXAnchor),
                overlayView.centerYAnchor.constraint(equalTo: circularBackground.centerYAnchor),
                overlayView.widthAnchor.constraint(equalTo: circularBackground.widthAnchor),
                overlayView.heightAnchor.constraint(equalTo: circularBackground.heightAnchor)
            ])
        } else {
            // Regular tab button
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 4
            stackView.isUserInteractionEnabled = false
            addSubview(stackView)

            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.image = UIImage(systemName: icon)
            iconImageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(iconImageView)

            customTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            customTitleLabel.text = title
            customTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            customTitleLabel.textAlignment = .center
            stackView.addArrangedSubview(customTitleLabel)

            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 20),
                iconImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
    }
    
    func setSelected(_ selected: Bool) {
        if isCenterButton {
            // Center button always keeps its circular background
            circularBackground.backgroundColor = selectedColor
            iconImageView.tintColor = UIColor.white
        } else {
            let color = selected ? selectedColor : unselectedColor
            iconImageView.tintColor = color
            customTitleLabel.textColor = color
        }
    }
}

// MARK: - Extension with Helper Methods
extension CustomTabBarController {
    
    // MARK: - Public Tab Selection Methods
    func selectHomeTab() {
        selectTab(at: 0)
    }

    func selectLibraryTab() {
        selectTab(at: 1)
    }

    func selectChatTab() {
        selectTab(at: 2)
    }

    func selectJournalTab() {
        selectTab(at: 3)
    }

    func selectProfileTab() {
        selectTab(at: 4)
    }
    
    // MARK: - Immersive View Integration
    func presentImmersiveChatForCategory(_ category: ChatCategoryData, messages: [ChatMessage] = []) {
        // First dismiss any existing immersive view
        dismissImmersiveChat()
        
        let immersiveVC = ImmersiveChatViewController(
            category: category,
            messages: messages,
            customTabBarController: self
        )
        
        // Add as child view controller
        addChild(immersiveVC)
        
        // Add to the content container area ONLY (not over the tab bar)
        contentContainerView.addSubview(immersiveVC.view)
        immersiveVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            immersiveVC.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            immersiveVC.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            immersiveVC.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            immersiveVC.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
        
        // Hide the current tab content (but keep tab bar visible)
        currentViewController?.view.isHidden = true
        
        // Animate in
        immersiveVC.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            immersiveVC.view.alpha = 1
        }
        
        immersiveVC.didMove(toParent: self)
    }
    
    func dismissImmersiveChat() {
        if let immersiveVC = children.first(where: { $0 is ImmersiveChatViewController }) {
            // Show the tab content again
            currentViewController?.view.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                immersiveVC.view.alpha = 0
            }) { _ in
                immersiveVC.willMove(toParent: nil)
                immersiveVC.view.removeFromSuperview()
                immersiveVC.removeFromParent()
            }
        }
    }
    
    // MARK: - Enhanced Tab Selection with Immersive Handling
    func selectTabDismissingImmersive(at index: Int) {
        // If immersive view is showing, dismiss it first
        dismissImmersiveChat()
        
        // Then proceed with normal tab selection
        selectTab(at: index)
    }
    
    // MARK: - Navigation Helpers
    func popToHomeRoot() {
        selectTab(at: 0)
        homeNavigationController.popToRootViewController(animated: true)
    }
    
    func getCurrentTabIndex() -> Int {
        return selectedTabIndex
    }
    
    func getCurrentViewController() -> UIViewController? {
        return currentViewController
    }
}
