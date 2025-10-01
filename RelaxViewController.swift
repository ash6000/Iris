import UIKit

// MARK: - Data Models
struct MeditationItem {
    let title: String
    let duration: String
    var isFavorited: Bool
}

struct BreathworkItem {
    let title: String
    let duration: String
    let imageName: String
}

// MARK: - LibraryViewController (RelaxViewController renamed)
class RelaxViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerView = UIView()
    private let titleLabel = UILabel()

    // Search
    private let searchContainerView = UIView()
    private let searchTextField = UITextField()
    private let searchIconView = UIImageView()

    // Deep Breath Section
    private let deepBreathSectionView = UIView()
    private let deepBreathTitleLabel = UILabel()
    private let deepBreathStackView = UIStackView()

    // Breathwork Section
    private let breathworkSectionView = UIView()
    private let breathworkTitleLabel = UILabel()
    private let breathworkScrollView = UIScrollView()
    private let breathworkStackView = UIStackView()

    // Affirmations Section
    private let affirmationsSectionView = UIView()
    private let affirmationsTitleLabel = UILabel()
    private let premiumLabel = UILabel()
    private let affirmationsStackView = UIStackView()

    // Data
    private var meditationItems: [MeditationItem] = []
    private var breathworkItems: [BreathworkItem] = []
    private var affirmationItems: [MeditationItem] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup Methods
    private func setupData() {
        meditationItems = [
            MeditationItem(title: "Morning Calm", duration: "5 min", isFavorited: false),
            MeditationItem(title: "Stress Relief", duration: "10 min", isFavorited: true),
            MeditationItem(title: "Focus Boost", duration: "7 min", isFavorited: false)
        ]

        breathworkItems = [
            BreathworkItem(title: "Box Breathing", duration: "8 min", imageName: "meditation_art_1"),
            BreathworkItem(title: "4-7-8 Technique", duration: "12 min", imageName: "meditation_art_2"),
            BreathworkItem(title: "Wim Hof Method", duration: "15 min", imageName: "meditation_art_3")
        ]

        affirmationItems = [
            MeditationItem(title: "Daily Confidence", duration: "3 min", isFavorited: false),
            MeditationItem(title: "Self Love", duration: "5 min", isFavorited: false),
            MeditationItem(title: "Success Mindset", duration: "4 min", isFavorited: true)
        ]
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        setupScrollView()
        setupHeader()
        setupSearchBar()
        setupDeepBreathSection()
        setupBreathworkSection()
        setupAffirmationsSection()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        scrollView.addSubview(contentView)
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Library"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }

    private func setupSearchBar() {
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        searchContainerView.layer.cornerRadius = 16
        contentView.addSubview(searchContainerView)

        searchIconView.translatesAutoresizingMaskIntoConstraints = false
        searchIconView.image = UIImage(systemName: "magnifyingglass")
        searchIconView.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        searchIconView.contentMode = .scaleAspectFit
        searchContainerView.addSubview(searchIconView)

        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Search meditations..."
        searchTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        searchTextField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        searchTextField.backgroundColor = UIColor.clear
        searchTextField.borderStyle = .none
        searchContainerView.addSubview(searchTextField)

        NSLayoutConstraint.activate([
            searchIconView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 16),
            searchIconView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 20),
            searchIconView.heightAnchor.constraint(equalToConstant: 20),

            searchTextField.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 12),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -16)
        ])
    }

    private func setupDeepBreathSection() {
        deepBreathSectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deepBreathSectionView)

        deepBreathTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        deepBreathTitleLabel.text = "Deep Breath"
        deepBreathTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        deepBreathTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        deepBreathSectionView.addSubview(deepBreathTitleLabel)

        deepBreathStackView.translatesAutoresizingMaskIntoConstraints = false
        deepBreathStackView.axis = .vertical
        deepBreathStackView.spacing = 12
        deepBreathSectionView.addSubview(deepBreathStackView)

        // Create meditation item views
        for item in meditationItems {
            let itemView = createMeditationItemView(item: item)
            deepBreathStackView.addArrangedSubview(itemView)
        }

        NSLayoutConstraint.activate([
            deepBreathTitleLabel.topAnchor.constraint(equalTo: deepBreathSectionView.topAnchor),
            deepBreathTitleLabel.leadingAnchor.constraint(equalTo: deepBreathSectionView.leadingAnchor),
            deepBreathTitleLabel.trailingAnchor.constraint(equalTo: deepBreathSectionView.trailingAnchor),

            deepBreathStackView.topAnchor.constraint(equalTo: deepBreathTitleLabel.bottomAnchor, constant: 16),
            deepBreathStackView.leadingAnchor.constraint(equalTo: deepBreathSectionView.leadingAnchor),
            deepBreathStackView.trailingAnchor.constraint(equalTo: deepBreathSectionView.trailingAnchor),
            deepBreathStackView.bottomAnchor.constraint(equalTo: deepBreathSectionView.bottomAnchor)
        ])
    }

    private func setupBreathworkSection() {
        breathworkSectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(breathworkSectionView)

        breathworkTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        breathworkTitleLabel.text = "Breathwork"
        breathworkTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        breathworkTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        breathworkSectionView.addSubview(breathworkTitleLabel)

        breathworkScrollView.translatesAutoresizingMaskIntoConstraints = false
        breathworkScrollView.showsHorizontalScrollIndicator = false
        breathworkSectionView.addSubview(breathworkScrollView)

        breathworkStackView.translatesAutoresizingMaskIntoConstraints = false
        breathworkStackView.axis = .horizontal
        breathworkStackView.spacing = 16
        breathworkScrollView.addSubview(breathworkStackView)

        // Create breathwork item views
        for item in breathworkItems {
            let itemView = createBreathworkItemView(item: item)
            breathworkStackView.addArrangedSubview(itemView)
        }

        NSLayoutConstraint.activate([
            breathworkTitleLabel.topAnchor.constraint(equalTo: breathworkSectionView.topAnchor),
            breathworkTitleLabel.leadingAnchor.constraint(equalTo: breathworkSectionView.leadingAnchor),
            breathworkTitleLabel.trailingAnchor.constraint(equalTo: breathworkSectionView.trailingAnchor),

            breathworkScrollView.topAnchor.constraint(equalTo: breathworkTitleLabel.bottomAnchor, constant: 16),
            breathworkScrollView.leadingAnchor.constraint(equalTo: breathworkSectionView.leadingAnchor),
            breathworkScrollView.trailingAnchor.constraint(equalTo: breathworkSectionView.trailingAnchor),
            breathworkScrollView.bottomAnchor.constraint(equalTo: breathworkSectionView.bottomAnchor),
            breathworkScrollView.heightAnchor.constraint(equalToConstant: 240),

            breathworkStackView.topAnchor.constraint(equalTo: breathworkScrollView.topAnchor),
            breathworkStackView.leadingAnchor.constraint(equalTo: breathworkScrollView.leadingAnchor),
            breathworkStackView.trailingAnchor.constraint(equalTo: breathworkScrollView.trailingAnchor),
            breathworkStackView.bottomAnchor.constraint(equalTo: breathworkScrollView.bottomAnchor),
            breathworkStackView.heightAnchor.constraint(equalTo: breathworkScrollView.heightAnchor)
        ])
    }

    private func setupAffirmationsSection() {
        affirmationsSectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(affirmationsSectionView)

        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        affirmationsSectionView.addSubview(headerContainer)

        affirmationsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        affirmationsTitleLabel.text = "Affirmations"
        affirmationsTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        affirmationsTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        headerContainer.addSubview(affirmationsTitleLabel)

        premiumLabel.translatesAutoresizingMaskIntoConstraints = false
        premiumLabel.text = "🔒 PREMIUM"
        premiumLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        premiumLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        headerContainer.addSubview(premiumLabel)

        affirmationsStackView.translatesAutoresizingMaskIntoConstraints = false
        affirmationsStackView.axis = .vertical
        affirmationsStackView.spacing = 16
        affirmationsSectionView.addSubview(affirmationsStackView)

        for item in affirmationItems {
            let itemView = createAffirmationItemView(item: item)
            affirmationsStackView.addArrangedSubview(itemView)
        }

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: affirmationsSectionView.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: affirmationsSectionView.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: affirmationsSectionView.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 40),

            affirmationsTitleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            affirmationsTitleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            premiumLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            premiumLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            affirmationsStackView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 16),
            affirmationsStackView.leadingAnchor.constraint(equalTo: affirmationsSectionView.leadingAnchor),
            affirmationsStackView.trailingAnchor.constraint(equalTo: affirmationsSectionView.trailingAnchor),
            affirmationsStackView.bottomAnchor.constraint(equalTo: affirmationsSectionView.bottomAnchor)
        ])
    }

    private func createMeditationItemView(item: MeditationItem) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1

        let playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        playButton.layer.cornerRadius = 25
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        containerView.addSubview(playButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = item.title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        containerView.addSubview(titleLabel)

        let durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = item.duration
        durationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        durationLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        containerView.addSubview(durationLabel)

        let heartButton = UIButton()
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        let heartIcon = item.isFavorited ? "heart.fill" : "heart"
        heartButton.setImage(UIImage(systemName: heartIcon), for: .normal)
        heartButton.tintColor = item.isFavorited ? UIColor.red : UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        containerView.addSubview(heartButton)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),

            playButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            playButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),

            durationLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            heartButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 24),
            heartButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        return containerView
    }

    private func createAffirmationItemView(item: MeditationItem) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1

        let playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        playButton.layer.cornerRadius = 25
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        containerView.addSubview(playButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = item.title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        containerView.addSubview(titleLabel)

        let durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = item.duration
        durationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        durationLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        containerView.addSubview(durationLabel)

        let heartButton = UIButton()
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        let heartIcon = item.isFavorited ? "heart.fill" : "heart"
        heartButton.setImage(UIImage(systemName: heartIcon), for: .normal)
        heartButton.tintColor = item.isFavorited ? UIColor.red : UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        containerView.addSubview(heartButton)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),

            playButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            playButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),

            durationLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            heartButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 24),
            heartButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        return containerView
    }

    private func createBreathworkItemView(item: BreathworkItem) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1

        let imageView = UIView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        imageView.layer.cornerRadius = 12
        containerView.addSubview(imageView)

        let placeholderLabel = UILabel()
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "Meditation Art"
        placeholderLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        placeholderLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        placeholderLabel.textAlignment = .center
        imageView.addSubview(placeholderLabel)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = item.title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.numberOfLines = 2
        containerView.addSubview(titleLabel)

        let durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = item.duration
        durationLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        durationLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        containerView.addSubview(durationLabel)

        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 160),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 120),

            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            durationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        return containerView
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

            // Header
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            headerView.heightAnchor.constraint(equalToConstant: 40),

            // Search
            searchContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            searchContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            searchContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            searchContainerView.heightAnchor.constraint(equalToConstant: 50),

            // Deep Breath Section
            deepBreathSectionView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 32),
            deepBreathSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            deepBreathSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Breathwork Section
            breathworkSectionView.topAnchor.constraint(equalTo: deepBreathSectionView.bottomAnchor, constant: 32),
            breathworkSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            breathworkSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Affirmations Section
            affirmationsSectionView.topAnchor.constraint(equalTo: breathworkSectionView.bottomAnchor, constant: 32),
            affirmationsSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            affirmationsSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            affirmationsSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}