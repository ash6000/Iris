import UIKit

// MARK: - Chat Category Selection View Controller
class ChatViewController: UIViewController {
    
    // MARK: - Custom Tab Bar Reference
    weak var customTabBarController: CustomTabBarController?
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let irisIconView = UIView()
    private let irisIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let categoryStackView = UIStackView()
    private let footerLabel = UILabel()
    
    // Categories Data
    private let categories: [ChatCategoryData] = [
        ChatCategoryData(
            title: "What's my Purpose?",
            subtitle: "Discover your calling",
            iconName: "target",
            backgroundColor: UIColor(red: 0.85, green: 0.4, blue: 0.6, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Dreams & Interpretation",
            subtitle: "Unlock hidden meanings",
            iconName: "moon.stars.fill",
            backgroundColor: UIColor(red: 0.5, green: 0.4, blue: 0.8, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Love & Relationships",
            subtitle: "Heal your heart",
            iconName: "heart.fill",
            backgroundColor: UIColor(red: 0.9, green: 0.4, blue: 0.5, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Inner Peace & Mindfulness",
            subtitle: "Find your center",
            iconName: "leaf.fill",
            backgroundColor: UIColor(red: 0.4, green: 0.7, blue: 0.5, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Overcoming pain or loss",
            subtitle: "Transform through healing",
            iconName: "heart.text.square.fill",
            backgroundColor: UIColor(red: 0.6, green: 0.5, blue: 0.8, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Spiritual connection & signs",
            subtitle: "Receive divine guidance",
            iconName: "sparkles",
            backgroundColor: UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Creativity & Self-Expression",
            subtitle: "Unleash your gifts",
            iconName: "paintbrush.fill",
            backgroundColor: UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Life Directions & Decisions",
            subtitle: "Choose your path",
            iconName: "arrow.triangle.branch",
            backgroundColor: UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Your Past & Story",
            subtitle: "Honor your journey",
            iconName: "book.fill",
            backgroundColor: UIColor(red: 0.7, green: 0.5, blue: 0.6, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "The Future & Hope",
            subtitle: "Manifest your dreams",
            iconName: "star.fill",
            backgroundColor: UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Forgiveness & Letting Go",
            subtitle: "Release and heal",
            iconName: "wind",
            backgroundColor: UIColor(red: 0.5, green: 0.7, blue: 0.8, alpha: 1.0)
        ),
        ChatCategoryData(
            title: "Astrology & Messages from the Universe",
            subtitle: "Explore cosmic wisdom",
            iconName: "moon.circle.fill",
            backgroundColor: UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0)
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        setupHeader()
        setupCategoryGrid()
        setupFooter()
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        // Iris Icon Container - Perfect circle
        irisIconView.translatesAutoresizingMaskIntoConstraints = false
        irisIconView.backgroundColor = UIColor(red: 0.9, green: 0.7, blue: 0.8, alpha: 1.0)
        irisIconView.layer.cornerRadius = 35  // Perfect circle (70/2)
        headerView.addSubview(irisIconView)
        
        // Iris Icon
        irisIconImageView.translatesAutoresizingMaskIntoConstraints = false
        irisIconImageView.image = UIImage(named: "iris_head") // Replace with your cropped image name
        irisIconImageView.contentMode = .scaleAspectFill
        irisIconImageView.clipsToBounds = true
        irisIconImageView.layer.cornerRadius = 35  // Match the container's corner radius
        irisIconView.addSubview(irisIconImageView)
        
        // Title - Slightly smaller for grid layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Hi, I'm Iris. What's been\n on your mind?"
        titleLabel.font = UIFont(name: "Georgia", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        headerView.addSubview(titleLabel)
    }
    
    private func setupCategoryGrid() {
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.axis = .vertical
        categoryStackView.spacing = 16  // Increased spacing between rows
        categoryStackView.alignment = .fill
        contentView.addSubview(categoryStackView)
        
        // Create rows with 2 columns each - ALL 12 CATEGORIES
        for i in stride(from: 0, to: categories.count, by: 2) {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 14  // Increased space between columns
            rowStackView.alignment = .fill
            
            // Left card
            let leftCard = createCategoryCard(category: categories[i])
            rowStackView.addArrangedSubview(leftCard)
            
            // Right card (if exists)
            if i + 1 < categories.count {
                let rightCard = createCategoryCard(category: categories[i + 1])
                rowStackView.addArrangedSubview(rightCard)
            } else {
                // Add empty view for spacing if odd number of categories
                let emptyView = UIView()
                rowStackView.addArrangedSubview(emptyView)
            }
            
            categoryStackView.addArrangedSubview(rowStackView)
        }
    }
    
    private func createCategoryCard(category: ChatCategoryData) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 0.92, green: 0.90, blue: 0.88, alpha: 1.0)
        cardView.layer.cornerRadius = 20
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // Icon Container - Perfect circle, larger size
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = category.backgroundColor
        iconContainer.layer.cornerRadius = 26  // Perfect circle (52/2)
        cardView.addSubview(iconContainer)
        
        // Icon - Larger for better visibility
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: category.iconName)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconImageView)
        
        // Title - Centered and larger since no subtitle
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = category.title
        titleLabel.font = UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.numberOfLines = 3  // Allow more lines to prevent cutoff
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        cardView.addSubview(titleLabel)
        
        // Constraints - Adjusted for no subtitle
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 140), // Reduced height since no subtitle
            
            // Icon at TOP - perfect circle, larger
            iconContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            iconContainer.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 52),  // Larger for perfect circle
            iconContainer.heightAnchor.constraint(equalToConstant: 52),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),  // Larger icon
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title below icon with more space - centered vertically in remaining space
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryCardTapped(_:)))
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = true
        cardView.tag = categories.firstIndex(where: { $0.title == category.title }) ?? 0
        
        return cardView
    }
    
    private func setupFooter() {
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.text = "☀️ Wishing you peace today"
        footerLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        footerLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        footerLabel.textAlignment = .center
        contentView.addSubview(footerLabel)
    }
    
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
            
            // Header View - More compact since no subtitle
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Iris Icon - Perfect circle, slightly larger
            irisIconView.topAnchor.constraint(equalTo: headerView.topAnchor),
            irisIconView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            irisIconView.widthAnchor.constraint(equalToConstant: 70),  // Larger perfect circle
            irisIconView.heightAnchor.constraint(equalToConstant: 70),
            
            irisIconImageView.topAnchor.constraint(equalTo: irisIconView.topAnchor),
            irisIconImageView.leadingAnchor.constraint(equalTo: irisIconView.leadingAnchor),
            irisIconImageView.trailingAnchor.constraint(equalTo: irisIconView.trailingAnchor),
            irisIconImageView.bottomAnchor.constraint(equalTo: irisIconView.bottomAnchor),
            
            // Title - No subtitle, so this is the bottom of header
            titleLabel.topAnchor.constraint(equalTo: irisIconView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            // Category Stack View - Better spacing for larger cards
            categoryStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 28),
            categoryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Footer - Proper spacing from grid
            footerLabel.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 32),
            footerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            footerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            footerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func categoryCardTapped(_ sender: UITapGestureRecognizer) {
        guard let cardView = sender.view else { return }
        let selectedCategory = categories[cardView.tag]
        
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                cardView.transform = CGAffineTransform.identity
            }
        }
        
        // Navigate to actual chat view - UPDATED to pass customTabBarController reference
        let actualChatVC = ActualChatViewController(category: selectedCategory)
        actualChatVC.customTabBarController = customTabBarController
        navigationController?.pushViewController(actualChatVC, animated: true)
    }
}
