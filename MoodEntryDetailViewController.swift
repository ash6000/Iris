//
//  MoodEntryDetailViewController.swift
//  irisOne
//
//  Created by Test User on 8/4/25.
//

import Foundation
import UIKit

// MARK: - Delegate Protocol
protocol MoodEntryDetailDelegate: AnyObject {
    func moodEntryDidUpdate(_ moodEntry: MoodEntry)
    func moodEntryDidDelete(_ moodEntry: MoodEntry)
}

class MoodEntryDetailViewController: UIViewController {
    
    // MARK: - Properties
    private var moodEntry: MoodEntry
    private var isEditingJournal = false
    private var originalJournalText = ""
    
    // Data management
    private let dataManager = MoodDataManager.shared
    weak var delegate: MoodEntryDetailDelegate?
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header Section
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    // Mood Section
    private let moodCardView = UIView()
    private let moodEmojiLabel = UILabel()
    private let moodTitleLabel = UILabel()
    private let loggedTimeLabel = UILabel()
    
    // Tags Section
    private let tagsCardView = UIView()
    private let tagsLabel = UILabel()
    private let tagsEditButton = UIButton()
    private let tagsStackView = UIStackView()
    private let tagsEditContainerView = UIView()
    private var tagEditButtons: [UIButton] = []
    private var isEditingTags = false
    private var originalTags: Set<String> = []
    private var selectedTags: Set<String> = []
    
    // Dynamic height constraint for tags card
    private var tagsCardHeightConstraint: NSLayoutConstraint?
    
    // Edit Tags Buttons
    private let tagsEditButtonsStackView = UIStackView()
    private let tagsSaveButton = UIButton()
    private let tagsCancelButton = UIButton()
    
    // Journal Section
    private let journalCardView = UIView()
    private let journalLabel = UILabel()
    private let editButton = UIButton()
    private let journalTextView = UITextView()
    private let journalDisplayLabel = UILabel()
    
    // Edit Buttons (hidden by default)
    private let editButtonsStackView = UIStackView()
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    
    // Voice Journal Section
    private let voiceJournalCardView = UIView()
    private let voiceJournalLabel = UILabel()
    private let voicePlaybackView = UIView()
    private let playButton = UIButton()
    private let waveformView = UIView()
    private let durationLabel = UILabel()
    
    // Delete Button
    private let deleteButton = UIButton()
    
