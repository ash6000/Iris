import UIKit

class GuidedEntryViewController_MVVM: UIViewController {
    private let viewModel = GuidedEntryViewModel()

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
        setupKeyboardHandling()
        bindViewModel()
        setupInitialMessages()
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

    private func bindViewModel() {
        viewModel.$messages.bind(self) { [weak self] (messages: [GuidedJournalMessage]) in
            DispatchQueue.main.async {
                self?.messages = messages
                self?.tableView.reloadData()
                self?.scrollToBottom()
            }
        }

        viewModel.$isTyping.bind(self) { [weak self] isTyping in
            DispatchQueue.main.async {
                self?.inputTextField.isEnabled = !isTyping
            }
        }

        viewModel.$canSendMessage.bind(self) { [weak self] canSend in
            DispatchQueue.main.async {
                self?.inputTextField.isEnabled = canSend
            }
        }
    }

    private func setupInitialMessages() {
        viewModel.startSession()
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
        viewModel.sendUserMessage(text)

        // Clear input
        inputTextField.text = ""
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
extension GuidedEntryViewController_MVVM: UITableViewDataSource {
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
extension GuidedEntryViewController_MVVM: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


