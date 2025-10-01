import UIKit

class HomeViewController: UIViewController {

    // MARK: - Custom Tab Bar Reference
    weak var customTabBarController: CustomTabBarController?

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header Section
    private let headerContainerView = UIView()
    private let dateLabel = UILabel()
    private let greetingLabel = UILabel()

    // Journal Prompt Section
    private let promptContainerView = UIView()
    private let promptTitleLabel = UILabel()
    private let promptDropdownButton = UIButton()
    private let promptTextView = UITextView()
    private var promptTextViewHeightConstraint: NSLayoutConstraint!
    private var promptContainerBottomConstraint: NSLayoutConstraint!
    private var isPromptExpanded = false

    // Moon Phase Section
    private let moonSectionView = UIView()
    private let moonTitleLabel = UILabel()
    private let moonArrowButton = UIButton()
    private let moonStackView = UIStackView()

    // Box Breathing Section
    private let breathingContainerView = UIView()
    private let breathingTitleLabel = UILabel()
    private let breathingDescriptionLabel = UILabel()
    private let breathingPlayButton = UIButton()

    // Progress Section
    private let progressContainerView = UIView()
    private let progressTitleLabel = UILabel()
    private let progressBar = UIProgressView()
    private let progressDescriptionLabel = UILabel()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        configureContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        setupScrollView()
        setupHeader()
        setupPromptSection()
        setupMoonSection()
        setupBreathingSection()
        setupProgressSection()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }

    private func setupHeader() {
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.backgroundColor = UIColor.white
        headerContainerView.layer.cornerRadius = 16
        headerContainerView.layer.shadowColor = UIColor.black.cgColor
        headerContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerContainerView.layer.shadowRadius = 8
        headerContainerView.layer.shadowOpacity = 0.1
        contentView.addSubview(headerContainerView)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        dateLabel.text = "Wednesday, Sept 10"
        headerContainerView.addSubview(dateLabel)

        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        greetingLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        greetingLabel.text = "Good evening, Sarah."
        headerContainerView.addSubview(greetingLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 32),
            dateLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 32),
            dateLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -32),

            greetingLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            greetingLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 32),
            greetingLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -32),
            greetingLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -32)
        ])
    }

    private func setupPromptSection() {
        promptContainerView.translatesAutoresizingMaskIntoConstraints = false
        promptContainerView.backgroundColor = UIColor.white
        promptContainerView.layer.cornerRadius = 16
        promptContainerView.layer.shadowColor = UIColor.black.cgColor
        promptContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        promptContainerView.layer.shadowRadius = 8
        promptContainerView.layer.shadowOpacity = 0.1
        contentView.addSubview(promptContainerView)

        promptTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        promptTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        promptTitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        promptTitleLabel.text = "JOURNAL PROMPT FOR THE DAY -"
        promptContainerView.addSubview(promptTitleLabel)

        promptDropdownButton.translatesAutoresizingMaskIntoConstraints = false
        promptDropdownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        promptDropdownButton.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        promptContainerView.addSubview(promptDropdownButton)

        promptTextView.translatesAutoresizingMaskIntoConstraints = false
        promptTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        promptTextView.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        promptTextView.backgroundColor = UIColor.clear
        promptTextView.isEditable = false
        promptTextView.isScrollEnabled = false
        promptTextView.textContainerInset = UIEdgeInsets.zero
        promptTextView.textContainer.lineFragmentPadding = 0
        promptTextView.text = "What brought you peace today? Take a moment to reflect on the small moments of calm and joy that touched your heart. How did these moments make you feel, and what can you learn from them about what truly matters to you?"
        promptTextView.isHidden = true
        promptContainerView.addSubview(promptTextView)

        // Create dynamic constraints
        promptTextViewHeightConstraint = promptTextView.heightAnchor.constraint(equalToConstant: 0)
        promptContainerBottomConstraint = promptTitleLabel.bottomAnchor.constraint(equalTo: promptContainerView.bottomAnchor, constant: -20)

        NSLayoutConstraint.activate([
            promptTitleLabel.topAnchor.constraint(equalTo: promptContainerView.topAnchor, constant: 20),
            promptTitleLabel.leadingAnchor.constraint(equalTo: promptContainerView.leadingAnchor, constant: 20),
            promptContainerBottomConstraint,

            promptDropdownButton.centerYAnchor.constraint(equalTo: promptTitleLabel.centerYAnchor),
            promptDropdownButton.trailingAnchor.constraint(equalTo: promptContainerView.trailingAnchor, constant: -20),
            promptDropdownButton.widthAnchor.constraint(equalToConstant: 16),
            promptDropdownButton.heightAnchor.constraint(equalToConstant: 16),

            promptTextView.topAnchor.constraint(equalTo: promptTitleLabel.bottomAnchor, constant: 20),
            promptTextView.leadingAnchor.constraint(equalTo: promptContainerView.leadingAnchor, constant: 20),
            promptTextView.trailingAnchor.constraint(equalTo: promptContainerView.trailingAnchor, constant: -20),
            promptTextViewHeightConstraint
        ])
    }

    private func setupMoonSection() {
        moonSectionView.translatesAutoresizingMaskIntoConstraints = false
        moonSectionView.backgroundColor = UIColor.white
        moonSectionView.layer.cornerRadius = 16
        moonSectionView.layer.shadowColor = UIColor.black.cgColor
        moonSectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        moonSectionView.layer.shadowRadius = 8
        moonSectionView.layer.shadowOpacity = 0.1
        contentView.addSubview(moonSectionView)

        moonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        moonTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        moonTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        moonTitleLabel.text = "This Week's Moon"
        moonSectionView.addSubview(moonTitleLabel)

        moonArrowButton.translatesAutoresizingMaskIntoConstraints = false
        moonArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        moonArrowButton.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        moonSectionView.addSubview(moonArrowButton)

        moonStackView.translatesAutoresizingMaskIntoConstraints = false
        moonStackView.axis = .horizontal
        moonStackView.distribution = .fillEqually
        moonStackView.spacing = 8
        moonSectionView.addSubview(moonStackView)

        let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let moonPhases = ["○", "◐", "●", "◑", "○", "◐"]

        for i in 0..<dayLabels.count {
            let dayContainer = UIView()
            dayContainer.translatesAutoresizingMaskIntoConstraints = false

            let dayLabel = UILabel()
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            dayLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            dayLabel.text = dayLabels[i]
            dayLabel.textAlignment = .center
            dayContainer.addSubview(dayLabel)

            let moonLabel = UILabel()
            moonLabel.translatesAutoresizingMaskIntoConstraints = false
            moonLabel.font = UIFont.systemFont(ofSize: 24)
            moonLabel.text = moonPhases[i]
            moonLabel.textAlignment = .center
            if i == 2 {
                moonLabel.textColor = UIColor.black
            } else {
                moonLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            }
            dayContainer.addSubview(moonLabel)

            NSLayoutConstraint.activate([
                dayLabel.topAnchor.constraint(equalTo: dayContainer.topAnchor),
                dayLabel.centerXAnchor.constraint(equalTo: dayContainer.centerXAnchor),

                moonLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 8),
                moonLabel.centerXAnchor.constraint(equalTo: dayContainer.centerXAnchor),
                moonLabel.bottomAnchor.constraint(equalTo: dayContainer.bottomAnchor)
            ])

            moonStackView.addArrangedSubview(dayContainer)
        }

        NSLayoutConstraint.activate([
            moonTitleLabel.topAnchor.constraint(equalTo: moonSectionView.topAnchor, constant: 20),
            moonTitleLabel.leadingAnchor.constraint(equalTo: moonSectionView.leadingAnchor, constant: 20),

            moonArrowButton.centerYAnchor.constraint(equalTo: moonTitleLabel.centerYAnchor),
            moonArrowButton.trailingAnchor.constraint(equalTo: moonSectionView.trailingAnchor, constant: -20),
            moonArrowButton.widthAnchor.constraint(equalToConstant: 16),
            moonArrowButton.heightAnchor.constraint(equalToConstant: 16),

            moonStackView.topAnchor.constraint(equalTo: moonTitleLabel.bottomAnchor, constant: 20),
            moonStackView.leadingAnchor.constraint(equalTo: moonSectionView.leadingAnchor, constant: 20),
            moonStackView.trailingAnchor.constraint(equalTo: moonSectionView.trailingAnchor, constant: -20),
            moonStackView.bottomAnchor.constraint(equalTo: moonSectionView.bottomAnchor, constant: -20)
        ])
    }

    private func setupBreathingSection() {
        breathingContainerView.translatesAutoresizingMaskIntoConstraints = false
        breathingContainerView.backgroundColor = UIColor.white
        breathingContainerView.layer.cornerRadius = 16
        breathingContainerView.layer.shadowColor = UIColor.black.cgColor
        breathingContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        breathingContainerView.layer.shadowRadius = 8
        breathingContainerView.layer.shadowOpacity = 0.1
        contentView.addSubview(breathingContainerView)

        breathingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        breathingTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        breathingTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        breathingTitleLabel.text = "Box Breathing"
        breathingContainerView.addSubview(breathingTitleLabel)

        breathingDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        breathingDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        breathingDescriptionLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        breathingDescriptionLabel.text = "A simple technique to calm your mind."
        breathingDescriptionLabel.numberOfLines = 0
        breathingContainerView.addSubview(breathingDescriptionLabel)

        breathingPlayButton.translatesAutoresizingMaskIntoConstraints = false
        breathingPlayButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        breathingPlayButton.layer.cornerRadius = 25
        breathingPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        breathingPlayButton.tintColor = UIColor.white
        breathingContainerView.addSubview(breathingPlayButton)

        NSLayoutConstraint.activate([
            breathingTitleLabel.topAnchor.constraint(equalTo: breathingContainerView.topAnchor, constant: 20),
            breathingTitleLabel.leadingAnchor.constraint(equalTo: breathingContainerView.leadingAnchor, constant: 20),

            breathingDescriptionLabel.topAnchor.constraint(equalTo: breathingTitleLabel.bottomAnchor, constant: 4),
            breathingDescriptionLabel.leadingAnchor.constraint(equalTo: breathingContainerView.leadingAnchor, constant: 20),
            breathingDescriptionLabel.trailingAnchor.constraint(equalTo: breathingPlayButton.leadingAnchor, constant: -16),
            breathingDescriptionLabel.bottomAnchor.constraint(equalTo: breathingContainerView.bottomAnchor, constant: -20),

            breathingPlayButton.centerYAnchor.constraint(equalTo: breathingContainerView.centerYAnchor),
            breathingPlayButton.trailingAnchor.constraint(equalTo: breathingContainerView.trailingAnchor, constant: -20),
            breathingPlayButton.widthAnchor.constraint(equalToConstant: 50),
            breathingPlayButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupProgressSection() {
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.backgroundColor = UIColor.white
        progressContainerView.layer.cornerRadius = 16
        progressContainerView.layer.shadowColor = UIColor.black.cgColor
        progressContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        progressContainerView.layer.shadowRadius = 8
        progressContainerView.layer.shadowOpacity = 0.1
        contentView.addSubview(progressContainerView)

        progressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        progressTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        progressTitleLabel.text = "Your Exploration Journey"
        progressContainerView.addSubview(progressTitleLabel)

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        progressBar.trackTintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        progressBar.layer.cornerRadius = 3
        progressBar.progress = 0.6
        progressContainerView.addSubview(progressBar)

        progressDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        progressDescriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        progressDescriptionLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        progressDescriptionLabel.text = "3 of 5 steps completed"
        progressContainerView.addSubview(progressDescriptionLabel)

        NSLayoutConstraint.activate([
            progressTitleLabel.topAnchor.constraint(equalTo: progressContainerView.topAnchor, constant: 20),
            progressTitleLabel.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 20),
            progressTitleLabel.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -20),

            progressBar.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 12),
            progressBar.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 6),

            progressDescriptionLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 6),
            progressDescriptionLabel.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 20),
            progressDescriptionLabel.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -20),
            progressDescriptionLabel.bottomAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: -20)
        ])
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
            headerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            headerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Prompt Section
            promptContainerView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 20),
            promptContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            promptContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Moon Section
            moonSectionView.topAnchor.constraint(equalTo: promptContainerView.bottomAnchor, constant: 20),
            moonSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            moonSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Breathing Section
            breathingContainerView.topAnchor.constraint(equalTo: moonSectionView.bottomAnchor, constant: 20),
            breathingContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            breathingContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Progress Section
            progressContainerView.topAnchor.constraint(equalTo: breathingContainerView.bottomAnchor, constant: 20),
            progressContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            progressContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            progressContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        promptDropdownButton.addTarget(self, action: #selector(promptDropdownTapped), for: .touchUpInside)
        moonArrowButton.addTarget(self, action: #selector(moonArrowTapped), for: .touchUpInside)
        breathingPlayButton.addTarget(self, action: #selector(breathingPlayTapped), for: .touchUpInside)
    }

    private func configureContent() {
        // Set current date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        dateLabel.text = formatter.string(from: Date())

        // Set time-based greeting
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        switch hour {
        case 5..<12:
            greeting = "Good morning, Sarah."
        case 12..<17:
            greeting = "Good afternoon, Sarah."
        default:
            greeting = "Good evening, Sarah."
        }
        greetingLabel.text = greeting
    }

    // MARK: - Actions
    @objc private func promptDropdownTapped() {
        isPromptExpanded.toggle()

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            if self.isPromptExpanded {
                // Expand: Show text view
                self.promptTextView.isHidden = false

                // Calculate the height needed for the text
                let textSize = self.promptTextView.sizeThatFits(CGSize(width: self.promptContainerView.frame.width - 40, height: CGFloat.greatestFiniteMagnitude))
                self.promptTextViewHeightConstraint.constant = max(120, textSize.height)

                // Update container bottom constraint to include text view
                self.promptContainerBottomConstraint.isActive = false
                self.promptContainerBottomConstraint = self.promptTextView.bottomAnchor.constraint(equalTo: self.promptContainerView.bottomAnchor, constant: -20)
                self.promptContainerBottomConstraint.isActive = true

                // Rotate arrow down
                self.promptDropdownButton.transform = CGAffineTransform(rotationAngle: .pi)
            } else {
                // Collapse: Hide text view
                self.promptTextViewHeightConstraint.constant = 0

                // Update container bottom constraint to only include title
                self.promptContainerBottomConstraint.isActive = false
                self.promptContainerBottomConstraint = self.promptTitleLabel.bottomAnchor.constraint(equalTo: self.promptContainerView.bottomAnchor, constant: -20)
                self.promptContainerBottomConstraint.isActive = true

                // Rotate arrow back up
                self.promptDropdownButton.transform = CGAffineTransform.identity
            }

            self.view.layoutIfNeeded()
        }) { _ in
            if !self.isPromptExpanded {
                self.promptTextView.isHidden = true
            }
        }
    }

    @objc private func moonArrowTapped() {
        let lunarCalendarVC = LunarCalendarViewController()
        lunarCalendarVC.modalPresentationStyle = .overFullScreen
        lunarCalendarVC.modalTransitionStyle = .crossDissolve
        present(lunarCalendarVC, animated: true)
    }

    @objc private func breathingPlayTapped() {
        print("Breathing play tapped")
    }
}