    // MARK: - Initialization
    init(moodEntry: MoodEntry) {
        self.moodEntry = moodEntry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureContent()
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Refresh mood entry data in case it was updated elsewhere
        refreshMoodEntryData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0) :
                UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        }
        
        setupScrollView()
        setupHeader()
        setupMoodSection()
        setupTagsSection()
        setupJournalSection()
        setupVoiceJournalSection()
        setupDeleteButton()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0) :
                UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        }
        contentView.addSubview(headerView)
        
        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Mood Entry"
        titleLabel.font = UIFont(name: "Georgia", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        // Date
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dateLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        dateLabel.textAlignment = .center
        headerView.addSubview(dateLabel)
    }
    
    private func setupMoodSection() {
        moodCardView.translatesAutoresizingMaskIntoConstraints = false
        moodCardView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) :
                UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        }
        moodCardView.layer.cornerRadius = 20
        moodCardView.layer.shadowColor = UIColor.black.cgColor
        moodCardView.layer.shadowOpacity = 0.08
        moodCardView.layer.shadowRadius = 8
        moodCardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.addSubview(moodCardView)
        
        // Emoji
        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        moodEmojiLabel.font = UIFont.systemFont(ofSize: 64)
        moodEmojiLabel.textAlignment = .center
        moodCardView.addSubview(moodEmojiLabel)
        
        // Mood Title
        moodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        moodTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        moodTitleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        }
        moodTitleLabel.textAlignment = .center
        moodCardView.addSubview(moodTitleLabel)
        
        // Logged Time
        loggedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        loggedTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loggedTimeLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        loggedTimeLabel.textAlignment = .center
        moodCardView.addSubview(loggedTimeLabel)
    }
    
    private func setupTagsSection() {
        tagsCardView.translatesAutoresizingMaskIntoConstraints = false
        tagsCardView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) :
                UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        }
        tagsCardView.layer.cornerRadius = 20
        tagsCardView.layer.shadowColor = UIColor.black.cgColor
        tagsCardView.layer.shadowOpacity = 0.08
        tagsCardView.layer.shadowRadius = 8
        tagsCardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.addSubview(tagsCardView)
        
        // Tags Label (header style like journal entry) - Always visible
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsLabel.text = "Tags"
        tagsLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        tagsLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        tagsLabel.backgroundColor = UIColor.clear
        tagsLabel.alpha = 1.0
        tagsLabel.isHidden = false
        tagsLabel.clipsToBounds = false
        tagsLabel.layer.zPosition = 1000 // Ensure it's on top
        tagsCardView.addSubview(tagsLabel)
        tagsCardView.bringSubviewToFront(tagsLabel)
        
        // Tags Edit Button - Always visible
        tagsEditButton.translatesAutoresizingMaskIntoConstraints = false
        tagsEditButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        tagsEditButton.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        tagsEditButton.alpha = 1.0
        tagsEditButton.isHidden = false
        tagsEditButton.addTarget(self, action: #selector(tagsEditButtonTapped), for: .touchUpInside)
        tagsCardView.addSubview(tagsEditButton)
        tagsCardView.bringSubviewToFront(tagsEditButton)
        
        // Tags Stack View (for display)
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 12
        tagsStackView.alignment = .leading
        tagsStackView.distribution = .fillProportionally
        tagsCardView.addSubview(tagsStackView)
        
        // Tags Edit Container (for editing)
        tagsEditContainerView.translatesAutoresizingMaskIntoConstraints = false
        tagsEditContainerView.isHidden = true
        tagsEditContainerView.alpha = 0
        tagsCardView.addSubview(tagsEditContainerView)
        
        setupTagEditButtons()
        
        // Tags Edit Buttons Stack View
        tagsEditButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        tagsEditButtonsStackView.axis = .horizontal
        tagsEditButtonsStackView.spacing = 16
        tagsEditButtonsStackView.distribution = .fill
        tagsEditButtonsStackView.isHidden = true
        tagsEditButtonsStackView.alpha = 0
        tagsCardView.addSubview(tagsEditButtonsStackView)
        
        // Tags Save Button
        tagsSaveButton.translatesAutoresizingMaskIntoConstraints = false
        tagsSaveButton.setTitle("💾 Save", for: .normal)
        tagsSaveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tagsSaveButton.setTitleColor(.white, for: .normal)
        tagsSaveButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        tagsSaveButton.layer.cornerRadius = 16
        tagsSaveButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        tagsSaveButton.addTarget(self, action: #selector(tagsSaveButtonTapped), for: .touchUpInside)
        tagsEditButtonsStackView.addArrangedSubview(tagsSaveButton)
        
        // Tags Cancel Button
        tagsCancelButton.translatesAutoresizingMaskIntoConstraints = false
        tagsCancelButton.setTitle("✕ Cancel", for: .normal)
        tagsCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tagsCancelButton.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) :
                UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }, for: .normal)
        tagsCancelButton.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) :
                UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        }
        tagsCancelButton.layer.cornerRadius = 16
        tagsCancelButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        tagsCancelButton.addTarget(self, action: #selector(tagsCancelButtonTapped), for: .touchUpInside)
        tagsEditButtonsStackView.addArrangedSubview(tagsCancelButton)
    }
    
    private func setupTagEditButtons() {
        // Clear any existing buttons
        tagEditButtons.forEach { $0.removeFromSuperview() }
        tagEditButtons.removeAll()
        
        let availableTags = ["Work", "Sleep", "Family", "Social", "Self-care", "Exercise", "Creativity", "Stress"]
        
        // Create a vertical stack view to hold rows of buttons
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.alignment = .leading
        verticalStackView.distribution = .fill
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        tagsEditContainerView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: tagsEditContainerView.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: tagsEditContainerView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(lessThanOrEqualTo: tagsEditContainerView.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: tagsEditContainerView.bottomAnchor)
        ])
        
        let containerWidth = UIScreen.main.bounds.width - 72 // Account for card margins (16*2 + 20*2)
        let spacing: CGFloat = 8
        var currentRowWidth: CGFloat = 0
        var currentRowStackView = createTagEditRowStackView()
        verticalStackView.addArrangedSubview(currentRowStackView)
        
        for tag in availableTags {
            let tagButton = createTagEditButton(title: tag)
            tagEditButtons.append(tagButton)
            
            // Calculate button width
            let buttonSize = tagButton.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 32))
            let buttonWidth = buttonSize.width
            
            // Check if button fits in current row
            let neededWidth = currentRowWidth + (currentRowStackView.arrangedSubviews.isEmpty ? 0 : spacing) + buttonWidth
            
            if neededWidth > containerWidth && !currentRowStackView.arrangedSubviews.isEmpty {
                // Start new row
                currentRowStackView = createTagEditRowStackView()
                verticalStackView.addArrangedSubview(currentRowStackView)
                currentRowWidth = buttonWidth
            } else {
                currentRowWidth = neededWidth
            }
            
            currentRowStackView.addArrangedSubview(tagButton)
        }
    }
    
    private func createTagEditRowStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func createTagEditButton(title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) :
                UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        }
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(tagEditButtonTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return button
    }
    
    private func setupJournalSection() {
        journalCardView.translatesAutoresizingMaskIntoConstraints = false
        journalCardView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) :
                UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        }
        journalCardView.layer.cornerRadius = 20
        journalCardView.layer.shadowColor = UIColor.black.cgColor
        journalCardView.layer.shadowOpacity = 0.08
        journalCardView.layer.shadowRadius = 8
        journalCardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.addSubview(journalCardView)
        
        // Journal Label
        journalLabel.translatesAutoresizingMaskIntoConstraints = false
        journalLabel.text = "Journal Entry"
        journalLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        journalLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        journalCardView.addSubview(journalLabel)
        
        // Edit Button
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        journalCardView.addSubview(editButton)
        
        // Journal Display Label (visible by default)
        journalDisplayLabel.translatesAutoresizingMaskIntoConstraints = false
        journalDisplayLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        journalDisplayLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) :
                UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        }
        journalDisplayLabel.numberOfLines = 0
        journalDisplayLabel.lineBreakMode = .byWordWrapping
        journalCardView.addSubview(journalDisplayLabel)
        
        // Journal Text View (hidden by default)
        journalTextView.translatesAutoresizingMaskIntoConstraints = false
        journalTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        journalTextView.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        journalTextView.backgroundColor = UIColor.clear
        journalTextView.isScrollEnabled = true
        journalTextView.layer.cornerRadius = 12
        journalTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        journalTextView.isHidden = true
        journalCardView.addSubview(journalTextView)
        
        // Edit Buttons Stack View (hidden by default)
        editButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        editButtonsStackView.axis = .horizontal
        editButtonsStackView.spacing = 16
        editButtonsStackView.distribution = .fill
        editButtonsStackView.isHidden = true
        editButtonsStackView.alpha = 0
        journalCardView.addSubview(editButtonsStackView)
        
        // Save Button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("💾 Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        saveButton.layer.cornerRadius = 16
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        editButtonsStackView.addArrangedSubview(saveButton)
        
        // Cancel Button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("✕ Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) :
                UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }, for: .normal)
        cancelButton.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) :
                UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        }
        cancelButton.layer.cornerRadius = 16
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        editButtonsStackView.addArrangedSubview(cancelButton)
    }
    
    private func setupVoiceJournalSection() {
        voiceJournalCardView.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalCardView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) :
                UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        }
        voiceJournalCardView.layer.cornerRadius = 20
        voiceJournalCardView.layer.shadowColor = UIColor.black.cgColor
        voiceJournalCardView.layer.shadowOpacity = 0.08
        voiceJournalCardView.layer.shadowRadius = 8
        voiceJournalCardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.addSubview(voiceJournalCardView)
        
        // Voice Journal Label
        voiceJournalLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalLabel.text = "Voice Journal"
        voiceJournalLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        voiceJournalLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) :
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        voiceJournalCardView.addSubview(voiceJournalLabel)
        
        // Voice Playback View
        voicePlaybackView.translatesAutoresizingMaskIntoConstraints = false
        voicePlaybackView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) :
                UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        }
        voicePlaybackView.layer.cornerRadius = 16
        voiceJournalCardView.addSubview(voicePlaybackView)
        
        // Play Button
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        playButton.backgroundColor = .clear
        playButton.layer.cornerRadius = 20
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        voicePlaybackView.addSubview(playButton)
        
        // Waveform View (simulated)
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        voicePlaybackView.addSubview(waveformView)
        setupWaveform()
        
        // Duration Label
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = "2:15"
        durationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        durationLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        voicePlaybackView.addSubview(durationLabel)
    }
    
    private func setupWaveform() {
        // Create simple waveform visualization
        let waveformColors = [
            UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.75, green: 0.6, blue: 0.7, alpha: 1.0),
            UIColor(red: 0.65, green: 0.5, blue: 0.6, alpha: 1.0)
        ]
        
        let barCount = 12
        let barWidth: CGFloat = 3
        let barSpacing: CGFloat = 4
        
        for i in 0..<barCount {
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = waveformColors[i % waveformColors.count]
            bar.layer.cornerRadius = barWidth / 2
            waveformView.addSubview(bar)
            
            let height: CGFloat = CGFloat.random(in: 8...24)
            
            NSLayoutConstraint.activate([
                bar.widthAnchor.constraint(equalToConstant: barWidth),
                bar.heightAnchor.constraint(equalToConstant: height),
                bar.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor),
                bar.leadingAnchor.constraint(equalTo: waveformView.leadingAnchor, constant: CGFloat(i) * (barWidth + barSpacing))
            ])
        }
    }
    
    private func setupDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("🗑 Delete Entry", for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        deleteButton.layer.cornerRadius = 20
        deleteButton.layer.shadowColor = UIColor.red.cgColor
        deleteButton.layer.shadowOpacity = 0.2
        deleteButton.layer.shadowRadius = 8
        deleteButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Constraints
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
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            
            dateLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Mood Card
            moodCardView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            moodCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            moodCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            moodEmojiLabel.topAnchor.constraint(equalTo: moodCardView.topAnchor, constant: 24),
            moodEmojiLabel.centerXAnchor.constraint(equalTo: moodCardView.centerXAnchor),
            
            moodTitleLabel.topAnchor.constraint(equalTo: moodEmojiLabel.bottomAnchor, constant: 16),
            moodTitleLabel.centerXAnchor.constraint(equalTo: moodCardView.centerXAnchor),
            
            loggedTimeLabel.topAnchor.constraint(equalTo: moodTitleLabel.bottomAnchor, constant: 8),
            loggedTimeLabel.centerXAnchor.constraint(equalTo: moodCardView.centerXAnchor),
            loggedTimeLabel.bottomAnchor.constraint(equalTo: moodCardView.bottomAnchor, constant: -24),
            
            // Tags Card
            tagsCardView.topAnchor.constraint(equalTo: moodCardView.bottomAnchor, constant: 20),
            tagsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tagsLabel.topAnchor.constraint(equalTo: tagsCardView.topAnchor, constant: 20),
            tagsLabel.leadingAnchor.constraint(equalTo: tagsCardView.leadingAnchor, constant: 20),
            tagsLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            tagsLabel.heightAnchor.constraint(equalToConstant: 30),
            
            tagsEditButton.topAnchor.constraint(equalTo: tagsCardView.topAnchor, constant: 20),
            tagsEditButton.trailingAnchor.constraint(equalTo: tagsCardView.trailingAnchor, constant: -20),
            tagsEditButton.widthAnchor.constraint(equalToConstant: 24),
            tagsEditButton.heightAnchor.constraint(equalToConstant: 24),
            
            tagsStackView.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 24),
            tagsStackView.leadingAnchor.constraint(equalTo: tagsCardView.leadingAnchor, constant: 20),
            tagsStackView.trailingAnchor.constraint(lessThanOrEqualTo: tagsCardView.trailingAnchor, constant: -20),
            tagsStackView.bottomAnchor.constraint(equalTo: tagsCardView.bottomAnchor, constant: -20),
            
            tagsEditContainerView.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 24),
            tagsEditContainerView.leadingAnchor.constraint(equalTo: tagsCardView.leadingAnchor, constant: 20),
            tagsEditContainerView.trailingAnchor.constraint(lessThanOrEqualTo: tagsCardView.trailingAnchor, constant: -20),
            
            tagsEditButtonsStackView.topAnchor.constraint(equalTo: tagsEditContainerView.bottomAnchor, constant: 16),
            tagsEditButtonsStackView.centerXAnchor.constraint(equalTo: tagsCardView.centerXAnchor),
            tagsEditButtonsStackView.bottomAnchor.constraint(equalTo: tagsCardView.bottomAnchor, constant: -20),
        ])
        
        // Set initial height constraint for tags card (will be updated dynamically)
        tagsCardHeightConstraint = tagsCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110)
        tagsCardHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            // Journal Card
            journalCardView.topAnchor.constraint(equalTo: tagsCardView.bottomAnchor, constant: 20),
            journalCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            journalCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            journalLabel.topAnchor.constraint(equalTo: journalCardView.topAnchor, constant: 20),
            journalLabel.leadingAnchor.constraint(equalTo: journalCardView.leadingAnchor, constant: 20),
            
            editButton.topAnchor.constraint(equalTo: journalCardView.topAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: journalCardView.trailingAnchor, constant: -20),
            editButton.widthAnchor.constraint(equalToConstant: 24),
            editButton.heightAnchor.constraint(equalToConstant: 24),
            
            journalDisplayLabel.topAnchor.constraint(equalTo: journalLabel.bottomAnchor, constant: 16),
            journalDisplayLabel.leadingAnchor.constraint(equalTo: journalCardView.leadingAnchor, constant: 20),
            journalDisplayLabel.trailingAnchor.constraint(equalTo: journalCardView.trailingAnchor, constant: -20),
            journalDisplayLabel.bottomAnchor.constraint(equalTo: journalCardView.bottomAnchor, constant: -20),
            
            journalTextView.topAnchor.constraint(equalTo: journalLabel.bottomAnchor, constant: 16),
            journalTextView.leadingAnchor.constraint(equalTo: journalCardView.leadingAnchor, constant: 20),
            journalTextView.trailingAnchor.constraint(equalTo: journalCardView.trailingAnchor, constant: -20),
            journalTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            editButtonsStackView.topAnchor.constraint(equalTo: journalTextView.bottomAnchor, constant: 16),
            editButtonsStackView.centerXAnchor.constraint(equalTo: journalCardView.centerXAnchor),
            editButtonsStackView.bottomAnchor.constraint(equalTo: journalCardView.bottomAnchor, constant: -20),
            
            // Voice Journal Card
            voiceJournalCardView.topAnchor.constraint(equalTo: journalCardView.bottomAnchor, constant: 20),
            voiceJournalCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            voiceJournalCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            voiceJournalLabel.topAnchor.constraint(equalTo: voiceJournalCardView.topAnchor, constant: 20),
            voiceJournalLabel.leadingAnchor.constraint(equalTo: voiceJournalCardView.leadingAnchor, constant: 20),
            
            voicePlaybackView.topAnchor.constraint(equalTo: voiceJournalLabel.bottomAnchor, constant: 16),
            voicePlaybackView.leadingAnchor.constraint(equalTo: voiceJournalCardView.leadingAnchor, constant: 20),
            voicePlaybackView.trailingAnchor.constraint(equalTo: voiceJournalCardView.trailingAnchor, constant: -20),
            voicePlaybackView.bottomAnchor.constraint(equalTo: voiceJournalCardView.bottomAnchor, constant: -20),
            voicePlaybackView.heightAnchor.constraint(equalToConstant: 60),
            
            playButton.leadingAnchor.constraint(equalTo: voicePlaybackView.leadingAnchor, constant: 16),
            playButton.centerYAnchor.constraint(equalTo: voicePlaybackView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalToConstant: 40),
            
            waveformView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            waveformView.centerYAnchor.constraint(equalTo: voicePlaybackView.centerYAnchor),
            waveformView.heightAnchor.constraint(equalToConstant: 32),
            waveformView.widthAnchor.constraint(equalToConstant: 120),
            
            durationLabel.trailingAnchor.constraint(equalTo: voicePlaybackView.trailingAnchor, constant: -16),
            durationLabel.centerYAnchor.constraint(equalTo: voicePlaybackView.centerYAnchor),
            
            // Delete Button
            deleteButton.topAnchor.constraint(equalTo: voiceJournalCardView.bottomAnchor, constant: 40),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.heightAnchor.constraint(equalToConstant: 56),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Data Refresh
    private func refreshMoodEntryData() {
        // Get the latest version of this mood entry from persistence
        if let updatedEntry = dataManager.getMoodEntry(for: moodEntry.date) {
            print("🔄 Refreshing mood entry data: '\(updatedEntry.journalText)'")
            moodEntry = updatedEntry
            configureContent()
        } else {
            print("⚠️ Could not find mood entry for date: \(moodEntry.date)")
        }
    }
    
    // MARK: - Configuration
    private func configureContent() {
        // Configure date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateLabel.text = formatter.string(from: moodEntry.date)
        
        // Configure mood
        moodEmojiLabel.text = moodEntry.emoji
        moodTitleLabel.text = moodEntry.moodLabel
        
        // Configure logged time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        loggedTimeLabel.text = "Logged at \(timeFormatter.string(from: moodEntry.date))"
        
        // Configure journal text
        print("📝 Configuring journal text: '\(moodEntry.journalText)' (isEmpty: \(moodEntry.journalText.isEmpty))")
        let displayText = moodEntry.journalText.isEmpty ? "No journal entry" : moodEntry.journalText
        journalDisplayLabel.text = displayText
        print("📝 Display text set to: '\(displayText)'")
        journalDisplayLabel.textColor = moodEntry.journalText.isEmpty ? 
            UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) : 
            UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) :
                    UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            }
        
        journalTextView.text = moodEntry.journalText
        originalJournalText = moodEntry.journalText
        
        // Configure tags
        originalTags = Set(moodEntry.tags)
        selectedTags = Set(moodEntry.tags)
        setupTags()
        updateTagEditButtons()
        
        // Configure voice journal
        configureVoiceJournal()
    }
    
    private func configureVoiceJournal() {
        let voicePath = dataManager.getVoiceRecordingPath(for: moodEntry.date)
        let voiceDuration = dataManager.getVoiceRecordingDuration(for: moodEntry.date)
        
        if let _ = voicePath, voiceDuration > 0 {
            // Has voice recording
            durationLabel.text = formatDuration(voiceDuration)
            voiceJournalCardView.isHidden = false
        } else {
            // No voice recording
            voiceJournalCardView.isHidden = true
        }
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func setupTags() {
        // Clear existing tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Always show tags card
        tagsCardView.isHidden = false
        
        if moodEntry.tags.isEmpty {
            // Create compact empty state
            setupEmptyTagsState()
            return
        }
        
        // Setup tags with dynamic sizing
        setupTagsWithContent()
    }
    
    private func setupEmptyTagsState() {
        // Add "No tags" message (keeping it simple like journal entry when empty)
        let noTagsLabel = UILabel()
        noTagsLabel.text = "No tags added"
        noTagsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        noTagsLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) :
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        noTagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure main stack view for vertical layout (consistent with content state)
        tagsStackView.axis = .vertical
        tagsStackView.spacing = 8
        tagsStackView.alignment = .leading
        tagsStackView.distribution = .fill
        
        tagsStackView.addArrangedSubview(noTagsLabel)
        
        // Update height constraint for compact size
        updateTagsCardHeight()
    }
    
    private func setupTagsWithContent() {
        let tagColors: [(background: UIColor, text: UIColor)] = [
            (UIColor(red: 0.85, green: 0.78, blue: 0.68, alpha: 0.8), UIColor(red: 0.4, green: 0.35, blue: 0.25, alpha: 1.0)),
            (UIColor(red: 0.82, green: 0.72, blue: 0.8, alpha: 0.8), UIColor(red: 0.4, green: 0.3, blue: 0.38, alpha: 1.0)),
            (UIColor(red: 0.88, green: 0.83, blue: 0.75, alpha: 0.8), UIColor(red: 0.38, green: 0.33, blue: 0.28, alpha: 1.0)),
            (UIColor(red: 0.78, green: 0.85, blue: 0.75, alpha: 0.8), UIColor(red: 0.3, green: 0.4, blue: 0.28, alpha: 1.0))
        ]
        
        // Create a container to hold tag buttons with proper flow layout
        let containerWidth = UIScreen.main.bounds.width - 72 // Account for card margins (16*2 + 20*2)
        let spacing: CGFloat = 12
        var currentRowWidth: CGFloat = 0
        var rowViews: [UIStackView] = []
        var currentRowStackView = createRowStackView()
        rowViews.append(currentRowStackView)
        
        for (index, tag) in moodEntry.tags.enumerated() {
            let tagButton = UIButton(type: .custom)
            tagButton.setTitle(tag, for: .normal)
            tagButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            
            let colorPair = tagColors[index % tagColors.count]
            tagButton.backgroundColor = colorPair.background
            tagButton.setTitleColor(colorPair.text, for: .normal)
            
            tagButton.layer.cornerRadius = 16
            tagButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
            
            tagButton.layer.shadowColor = UIColor.black.cgColor
            tagButton.layer.shadowOpacity = 0.05
            tagButton.layer.shadowRadius = 3
            tagButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            
            tagButton.translatesAutoresizingMaskIntoConstraints = false
            tagButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            // Calculate button width
            let buttonSize = tagButton.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 36))
            let buttonWidth = buttonSize.width
            
            // Check if button fits in current row
            let neededWidth = currentRowWidth + (currentRowStackView.arrangedSubviews.isEmpty ? 0 : spacing) + buttonWidth
            
            if neededWidth > containerWidth && !currentRowStackView.arrangedSubviews.isEmpty {
                // Start new row
                currentRowStackView = createRowStackView()
                rowViews.append(currentRowStackView)
                currentRowWidth = buttonWidth
            } else {
                currentRowWidth = neededWidth
            }
            
            currentRowStackView.addArrangedSubview(tagButton)
        }
        
        // Add all row stack views to the main tags stack view
        tagsStackView.axis = .vertical
        tagsStackView.spacing = 8
        tagsStackView.alignment = .leading
        tagsStackView.distribution = .fill
        
        for rowStackView in rowViews {
            tagsStackView.addArrangedSubview(rowStackView)
        }
        
        // Update height constraint to grow with content
        updateTagsCardHeight()
    }
    
    private func updateTagsCardHeight(isEditingMode: Bool = false) {
        // Remove existing constraint
        tagsCardHeightConstraint?.isActive = false
        
        // Calculate the exact height needed based on content
        let calculatedHeight = calculateRequiredHeight(isEditingMode: isEditingMode)
        tagsCardHeightConstraint = tagsCardView.heightAnchor.constraint(equalToConstant: calculatedHeight)
        tagsCardHeightConstraint?.isActive = true
        
        // Animate the height change
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func calculateRequiredHeight(isEditingMode: Bool = false) -> CGFloat {
        let topPadding: CGFloat = 20      // tagsLabel top margin
        let labelHeight: CGFloat = 30     // tagsLabel height (20pt semibold font needs more space)
        let labelToContentSpacing: CGFloat = 24  // increased spacing between label and tags
        let bottomPadding: CGFloat = 20   // bottom margin
        
        if isEditingMode {
            // For editing mode, calculate height for tag selection buttons (8 tags in 2-3 rows typically)
            let editTagHeight: CGFloat = 32   // Height of edit tag buttons
            let editTagSpacing: CGFloat = 8   // Spacing between edit tags
            let editRowSpacing: CGFloat = 8   // Spacing between rows
            let saveButtonsHeight: CGFloat = 44  // Height of save/cancel buttons
            let saveButtonsSpacing: CGFloat = 16 // Spacing above save buttons
            
            let availableTags = ["Work", "Sleep", "Family", "Social", "Self-care", "Exercise", "Creativity", "Stress"]
            let containerWidth = UIScreen.main.bounds.width - 72
            
            // Calculate rows needed for editing tags
            var currentRowWidth: CGFloat = 0
            var numberOfRows: Int = 1
            
            for tag in availableTags {
                let tempButton = UIButton()
                tempButton.setTitle(tag, for: .normal)
                tempButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                tempButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                
                let buttonSize = tempButton.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: editTagHeight))
                let buttonWidth = buttonSize.width
                
                let neededWidth = currentRowWidth + (currentRowWidth > 0 ? editTagSpacing : 0) + buttonWidth
                
                if neededWidth > containerWidth && currentRowWidth > 0 {
                    numberOfRows += 1
                    currentRowWidth = buttonWidth
                } else {
                    currentRowWidth = neededWidth
                }
            }
            
            let editTagsHeight = CGFloat(numberOfRows) * editTagHeight + CGFloat(numberOfRows - 1) * editRowSpacing
            return topPadding + labelHeight + labelToContentSpacing + editTagsHeight + saveButtonsSpacing + saveButtonsHeight + bottomPadding
            
        } else if moodEntry.tags.isEmpty {
            // Empty state: ensure minimum height to show header + content
            let emptyStateHeight: CGFloat = 20  // Height of "No tags added" text
            let calculatedHeight = topPadding + labelHeight + labelToContentSpacing + emptyStateHeight + bottomPadding
            return max(calculatedHeight, 110) // Ensure minimum 110pt height for header space
        } else {
            // Calculate height based on number of tag rows
            let containerWidth = UIScreen.main.bounds.width - 72 // Account for card margins (16*2 + 20*2)
            let tagSpacing: CGFloat = 12
            let tagRowHeight: CGFloat = 36  // Height of tag buttons
            let rowSpacing: CGFloat = 8     // Spacing between rows
            
            // Calculate how many rows we need
            var currentRowWidth: CGFloat = 0
            var numberOfRows: Int = 1
            
            for tag in moodEntry.tags {
                // Create a temporary button to measure size
                let tempButton = UIButton()
                tempButton.setTitle(tag, for: .normal)
                tempButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                tempButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
                
                let buttonSize = tempButton.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: tagRowHeight))
                let buttonWidth = buttonSize.width
                
                // Check if button fits in current row
                let neededWidth = currentRowWidth + (currentRowWidth > 0 ? tagSpacing : 0) + buttonWidth
                
                if neededWidth > containerWidth && currentRowWidth > 0 {
                    // Start new row
                    numberOfRows += 1
                    currentRowWidth = buttonWidth
                } else {
                    currentRowWidth = neededWidth
                }
            }
            
            // Calculate total content height
            let tagsContentHeight = CGFloat(numberOfRows) * tagRowHeight + CGFloat(numberOfRows - 1) * rowSpacing
            let calculatedHeight = topPadding + labelHeight + labelToContentSpacing + tagsContentHeight + bottomPadding
            return max(calculatedHeight, 110) // Ensure minimum height to show header
        }
    }
    
    private func createRowStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        if isEditingJournal {
            cancelEditing()
        } else if isEditingTags {
            cancelTagsEditing()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func editButtonTapped() {
        toggleEditingMode()
    }
    
    @objc private func saveButtonTapped() {
        saveJournalChanges()
    }
    
    @objc private func cancelButtonTapped() {
        cancelEditing()
    }
    
    @objc private func playButtonTapped() {
        // Animate play button
        UIView.animate(withDuration: 0.1, animations: {
            self.playButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.playButton.transform = .identity
            }
        }
        
        // Toggle play/pause
        let isPlaying = playButton.currentImage == UIImage(systemName: "pause.fill")
        let newImage = isPlaying ? UIImage(systemName: "play.fill") : UIImage(systemName: "pause.fill")
        playButton.setImage(newImage, for: .normal)
        
        // Simulate playback animation
        if !isPlaying {
            animateWaveform()
        }
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete Entry",
            message: "Are you sure you want to delete this mood entry? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteMoodEntry()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteMoodEntry() {
        let success = dataManager.deleteMoodEntry(for: moodEntry.date)
        
        if success {
            // Notify delegate about the deletion
            delegate?.moodEntryDidDelete(moodEntry)
            
            // Animate deletion feedback
            UIView.animate(withDuration: 0.3, animations: {
                self.view.alpha = 0.5
                self.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                // Navigate back
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            // Show error alert
            let errorAlert = UIAlertController(
                title: "Delete Failed", 
                message: "Could not delete the mood entry. Please try again.", 
                preferredStyle: .alert
            )
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func tagsEditButtonTapped() {
        toggleTagsEditingMode()
    }
    
    @objc private func tagsSaveButtonTapped() {
        saveTagsChanges()
    }
    
    @objc private func tagsCancelButtonTapped() {
        cancelTagsEditing()
    }
    
    @objc private func tagEditButtonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        
        if selectedTags.contains(title) {
            selectedTags.remove(title)
            sender.backgroundColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) :
                    UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
            }
            sender.setTitleColor(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                    UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
            }, for: .normal)
        } else {
            selectedTags.insert(title)
            sender.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.3)
            sender.setTitleColor(UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0), for: .normal)
        }
    }
    
    // MARK: - Editing Methods
    private func toggleEditingMode() {
        isEditingJournal.toggle()
        
        if isEditingJournal {
            startEditing()
        } else {
            cancelEditing()
        }
    }
    
    private func toggleTagsEditingMode() {
        isEditingTags.toggle()
        
        if isEditingTags {
            startTagsEditing()
        } else {
            cancelTagsEditing()
        }
    }
    
    private func startTagsEditing() {
        selectedTags = Set(originalTags)
        updateTagEditButtons()
        
        // Ensure adequate height for editing mode
        updateTagsCardHeight(isEditingMode: true)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.tagsStackView.alpha = 0
            // Keep tags label and edit button visible during transition
        }) { _ in
            self.tagsStackView.isHidden = true
            // Don't hide the tagsEditButton - keep it visible
            
            self.tagsEditContainerView.isHidden = false
            self.tagsEditContainerView.alpha = 0
            self.tagsEditButtonsStackView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.tagsEditContainerView.alpha = 1
                self.tagsEditButtonsStackView.alpha = 1
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func cancelTagsEditing() {
        selectedTags = Set(originalTags)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.tagsEditContainerView.alpha = 0
            self.tagsEditButtonsStackView.alpha = 0
        }) { _ in
            self.tagsEditContainerView.isHidden = true
            self.tagsEditButtonsStackView.isHidden = true
            
            self.tagsStackView.isHidden = false
            // Tags label and edit button should already be visible
            self.tagsStackView.alpha = 0
            
            // Restore correct height based on current tags
            self.updateTagsCardHeight()
            
            UIView.animate(withDuration: 0.3) {
                self.tagsStackView.alpha = 1
                
                self.view.layoutIfNeeded()
            }
        }
        
        isEditingTags = false
    }
    
    private func saveTagsChanges() {
        let newTagsArray = Array(selectedTags)
        
        // Update the mood entry with new tags
        let success = dataManager.saveMoodEntry(
            emoji: moodEntry.emoji,
            moodLabel: moodEntry.moodLabel,
            journalText: moodEntry.journalText,
            tags: newTagsArray,
            voiceRecordingPath: dataManager.getVoiceRecordingPath(for: moodEntry.date),
            voiceRecordingDuration: dataManager.getVoiceRecordingDuration(for: moodEntry.date)
        )
        
        if success {
            // Update local mood entry object
            let updatedEntry = MoodEntry(
                id: moodEntry.id,
                date: moodEntry.date,
                emoji: moodEntry.emoji,
                moodLabel: moodEntry.moodLabel,
                journalText: moodEntry.journalText,
                tags: newTagsArray
            )
            self.moodEntry = updatedEntry
            
            // Update original tags
            originalTags = selectedTags
            
            // Update tags display (this will also update the height)
            setupTags()
            
            // Notify delegate about the update
            delegate?.moodEntryDidUpdate(updatedEntry)
            
            // Show success feedback
            showTagsSaveSuccess()
            
        } else {
            // Show error alert
            let alert = UIAlertController(title: "Save Failed", message: "Could not save tags. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        // Exit editing mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.cancelTagsEditing()
        }
    }
    
    private func updateTagEditButtons() {
        let availableTags = ["Work", "Sleep", "Family", "Social", "Self-care", "Exercise", "Creativity", "Stress"]
        
        for (index, tag) in availableTags.enumerated() {
            if index < tagEditButtons.count {
                let button = tagEditButtons[index]
                if selectedTags.contains(tag) {
                    button.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.3)
                    button.setTitleColor(UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0), for: .normal)
                } else {
                    button.backgroundColor = UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark ?
                            UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) :
                            UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
                    }
                    button.setTitleColor(UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark ?
                            UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) :
                            UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
                    }, for: .normal)
                }
            }
        }
    }
    
    private func showTagsSaveSuccess() {
        // Create temporary success label
        let successLabel = UILabel()
        successLabel.text = "✅ Tags Saved"
        successLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        successLabel.textColor = UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0)
        successLabel.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 0.9, alpha: 0.9)
        successLabel.textAlignment = .center
        successLabel.layer.cornerRadius = 12
        successLabel.clipsToBounds = true
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(successLabel)
        
        NSLayoutConstraint.activate([
            successLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            successLabel.widthAnchor.constraint(equalToConstant: 120),
            successLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Animate in and out
        successLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            successLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, animations: {
                successLabel.alpha = 0
            }) { _ in
                successLabel.removeFromSuperview()
            }
        }
    }
    
    private func startEditing() {
        // Use the actual journal text, not the display text which might be "No journal entry"
        journalTextView.text = moodEntry.journalText
        
        UIView.animate(withDuration: 0.3, animations: {
            self.journalDisplayLabel.alpha = 0
            self.editButton.alpha = 0
        }) { _ in
            self.journalDisplayLabel.isHidden = true
            self.editButton.isHidden = true
            
            self.journalTextView.isHidden = false
            self.journalTextView.alpha = 0
            self.editButtonsStackView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.journalTextView.alpha = 1
                self.editButtonsStackView.alpha = 1
                
                // Update constraints for editing mode
                self.view.layoutIfNeeded()
            }
            
            self.journalTextView.becomeFirstResponder()
        }
    }
    
    private func cancelEditing() {
        journalTextView.text = originalJournalText
        
        // Update display label to show current journal text
        let displayText = originalJournalText.isEmpty ? "No journal entry" : originalJournalText
        journalDisplayLabel.text = displayText
        journalDisplayLabel.textColor = originalJournalText.isEmpty ? 
            UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) : 
            UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) :
                    UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.journalTextView.alpha = 0
            self.editButtonsStackView.alpha = 0
        }) { _ in
            self.journalTextView.isHidden = true
            self.editButtonsStackView.isHidden = true
            
            self.journalDisplayLabel.isHidden = false
            self.editButton.isHidden = false
            self.journalDisplayLabel.alpha = 0
            self.editButton.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.journalDisplayLabel.alpha = 1
                self.editButton.alpha = 1
                
                // Update constraints for display mode
                self.view.layoutIfNeeded()
            }
        }
        
        isEditingJournal = false
        journalTextView.resignFirstResponder()
    }
    
    private func saveJournalChanges() {
        guard let newText = journalTextView.text else { return }
        
        // Allow empty text (user can clear journal entry)
        let trimmedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("💾 Saving journal text: '\(trimmedText)' (original: '\(originalJournalText)')")
        
        // Update the mood entry with new journal text
        let success = dataManager.saveMoodEntry(
            emoji: moodEntry.emoji,
            moodLabel: moodEntry.moodLabel,
            journalText: trimmedText,
            tags: moodEntry.tags,
            voiceRecordingPath: dataManager.getVoiceRecordingPath(for: moodEntry.date),
            voiceRecordingDuration: dataManager.getVoiceRecordingDuration(for: moodEntry.date)
        )
        
        print("💾 Save result: \(success)")
        
        if success {
            // Update local mood entry object
            let updatedEntry = MoodEntry(
                id: moodEntry.id,
                date: moodEntry.date,
                emoji: moodEntry.emoji,
                moodLabel: moodEntry.moodLabel,
                journalText: trimmedText,
                tags: moodEntry.tags
            )
            self.moodEntry = updatedEntry
            
            // Update UI
            let displayText = trimmedText.isEmpty ? "No journal entry" : trimmedText
            print("💾 Updating display text to: '\(displayText)'")
            journalDisplayLabel.text = displayText
            journalDisplayLabel.textColor = trimmedText.isEmpty ? 
                UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) : 
                UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ?
                        UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) :
                        UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                }
            
            originalJournalText = trimmedText
            
            // Notify delegate about the update
            delegate?.moodEntryDidUpdate(updatedEntry)
            
            // Animate save feedback
            UIView.animate(withDuration: 0.2, animations: {
                self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                self.saveButton.alpha = 0.8
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.saveButton.transform = .identity
                    self.saveButton.alpha = 1.0
                }
            }
            
            // Show success feedback
            showSaveSuccess()
            
        } else {
            // Show error alert
            let alert = UIAlertController(title: "Save Failed", message: "Could not save journal entry. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        // Exit editing mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.cancelEditing()
        }
    }
    
    private func showSaveSuccess() {
        // Create temporary success label
        let successLabel = UILabel()
        successLabel.text = "✅ Saved"
        successLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        successLabel.textColor = UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0)
        successLabel.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 0.9, alpha: 0.9)
        successLabel.textAlignment = .center
        successLabel.layer.cornerRadius = 12
        successLabel.clipsToBounds = true
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(successLabel)
        
        NSLayoutConstraint.activate([
            successLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            successLabel.widthAnchor.constraint(equalToConstant: 100),
            successLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Animate in and out
        successLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            successLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, animations: {
                successLabel.alpha = 0
            }) { _ in
                successLabel.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Animations
    private func animateWaveform() {
        for (index, subview) in waveformView.subviews.enumerated() {
            let delay = Double(index) * 0.1
            
            UIView.animate(withDuration: 0.5, delay: delay, options: [.repeat, .autoreverse], animations: {
                subview.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: 0.5...1.5))
            })
        }
    }
    
    // MARK: - Keyboard Handling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Scroll to show the text view
        if isEditingJournal {
            let rect = journalTextView.convert(journalTextView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
