//
//
//
////
////  ActualChatViewController.swift
////  irisOne
////
////  Created by Test User on 7/26/25.
////
//
//import Foundation
//import UIKit
//
//class ActualChatViewController: UIViewController {
//    
//    private let category: ChatCategoryData
//    private var messages: [ChatMessage] = []
//    private var tokensLeft = 3
//    private var isTyping = false
//    
//    // UI Components
//    private let headerView = UIView()
//    private let backButton = UIButton()
//    private let categoryIconView = UIImageView()
//    private let titleStackView = UIStackView()
//    private let titleLabel = UILabel()
//    private let subtitleLabel = UILabel()
//    private let tokensLabel = UILabel()
//    private let tokensProgressView = UIProgressView()
//    private let switchTo3DButton = UIButton()
//    
//    private let tableView = UITableView()
//    private let inputContainerView = UIView()
//    private let inputBackgroundView = UIView()
//    private let messageInputField = UITextField()
//    private let sendButton = UIButton()
//    
//    // Keyboard handling
//    private var inputContainerBottomConstraint: NSLayoutConstraint!
//    
//    init(category: ChatCategoryData) {
//        self.category = category
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupConstraints()
//        setupKeyboardObservers()
//        loadInitialMessages()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        removeKeyboardObservers()
//    }
//    
//    deinit {
//        removeKeyboardObservers()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
//        
//        setupHeader()
//        setupTableView()
//        setupInputBar()
//    }
//    
//    private func setupHeader() {
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
//        view.addSubview(headerView)
//        
//        // Back Button
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        backButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1.0)
//        backButton.layer.cornerRadius = 20
//        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        backButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
//        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        headerView.addSubview(backButton)
//        
//        // Switch to 3D Button
//        switchTo3DButton.translatesAutoresizingMaskIntoConstraints = false
//        switchTo3DButton.backgroundColor = UIColor.white
//        switchTo3DButton.layer.cornerRadius = 16
//        switchTo3DButton.layer.borderWidth = 1.5
//        switchTo3DButton.layer.borderColor = UIColor(red: 0.8, green: 0.4, blue: 0.7, alpha: 0.6).cgColor
//        switchTo3DButton.setTitle("✨ 3D Mode", for: .normal)
//        switchTo3DButton.setTitleColor(UIColor(red: 0.6, green: 0.3, blue: 0.6, alpha: 1.0), for: .normal)
//        switchTo3DButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
//        switchTo3DButton.addTarget(self, action: #selector(switchTo3DModeTapped), for: .touchUpInside)
//        headerView.addSubview(switchTo3DButton)
//        
//        // Category Icon
//        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
//        categoryIconView.backgroundColor = category.backgroundColor
//        categoryIconView.layer.cornerRadius = 20
//        categoryIconView.image = UIImage(systemName: category.iconName)
//        categoryIconView.tintColor = .white
//        categoryIconView.contentMode = .center
//        headerView.addSubview(categoryIconView)
//        
//        // Title Stack
//        titleStackView.translatesAutoresizingMaskIntoConstraints = false
//        titleStackView.axis = .vertical
//        titleStackView.alignment = .leading
//        titleStackView.spacing = 2
//        headerView.addSubview(titleStackView)
//        
//        // Title Label - Fixed for long titles
//        titleLabel.text = category.title
//        titleLabel.font = UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
//        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        titleLabel.numberOfLines = 2
//        titleLabel.lineBreakMode = .byWordWrapping
//        titleLabel.adjustsFontSizeToFitWidth = true
//        titleLabel.minimumScaleFactor = 0.8
//        titleStackView.addArrangedSubview(titleLabel)
//        
//        subtitleLabel.text = "with Iris"
//        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        titleStackView.addArrangedSubview(subtitleLabel)
//        
//        // Tokens Label - Smaller and more compact
//        tokensLabel.translatesAutoresizingMaskIntoConstraints = false
//        tokensLabel.text = "\(tokensLeft) tokens\nleft"
//        tokensLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
//        tokensLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        tokensLabel.textAlignment = .right
//        tokensLabel.numberOfLines = 2
//        headerView.addSubview(tokensLabel)
//        
//        // Progress View
//        tokensProgressView.translatesAutoresizingMaskIntoConstraints = false
//        tokensProgressView.progressTintColor = category.backgroundColor
//        tokensProgressView.trackTintColor = UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1.0)
//        tokensProgressView.progress = Float(tokensLeft) / 5.0
//        tokensProgressView.layer.cornerRadius = 2
//        tokensProgressView.clipsToBounds = true
//        headerView.addSubview(tokensProgressView)
//    }
//    
//    private func setupTableView() {
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.backgroundColor = .clear
//        tableView.separatorStyle = .none
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
//        tableView.register(TypingIndicatorCell.self, forCellReuseIdentifier: "TypingIndicatorCell")
//        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
//        tableView.keyboardDismissMode = .onDrag
//        tableView.showsVerticalScrollIndicator = false
//        view.addSubview(tableView)
//    }
//    
//    private func setupInputBar() {
//        // Input Container
//        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
//        inputContainerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
//        view.addSubview(inputContainerView)
//        
//        // Input Background
//        inputBackgroundView.translatesAutoresizingMaskIntoConstraints = false
//        inputBackgroundView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
//        inputBackgroundView.layer.cornerRadius = 20
//        inputBackgroundView.layer.cornerCurve = .continuous
//        inputContainerView.addSubview(inputBackgroundView)
//        
//        // Message Input Field
//        messageInputField.translatesAutoresizingMaskIntoConstraints = false
//        messageInputField.placeholder = "Type a message..."
//        messageInputField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        messageInputField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        messageInputField.backgroundColor = .clear
//        messageInputField.borderStyle = .none
//        messageInputField.returnKeyType = .send
//        messageInputField.delegate = self
//        inputBackgroundView.addSubview(messageInputField)
//        
//        // Send Button
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
//        sendButton.tintColor = category.backgroundColor
//        sendButton.backgroundColor = .clear
//        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
//        inputBackgroundView.addSubview(sendButton)
//        
//        // Add tap gesture to table view to dismiss keyboard
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tapGesture.cancelsTouchesInView = false
//        tableView.addGestureRecognizer(tapGesture)
//    }
//    
//    private func setupConstraints() {
//        // Store the input container bottom constraint for keyboard handling
//        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
//        
//        NSLayoutConstraint.activate([
//            // Header
//            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            headerView.heightAnchor.constraint(equalToConstant: 80),
//            
//            // Back Button
//            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            backButton.widthAnchor.constraint(equalToConstant: 40),
//            backButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Switch to 3D Button
//            switchTo3DButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            switchTo3DButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
//            switchTo3DButton.widthAnchor.constraint(equalToConstant: 85),
//            switchTo3DButton.heightAnchor.constraint(equalToConstant: 32),
//            
//            // Category Icon
//            categoryIconView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
//            categoryIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            categoryIconView.widthAnchor.constraint(equalToConstant: 40),
//            categoryIconView.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Title Stack - Adjusted for 3D button
//            titleStackView.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 12),
//            titleStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            titleStackView.trailingAnchor.constraint(equalTo: tokensLabel.leadingAnchor, constant: -12),
//            
//            // Tokens Label - Repositioned
//            tokensLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            tokensLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
//            tokensLabel.widthAnchor.constraint(equalToConstant: 60),
//            
//            // Progress View
//            tokensProgressView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            tokensProgressView.topAnchor.constraint(equalTo: tokensLabel.bottomAnchor, constant: 2),
//            tokensProgressView.widthAnchor.constraint(equalToConstant: 60),
//            tokensProgressView.heightAnchor.constraint(equalToConstant: 4),
//            
//            // Input Container
//            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            inputContainerBottomConstraint,
//            inputContainerView.heightAnchor.constraint(equalToConstant: 60),
//            
//            // Input Background
//            inputBackgroundView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
//            inputBackgroundView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
//            inputBackgroundView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
//            inputBackgroundView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -8),
//            
//            // Message Input Field
//            messageInputField.leadingAnchor.constraint(equalTo: inputBackgroundView.leadingAnchor, constant: 16),
//            messageInputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
//            messageInputField.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
//            
//            // Send Button
//            sendButton.trailingAnchor.constraint(equalTo: inputBackgroundView.trailingAnchor, constant: -12),
//            sendButton.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
//            sendButton.widthAnchor.constraint(equalToConstant: 28),
//            sendButton.heightAnchor.constraint(equalToConstant: 28),
//            
//            // Table View
//            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
//        ])
//    }
//    
//    // MARK: - Actions
//    @objc private func switchTo3DModeTapped() {
//        let immersiveVC = ImmersiveChatViewController(category: category, messages: messages)
//        immersiveVC.modalPresentationStyle = .fullScreen
//        immersiveVC.modalTransitionStyle = .crossDissolve
//        present(immersiveVC, animated: true)
//    }
//    
//    @objc private func sendButtonTapped() {
//        sendMessage()
//    }
//    
//    @objc private func dismissKeyboard() {
//        view.endEditing(true)
//    }
//    
//    @objc private func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    // MARK: - Message Handling (existing methods remain the same)
//    private func loadInitialMessages() {
//        let categorySpecificMessage = getCategorySpecificMessage()
//        
//        messages = [
//            ChatMessage(
//                text: categorySpecificMessage,
//                isFromIris: true,
//                timestamp: "2:14 PM"
//            ),
//            ChatMessage(
//                text: "I've been feeling uncertain about this lately.",
//                isFromIris: false,
//                timestamp: "2:15 PM"
//            ),
//            ChatMessage(
//                text: "Thank you for sharing that with me. Uncertainty can be a sacred space where transformation begins. What would it feel like to trust the process?",
//                isFromIris: true,
//                timestamp: "2:15 PM"
//            )
//        ]
//        
//        tableView.reloadData()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.showTypingIndicator()
//        }
//    }
//    
//    private func getCategorySpecificMessage() -> String {
//        switch category.title {
//        case "What's my Purpose?":
//            return "What deep calling is stirring in your soul? Let's explore your unique gifts and purpose together."
//        case "Dreams & Interpretation":
//            return "What dreams have been visiting you? Let's unlock the wisdom your subconscious is sharing."
//        case "Love & Relationships":
//            return "What's on your heart about love and connection? I'm here to help you heal and grow."
//        case "Inner Peace & Mindfulness":
//            return "How can we bring more peace into your daily experience? Let's find your center together."
//        case "Overcoming pain or loss":
//            return "I honor your courage in facing this pain. Let's transform it into wisdom and healing together."
//        case "Spiritual connection & signs":
//            return "What signs and synchronicities have you been noticing? The universe speaks in many ways."
//        case "Creativity & Self-Expression":
//            return "What creative energy is wanting to flow through you? Let's unlock your artistic gifts."
//        case "Life Directions & Decisions":
//            return "What crossroads are you facing? Let's explore the path that aligns with your highest good."
//        case "Your Past & Story":
//            return "Your story has shaped you beautifully. How can we honor your journey and integrate its lessons?"
//        case "The Future & Hope":
//            return "What dreams are calling to your heart? Let's plant seeds for the future you desire."
//        case "Forgiveness & Letting Go":
//            return "What are you ready to release? Forgiveness is a gift you give yourself."
//        case "Astrology & Messages from the Universe":
//            return "What cosmic wisdom is calling to you? Let's explore the messages written in the stars."
//        default:
//            return "What's stirring in your heart today? I'm here to listen and guide you."
//        }
//    }
//    
//    private func showTypingIndicator() {
//        isTyping = true
//        tableView.insertRows(at: [IndexPath(row: messages.count, section: 0)], with: .none)
//        scrollToBottom()
//    }
//    
//    private func hideTypingIndicator() {
//        if isTyping {
//            isTyping = false
//            tableView.deleteRows(at: [IndexPath(row: messages.count, section: 0)], with: .none)
//        }
//    }
//    
//    private func scrollToBottom() {
//        let totalRows = messages.count + (isTyping ? 1 : 0)
//        if totalRows > 0 {
//            let indexPath = IndexPath(row: totalRows - 1, section: 0)
//            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        }
//    }
//    
//    private func sendMessage() {
//        guard let text = messageInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
//              !text.isEmpty else { return }
//        
//        let userMessage = ChatMessage(
//            text: text,
//            isFromIris: false,
//            timestamp: getCurrentTimeString()
//        )
//        
//        hideTypingIndicator()
//        messages.append(userMessage)
//        messageInputField.text = ""
//        
//        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .bottom)
//        scrollToBottom()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.showTypingIndicator()
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                self.addIrisResponse()
//            }
//        }
//    }
//    
//    private func addIrisResponse() {
//        let responses = [
//            "I hear the wisdom in your words. What does your heart tell you about this?",
//            "Thank you for trusting me with this. How does sharing this make you feel?",
//            "That's a beautiful insight. What step feels most aligned for you right now?",
//            "I sense there's more to explore here. What's calling for your attention?"
//        ]
//        
//        let irisMessage = ChatMessage(
//            text: responses.randomElement() ?? responses[0],
//            isFromIris: true,
//            timestamp: getCurrentTimeString()
//        )
//        
//        hideTypingIndicator()
//        messages.append(irisMessage)
//        
//        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .bottom)
//        scrollToBottom()
//    }
//    
//    private func getCurrentTimeString() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "h:mm a"
//        return formatter.string(from: Date())
//    }
//    
//    // MARK: - Keyboard Handling (existing methods remain the same)
//    private func setupKeyboardObservers() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow(_:)),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil
//        )
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHide(_:)),
//            name: UIResponder.keyboardWillHideNotification,
//            object: nil
//        )
//    }
//    
//    private func removeKeyboardObservers() {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//    
//    @objc private func keyboardWillShow(_ notification: Notification) {
//        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
//              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
//            return
//        }
//        
//        let keyboardHeight = keyboardFrame.height
//        let safeAreaBottomInset = view.safeAreaInsets.bottom
//        
//        inputContainerBottomConstraint.constant = -(keyboardHeight - safeAreaBottomInset - 85)
//        
//        UIView.animate(withDuration: animationDuration, animations: {
//            self.view.layoutIfNeeded()
//        }) { _ in
//            self.scrollToBottom()
//        }
//    }
//    
//    @objc private func keyboardWillHide(_ notification: Notification) {
//        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
//            return
//        }
//        
//        inputContainerBottomConstraint.constant = -15
//        
//        UIView.animate(withDuration: animationDuration) {
//            self.view.layoutIfNeeded()
//        }
//    }
//}
//
//// MARK: - Table View Extensions (unchanged)
//extension ActualChatViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count + (isTyping ? 1 : 0)
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row < messages.count {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
//            cell.configure(with: messages[indexPath.row], categoryColor: category.backgroundColor)
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TypingIndicatorCell", for: indexPath) as! TypingIndicatorCell
//            cell.configure(with: category.backgroundColor)
//            return cell
//        }
//    }
//}
//
//extension ActualChatViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        sendMessage()
//        return true
//    }
//}

//
//  ActualChatViewController.swift
//  irisOne
//
//  Created by Test User on 7/26/25.
//

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
    private let switchTo3DButton = UIButton()
    
    private let tableView = UITableView()
    private let inputContainerView = UIView()
    private let inputBackgroundView = UIView()
    private let messageInputField = UITextField()
    private let sendButton = UIButton()
    
    // Keyboard handling
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    weak var customTabBarController: CustomTabBarController?
    
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
    
//    private func setupHeader() {
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
//        view.addSubview(headerView)
//        
//        // Back Button
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        backButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1.0)
//        backButton.layer.cornerRadius = 20
//        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        backButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
//        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        headerView.addSubview(backButton)
//        
//        // Switch to 3D Button
//        switchTo3DButton.translatesAutoresizingMaskIntoConstraints = false
//        switchTo3DButton.backgroundColor = UIColor.white
//        switchTo3DButton.layer.cornerRadius = 16
//        switchTo3DButton.layer.borderWidth = 1.5
//        switchTo3DButton.layer.borderColor = UIColor(red: 0.8, green: 0.4, blue: 0.7, alpha: 0.6).cgColor
//        switchTo3DButton.setTitle("✨ 3D Mode", for: .normal)
//        switchTo3DButton.setTitleColor(UIColor(red: 0.6, green: 0.3, blue: 0.6, alpha: 1.0), for: .normal)
//        switchTo3DButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
//        switchTo3DButton.addTarget(self, action: #selector(switchTo3DModeTapped), for: .touchUpInside)
//        switchTo3DButton.isHidden = false
//        headerView.addSubview(switchTo3DButton)
//        
//        // Category Icon
//        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
//        categoryIconView.backgroundColor = category.backgroundColor
//        categoryIconView.layer.cornerRadius = 20
//        categoryIconView.image = UIImage(systemName: category.iconName)
//        categoryIconView.tintColor = .white
//        categoryIconView.contentMode = .center
//        headerView.addSubview(categoryIconView)
//        
//        // Title Stack
//        titleStackView.translatesAutoresizingMaskIntoConstraints = false
//        titleStackView.axis = .vertical
//        titleStackView.alignment = .leading
//        titleStackView.spacing = 2
//        headerView.addSubview(titleStackView)
//        
//        // Title Label - Fixed for long titles
//        titleLabel.text = category.title
//        titleLabel.font = UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
//        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        titleLabel.numberOfLines = 2
//        titleLabel.lineBreakMode = .byWordWrapping
//        titleLabel.adjustsFontSizeToFitWidth = true
//        titleLabel.minimumScaleFactor = 0.8
//        titleStackView.addArrangedSubview(titleLabel)
//        
//        subtitleLabel.text = "with Iris"
//        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        titleStackView.addArrangedSubview(subtitleLabel)
//        
//        // Tokens Label - Smaller and more compact
//        tokensLabel.translatesAutoresizingMaskIntoConstraints = false
//        tokensLabel.text = "\(tokensLeft) tokens\nleft"
//        tokensLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
//        tokensLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        tokensLabel.textAlignment = .right
//        tokensLabel.numberOfLines = 2
//        headerView.addSubview(tokensLabel)
//        
//        // Progress View
//        tokensProgressView.translatesAutoresizingMaskIntoConstraints = false
//        tokensProgressView.progressTintColor = category.backgroundColor
//        tokensProgressView.trackTintColor = UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1.0)
//        tokensProgressView.progress = Float(tokensLeft) / 5.0
//        tokensProgressView.layer.cornerRadius = 2
//        tokensProgressView.clipsToBounds = true
//        headerView.addSubview(tokensProgressView)
//    }
    
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
    


