//
//  WelcomeViewController.swift
//  irisOne
//
//  Created by Test User on 9/20/25.
//

import UIKit

class WelcomeViewController: UIViewController {

    // Personalization
    private var personalizedMessage: String?
    private var isPersonalized: Bool = false
    
    // MARK: - UI Components
    private let backgroundImageView = UIImageView()
    private let containerView = UIView()
    
    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let helpButton = UIButton()
    
    // Avatar section
    private let avatarContainerView = UIView()
    private let avatarLabel = UILabel()
    
    // Chat section
    private let chatContainerView = UIView()
    private let hiLabel = UILabel()
    private let irisAvatarCircle = UIView()
    private let irisAvatarImageView = UIImageView()
    private var particleEmitter: CAEmitterLayer?
    private let chatBubbleView = UIView()
    private let chatMessageLabel = UILabel()
    
    // Privacy section
    private let privacyContainerView = UIView()
    private let privacyIconLabel = UILabel()
    private let privacyTitleLabel = UILabel()
    private let privacyMessageLabel = UILabel()
    
    // Action buttons
    private let startJourneyButton = UIButton()
    private let startJourneySubtitleLabel = UILabel()
    private let skipButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupInitialAnimationState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startWelcomeAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        // Setup content directly in the main view
        setupContentInContainer(view)
    }
    
    private func setupContentInContainer(_ contentContainer: UIView) {
        
        // Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        contentContainer.addSubview(headerView)
        
        // Back Button (only show if not personalized)
        if !isPersonalized {
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            backButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
            backButton.contentMode = .scaleAspectFit
            headerView.addSubview(backButton)
        }
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = isPersonalized ? "Begin" : "Welcome"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Meet your AI companion"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        headerView.addSubview(subtitleLabel)
        
        // Help Button
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        helpButton.contentMode = .scaleAspectFit
        headerView.addSubview(helpButton)
        
        // Chat Container - now takes full space below header
        chatContainerView.translatesAutoresizingMaskIntoConstraints = false
        chatContainerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        contentContainer.addSubview(chatContainerView)
        
        // Hi Label
        hiLabel.translatesAutoresizingMaskIntoConstraints = false
        hiLabel.text = "Hi, I'm Iris"
        hiLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        hiLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        hiLabel.textAlignment = .center
        chatContainerView.addSubview(hiLabel)
        
        // Iris Avatar Circle
        irisAvatarCircle.translatesAutoresizingMaskIntoConstraints = false
        irisAvatarCircle.backgroundColor = UIColor.white
        irisAvatarCircle.layer.cornerRadius = 40
        irisAvatarCircle.layer.shadowColor = UIColor.black.cgColor
        irisAvatarCircle.layer.shadowOpacity = 0.1
        irisAvatarCircle.layer.shadowOffset = CGSize(width: 0, height: 4)
        irisAvatarCircle.layer.shadowRadius = 8
        chatContainerView.addSubview(irisAvatarCircle)
        
        // Iris Avatar Image
        irisAvatarImageView.translatesAutoresizingMaskIntoConstraints = false
        irisAvatarImageView.image = UIImage(named: "iris_head")
        irisAvatarImageView.contentMode = .scaleAspectFill
        irisAvatarImageView.layer.cornerRadius = 35
        irisAvatarImageView.clipsToBounds = true
        irisAvatarCircle.addSubview(irisAvatarImageView)
        
        // Chat Bubble View
        chatBubbleView.translatesAutoresizingMaskIntoConstraints = false
        chatBubbleView.backgroundColor = UIColor.white
        chatBubbleView.layer.cornerRadius = 16
        chatBubbleView.layer.shadowColor = UIColor.black.cgColor
        chatBubbleView.layer.shadowOpacity = 0.05
        chatBubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        chatBubbleView.layer.shadowRadius = 8
        chatContainerView.addSubview(chatBubbleView)
        
        // Chat Message Label
        chatMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        if let message = personalizedMessage {
            chatMessageLabel.text = "\"\(message)\""
        } else {
            chatMessageLabel.text = "\"I'm here to listen, learn about you, and provide guidance tailored specifically to who you are and what you want to achieve.\""
        }
        chatMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        chatMessageLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        chatMessageLabel.textAlignment = .center
        chatMessageLabel.numberOfLines = 0
        chatBubbleView.addSubview(chatMessageLabel)
        
        // Privacy Container
        privacyContainerView.translatesAutoresizingMaskIntoConstraints = false
        privacyContainerView.backgroundColor = UIColor.white
        privacyContainerView.layer.cornerRadius = 16
        privacyContainerView.layer.shadowColor = UIColor.black.cgColor
        privacyContainerView.layer.shadowOpacity = 0.05
        privacyContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        privacyContainerView.layer.shadowRadius = 8
        contentContainer.addSubview(privacyContainerView)
        
        // Privacy Icon Label
        privacyIconLabel.translatesAutoresizingMaskIntoConstraints = false
        privacyIconLabel.text = "🛡"
        privacyIconLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        privacyContainerView.addSubview(privacyIconLabel)
        
        // Privacy Title Label
        privacyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        privacyTitleLabel.text = "Your Privacy Matters"
        privacyTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        privacyTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        privacyContainerView.addSubview(privacyTitleLabel)
        
        // Privacy Message Label
        privacyMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        privacyMessageLabel.text = "All conversations are encrypted and secure. I only learn what you choose to share with me."
        privacyMessageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        privacyMessageLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        privacyMessageLabel.numberOfLines = 0
        privacyContainerView.addSubview(privacyMessageLabel)
        
        // Start Journey Button with combined text
        startJourneyButton.translatesAutoresizingMaskIntoConstraints = false
        startJourneyButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        startJourneyButton.layer.cornerRadius = 12
        
        if isPersonalized {
            // For personalized state, show single line "Start Conversation" button
            startJourneyButton.setTitle("Start Conversation", for: .normal)
            startJourneyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            startJourneyButton.titleLabel?.numberOfLines = 1
            startJourneyButton.titleLabel?.textAlignment = .center
        } else {
            // Create attributed string for two-line button text
            let buttonText = NSMutableAttributedString()

            // Main title
            let mainTitle = NSAttributedString(
                string: "Start My Journey\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .foregroundColor: UIColor.white
                ]
            )

            // Subtitle
            let subtitle = NSAttributedString(
                string: "Begin personality detection",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                    .foregroundColor: UIColor.white
                ]
            )

            buttonText.append(mainTitle)
            buttonText.append(subtitle)

            // Apply to button
            startJourneyButton.setAttributedTitle(buttonText, for: .normal)
            startJourneyButton.titleLabel?.numberOfLines = 2
            startJourneyButton.titleLabel?.textAlignment = .center
            startJourneyButton.titleLabel?.lineBreakMode = .byWordWrapping
        }
        
        contentContainer.addSubview(startJourneyButton)
        
        // Skip Button (only show if not personalized)
        if !isPersonalized {
            skipButton.translatesAutoresizingMaskIntoConstraints = false
            skipButton.setTitle("SKIP", for: .normal)
            skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            skipButton.setTitleColor(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), for: .normal)
            contentContainer.addSubview(skipButton)
        }
    }
    
    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            // Header View
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80)
        ]

        // Add back button constraints only if not personalized
        if !isPersonalized {
            constraints.append(contentsOf: [
                // Back Button
                backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
                backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -8),
                backButton.widthAnchor.constraint(equalToConstant: 24),
                backButton.heightAnchor.constraint(equalToConstant: 24)
            ])
        }

        constraints.append(contentsOf: [
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            
            // Subtitle Label
            subtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Help Button
            helpButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            helpButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -8),
            helpButton.widthAnchor.constraint(equalToConstant: 24),
            helpButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Chat Container - takes remaining space
            chatContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            chatContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Hi Label
            hiLabel.centerXAnchor.constraint(equalTo: chatContainerView.centerXAnchor),
            hiLabel.topAnchor.constraint(equalTo: chatContainerView.topAnchor, constant: 20),
            
            // Iris Avatar Circle
            irisAvatarCircle.centerXAnchor.constraint(equalTo: chatContainerView.centerXAnchor),
            irisAvatarCircle.topAnchor.constraint(equalTo: hiLabel.bottomAnchor, constant: 20),
            irisAvatarCircle.widthAnchor.constraint(equalToConstant: 80),
            irisAvatarCircle.heightAnchor.constraint(equalToConstant: 80),
            
            // Iris Avatar Image
            irisAvatarImageView.centerXAnchor.constraint(equalTo: irisAvatarCircle.centerXAnchor),
            irisAvatarImageView.centerYAnchor.constraint(equalTo: irisAvatarCircle.centerYAnchor),
            irisAvatarImageView.widthAnchor.constraint(equalToConstant: 70),
            irisAvatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Chat Bubble View
            chatBubbleView.topAnchor.constraint(equalTo: irisAvatarCircle.bottomAnchor, constant: 30),
            chatBubbleView.leadingAnchor.constraint(equalTo: chatContainerView.leadingAnchor, constant: 20),
            chatBubbleView.trailingAnchor.constraint(equalTo: chatContainerView.trailingAnchor, constant: -20),
            
            // Chat Message Label
            chatMessageLabel.topAnchor.constraint(equalTo: chatBubbleView.topAnchor, constant: 16),
            chatMessageLabel.leadingAnchor.constraint(equalTo: chatBubbleView.leadingAnchor, constant: 16),
            chatMessageLabel.trailingAnchor.constraint(equalTo: chatBubbleView.trailingAnchor, constant: -16),
            chatMessageLabel.bottomAnchor.constraint(equalTo: chatBubbleView.bottomAnchor, constant: -16),
            
            // Privacy Container
            privacyContainerView.topAnchor.constraint(equalTo: chatBubbleView.bottomAnchor, constant: 40),
            privacyContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            privacyContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Privacy Icon Label
            privacyIconLabel.leadingAnchor.constraint(equalTo: privacyContainerView.leadingAnchor, constant: 16),
            privacyIconLabel.topAnchor.constraint(equalTo: privacyContainerView.topAnchor, constant: 16),
            
            // Privacy Title Label
            privacyTitleLabel.leadingAnchor.constraint(equalTo: privacyIconLabel.trailingAnchor, constant: 12),
            privacyTitleLabel.trailingAnchor.constraint(equalTo: privacyContainerView.trailingAnchor, constant: -16),
            privacyTitleLabel.topAnchor.constraint(equalTo: privacyContainerView.topAnchor, constant: 16),
            
            // Privacy Message Label
            privacyMessageLabel.leadingAnchor.constraint(equalTo: privacyIconLabel.trailingAnchor, constant: 12),
            privacyMessageLabel.trailingAnchor.constraint(equalTo: privacyContainerView.trailingAnchor, constant: -16),
            privacyMessageLabel.topAnchor.constraint(equalTo: privacyTitleLabel.bottomAnchor, constant: 4),
            privacyMessageLabel.bottomAnchor.constraint(equalTo: privacyContainerView.bottomAnchor, constant: -16),
            
            // Start Journey Button (now taller for two lines)
            startJourneyButton.topAnchor.constraint(equalTo: privacyContainerView.bottomAnchor, constant: 40),
            startJourneyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startJourneyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startJourneyButton.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Add skip button constraints only if not personalized
        if !isPersonalized {
            constraints.append(contentsOf: [
                // Skip Button
                skipButton.topAnchor.constraint(equalTo: startJourneyButton.bottomAnchor, constant: 16),
                skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                skipButton.bottomAnchor.constraint(equalTo: chatContainerView.bottomAnchor, constant: -20)
            ])
        } else {
            constraints.append(contentsOf: [
                startJourneyButton.bottomAnchor.constraint(equalTo: chatContainerView.bottomAnchor, constant: -40)
            ])
        }

        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        startJourneyButton.addTarget(self, action: #selector(startJourneyButtonTapped), for: .touchUpInside)
        if !isPersonalized {
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        }
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        // Navigate back to email verification screen
        let emailVerifyVC = EmailVerifyViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = emailVerifyVC
            }, completion: nil)
        }
    }
    
    @objc private func helpButtonTapped() {
        print("Help button tapped")
        showAlert(title: "Help", message: "Need assistance? Contact our support team!")
    }
    
    @objc private func startJourneyButtonTapped() {
        if isPersonalized {
            // Mark onboarding as completed
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.synchronize()

            // Navigate to main app with chat tab selected
            let tabBarController = CustomTabBarController()
            tabBarController.modalPresentationStyle = .fullScreen
            present(tabBarController, animated: true)

            // Select chat tab after presentation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                tabBarController.selectTab(at: 2)
            }
        } else {
            print("Starting personality detection journey...")
            // Navigate directly to personality questions screen
            let questionsVC = PersonalityQuestionsViewController()

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {

                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = questionsVC
                }, completion: nil)
            }
        }
    }
    
    @objc private func skipButtonTapped() {
        print("Skipping personality detection...")
        // Navigate to main app
        navigateToMainApp()
    }
    
    // MARK: - Helper Methods
    private func navigateToMainApp() {
        // Save journey completion
        UserDefaults.standard.set(true, forKey: "journey_started")
        UserDefaults.standard.set(Date(), forKey: "journey_start_date")
        UserDefaults.standard.synchronize()
        
        // Navigate to main app
        let customTabBarController = CustomTabBarController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = customTabBarController
            }, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Animation Methods
    private func setupInitialAnimationState() {
        // Hide all elements initially
        hiLabel.alpha = 0
        irisAvatarCircle.alpha = 0
        irisAvatarCircle.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        chatBubbleView.alpha = 0
        chatBubbleView.transform = CGAffineTransform(translationX: 0, y: 30)
        privacyContainerView.alpha = 0
        privacyContainerView.transform = CGAffineTransform(translationX: 0, y: 30)
        startJourneyButton.alpha = 0
        startJourneyButton.transform = CGAffineTransform(translationX: 0, y: 30)
        skipButton.alpha = 0
    }
    
    private func startWelcomeAnimation() {
        // Step 1: Pop in the avatar with dramatic bounce effect and particles
        UIView.animate(withDuration: 1.2, delay: 0.8, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.irisAvatarCircle.alpha = 1
            self.irisAvatarCircle.transform = CGAffineTransform.identity
        } completion: { _ in
            // Add sparkle particles when avatar finishes appearing
            self.addSparkleParticles()
            
            // Remove particles after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.removeSparkleParticles()
            }
        }
        
        // Step 2: Fade in "Hi, I'm Iris" text with gentle delay
        UIView.animate(withDuration: 0.8, delay: 1.8) {
            self.hiLabel.alpha = 1
        }
        
        // Step 2.5: Add breathing effect while user reads the greeting
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.addBreathingEffect()
        }
        
        // Step 3: Typewriter effect for chat bubble (simulate typing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            self.animateTypingEffect()
        }
        
        // Step 4: Slide up privacy section with more deliberate timing
        UIView.animate(withDuration: 0.8, delay: 4.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseOut) {
            self.privacyContainerView.alpha = 1
            self.privacyContainerView.transform = CGAffineTransform.identity
        }
        
        // Step 5: Action buttons with staggered entrance
        UIView.animate(withDuration: 0.7, delay: 5.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseOut) {
            self.startJourneyButton.alpha = 1
            self.startJourneyButton.transform = CGAffineTransform.identity
        }
        
        // Step 6: Final element fade in
        UIView.animate(withDuration: 0.5, delay: 5.8) {
            self.skipButton.alpha = 1
        }
        
        // Add pulse animation after everything settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            self.addAvatarPulseAnimation()
        }
    }
    
    private func animateTypingEffect() {
        // First show the bubble container
        UIView.animate(withDuration: 0.4) {
            self.chatBubbleView.alpha = 1
            self.chatBubbleView.transform = CGAffineTransform.identity
        }

        // Then animate the text appearing character by character
        let fullText: String
        if let message = personalizedMessage {
            fullText = "\"\(message)\""
        } else {
            fullText = "\"I'm here to listen, learn about you, and provide guidance tailored specifically to who you are and what you want to achieve.\""
        }
        self.chatMessageLabel.text = ""

        for (index, character) in fullText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                self.chatMessageLabel.text! += String(character)
            }
        }
    }
    
    private func addAvatarPulseAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 2.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.05
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        irisAvatarCircle.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    private func addBreathingEffect() {
        // Remove any existing breathing animation
        irisAvatarCircle.layer.removeAnimation(forKey: "breathe")
        
        let breathe = CABasicAnimation(keyPath: "transform.scale")
        breathe.duration = 1.5
        breathe.fromValue = 1.0
        breathe.toValue = 1.02
        breathe.autoreverses = true
        breathe.repeatCount = .infinity
        breathe.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        irisAvatarCircle.layer.add(breathe, forKey: "breathe")
    }
    
    private func addSparkleParticles() {
        // Create emitter layer
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: irisAvatarCircle.bounds.midX, y: irisAvatarCircle.bounds.midY)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 100, height: 100)
        emitter.renderMode = .additive
        
        // Create sparkle particle
        let sparkle = CAEmitterCell()
        sparkle.birthRate = 20
        sparkle.lifetime = 1.5
        sparkle.lifetimeRange = 0.5
        sparkle.velocity = 50
        sparkle.velocityRange = 30
        sparkle.emissionRange = .pi * 2
        sparkle.spin = 2
        sparkle.spinRange = 3
        sparkle.scaleRange = 0.5
        sparkle.scaleSpeed = -0.05
        
        // Create sparkle image (using a star symbol)
        sparkle.contents = createSparkleImage().cgImage
        sparkle.scale = 0.1
        sparkle.alphaSpeed = -0.7
        sparkle.color = UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
        
        emitter.emitterCells = [sparkle]
        
        // Add to avatar circle
        irisAvatarCircle.layer.addSublayer(emitter)
        self.particleEmitter = emitter
    }
    
    private func removeSparkleParticles() {
        particleEmitter?.removeFromSuperlayer()
        particleEmitter = nil
    }
    
    private func createSparkleImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Draw a simple star shape
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.setStrokeColor(UIColor.clear.cgColor)
            
            let path = UIBezierPath()
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 8
            let innerRadius: CGFloat = 4
            
            for i in 0..<10 {
                let angle = CGFloat(i) * .pi / 5
                let pointRadius = i % 2 == 0 ? radius : innerRadius
                let x = center.x + cos(angle) * pointRadius
                let y = center.y + sin(angle) * pointRadius
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.close()
            
            context.cgContext.addPath(path.cgPath)
            context.cgContext.fillPath()
        }
    }

    // MARK: - Personalization Methods
    func setPersonalizedContent(_ message: String) {
        personalizedMessage = message
        isPersonalized = true

        // Update the chat message if view is already loaded
        if isViewLoaded {
            chatMessageLabel.text = "\"\(message)\""
            // Update title and hide back button
            titleLabel.text = "Begin"
            backButton.isHidden = true
        }
    }
}
