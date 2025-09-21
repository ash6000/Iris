//
//  PersonalizedChatViewController.swift
//  irisOne
//
//  Created by Test User on 9/20/25.
//

import UIKit

class PersonalizedChatViewController: UIViewController {

    // MARK: - UI Components
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let moreButton = UIButton()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Avatar and greeting section
    private let avatarView = UIView()
    private let avatarImageView = UIImageView()
    private let greetingLabel = UILabel()
    private let descriptionLabel = UILabel()

    // Chat messages section
    private let messagesStackView = UIStackView()

    // Quick starters section
    private let quickStartersLabel = UILabel()
    private let quickStartersStackView = UIStackView()

    // Chat input section
    private let inputContainerView = UIView()
    private let inputBackgroundView = UIView()
    private let textInputView = UITextView()
    private let sendButton = UIButton()
    private let placeholderLabel = UILabel()


    // Data
    private var personalityType: String?
    private var messages: [ChatMessage] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadPersonalizedContent()
        setupKeyboardObservers()

        // Hide elements initially for animation
        prepareForAnimations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start the entrance animations
        startEntranceAnimations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        // Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(headerView)

        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Iris"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Your AI Companion"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        headerView.addSubview(subtitleLabel)

        // More Button
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        headerView.addSubview(moreButton)

        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Avatar View
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 50
        contentView.addSubview(avatarView)

        // Avatar Image
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(named: "iris_head")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 45
        avatarImageView.clipsToBounds = true
        avatarView.addSubview(avatarImageView)

        // Greeting Label
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.text = "Hi, I'm Iris"
        greetingLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        greetingLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        greetingLabel.textAlignment = .center
        contentView.addSubview(greetingLabel)

