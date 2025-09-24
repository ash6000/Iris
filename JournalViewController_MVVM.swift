import UIKit

class JournalViewController_MVVM: UIViewController {
    private let viewModel = JournalViewModel()

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let profileImageView = UIImageView()

    // Search and Filter Section
    private let searchFilterView = UIView()
    private let searchTextField = UITextField()
    private let filterButton = UIButton()

    // Journal Entries Stack
    private let entriesStackView = UIStackView()

    // Load More Button
    private let loadMoreButton = UIButton()

    // Floating Add Button
    private let addButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        bindViewModel()
        viewModel.loadSampleEntries()
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
        setupSearchFilter()
        setupEntriesStack()
        setupLoadMoreButton()
        setupFloatingAddButton()
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(headerView)

        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Journal"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        // Profile Image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        headerView.addSubview(profileImageView)
    }

    private func setupSearchFilter() {
        searchFilterView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(searchFilterView)

        // Search Text Field
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Search entries..."
        searchTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        searchTextField.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        searchTextField.backgroundColor = UIColor.white
        searchTextField.layer.cornerRadius = 12
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor

        // Add search icon
        let searchIconView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let searchIcon = UIImageView(frame: CGRect(x: 12, y: 12, width: 16, height: 16))
        searchIcon.image = UIImage(systemName: "magnifyingglass")
        searchIcon.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        searchIconView.addSubview(searchIcon)
        searchTextField.leftView = searchIconView
        searchTextField.leftViewMode = .always

        searchFilterView.addSubview(searchTextField)

        // Filter Button
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        filterButton.setTitle(" Jan 2025", for: .normal)
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        filterButton.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
        filterButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        filterButton.backgroundColor = UIColor.white
        filterButton.layer.cornerRadius = 12
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        filterButton.contentHorizontalAlignment = .center
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        searchFilterView.addSubview(filterButton)
    }

    private func setupEntriesStack() {
        entriesStackView.translatesAutoresizingMaskIntoConstraints = false
        entriesStackView.axis = .vertical
        entriesStackView.spacing = 16
        entriesStackView.alignment = .fill
        contentView.addSubview(entriesStackView)
    }

    private func setupLoadMoreButton() {
        loadMoreButton.translatesAutoresizingMaskIntoConstraints = false
        loadMoreButton.setTitle("Load More Entries", for: .normal)
        loadMoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loadMoreButton.setTitleColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), for: .normal)
        loadMoreButton.backgroundColor = UIColor.clear
        contentView.addSubview(loadMoreButton)
    }

    private func setupFloatingAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = UIColor.white
        addButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        addButton.layer.cornerRadius = 28
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.3
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowRadius = 8
        view.addSubview(addButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header View
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            // Profile Image
            profileImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),

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

            // Search Filter View
            searchFilterView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            searchFilterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            searchFilterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            searchFilterView.heightAnchor.constraint(equalToConstant: 44),

            // Search Text Field
            searchTextField.leadingAnchor.constraint(equalTo: searchFilterView.leadingAnchor),
            searchTextField.topAnchor.constraint(equalTo: searchFilterView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchFilterView.bottomAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -12),

            // Filter Button
            filterButton.trailingAnchor.constraint(equalTo: searchFilterView.trailingAnchor),
            filterButton.topAnchor.constraint(equalTo: searchFilterView.topAnchor),
            filterButton.bottomAnchor.constraint(equalTo: searchFilterView.bottomAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 100),

            // Entries Stack View
            entriesStackView.topAnchor.constraint(equalTo: searchFilterView.bottomAnchor, constant: 20),
            entriesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            entriesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Load More Button
            loadMoreButton.topAnchor.constraint(equalTo: entriesStackView.bottomAnchor, constant: 20),
            loadMoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadMoreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),

            // Floating Add Button
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.$entries.bind(self) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadJournalEntries()
            }
        }

        viewModel.$isLoading.bind(self) { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.addButton.isEnabled = !isLoading
                self?.addButton.alpha = isLoading ? 0.6 : 1.0
            }
        }
    }

    private func loadJournalEntries() {
        // Clear existing entries
        entriesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new entries
        for entry in viewModel.entries {
            let entryView = createJournalEntryView(entry: entry)
            entriesStackView.addArrangedSubview(entryView)
        }
    }

    private func createJournalEntryView(entry: MVVMJournalEntry) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8

        // Emoji
        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.text = entry.emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 24)
        containerView.addSubview(emojiLabel)

        // Header Stack (Title and Date)
        let headerStackView = UIStackView()
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .vertical
        headerStackView.alignment = .leading
        headerStackView.spacing = 2

        let titleLabel = UILabel()
        titleLabel.text = entry.title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let dateLabel = UILabel()
        dateLabel.text = dateFormatter.string(from: entry.date)
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)

        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(dateLabel)
        containerView.addSubview(headerStackView)

        // Menu Button
        let menuButton = UIButton()
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        containerView.addSubview(menuButton)

        // Content
        let contentLabel = UILabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.text = entry.preview
        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentLabel.numberOfLines = 3
        containerView.addSubview(contentLabel)

        // Footer Stack (Type and Read Time)
        let footerStackView = UIStackView()
        footerStackView.translatesAutoresizingMaskIntoConstraints = false
        footerStackView.axis = .horizontal
        footerStackView.alignment = .center

        let typeLabel = UILabel()
        typeLabel.text = entry.type
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        typeLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        footerStackView.addArrangedSubview(typeLabel)

        // Read Time
        let readTimeLabel = UILabel()
        readTimeLabel.text = entry.readTime
        readTimeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        readTimeLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        footerStackView.addArrangedSubview(readTimeLabel)

        // Spacer
        let spacer = UIView()
        footerStackView.addArrangedSubview(spacer)

        // Edit Button
        let editButton = UIButton()
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        editButton.setTitleColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), for: .normal)
        footerStackView.addArrangedSubview(editButton)

        containerView.addSubview(footerStackView)

        // Constraints
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),

            // Emoji
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            // Header Stack
            headerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerStackView.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            headerStackView.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -12),

            // Menu Button
            menuButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            menuButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            menuButton.widthAnchor.constraint(equalToConstant: 24),
            menuButton.heightAnchor.constraint(equalToConstant: 24),

            // Content
            contentLabel.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Footer Stack
            footerStackView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16),
            footerStackView.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            footerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            footerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        return containerView
    }

    @objc private func addButtonTapped() {
        let entryModal = EntryMethodModalViewController()
        entryModal.delegate = self
        entryModal.modalPresentationStyle = .overFullScreen
        entryModal.modalTransitionStyle = .crossDissolve
        present(entryModal, animated: true)
    }
}

extension JournalViewController_MVVM: EntryMethodModalDelegate {
    func didSelectEntryMethod(type: EntryMethodType) {
        switch type {
        case .voice:
            let voiceEntryVC = VoiceEntryViewController_MVVM()
            navigationController?.pushViewController(voiceEntryVC, animated: true)
        case .text:
            let textEntryVC = TextEntryViewController_MVVM()
            navigationController?.pushViewController(textEntryVC, animated: true)
        case .guided:
            let guidedEntryVC = GuidedEntryViewController_MVVM()
            navigationController?.pushViewController(guidedEntryVC, animated: true)
        }
    }
}