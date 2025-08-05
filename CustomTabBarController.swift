import Foundation
import UIKit

// MARK: - Custom Tab Bar Controller
class CustomTabBarController: UIViewController {
    
    // Tab Bar UI
    private let tabBarView = UIView()
    private let tabStackView = UIStackView()
    private var tabButtons: [TabButton] = []
    
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
        
        // Initialize the first tab immediately after setup
        DispatchQueue.main.async {
            self.selectTab(at: 0)
        }
    }
    
    private func setupViewControllers() {
        // Home tab - Now uses ChatViewController
        let homeVC = ChatViewController()
        //let homeVC = IrisWelcomeViewController()
        homeVC.customTabBarController = self
        homeNavigationController = UINavigationController(rootViewController: homeVC)
        homeNavigationController.isNavigationBarHidden = true
       // homeNavigationController.isToolbarHidden = true

        // Mood tab
        let moodVC = MoodTrackingViewController()
        moodNavigationController = UINavigationController(rootViewController: moodVC)
        moodNavigationController.isNavigationBarHidden = true
        
        // Relax tab
        let relaxVC = RelaxViewController()
        relaxNavigationController = UINavigationController(rootViewController: relaxVC)
        relaxNavigationController.isNavigationBarHidden = true

        // Reflect tab - Placeholder for now
        reflectNavigationController = UINavigationController(rootViewController: createPlaceholderVC(title: "Reflect Coming Soon", color: .systemPink))
        reflectNavigationController.isNavigationBarHidden = true
        
        // More tab
        let moreVc = SettingsViewController()
        moreNavigationController = UINavigationController(rootViewController: moreVc)
        moreNavigationController.isNavigationBarHidden = true
        //moreNavigationController = UINavigationController(rootViewController: createPlaceholderVC(title: "More Options", color: .systemOrange))
       // moreNavigationController.isNavigationBarHidden = true
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
        view.addSubview(tabBarView)
        
        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        tabStackView.axis = .horizontal
        tabStackView.distribution = .fillEqually
        tabStackView.alignment = .center
        tabBarView.addSubview(tabStackView)
        
        // Updated tab items - Added Reflect tab back
        let tabItems = [
            ("heart.fill", "Home"),        // ChatViewController with categories
            ("calendar", "Mood"),
            ("headphones", "Relax"),
            ("book.fill", "Reflect"),      // Placeholder for now
            ("ellipsis", "More")
        ]
        
        for (index, (icon, title)) in tabItems.enumerated() {
            let tabButton = TabButton(icon: icon, title: title, isSelected: index == 0)
            tabButton.tag = index
            tabButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            tabStackView.addArrangedSubview(tabButton)
            tabButtons.append(tabButton)
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
    
    @objc private func tabButtonTapped(_ sender: TabButton) {
        print("Tab button tapped: \(sender.tag)")
        selectTab(at: sender.tag)
    }
    
    func selectTab(at index: Int) {
        // If immersive view is showing, dismiss it first
        dismissImmersiveChat()
        
        // Handle Home tab re-selection to go back to category list
        if index == selectedTabIndex && index == 0 && currentViewController != nil {
            // Pop to root view controller in home navigation
            homeNavigationController.popToRootViewController(animated: true)
            return
        }
        
        // Don't prevent initial selection
        if currentViewController != nil && index == selectedTabIndex && index != 0 {
            return
        }
        
        selectedTabIndex = index
        
        // Update tab button states
        for (i, button) in tabButtons.enumerated() {
            button.setSelected(i == index)
        }
        
        // Switch view controller - Updated mapping for 5 tabs
        let viewControllerToShow: UIViewController
        switch index {
        case 0: viewControllerToShow = homeNavigationController      // ChatViewController
        case 1: viewControllerToShow = moodNavigationController
        case 2: viewControllerToShow = relaxNavigationController
        case 3: viewControllerToShow = reflectNavigationController  // Placeholder
        case 4: viewControllerToShow = moreNavigationController
        default: return
        }
        
        switchToViewController(viewControllerToShow)
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
    
    private let selectedColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
    private let unselectedColor = UIColor.gray
    
    init(icon: String, title: String, isSelected: Bool = false) {
        super.init(frame: .zero)
        setupUI(icon: icon, title: title)
        setSelected(isSelected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(icon: String, title: String) {
        // Stack View
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        addSubview(stackView)
        
        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(iconImageView)
        
        // Title
        customTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        customTitleLabel.text = title
        customTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        customTitleLabel.textAlignment = .center
        stackView.addArrangedSubview(customTitleLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setSelected(_ selected: Bool) {
        let color = selected ? selectedColor : unselectedColor
        iconImageView.tintColor = color
        customTitleLabel.textColor = color
    }
}

// MARK: - Extension with Helper Methods
extension CustomTabBarController {
    
    // MARK: - Public Tab Selection Methods
    func selectHomeTab() {
        selectTab(at: 0)
    }
    
    func selectMoodTab() {
        selectTab(at: 1)
    }
    
    func selectRelaxTab() {
        selectTab(at: 2)
    }
    
    func selectReflectTab() {
        selectTab(at: 3)
    }
    
    func selectMoreTab() {
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