        // Description Label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "I'm your personalized AI companion, here to understand you and help with whatever's on your mind. Let's start our journey together."
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)

        // Messages Stack View
        messagesStackView.translatesAutoresizingMaskIntoConstraints = false
        messagesStackView.axis = .vertical
        messagesStackView.spacing = 16
        contentView.addSubview(messagesStackView)

        // Quick Starters Label
        quickStartersLabel.translatesAutoresizingMaskIntoConstraints = false
        quickStartersLabel.text = "Quick starters:"
        quickStartersLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        quickStartersLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        contentView.addSubview(quickStartersLabel)

        // Quick Starters Stack View
        quickStartersStackView.translatesAutoresizingMaskIntoConstraints = false
        quickStartersStackView.axis = .vertical
        quickStartersStackView.spacing = 12
        contentView.addSubview(quickStartersStackView)

        setupInitialMessagesData()
        setupQuickStarters()
        setupInputContainer()
    }

    private func setupInputContainer() {
        // Input Container
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(inputContainerView)

        // Input Background
        inputBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        inputBackgroundView.backgroundColor = UIColor.white
        inputBackgroundView.layer.cornerRadius = 20
        inputBackgroundView.layer.shadowColor = UIColor.black.cgColor
        inputBackgroundView.layer.shadowOpacity = 0.1
        inputBackgroundView.layer.shadowOffset = CGSize(width: 0, height: -2)
        inputBackgroundView.layer.shadowRadius = 8
        inputContainerView.addSubview(inputBackgroundView)

        // Text Input
        textInputView.translatesAutoresizingMaskIntoConstraints = false
        textInputView.backgroundColor = UIColor.clear
        textInputView.font = UIFont.systemFont(ofSize: 16)
        textInputView.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        textInputView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        textInputView.isScrollEnabled = false
        textInputView.delegate = self
        inputBackgroundView.addSubview(textInputView)

        // Placeholder Label
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "Ask me anything..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        placeholderLabel.isUserInteractionEnabled = false
        inputBackgroundView.addSubview(placeholderLabel)

        // Send Button
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        sendButton.layer.cornerRadius = 20
        sendButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        sendButton.tintColor = UIColor.white
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        inputBackgroundView.addSubview(sendButton)

        updatePlaceholderVisibility()
    }

    private func setupInitialMessagesData() {
        // Store initial messages data but don't add to UI yet
        // Will be animated in later
    }

    private func prepareForAnimations() {
        // Hide elements that will animate in
        avatarView.alpha = 0
        avatarView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)

        greetingLabel.alpha = 0
        greetingLabel.transform = CGAffineTransform(translationX: 0, y: 30)

        descriptionLabel.alpha = 0
        descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 30)

        quickStartersLabel.alpha = 0
        quickStartersStackView.alpha = 0

        inputContainerView.alpha = 0
        inputContainerView.transform = CGAffineTransform(translationX: 0, y: 50)
    }

    private func startEntranceAnimations() {
        // Animate header elements first
        animateHeaderElements()

        // Then animate messages with delays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.animateFirstMessage()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            self.animateSecondMessage()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.animateQuickStarters()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            self.animateInputContainer()
        }
    }

    private func animateHeaderElements() {
        // Avatar animation with spring effect
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.avatarView.alpha = 1
            self.avatarView.transform = CGAffineTransform.identity
        }) { _ in
            // Start breathing animation after avatar appears
            self.startBreathingAnimation()
        }

        // Greeting label animation
        UIView.animate(withDuration: 0.6, delay: 0.5, options: .curveEaseOut) {
            self.greetingLabel.alpha = 1
            self.greetingLabel.transform = CGAffineTransform.identity
        }

        // Description label animation
        UIView.animate(withDuration: 0.6, delay: 0.7, options: .curveEaseOut) {
            self.descriptionLabel.alpha = 1
            self.descriptionLabel.transform = CGAffineTransform.identity
        }
    }

    private func animateFirstMessage() {
        let firstMessage = createMessageBubble(
            text: "Hello! I've learned about your personality from our initial setup. I'm excited to be your thinking partner.",
            isFromIris: true
        )

        // Start with hidden and scaled down
        firstMessage.alpha = 0
        firstMessage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: -20, y: 0)

        messagesStackView.addArrangedSubview(firstMessage)

        // Animate typing effect
        animateTypingIndicator {
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                firstMessage.alpha = 1
                firstMessage.transform = CGAffineTransform.identity
            }
        }
    }

    private func animateSecondMessage() {
        let secondMessage = createMessageBubble(
            text: "What's on your mind today? I'm here to help you think through anything - whether it's planning your next big goal, solving a challenge, or just exploring ideas.",
            isFromIris: true
        )

        // Start with hidden and scaled down
        secondMessage.alpha = 0
        secondMessage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: -20, y: 0)

        messagesStackView.addArrangedSubview(secondMessage)

        // Animate typing effect
        animateTypingIndicator {
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                secondMessage.alpha = 1
                secondMessage.transform = CGAffineTransform.identity
            }
        }
    }

    private func animateQuickStarters() {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut) {
            self.quickStartersLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseOut) {
            self.quickStartersStackView.alpha = 1
        }
    }

    private func animateInputContainer() {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.inputContainerView.alpha = 1
            self.inputContainerView.transform = CGAffineTransform.identity
        }
    }

    private func animateTypingIndicator(completion: @escaping () -> Void) {
        // Create temporary typing indicator
        let typingIndicator = createTypingIndicator()
        typingIndicator.alpha = 0
        messagesStackView.addArrangedSubview(typingIndicator)

        // Fade in typing indicator
        UIView.animate(withDuration: 0.3) {
            typingIndicator.alpha = 1
        }

        // Show typing for 1.5 seconds then remove and show message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.2, animations: {
                typingIndicator.alpha = 0
            }) { _ in
                typingIndicator.removeFromSuperview()
                completion()
            }
        }
    }

    private func createTypingIndicator() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let bubbleView = UIView()
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = UIColor.white
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.05
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowRadius = 8
        containerView.addSubview(bubbleView)

        // Add avatar for Iris
        let avatarView = UIView()
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 16
        containerView.addSubview(avatarView)

        let avatarLabel = UILabel()
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.text = "I"
        avatarLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        avatarLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        avatarLabel.textAlignment = .center
        avatarView.addSubview(avatarLabel)

        // Add typing dots
        let dotsStackView = UIStackView()
        dotsStackView.translatesAutoresizingMaskIntoConstraints = false
        dotsStackView.axis = .horizontal
        dotsStackView.spacing = 4
        dotsStackView.alignment = .center
        bubbleView.addSubview(dotsStackView)

        for i in 0..<3 {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            dot.layer.cornerRadius = 3

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 6),
                dot.heightAnchor.constraint(equalToConstant: 6)
            ])

            dotsStackView.addArrangedSubview(dot)

            // Animate dots
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.3
            animation.toValue = 1.0
            animation.duration = 0.6
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.beginTime = CACurrentMediaTime() + Double(i) * 0.2
            dot.layer.add(animation, forKey: "opacity")
        }

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            avatarView.topAnchor.constraint(equalTo: containerView.topAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),

            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            bubbleView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            bubbleView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            dotsStackView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            dotsStackView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            dotsStackView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 16),
            dotsStackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16)
        ])

        return containerView
    }

    private func startBreathingAnimation() {
        let breathingAnimation = CABasicAnimation(keyPath: "transform.scale")
        breathingAnimation.fromValue = 1.0
        breathingAnimation.toValue = 1.08
        breathingAnimation.duration = 2.0
        breathingAnimation.repeatCount = .infinity
        breathingAnimation.autoreverses = true
        breathingAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        avatarView.layer.add(breathingAnimation, forKey: "breathing")
    }

    private func setupQuickStarters() {
        let starters = [
            ("I want to plan my career goals", "Let's map out your professional journey"),
            ("I'm facing a difficult decision", "We can work through it together"),
            ("I need help staying motivated", "Let's find what drives you")
        ]

        for (title, subtitle) in starters {
            let starterView = createQuickStarterView(title: title, subtitle: subtitle)
            quickStartersStackView.addArrangedSubview(starterView)
        }
    }

    private func createMessageBubble(text: String, isFromIris: Bool) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let bubbleView = UIView()
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        if isFromIris {
            bubbleView.backgroundColor = UIColor.white
        } else {
            bubbleView.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) // User message color
        }
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.05
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowRadius = 8
        containerView.addSubview(bubbleView)

        if isFromIris {
            // Add avatar for Iris messages
            let avatarView = UIView()
            avatarView.translatesAutoresizingMaskIntoConstraints = false
            avatarView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            avatarView.layer.cornerRadius = 16
            containerView.addSubview(avatarView)

            let avatarLabel = UILabel()
            avatarLabel.translatesAutoresizingMaskIntoConstraints = false
            avatarLabel.text = "I"
            avatarLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            avatarLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            avatarLabel.textAlignment = .center
            avatarView.addSubview(avatarLabel)

            NSLayoutConstraint.activate([
                avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                avatarView.topAnchor.constraint(equalTo: containerView.topAnchor),
                avatarView.widthAnchor.constraint(equalToConstant: 32),
                avatarView.heightAnchor.constraint(equalToConstant: 32),

                avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
                avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

                bubbleView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
                bubbleView.topAnchor.constraint(equalTo: containerView.topAnchor),
                bubbleView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                bubbleView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        } else {
            // User messages - right aligned with left margin
            NSLayoutConstraint.activate([
                bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 44),
                bubbleView.topAnchor.constraint(equalTo: containerView.topAnchor),
                bubbleView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                bubbleView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = text
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        if isFromIris {
            messageLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        } else {
            messageLabel.textColor = UIColor.white // White text for user messages
        }
        messageLabel.numberOfLines = 0
        bubbleView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16)
        ])

        return containerView
    }


    private func createQuickStarterView(title: String, subtitle: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        subtitleLabel.numberOfLines = 0
        containerView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(quickStarterTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)

        return containerView
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header View
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),


            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),

            // Subtitle Label
            subtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            // More Button
            moreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Avatar View
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),

            // Avatar Image
            avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 90),
            avatarImageView.heightAnchor.constraint(equalToConstant: 90),

            // Greeting Label
            greetingLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Messages Stack View
            messagesStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            messagesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            messagesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Quick Starters Label
            quickStartersLabel.topAnchor.constraint(equalTo: messagesStackView.bottomAnchor, constant: 32),
            quickStartersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            // Quick Starters Stack View
            quickStartersStackView.topAnchor.constraint(equalTo: quickStartersLabel.bottomAnchor, constant: 16),
            quickStartersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            quickStartersStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            quickStartersStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            // Input Container
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            inputContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),

            // Input Background
            inputBackgroundView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 16),
            inputBackgroundView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            inputBackgroundView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            inputBackgroundView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -16),
            inputBackgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),

            // Text Input
            textInputView.topAnchor.constraint(equalTo: inputBackgroundView.topAnchor),
            textInputView.leadingAnchor.constraint(equalTo: inputBackgroundView.leadingAnchor),
            textInputView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textInputView.bottomAnchor.constraint(equalTo: inputBackgroundView.bottomAnchor),
            textInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),

            // Placeholder Label
            placeholderLabel.topAnchor.constraint(equalTo: textInputView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textInputView.leadingAnchor, constant: 16),

            // Send Button
            sendButton.trailingAnchor.constraint(equalTo: inputBackgroundView.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40),

        ])
    }

    private func setupActions() {
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }

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

    private func loadPersonalizedContent() {
        // Load personality type from UserDefaults
        if let responses = UserDefaults.standard.array(forKey: "personality_responses") as? [Int],
           responses.count == 2 {
            personalityType = generatePersonalityType(from: responses)
            updatePersonalizedGreeting()
        }
    }

    private func generatePersonalityType(from responses: [Int]) -> String {
        let decisionStyle = responses[0]
        let stressStyle = responses[1]

        switch (decisionStyle, stressStyle) {
        case (0, 0): return "methodical planner"
        case (0, 1): return "strategic adapter"
        case (0, 2): return "collaborative analyst"
        case (1, 0): return "intuitive organizer"
        case (1, 1): return "spontaneous leader"
        case (1, 2): return "empathetic decision-maker"
        case (2, 0): return "systematic collaborator"
        case (2, 1): return "flexible team player"
        case (2, 2): return "natural networker"
        default: return "thoughtful individual"
        }
    }

    private func updatePersonalizedGreeting() {
        guard let personalityType = personalityType else { return }

        // Update the first message with personalized content
        if let firstMessageContainer = messagesStackView.arrangedSubviews.first,
           let bubbleView = firstMessageContainer.subviews.first(where: { $0.backgroundColor == UIColor.white }),
           let messageLabel = bubbleView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            messageLabel.text = "Hello! I've learned about your \(personalityType) personality from our initial setup. I'm excited to be your thinking partner."
        }
    }

    // MARK: - Actions

    @objc private func moreButtonTapped() {
        // Handle more button tap
        print("More button tapped")
    }

    @objc private func quickStarterTapped(_ gesture: UITapGestureRecognizer) {
        guard let containerView = gesture.view,
              let titleLabel = containerView.subviews.first(where: { $0 is UILabel }) as? UILabel,
              let text = titleLabel.text else { return }

        // Set the text in the input field
        textInputView.text = text
        updatePlaceholderVisibility()
        textInputView.becomeFirstResponder()
    }


    private func createPlaceholderVC(title: String, color: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = color
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }

    @objc private func sendButtonTapped() {
        guard let messageText = textInputView.text, !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // Hide quick starters after first user message
        hideQuickStarters()

        // Add user message
        addMessage(text: messageText, isFromIris: false)

        // Clear input
        textInputView.text = ""
        updatePlaceholderVisibility()

        // Simulate Iris response (in a real app, this would call an AI service)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addIrisResponse(to: messageText)
        }
    }

    private func addMessage(text: String, isFromIris: Bool) {
        let messageBubble = createMessageBubble(text: text, isFromIris: isFromIris)
        messagesStackView.addArrangedSubview(messageBubble)

        // Scroll to bottom
        DispatchQueue.main.async {
            self.scrollToBottom()
        }
    }

    private func scrollToBottom() {
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(x: 0, y: max(0, self.scrollView.contentSize.height - self.scrollView.bounds.height))
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

    private func addIrisResponse(to userMessage: String) {
        // Simple response logic - in a real app this would use AI
        let responses = [
            "That's really interesting! Tell me more about that.",
            "I understand what you're saying. How does that make you feel?",
            "That's a great question. Let's explore that together.",
            "I can see why that would be important to you. What would you like to do about it?",
            "Thank you for sharing that with me. What's your biggest concern about this?"
        ]

        let randomResponse = responses.randomElement() ?? "I'm here to help you think through this."
        addMessage(text: randomResponse, isFromIris: true)
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !textInputView.text.isEmpty
    }

    private func hideQuickStarters() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.quickStartersLabel.alpha = 0
            self.quickStartersStackView.alpha = 0
            self.quickStartersLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            self.quickStartersStackView.transform = CGAffineTransform(translationX: 0, y: -20)
        }) { _ in
            // After animation completes, hide the views to free up space
            self.quickStartersLabel.isHidden = true
            self.quickStartersStackView.isHidden = true
        }
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height

        // Calculate how much we need to move up to keep input visible
        let inputContainerFrame = inputContainerView.frame
        let inputContainerBottom = inputContainerFrame.maxY
        let screenHeight = view.frame.height
        let keyboardTop = screenHeight - keyboardHeight

        // Calculate movement to keep input container visible above keyboard
        let inputContainerHeight: CGFloat = 80 // Input container height
        let targetPadding: CGFloat = 10 // Small padding above input
        let moveUpDistance = keyboardHeight - view.safeAreaInsets.bottom + inputContainerHeight + targetPadding

        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -moveUpDistance)
        } completion: { _ in
            // Scroll to bottom to show latest messages
            self.scrollToBottom()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.view.transform = .identity
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate
extension PersonalizedChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()

        // Auto-resize text view
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        // Limit maximum height
        let maxHeight: CGFloat = 100
        let newHeight = min(newSize.height, maxHeight)

        textView.isScrollEnabled = newHeight >= maxHeight
    }
}


