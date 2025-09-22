//
//  JournalViewController.swift
//  irisOne
//
//  Created by Test User on 9/21/25.
//

import UIKit

class JournalViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
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

    // Sample journal entries data
    private let journalEntries: [JournalEntry] = [
        JournalEntry(
            emoji: "😊",
            title: "Today",
            date: "January 15, 2025",
            content: "Today I felt grateful for the quiet morning coffee and the way sunlight streamed through my window. There's something magical about these peaceful moments before the world wakes up...",
            type: "Voice Entry",
            readTime: "2 min read"
        ),
        JournalEntry(
            emoji: "🙏",
            title: "Yesterday",
            date: "January 14, 2025",
            content: "Meditation helped me find clarity about the challenges I'm facing. I'm learning to trust the process and embrace uncertainty as part of growth...",
            type: "Guided Entry",
            readTime: "3 min read"
        ),
        JournalEntry(
            emoji: "✨",
            title: "2 days ago",
            date: "January 13, 2025",
            content: "Had an incredible breakthrough during my morning walk. Sometimes the answers we seek come when we stop looking so hard and just allow ourselves to be present...",
            type: "Text Entry",
            readTime: "4 min read"
        ),
        JournalEntry(
            emoji: "🌱",
            title: "3 days ago",
            date: "January 12, 2025",
            content: "Reflecting on personal growth and how far I've come. Every small step matters, even when progress feels slow. Today I choose patience with myself...",
            type: "Voice Entry",
            readTime: "1 min read"
        )
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadJournalEntries()
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

    private func loadJournalEntries() {
        for entry in journalEntries {
            let entryView = createJournalEntryView(entry: entry)
            entriesStackView.addArrangedSubview(entryView)
        }
    }

    private func createJournalEntryView(entry: JournalEntry) -> UIView {
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
        emojiLabel.font = UIFont.systemFont(ofSize: 20)
        containerView.addSubview(emojiLabel)

        // Title and Date Stack
        let headerStackView = UIStackView()
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .vertical
        headerStackView.spacing = 2
        headerStackView.alignment = .leading
        containerView.addSubview(headerStackView)

        let titleLabel = UILabel()
        titleLabel.text = entry.title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        headerStackView.addArrangedSubview(titleLabel)

        let dateLabel = UILabel()
        dateLabel.text = entry.date
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        headerStackView.addArrangedSubview(dateLabel)

        // Menu Button
        let menuButton = UIButton()
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        containerView.addSubview(menuButton)

        // Content
        let contentLabel = UILabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.text = entry.content
        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentLabel.numberOfLines = 0
        containerView.addSubview(contentLabel)

        // Footer Stack
        let footerStackView = UIStackView()
        footerStackView.translatesAutoresizingMaskIntoConstraints = false
        footerStackView.axis = .horizontal
        footerStackView.spacing = 16
        footerStackView.alignment = .center
        containerView.addSubview(footerStackView)

        let typeLabel = UILabel()
        typeLabel.text = entry.type
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        typeLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        footerStackView.addArrangedSubview(typeLabel)

        let readTimeLabel = UILabel()
        readTimeLabel.text = entry.readTime
        readTimeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
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

        // Constraints
        NSLayoutConstraint.activate([
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
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Footer
            footerStackView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16),
            footerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            footerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            footerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        return containerView
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            profileImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
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
            searchFilterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchFilterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            searchFilterView.heightAnchor.constraint(equalToConstant: 48),

            // Search Text Field
            searchTextField.leadingAnchor.constraint(equalTo: searchFilterView.leadingAnchor),
            searchTextField.centerYAnchor.constraint(equalTo: searchFilterView.centerYAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            searchTextField.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -12),

            // Filter Button
            filterButton.trailingAnchor.constraint(equalTo: searchFilterView.trailingAnchor),
            filterButton.centerYAnchor.constraint(equalTo: searchFilterView.centerYAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 100),
            filterButton.heightAnchor.constraint(equalToConstant: 48),

            // Entries Stack
            entriesStackView.topAnchor.constraint(equalTo: searchFilterView.bottomAnchor, constant: 24),
            entriesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            entriesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Load More Button
            loadMoreButton.topAnchor.constraint(equalTo: entriesStackView.bottomAnchor, constant: 32),
            loadMoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadMoreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),

            // Floating Add Button
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupActions() {
        profileImageView.isUserInteractionEnabled = true
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(profileTap)

        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        loadMoreButton.addTarget(self, action: #selector(loadMoreButtonTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func profileImageTapped() {
        let profileViewController = ProfileViewController()
        navigationController?.pushViewController(profileViewController, animated: true)
    }

    @objc private func filterButtonTapped() {
        print("Filter button tapped")
    }

    @objc private func loadMoreButtonTapped() {
        print("Load more entries tapped")
    }

    @objc private func addButtonTapped() {
        let entryMethodModal = EntryMethodModalViewController()
        entryMethodModal.delegate = self
        entryMethodModal.modalPresentationStyle = .overFullScreen
        entryMethodModal.modalTransitionStyle = .crossDissolve
        present(entryMethodModal, animated: true)
    }
}

// MARK: - EntryMethodModalDelegate
extension JournalViewController: EntryMethodModalDelegate {
    func didSelectEntryMethod(type: EntryMethodType) {
        switch type {
        case .voice:
            let voiceEntryVC = VoiceEntryViewController()
            navigationController?.pushViewController(voiceEntryVC, animated: true)
        case .text:
            let textEntryVC = TextEntryViewController()
            navigationController?.pushViewController(textEntryVC, animated: true)
        case .guided:
            let guidedEntryVC = GuidedEntryViewController()
            navigationController?.pushViewController(guidedEntryVC, animated: true)
        }
    }
}

// MARK: - Journal Entry Model
struct JournalEntry {
    let emoji: String
    let title: String
    let date: String
    let content: String
    let type: String
    let readTime: String
}