//    private func setupHeader() {
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
//        view.addSubview(headerView)
//        
//        // Back Button
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        backButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1.0)
//        backButton.layer.cornerRadius = 20
//        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        backButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
//        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        headerView.addSubview(backButton)
//        
//        // Improved 3D Button - Matches the design language
//        switchTo3DButton.translatesAutoresizingMaskIntoConstraints = false
//        switchTo3DButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1.0)
//        switchTo3DButton.layer.cornerRadius = 18
//        switchTo3DButton.layer.cornerCurve = .continuous
//        
//        // Create a subtle gradient background
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor(red: 0.92, green: 0.89, blue: 0.84, alpha: 1.0).cgColor,
//            UIColor(red: 0.84, green: 0.81, blue: 0.76, alpha: 1.0).cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientLayer.cornerRadius = 18
//        switchTo3DButton.layer.insertSublayer(gradientLayer, at: 0)
//        
//        // Add subtle shadow
//        switchTo3DButton.layer.shadowColor = UIColor.black.cgColor
//        switchTo3DButton.layer.shadowOpacity = 0.05
//        switchTo3DButton.layer.shadowRadius = 4
//        switchTo3DButton.layer.shadowOffset = CGSize(width: 0, height: 2)
//        
//        // Create custom content view for the button
//        let buttonContentView = UIView()
//        buttonContentView.translatesAutoresizingMaskIntoConstraints = false
//        buttonContentView.isUserInteractionEnabled = false
//        switchTo3DButton.addSubview(buttonContentView)
//        
//        // 3D Icon using SF Symbols
//        let iconImageView = UIImageView()
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconImageView.image = UIImage(systemName: "cube.transparent")
//        iconImageView.tintColor = category.backgroundColor
//        iconImageView.contentMode = .scaleAspectFit
//        buttonContentView.addSubview(iconImageView)
//        
//        // 3D Label
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "3D"
//        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
//        label.textColor = category.backgroundColor
//        buttonContentView.addSubview(label)
//        
//        switchTo3DButton.addTarget(self, action: #selector(switchTo3DModeTapped), for: .touchUpInside)
//        headerView.addSubview(switchTo3DButton)
//        
//        // Update the gradient layer frame when the button's bounds change
//        DispatchQueue.main.async {
//            gradientLayer.frame = self.switchTo3DButton.bounds
//        }
//        
//        // Category Icon
//        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
//        categoryIconView.backgroundColor = category.backgroundColor
//        categoryIconView.layer.cornerRadius = 20
//        categoryIconView.image = UIImage(systemName: category.iconName)
//        categoryIconView.tintColor = .white
//        categoryIconView.contentMode = .center
//        headerView.addSubview(categoryIconView)
//        
//        // Title Stack
//        titleStackView.translatesAutoresizingMaskIntoConstraints = false
//        titleStackView.axis = .vertical
//        titleStackView.alignment = .leading
//        titleStackView.spacing = 2
//        headerView.addSubview(titleStackView)
//        
//        // Title Label - Fixed for long titles
//        titleLabel.text = category.title
//        titleLabel.font = UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
//        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        titleLabel.numberOfLines = 2
//        titleLabel.lineBreakMode = .byWordWrapping
//        titleLabel.adjustsFontSizeToFitWidth = true
//        titleLabel.minimumScaleFactor = 0.8
//        titleStackView.addArrangedSubview(titleLabel)
//        
//        subtitleLabel.text = "with Iris"
//        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        titleStackView.addArrangedSubview(subtitleLabel)
//        
//        // Tokens UI removed for cleaner design
//        
//        // Constraints for the new button design
//        NSLayoutConstraint.activate([
//            // Button content view
//            buttonContentView.centerXAnchor.constraint(equalTo: switchTo3DButton.centerXAnchor),
//            buttonContentView.centerYAnchor.constraint(equalTo: switchTo3DButton.centerYAnchor),
//            buttonContentView.widthAnchor.constraint(equalTo: switchTo3DButton.widthAnchor, constant: -8),
//            buttonContentView.heightAnchor.constraint(equalTo: switchTo3DButton.heightAnchor, constant: -8),
//            
//            // Icon positioning
//            iconImageView.leadingAnchor.constraint(equalTo: buttonContentView.leadingAnchor, constant: 4),
//            iconImageView.centerYAnchor.constraint(equalTo: buttonContentView.centerYAnchor),
//            iconImageView.widthAnchor.constraint(equalToConstant: 14),
//            iconImageView.heightAnchor.constraint(equalToConstant: 14),
//            
//            // Label positioning
//            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 4),
//            label.centerYAnchor.constraint(equalTo: buttonContentView.centerYAnchor),
//            label.trailingAnchor.constraint(lessThanOrEqualTo: buttonContentView.trailingAnchor, constant: -4)
//        ])
//    }

    // Update the setupConstraints method to reflect the new button size:
