//
//  GuidedEntryViewController.swift
//  irisOne
//
//  Created by Test User on 9/21/25.
//

import UIKit

class GuidedEntryViewController: UIViewController {

    // MARK: - UI Components
    private let tableView = UITableView()

    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let modeDropdown = UIButton()

    // Input Container
    private let inputContainerView = UIView()
    private let inputTextField = UITextField()
    private let voiceButton = UIButton()
    private let calendarButton = UIButton()


    // Chat messages data
    private var messages: [GuidedJournalMessage] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupInitialMessages()
        setupKeyboardHandling()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        setupHeader()
        setupTableView()
        setupInputContainer()
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
        modeDropdown.setTitle("Guided Entry", for: .normal)
        modeDropdown.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        modeDropdown.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal)
        modeDropdown.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        modeDropdown.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        modeDropdown.semanticContentAttribute = .forceRightToLeft
        modeDropdown.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        headerView.addSubview(modeDropdown)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        // Register cells
        tableView.register(IntroMessageCell.self, forCellReuseIdentifier: "IntroMessageCell")
        tableView.register(MoodSelectionCell.self, forCellReuseIdentifier: "MoodSelectionCell")
        tableView.register(AIMessageCell.self, forCellReuseIdentifier: "AIMessageCell")
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: "UserMessageCell")

        view.addSubview(tableView)
    }

    private func setupInputContainer() {
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(inputContainerView)

        // Input Text Field
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.placeholder = "I'm feeling..."
        inputTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        inputTextField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        inputTextField.backgroundColor = UIColor.white
        inputTextField.layer.cornerRadius = 20
        inputTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        inputTextField.leftViewMode = .always
        inputTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 0))
        inputTextField.rightViewMode = .always
        inputContainerView.addSubview(inputTextField)

        // Voice Button
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        voiceButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        voiceButton.backgroundColor = UIColor.white
        voiceButton.layer.cornerRadius = 20
        inputContainerView.addSubview(voiceButton)

        // Calendar Button
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        calendarButton.backgroundColor = UIColor.white
        calendarButton.layer.cornerRadius = 20
        inputContainerView.addSubview(calendarButton)
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

            // Table View
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),

            // Input Container
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            inputContainerView.heightAnchor.constraint(equalToConstant: 80),

            inputTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            inputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),
            inputTextField.trailingAnchor.constraint(equalTo: voiceButton.leadingAnchor, constant: -8),

            voiceButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            voiceButton.widthAnchor.constraint(equalToConstant: 40),
            voiceButton.heightAnchor.constraint(equalToConstant: 40),
            voiceButton.trailingAnchor.constraint(equalTo: calendarButton.leadingAnchor, constant: -8),

            calendarButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            calendarButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            calendarButton.widthAnchor.constraint(equalToConstant: 40),
            calendarButton.heightAnchor.constraint(equalToConstant: 40),

        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        modeDropdown.addTarget(self, action: #selector(modeDropdownTapped), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(voiceButtonTapped), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        inputTextField.addTarget(self, action: #selector(textFieldDidEndOnExit), for: .editingDidEndOnExit)
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

    private func setupInitialMessages() {
        messages = [
            GuidedJournalMessage(
                type: .intro,
                content: "What's on your mind today? Do you want today's backup prompt?",
                isUser: false
            ),
            GuidedJournalMessage(
                type: .moodSelection,
                content: "How are you feeling right now?",
                isUser: false
            ),
            GuidedJournalMessage(
                type: .aiMessage,
                content: "I sense you might be carrying some weight today. What's been on your heart lately?",
                isUser: false
            ),
            GuidedJournalMessage(
                type: .userMessage,
                content: "I'm feeling overwhelmed with work and personal stuff. Everything feels like it's piling up.",
                isUser: true
            ),
            GuidedJournalMessage(
                type: .aiMessage,
                content: "That feeling of overwhelm is so human and valid. Let's breathe through this together. Can you name one small thing that brought you even a moment of peace today?",
                isUser: false
            )
        ]

        tableView.reloadData()

        // Scroll to bottom
        DispatchQueue.main.async {
            if !self.messages.isEmpty {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
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

    @objc private func voiceButtonTapped() {
        print("Voice button tapped")
    }

    @objc private func calendarButtonTapped() {
        print("Calendar button tapped")
    }

    @objc private func textFieldDidChange() {
        // Handle text changes
    }

    @objc private func textFieldDidEndOnExit() {
        sendMessage()
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height

            // Adjust input container position
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -keyboardHeight + self.view.safeAreaInsets.bottom
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {

        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    private func sendMessage() {
        guard let text = inputTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Add user message
        let userMessage = GuidedJournalMessage(type: .userMessage, content: text, isUser: true)
        messages.append(userMessage)

        // Clear input
        inputTextField.text = ""

        // Reload and scroll
        tableView.reloadData()
        scrollToBottom()

        // Simulate AI response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addAIResponse()
        }
    }

    private func addAIResponse() {
        let responses = [
            "That's a beautiful reflection. How does it feel to share that?",
            "I hear you. What would you like to explore about that feeling?",
            "Thank you for being so open. What comes up for you when you sit with that?",
            "That sounds meaningful. Can you tell me more about what that experience was like?"
        ]

        let randomResponse = responses.randomElement() ?? responses[0]
        let aiMessage = GuidedJournalMessage(type: .aiMessage, content: randomResponse, isUser: false)
        messages.append(aiMessage)

        tableView.reloadData()
        scrollToBottom()
    }

    private func scrollToBottom() {
        DispatchQueue.main.async {
            if !self.messages.isEmpty {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource
extension GuidedEntryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]

        switch message.type {
        case .intro:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IntroMessageCell", for: indexPath) as! IntroMessageCell
            cell.configure(with: message.content)
            return cell
        case .moodSelection:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoodSelectionCell", for: indexPath) as! MoodSelectionCell
            cell.configure(with: message.content)
            return cell
        case .aiMessage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AIMessageCell", for: indexPath) as! AIMessageCell
            cell.configure(with: message.content)
            return cell
        case .userMessage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageCell", for: indexPath) as! UserMessageCell
            cell.configure(with: message.content)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension GuidedEntryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Chat Message Model
struct GuidedJournalMessage {
    enum MessageType {
        case intro
        case moodSelection
        case aiMessage
        case userMessage
    }

    let type: MessageType
    let content: String
    let isUser: Bool
}

// MARK: - Custom Cells
class IntroMessageCell: UITableViewCell {
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        contentView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with message: String) {
        messageLabel.text = message
    }
}

class MoodSelectionCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let moodStackView = UIStackView()
    private var selectedMoodIndex = 1

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentView.addSubview(titleLabel)

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
            button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
            button.tag = index

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 44),
                button.heightAnchor.constraint(equalToConstant: 44)
            ])

            moodStackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            moodStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            moodStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            moodStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            moodStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with message: String) {
        titleLabel.text = message
    }
}

class AIMessageCell: UITableViewCell {
    private let avatarView = UIView()
    private let messageContainerView = UIView()
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        // Avatar
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 16
        contentView.addSubview(avatarView)

        let avatarIcon = UIImageView()
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.image = UIImage(systemName: "sparkles")
        avatarIcon.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        avatarIcon.contentMode = .scaleAspectFit
        avatarView.addSubview(avatarIcon)

        // Message container
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        messageContainerView.layer.cornerRadius = 16
        messageContainerView.layer.cornerCurve = .continuous
        contentView.addSubview(messageContainerView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        messageLabel.numberOfLines = 0
        messageContainerView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),

            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 16),
            avatarIcon.heightAnchor.constraint(equalToConstant: 16),

            messageContainerView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60),
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with message: String) {
        messageLabel.text = message
    }
}

class UserMessageCell: UITableViewCell {
    private let messageContainerView = UIView()
    private let messageLabel = UILabel()
    private let avatarView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        // Message container
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        messageContainerView.layer.cornerRadius = 16
        messageContainerView.layer.cornerCurve = .continuous
        contentView.addSubview(messageContainerView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0
        messageContainerView.addSubview(messageLabel)

        // Avatar
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 16
        contentView.addSubview(avatarView)

        let avatarIcon = UIImageView()
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.image = UIImage(systemName: "person.fill")
        avatarIcon.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        avatarIcon.contentMode = .scaleAspectFit
        avatarView.addSubview(avatarIcon)

        NSLayoutConstraint.activate([
            messageContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60),
            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageContainerView.trailingAnchor.constraint(equalTo: avatarView.leadingAnchor, constant: -12),
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -12),

            avatarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),

            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 16),
            avatarIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(with message: String) {
        messageLabel.text = message
    }
}