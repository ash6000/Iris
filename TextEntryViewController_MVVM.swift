import UIKit

class TextEntryViewController_MVVM: UIViewController {
    private let viewModel = TextEntryViewModel()

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let modeDropdown = UIButton()
    private let menuButton = UIButton()

    // Main Content
    private let questionLabel = UILabel()
    private let dateLabel = UILabel()

    // Mood Selection
    private let moodSelectionLabel = UILabel()
    private let moodStackView = UIStackView()
    private var moodButtons: [UIButton] = []
    private var selectedMoodIndex = 3 // Default to happy emoji (index 3)

    // Prompt Section
    private let promptContainerView = UIView()
    private let promptHeaderView = UIView()
    private let promptTitleLabel = UILabel()
    private let promptToggleButton = UIButton()
    private let promptSubtitleLabel = UILabel()

    // Text Input Section
    private let textInputLabel = UILabel()
    private let textInputContainerView = UIView()
    private let textView = UITextView()
    private let wordCountLabel = UILabel()
    private let voiceToTextButton = UIButton()

    // Bottom Actions (now in scroll view)
    private let saveDraftButton = UIButton()
    private let saveEntryButton = UIButton()
    private let cancelButton = UIButton()

    // State
    private var wordCount = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardHandling()
        bindViewModel()
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
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        setupHeader()
        setupMainContent()
        setupMoodSelection()
        setupPromptSection()
        setupTextInput()
        setupBottomActions()
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(headerView)

        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.setTitle(" Back", for: .normal)
        backButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal)
        backButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        headerView.addSubview(backButton)

        // Mode Dropdown (centered)
        modeDropdown.translatesAutoresizingMaskIntoConstraints = false
        modeDropdown.setTitle("Text", for: .normal)
        modeDropdown.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        modeDropdown.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal)
        modeDropdown.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        modeDropdown.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        modeDropdown.semanticContentAttribute = .forceRightToLeft
        modeDropdown.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        headerView.addSubview(modeDropdown)

        // Menu Button
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        headerView.addSubview(menuButton)
    }

    private func setupMainContent() {
        // Question Label
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.text = "How are you today?"
        questionLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        questionLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        questionLabel.textAlignment = .center
        contentView.addSubview(questionLabel)

        // Date Label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "January 15, 2025"
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        dateLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        dateLabel.textAlignment = .center
        contentView.addSubview(dateLabel)
    }

    private func setupMoodSelection() {
        moodSelectionLabel.translatesAutoresizingMaskIntoConstraints = false
        moodSelectionLabel.text = "Select your mood"
        moodSelectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        moodSelectionLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentView.addSubview(moodSelectionLabel)

        moodStackView.translatesAutoresizingMaskIntoConstraints = false
        moodStackView.axis = .horizontal
        moodStackView.distribution = .equalSpacing
        moodStackView.alignment = .center
        contentView.addSubview(moodStackView)

        let moods = ["😢", "😔", "😐", "😊", "😄"]

        for (index, mood) in moods.enumerated() {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(mood, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            button.tag = index
            button.addTarget(self, action: #selector(moodButtonTapped(_:)), for: .touchUpInside)

            if index == selectedMoodIndex {
                button.backgroundColor = UIColor.white
                button.layer.cornerRadius = 30
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.1
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
            }

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 60),
                button.heightAnchor.constraint(equalToConstant: 60)
            ])

            moodButtons.append(button)
            moodStackView.addArrangedSubview(button)
        }
    }

    private func setupPromptSection() {
        promptContainerView.translatesAutoresizingMaskIntoConstraints = false
        promptContainerView.backgroundColor = UIColor.white
        promptContainerView.layer.cornerRadius = 12
        promptContainerView.layer.borderWidth = 1
        promptContainerView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        contentView.addSubview(promptContainerView)

        // Prompt Header
        promptHeaderView.translatesAutoresizingMaskIntoConstraints = false
        promptContainerView.addSubview(promptHeaderView)

        promptTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        promptTitleLabel.text = "Today's Prompt (Optional)"
        promptTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        promptTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        promptHeaderView.addSubview(promptTitleLabel)

        promptToggleButton.translatesAutoresizingMaskIntoConstraints = false
        promptToggleButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        promptToggleButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        promptHeaderView.addSubview(promptToggleButton)

        promptSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        promptSubtitleLabel.text = "What brought you peace today?"
        promptSubtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        promptSubtitleLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        promptContainerView.addSubview(promptSubtitleLabel)
    }

    private func setupTextInput() {
        textInputLabel.translatesAutoresizingMaskIntoConstraints = false
        textInputLabel.text = "Your thoughts"
        textInputLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textInputLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentView.addSubview(textInputLabel)

        textInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        textInputContainerView.backgroundColor = UIColor.white
        textInputContainerView.layer.cornerRadius = 12
        textInputContainerView.layer.borderWidth = 1
        textInputContainerView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        contentView.addSubview(textInputContainerView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        textView.backgroundColor = UIColor.clear
        textView.delegate = self
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        // Add placeholder
        let placeholderText = "Take a deep breath and share what's on your mind..."
        textView.text = placeholderText
        textView.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)

        textInputContainerView.addSubview(textView)

        // Bottom toolbar in text container
        let bottomToolbar = UIView()
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbar.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        textInputContainerView.addSubview(bottomToolbar)

        wordCountLabel.translatesAutoresizingMaskIntoConstraints = false
        wordCountLabel.text = "0 words"
        wordCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        wordCountLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        bottomToolbar.addSubview(wordCountLabel)

        voiceToTextButton.translatesAutoresizingMaskIntoConstraints = false
        voiceToTextButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        voiceToTextButton.setTitle(" Voice to text", for: .normal)
        voiceToTextButton.setTitleColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), for: .normal)
        voiceToTextButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        voiceToTextButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bottomToolbar.addSubview(voiceToTextButton)

        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: textInputContainerView.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: textInputContainerView.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: textInputContainerView.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 40),

            wordCountLabel.leadingAnchor.constraint(equalTo: bottomToolbar.leadingAnchor, constant: 16),
            wordCountLabel.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor),

            voiceToTextButton.trailingAnchor.constraint(equalTo: bottomToolbar.trailingAnchor, constant: -16),
            voiceToTextButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor),

            textView.topAnchor.constraint(equalTo: textInputContainerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textInputContainerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textInputContainerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor)
        ])
    }

    private func setupBottomActions() {
        // Save Draft Button
        saveDraftButton.translatesAutoresizingMaskIntoConstraints = false
        saveDraftButton.setTitle("Save Draft", for: .normal)
        saveDraftButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveDraftButton.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
        saveDraftButton.backgroundColor = UIColor.white
        saveDraftButton.layer.cornerRadius = 12
        saveDraftButton.layer.borderWidth = 1
        saveDraftButton.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        contentView.addSubview(saveDraftButton)

        // Save Entry Button
        saveEntryButton.translatesAutoresizingMaskIntoConstraints = false
        saveEntryButton.setTitle("Save Entry", for: .normal)
        saveEntryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        saveEntryButton.setTitleColor(UIColor.white, for: .normal)
        saveEntryButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        saveEntryButton.layer.cornerRadius = 12
        contentView.addSubview(saveEntryButton)

        // Cancel Button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), for: .normal)
        cancelButton.backgroundColor = UIColor.clear
        contentView.addSubview(cancelButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            modeDropdown.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            modeDropdown.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            menuButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            menuButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 24),
            menuButton.heightAnchor.constraint(equalToConstant: 24),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Question Label
            questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            questionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Date Label
            dateLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 8),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Mood Selection
            moodSelectionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 32),
            moodSelectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            moodStackView.topAnchor.constraint(equalTo: moodSelectionLabel.bottomAnchor, constant: 16),
            moodStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            moodStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),

            // Prompt Section
            promptContainerView.topAnchor.constraint(equalTo: moodStackView.bottomAnchor, constant: 32),
            promptContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            promptContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            promptContainerView.heightAnchor.constraint(equalToConstant: 80),

            promptHeaderView.topAnchor.constraint(equalTo: promptContainerView.topAnchor, constant: 16),
            promptHeaderView.leadingAnchor.constraint(equalTo: promptContainerView.leadingAnchor, constant: 16),
            promptHeaderView.trailingAnchor.constraint(equalTo: promptContainerView.trailingAnchor, constant: -16),
            promptHeaderView.heightAnchor.constraint(equalToConstant: 24),

            promptTitleLabel.leadingAnchor.constraint(equalTo: promptHeaderView.leadingAnchor),
            promptTitleLabel.centerYAnchor.constraint(equalTo: promptHeaderView.centerYAnchor),

            promptToggleButton.trailingAnchor.constraint(equalTo: promptHeaderView.trailingAnchor),
            promptToggleButton.centerYAnchor.constraint(equalTo: promptHeaderView.centerYAnchor),

            promptSubtitleLabel.topAnchor.constraint(equalTo: promptHeaderView.bottomAnchor, constant: 8),
            promptSubtitleLabel.leadingAnchor.constraint(equalTo: promptContainerView.leadingAnchor, constant: 16),
            promptSubtitleLabel.trailingAnchor.constraint(equalTo: promptContainerView.trailingAnchor, constant: -16),

            // Text Input
            textInputLabel.topAnchor.constraint(equalTo: promptContainerView.bottomAnchor, constant: 32),
            textInputLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            textInputContainerView.topAnchor.constraint(equalTo: textInputLabel.bottomAnchor, constant: 16),
            textInputContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            textInputContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            textInputContainerView.heightAnchor.constraint(equalToConstant: 200),

            // Bottom Actions (now in scroll view)
            saveDraftButton.topAnchor.constraint(equalTo: textInputContainerView.bottomAnchor, constant: 32),
            saveDraftButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            saveDraftButton.heightAnchor.constraint(equalToConstant: 50),

            saveEntryButton.topAnchor.constraint(equalTo: textInputContainerView.bottomAnchor, constant: 32),
            saveEntryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            saveEntryButton.leadingAnchor.constraint(equalTo: saveDraftButton.trailingAnchor, constant: 12),
            saveEntryButton.heightAnchor.constraint(equalToConstant: 50),
            saveEntryButton.widthAnchor.constraint(equalTo: saveDraftButton.widthAnchor, multiplier: 1.3),

            cancelButton.topAnchor.constraint(equalTo: saveDraftButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        modeDropdown.addTarget(self, action: #selector(modeDropdownTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        promptToggleButton.addTarget(self, action: #selector(promptToggleTapped), for: .touchUpInside)
        voiceToTextButton.addTarget(self, action: #selector(voiceToTextTapped), for: .touchUpInside)
        saveDraftButton.addTarget(self, action: #selector(saveDraftTapped), for: .touchUpInside)
        saveEntryButton.addTarget(self, action: #selector(saveEntryTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    private func setupKeyboardHandling() {
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

    private func bindViewModel() {
        viewModel.$entryText.bind(self) { [weak self] text in
            DispatchQueue.main.async {
                if self?.textView.text != text && text != "Take a deep breath and share what's on your mind..." {
                    self?.textView.text = text
                    self?.textView.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
                }
            }
        }

        viewModel.$wordCount.bind(self) { [weak self] count in
            DispatchQueue.main.async {
                self?.wordCount = count
                self?.wordCountLabel.text = "\(count) words"
            }
        }

        viewModel.$selectedMood.bind(self) { [weak self] mood in
            DispatchQueue.main.async {
                self?.selectedMoodIndex = mood
                self?.updateMoodSelection()
            }
        }

        viewModel.$currentPrompt.bind(self) { [weak self] prompt in
            DispatchQueue.main.async {
                self?.promptSubtitleLabel.text = prompt
            }
        }

        viewModel.$canSave.bind(self) { [weak self] canSave in
            DispatchQueue.main.async {
                self?.saveEntryButton.alpha = canSave ? 1.0 : 0.6
                self?.saveEntryButton.isEnabled = canSave
            }
        }

        viewModel.$isLoading.bind(self) { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.saveEntryButton.setTitle(isLoading ? "Saving..." : "Save Entry", for: .normal)
                self?.saveEntryButton.isEnabled = !isLoading
            }
        }
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func modeDropdownTapped() {
        print("Mode dropdown tapped")
    }

    @objc private func menuButtonTapped() {
        print("Menu button tapped")
    }

    @objc private func moodButtonTapped(_ sender: UIButton) {
        // Update selected mood
        for (index, button) in moodButtons.enumerated() {
            if index == sender.tag {
                button.backgroundColor = UIColor.white
                button.layer.cornerRadius = 30
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.1
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
                selectedMoodIndex = index
            } else {
                button.backgroundColor = UIColor.clear
                button.layer.cornerRadius = 0
                button.layer.borderWidth = 0
                button.layer.shadowOpacity = 0
            }
        }
        viewModel.updateMood(selectedMoodIndex)
    }

    @objc private func promptToggleTapped() {
        print("Prompt toggle tapped")
    }

    @objc private func voiceToTextTapped() {
        print("Voice to text tapped")
    }

    @objc private func saveDraftTapped() {
        print("Save draft tapped")
    }

    @objc private func saveEntryTapped() {
        print("Save entry tapped")
        viewModel.saveEntry()
        // Navigate back to journal
        navigationController?.popViewController(animated: true)
    }

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    // MARK: - Helper Methods
    private func updateWordCount() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty || text == "Take a deep breath and share what's on your mind..." {
            wordCount = 0
        } else {
            wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        }
        wordCountLabel.text = "\(wordCount) words"
    }

    private func updateMoodSelection() {
        for (index, button) in moodButtons.enumerated() {
            if index == selectedMoodIndex {
                button.backgroundColor = UIColor.white
                button.layer.cornerRadius = 30
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.1
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
            } else {
                button.backgroundColor = UIColor.clear
                button.layer.cornerRadius = 0
                button.layer.borderWidth = 0
                button.layer.shadowOpacity = 0
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate
extension TextEntryViewController_MVVM: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Take a deep breath and share what's on your mind..." {
            textView.text = ""
            textView.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Take a deep breath and share what's on your mind..."
            textView.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text == "Take a deep breath and share what's on your mind..." ? "" : textView.text
        viewModel.updateText(text ?? "")
        updateWordCount()
    }
}