//    private func setupConstraints() {
//        // Store the input container bottom constraint for keyboard handling
//        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
//        
//        NSLayoutConstraint.activate([
//            // Header
//            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            headerView.heightAnchor.constraint(equalToConstant: 80),
//            
//            // Back Button
//            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            backButton.widthAnchor.constraint(equalToConstant: 40),
//            backButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Improved 3D Button - Better positioned and sized
//            switchTo3DButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            switchTo3DButton.centerYAnchor.constraint(equalTo: categoryIconView.centerYAnchor),
//            switchTo3DButton.widthAnchor.constraint(equalToConstant: 50),
//            switchTo3DButton.heightAnchor.constraint(equalToConstant: 36),
//            
//            // Category Icon
//            categoryIconView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
//            categoryIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            categoryIconView.widthAnchor.constraint(equalToConstant: 40),
//            categoryIconView.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Title Stack - Clean layout without tokens UI
//            titleStackView.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 12),
//            titleStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            titleStackView.trailingAnchor.constraint(equalTo: switchTo3DButton.leadingAnchor, constant: -12),
//            
//            // Input Container (unchanged)
//            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            inputContainerBottomConstraint,
//            inputContainerView.heightAnchor.constraint(equalToConstant: 60),
//            
//            // Input Background (unchanged)
//            inputBackgroundView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
//            inputBackgroundView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
//            inputBackgroundView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
//            inputBackgroundView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -8),
//            
//            // Message Input Field (unchanged)
//            messageInputField.leadingAnchor.constraint(equalTo: inputBackgroundView.leadingAnchor, constant: 16),
//            messageInputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
//            messageInputField.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
//            
//            // Send Button (unchanged)
//            sendButton.trailingAnchor.constraint(equalTo: inputBackgroundView.trailingAnchor, constant: -12),
//            sendButton.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
//            sendButton.widthAnchor.constraint(equalToConstant: 28),
//            sendButton.heightAnchor.constraint(equalToConstant: 28),
//            
//            // Table View (unchanged)
//            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
//        ])
//    }
    
    // Replace the setupHeader() method in ActualChatViewController with this improved version:

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
        
        // Enhanced 3D Button - More elegant with extra space
        switchTo3DButton.translatesAutoresizingMaskIntoConstraints = false
        switchTo3DButton.backgroundColor = UIColor.white
        switchTo3DButton.layer.cornerRadius = 22
        switchTo3DButton.layer.cornerCurve = .continuous
        
        // Enhanced gradient with more depth
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(red: 0.96, green: 0.94, blue: 0.92, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 22
        switchTo3DButton.layer.insertSublayer(gradientLayer, at: 0)
        
        // Enhanced shadow for depth
        switchTo3DButton.layer.shadowColor = UIColor.black.cgColor
        switchTo3DButton.layer.shadowOpacity = 0.08
        switchTo3DButton.layer.shadowRadius = 8
        switchTo3DButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Subtle border for definition
        switchTo3DButton.layer.borderWidth = 0.5
        switchTo3DButton.layer.borderColor = UIColor(red: 0.85, green: 0.83, blue: 0.80, alpha: 0.4).cgColor
        
        // Create custom content view for the button
        let buttonContentView = UIView()
        buttonContentView.translatesAutoresizingMaskIntoConstraints = false
        buttonContentView.isUserInteractionEnabled = false
        switchTo3DButton.addSubview(buttonContentView)
        
        // Enhanced 3D Icon stack
        let iconStackView = UIStackView()
        iconStackView.translatesAutoresizingMaskIntoConstraints = false
        iconStackView.axis = .horizontal
        iconStackView.alignment = .center
        iconStackView.spacing = 6
        iconStackView.isUserInteractionEnabled = false
        buttonContentView.addSubview(iconStackView)
        
        // 3D Icon using a more prominent symbol
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "cube.transparent")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        )
        iconImageView.tintColor = category.backgroundColor
        iconImageView.contentMode = .scaleAspectFit
        iconStackView.addArrangedSubview(iconImageView)
        
        // Enhanced label with better typography
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3D Mode"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = category.backgroundColor
        iconStackView.addArrangedSubview(label)
        
        // Add a subtle shine effect
        let shineView = UIView()
        shineView.translatesAutoresizingMaskIntoConstraints = false
        shineView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        shineView.layer.cornerRadius = 22
        shineView.layer.cornerCurve = .continuous
        shineView.isUserInteractionEnabled = false
        switchTo3DButton.insertSubview(shineView, at: 1)
        
        switchTo3DButton.addTarget(self, action: #selector(switchTo3DModeTapped), for: .touchUpInside)
        headerView.addSubview(switchTo3DButton)
        
        // Update the gradient layer frame when the button's bounds change
        DispatchQueue.main.async {
            gradientLayer.frame = self.switchTo3DButton.bounds
        }
        
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
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleStackView.addArrangedSubview(titleLabel)
        
        subtitleLabel.text = "with Iris"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        titleStackView.addArrangedSubview(subtitleLabel)
        
        // Tokens UI removed for cleaner design
        
        // Constraints for the enhanced button design
        NSLayoutConstraint.activate([
            // Button content view - centered
            buttonContentView.centerXAnchor.constraint(equalTo: switchTo3DButton.centerXAnchor),
            buttonContentView.centerYAnchor.constraint(equalTo: switchTo3DButton.centerYAnchor),
            
            // Icon stack view - perfectly centered
            iconStackView.centerXAnchor.constraint(equalTo: buttonContentView.centerXAnchor),
            iconStackView.centerYAnchor.constraint(equalTo: buttonContentView.centerYAnchor),
            
            // Icon dimensions
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // Shine effect overlay
            shineView.topAnchor.constraint(equalTo: switchTo3DButton.topAnchor),
            shineView.leadingAnchor.constraint(equalTo: switchTo3DButton.leadingAnchor),
            shineView.trailingAnchor.constraint(equalTo: switchTo3DButton.trailingAnchor),
            shineView.heightAnchor.constraint(equalTo: switchTo3DButton.heightAnchor, multiplier: 0.4)
        ])
    }

    // Update the setupConstraints method to reflect the new button size:
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
            
            // Enhanced 3D Button - Larger and more prominent
            switchTo3DButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            switchTo3DButton.centerYAnchor.constraint(equalTo: categoryIconView.centerYAnchor),
            switchTo3DButton.widthAnchor.constraint(equalToConstant: 100),
            switchTo3DButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Category Icon
            categoryIconView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            categoryIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 40),
            categoryIconView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title Stack - Clean layout without tokens UI
            titleStackView.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 12),
            titleStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleStackView.trailingAnchor.constraint(equalTo: switchTo3DButton.leadingAnchor, constant: -12),
            
            // Input Container (unchanged)
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            inputContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Input Background (unchanged)
            inputBackgroundView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
            inputBackgroundView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            inputBackgroundView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            inputBackgroundView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -8),
            
            // Message Input Field (unchanged)
            messageInputField.leadingAnchor.constraint(equalTo: inputBackgroundView.leadingAnchor, constant: 16),
            messageInputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageInputField.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
            
            // Send Button (unchanged)
            sendButton.trailingAnchor.constraint(equalTo: inputBackgroundView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 28),
            sendButton.heightAnchor.constraint(equalToConstant: 28),
            
            // Table View (unchanged)
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
        ])
    }

    // Add this method to handle the gradient layer updates in viewDidLayoutSubviews:
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient layer frame if it exists
        if let gradientLayer = switchTo3DButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = switchTo3DButton.bounds
        }
    }

 
    
    // Replace the switchTo3DModeTapped method in ActualChatViewController with this:

    @objc private func switchTo3DModeTapped() {
        // Use the enhanced method from CustomTabBarController
        customTabBarController?.presentImmersiveChatForCategory(category, messages: messages)
    }
    
    @objc private func sendButtonTapped() {
        sendMessage()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Message Handling (existing methods remain the same)
    private func loadInitialMessages() {
        let categorySpecificMessage = getCategorySpecificMessage()
        
        messages = [
            ChatMessage(
                text: categorySpecificMessage,
                isFromIris: true
            ),
            ChatMessage(
                text: "I've been feeling uncertain about this lately.",
                isFromIris: false
            ),
            ChatMessage(
                text: "Thank you for sharing that with me. Uncertainty can be a sacred space where transformation begins. What would it feel like to trust the process?",
                isFromIris: true
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
    
    private func sendMessage() {
        guard let text = messageInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        let userMessage = ChatMessage(
            text: text,
            isFromIris: false
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
            isFromIris: true
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
    
    // MARK: - Keyboard Handling (existing methods remain the same)
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
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        
        inputContainerBottomConstraint.constant = -(keyboardHeight - safeAreaBottomInset - 85)
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        inputContainerBottomConstraint.constant = -15 // Back to normal position
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Table View Extensions (unchanged)
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
