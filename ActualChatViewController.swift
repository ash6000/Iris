//
//  ActualChatViewController.swift
//  irisOne
//
//  Created by Test User on 7/26/25.
//

import Foundation
import UIKit

class ActualChatViewController: UIViewController {
    
    private let category: ChatCategoryData
    private var messages: [ChatMessage] = []
    private var tokensLeft = 3
    private var isTyping = false
    
    // UI Components
    private let headerView = UIView()
    private let backButton = UIButton()
    private let categoryIconView = UIImageView()
    private let titleStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let tokensLabel = UILabel()
    private let tokensProgressView = UIProgressView()
    
    private let tableView = UITableView()
    private let inputContainerView = UIView()
    private let inputBackgroundView = UIView()
    private let messageInputField = UITextField()
    private let sendButton = UIButton()
    
    // Keyboard handling
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    
    init(category: ChatCategoryData) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardObservers()
        loadInitialMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        setupHeader()
        setupTableView()
        setupInputBar()
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(headerView)
        
        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1.0)
        backButton.layer.cornerRadius = 20
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        // Category Icon
        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
        categoryIconView.backgroundColor = category.backgroundColor
        categoryIconView.layer.cornerRadius = 20
        categoryIconView.image = UIImage(systemName: category.iconName)
        categoryIconView.tintColor = .white
        categoryIconView.contentMode = .center
        headerView.addSubview(categoryIconView)
        
        // Title Stack
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.alignment = .leading
        titleStackView.spacing = 2
        headerView.addSubview(titleStackView)
        
        // Title Label - Fixed for long titles
        titleLabel.text = category.title
        titleLabel.font = UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.numberOfLines = 2  // Allow 2 lines for long titles
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleStackView.addArrangedSubview(titleLabel)
        
        subtitleLabel.text = "with Iris"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        titleStackView.addArrangedSubview(subtitleLabel)
        
        // Tokens Label - Smaller and more compact
        tokensLabel.translatesAutoresizingMaskIntoConstraints = false
        tokensLabel.text = "\(tokensLeft) tokens\nleft"
        tokensLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        tokensLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        tokensLabel.textAlignment = .right
        tokensLabel.numberOfLines = 2
        headerView.addSubview(tokensLabel)
        
        // Progress View
        tokensProgressView.translatesAutoresizingMaskIntoConstraints = false
        tokensProgressView.progressTintColor = category.backgroundColor
        tokensProgressView.trackTintColor = UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1.0)
        tokensProgressView.progress = Float(tokensLeft) / 5.0
        tokensProgressView.layer.cornerRadius = 2
        tokensProgressView.clipsToBounds = true
        headerView.addSubview(tokensProgressView)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.register(TypingIndicatorCell.self, forCellReuseIdentifier: "TypingIndicatorCell")
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
    }
    
    private func setupInputBar() {
        // Input Container
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(inputContainerView)
        
        // Input Background
        inputBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        inputBackgroundView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        inputBackgroundView.layer.cornerRadius = 20
        inputBackgroundView.layer.cornerCurve = .continuous
        inputContainerView.addSubview(inputBackgroundView)
        
        // Message Input Field
        messageInputField.translatesAutoresizingMaskIntoConstraints = false
        messageInputField.placeholder = "Type a message..."
        messageInputField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageInputField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        messageInputField.backgroundColor = .clear
        messageInputField.borderStyle = .none
        messageInputField.returnKeyType = .send
        messageInputField.delegate = self
        inputBackgroundView.addSubview(messageInputField)
        
        // Send Button
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = category.backgroundColor
        sendButton.backgroundColor = .clear
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        inputBackgroundView.addSubview(sendButton)
        
        // Add tap gesture to table view to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        // Store the input container bottom constraint for keyboard handling
        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Category Icon
            categoryIconView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            categoryIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 40),
            categoryIconView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title Stack - Fixed width constraints
            titleStackView.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 12),
            titleStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleStackView.trailingAnchor.constraint(equalTo: tokensLabel.leadingAnchor, constant: -12),
            
            // Tokens Label - Fixed positioning
            tokensLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            tokensLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -6),
            tokensLabel.widthAnchor.constraint(equalToConstant: 60),
            
            // Progress View
            tokensProgressView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            tokensProgressView.topAnchor.constraint(equalTo: tokensLabel.bottomAnchor, constant: 2),
            tokensProgressView.widthAnchor.constraint(equalToConstant: 60),
            tokensProgressView.heightAnchor.constraint(equalToConstant: 4),
            
            // Input Container - Use stored constraint for keyboard handling
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            inputContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Input Background
            inputBackgroundView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
            inputBackgroundView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            inputBackgroundView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            inputBackgroundView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -8),
            
            // Message Input Field
            messageInputField.leadingAnchor.constraint(equalTo: inputBackgroundView.leadingAnchor, constant: 16),
            messageInputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageInputField.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
            
            // Send Button
            sendButton.trailingAnchor.constraint(equalTo: inputBackgroundView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 28),
            sendButton.heightAnchor.constraint(equalToConstant: 28),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
        ])
    }
    
    private func loadInitialMessages() {
        let categorySpecificMessage = getCategorySpecificMessage()
        
        messages = [
            ChatMessage(
                text: categorySpecificMessage,
                isFromIris: true,
                timestamp: "2:14 PM"
            ),
            ChatMessage(
                text: "I've been feeling uncertain about this lately.",
                isFromIris: false,
                timestamp: "2:15 PM"
            ),
            ChatMessage(
                text: "Thank you for sharing that with me. Uncertainty can be a sacred space where transformation begins. What would it feel like to trust the process?",
                isFromIris: true,
                timestamp: "2:15 PM"
            )
        ]
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showTypingIndicator()
        }
    }
    
    private func getCategorySpecificMessage() -> String {
        switch category.title {
        case "What's my Purpose?":
            return "What deep calling is stirring in your soul? Let's explore your unique gifts and purpose together."
        case "Dreams & Interpretation":
            return "What dreams have been visiting you? Let's unlock the wisdom your subconscious is sharing."
        case "Love & Relationships":
            return "What's on your heart about love and connection? I'm here to help you heal and grow."
        case "Inner Peace & Mindfulness":
            return "How can we bring more peace into your daily experience? Let's find your center together."
        case "Overcoming pain or loss":
            return "I honor your courage in facing this pain. Let's transform it into wisdom and healing together."
        case "Spiritual connection & signs":
            return "What signs and synchronicities have you been noticing? The universe speaks in many ways."
        case "Creativity & Self-Expression":
            return "What creative energy is wanting to flow through you? Let's unlock your artistic gifts."
        case "Life Directions & Decisions":
            return "What crossroads are you facing? Let's explore the path that aligns with your highest good."
        case "Your Past & Story":
            return "Your story has shaped you beautifully. How can we honor your journey and integrate its lessons?"
        case "The Future & Hope":
            return "What dreams are calling to your heart? Let's plant seeds for the future you desire."
        case "Forgiveness & Letting Go":
            return "What are you ready to release? Forgiveness is a gift you give yourself."
        case "Astrology & Messages from the Universe":
            return "What cosmic wisdom is calling to you? Let's explore the messages written in the stars."
        default:
            return "What's stirring in your heart today? I'm here to listen and guide you."
        }
    }
    
    private func showTypingIndicator() {
        isTyping = true
        tableView.insertRows(at: [IndexPath(row: messages.count, section: 0)], with: .none)
        scrollToBottom()
    }
    
    private func hideTypingIndicator() {
        if isTyping {
            isTyping = false
            tableView.deleteRows(at: [IndexPath(row: messages.count, section: 0)], with: .none)
        }
    }
    
    private func scrollToBottom() {
        let totalRows = messages.count + (isTyping ? 1 : 0)
        if totalRows > 0 {
            let indexPath = IndexPath(row: totalRows - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc private func sendButtonTapped() {
        sendMessage()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    @objc private func keyboardWillShow(_ notification: Notification) {
//        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
//              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
//            return
//        }
//        
//        let keyboardHeight = keyboardFrame.height
//        let safeAreaBottomInset = view.safeAreaInsets.bottom
//        
//        // Update the input container bottom constraint
//        inputContainerBottomConstraint.constant = -(keyboardHeight - safeAreaBottomInset)
//        
//        UIView.animate(withDuration: animationDuration, animations: {
//            self.view.layoutIfNeeded()
//        }) { _ in
//            // Scroll to bottom after keyboard animation completes
//            self.scrollToBottom()
//        }
//    }
    
//    @objc private func keyboardWillShow(_ notification: Notification) {
//        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
//              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
//            return
//        }
//        
//        let keyboardHeight = keyboardFrame.height
//        
//        // Position input container directly above keyboard, accounting for safe area
//        inputContainerBottomConstraint.constant = -keyboardHeight
//        
//        UIView.animate(withDuration: animationDuration, animations: {
//            self.view.layoutIfNeeded()
//        }) { _ in
//            // Scroll to bottom after keyboard animation completes
//            self.scrollToBottom()
//        }
//    }
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        
        // Since constraint is relative to safeAreaLayoutGuide, adjust for the difference
       // inputContainerBottomConstraint.constant = -(keyboardHeight  - 65)
        
        inputContainerBottomConstraint.constant = -(keyboardHeight - safeAreaBottomInset - 85)
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            // Scroll to bottom after keyboard animation completes
            self.scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        // Reset the input container bottom constraint
        inputContainerBottomConstraint.constant = -15
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func sendMessage() {
        guard let text = messageInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        let userMessage = ChatMessage(
            text: text,
            isFromIris: false,
            timestamp: getCurrentTimeString()
        )
        
        hideTypingIndicator()
        messages.append(userMessage)
        messageInputField.text = ""
        
        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .bottom)
        scrollToBottom()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showTypingIndicator()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.addIrisResponse()
            }
        }
    }
    
    private func addIrisResponse() {
        let responses = [
            "I hear the wisdom in your words. What does your heart tell you about this?",
            "Thank you for trusting me with this. How does sharing this make you feel?",
            "That's a beautiful insight. What step feels most aligned for you right now?",
            "I sense there's more to explore here. What's calling for your attention?"
        ]
        
        let irisMessage = ChatMessage(
            text: responses.randomElement() ?? responses[0],
            isFromIris: true,
            timestamp: getCurrentTimeString()
        )
        
        hideTypingIndicator()
        messages.append(irisMessage)
        
        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .bottom)
        scrollToBottom()
    }
    
    private func getCurrentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table View Extensions
extension ActualChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + (isTyping ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < messages.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
            cell.configure(with: messages[indexPath.row], categoryColor: category.backgroundColor)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TypingIndicatorCell", for: indexPath) as! TypingIndicatorCell
            cell.configure(with: category.backgroundColor)
            return cell
        }
    }
}

extension ActualChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
