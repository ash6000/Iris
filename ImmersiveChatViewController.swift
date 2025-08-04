
import Foundation
import UIKit
import AVFoundation

class ImmersiveChatViewController: UIViewController {
    
    private let category: ChatCategoryData
    private var messages: [ChatMessage]
    private var isSpeaking = false
    
    // Reference to the main tab bar controller
    weak var customTabBarController: CustomTabBarController?
    
    // Speech synthesis
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // Full-screen avatar
    private let avatarImageView = UIImageView()
    private let avatarGlowView = UIView()
    
    // Bottom controls
    private let controlsContainer = UIView()
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    
    // Voice controls with mic feature
    private let inputContainer = UIView()
    private let inputBackground = UIView()
    private let micButton = UIButton()
    private let textField = UITextField()
    private let sendButton = UIButton()
    
    // Recording UI elements
    private let recordingContainer = UIView()
    private let recordingCircle = UIView()
    private let recordingPulseCircle = UIView()
    private let recordingMicIcon = UIImageView()
    private let recordingLabel = UILabel()
    
    // Recording state
    private var isRecording = false
    
    // Navigation buttons
    private let switchToChatButton = UIButton()
    
    // Animation properties
    private var glowAnimation: CABasicAnimation?
    
    init(category: ChatCategoryData, messages: [ChatMessage] = [], customTabBarController: CustomTabBarController? = nil) {
        self.category = category
        self.messages = messages
        self.customTabBarController = customTabBarController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpeechSynthesizer()
        setupUI()
        setupConstraints()
        
        // Start with immersive mode
        speakWelcomeMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Keep status bar visible for consistency with tab bar controller
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    private func setupSpeechSynthesizer() {
        speechSynthesizer.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.92, green: 0.88, blue: 0.94, alpha: 1.0) // Soft lavender
        
        setupAvatar()
        setupControls()
        setupNavigationButtons()
    }
    
    private func setupAvatar() {
        // Avatar container for centering
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        
        // Use the iris_rainbow_background image
        avatarImageView.image = UIImage(named: "iris_rainbow_background")
        
        // Add a subtle gradient overlay for depth and spiritual effect
        let overlayGradient = CAGradientLayer()
        overlayGradient.colors = [
            UIColor.clear.cgColor,
            UIColor(red: 0.9, green: 0.7, blue: 0.9, alpha: 0.08).cgColor,
            UIColor(red: 0.8, green: 0.4, blue: 0.7, alpha: 0.12).cgColor
        ]
        overlayGradient.locations = [0.0, 0.7, 1.0]
        overlayGradient.startPoint = CGPoint(x: 0.5, y: 0)
        overlayGradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        avatarImageView.layer.addSublayer(overlayGradient)
        
        // Glow effect for speaking indication
        avatarGlowView.translatesAutoresizingMaskIntoConstraints = false
        avatarGlowView.backgroundColor = UIColor(red: 0.8, green: 0.4, blue: 0.7, alpha: 0.3)
        avatarGlowView.layer.cornerRadius = 50
        avatarGlowView.alpha = 0
        avatarGlowView.isUserInteractionEnabled = false
        
        // Add sparkles overlay for magical effect
        let sparklesOverlay = UIImageView()
        sparklesOverlay.translatesAutoresizingMaskIntoConstraints = false
        sparklesOverlay.contentMode = .scaleAspectFit
        sparklesOverlay.alpha = 0.15
        sparklesOverlay.image = UIImage(systemName: "sparkles")
        sparklesOverlay.tintColor = .white
        sparklesOverlay.isUserInteractionEnabled = false
        
        view.addSubview(avatarGlowView)
        view.addSubview(avatarImageView)
        avatarImageView.addSubview(sparklesOverlay)
        
        // Constraints for avatar elements
        NSLayoutConstraint.activate([
            sparklesOverlay.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            sparklesOverlay.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            sparklesOverlay.widthAnchor.constraint(equalToConstant: 150),
            sparklesOverlay.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Resize overlay gradient when view appears
        DispatchQueue.main.async {
            overlayGradient.frame = self.view.bounds
        }
        
        // Start gentle sparkle animation
        startSparkleAnimation(sparklesOverlay)
    }
    
    private func setupControls() {
        // Controls container with mic and text input
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsContainer)
        
        // Visual effect background (frosted glass)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.layer.cornerRadius = 25
        visualEffectView.clipsToBounds = true
        visualEffectView.layer.shadowColor = UIColor.black.cgColor
        visualEffectView.layer.shadowOffset = CGSize(width: 0, height: 4)
        visualEffectView.layer.shadowRadius = 15
        visualEffectView.layer.shadowOpacity = 0.1
        controlsContainer.addSubview(visualEffectView)
        
        // Recording container (appears above text box when recording)
        recordingContainer.translatesAutoresizingMaskIntoConstraints = false
        recordingContainer.isHidden = true
        view.addSubview(recordingContainer)
        
        // Recording pulse circle (outer)
        recordingPulseCircle.translatesAutoresizingMaskIntoConstraints = false
        recordingPulseCircle.backgroundColor = category.backgroundColor.withAlphaComponent(0.3)
        recordingPulseCircle.layer.cornerRadius = 60
        recordingContainer.addSubview(recordingPulseCircle)
        
        // Recording circle (main)
        recordingCircle.translatesAutoresizingMaskIntoConstraints = false
        recordingCircle.backgroundColor = category.backgroundColor
        recordingCircle.layer.cornerRadius = 50
        recordingCircle.layer.shadowColor = UIColor.black.cgColor
        recordingCircle.layer.shadowOffset = CGSize(width: 0, height: 8)
        recordingCircle.layer.shadowRadius = 20
        recordingCircle.layer.shadowOpacity = 0.3
        recordingContainer.addSubview(recordingCircle)
        
        // Recording mic icon
        recordingMicIcon.translatesAutoresizingMaskIntoConstraints = false
        recordingMicIcon.image = UIImage(systemName: "mic.fill")
        recordingMicIcon.tintColor = .white
        recordingMicIcon.contentMode = .scaleAspectFit
        recordingCircle.addSubview(recordingMicIcon)
        
        // Recording label
        recordingLabel.translatesAutoresizingMaskIntoConstraints = false
        recordingLabel.text = "Listening..."
        recordingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        recordingLabel.textColor = category.backgroundColor
        recordingLabel.textAlignment = .center
        recordingContainer.addSubview(recordingLabel)
        
        // Horizontal input container: 🎤 [ placeholder text ] 📤
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(inputContainer)
        
        // Input background with frosted glass effect
        inputBackground.translatesAutoresizingMaskIntoConstraints = false
        inputBackground.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        inputBackground.layer.cornerRadius = 25
        inputBackground.layer.cornerCurve = .continuous
        inputBackground.layer.shadowColor = UIColor.black.cgColor
        inputBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
        inputBackground.layer.shadowRadius = 10
        inputBackground.layer.shadowOpacity = 0.12
        inputContainer.addSubview(inputBackground)
        
        // Mic button (left side, matching send arrow style)
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        micButton.tintColor = category.backgroundColor
        micButton.backgroundColor = .clear
        micButton.addTarget(self, action: #selector(micButtonTapped), for: .touchUpInside)
        inputBackground.addSubview(micButton)
        
        // Text field with spiritual placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "What do you want to talk about?"
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        // Enhanced placeholder styling for better contrast
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        textField.attributedPlaceholder = NSAttributedString(
            string: "What do you want to talk about?",
            attributes: placeholderAttributes
        )
        
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.returnKeyType = .send
        textField.delegate = self
        inputBackground.addSubview(textField)
        
        // Send button (right side)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = category.backgroundColor
        sendButton.backgroundColor = .clear
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        inputBackground.addSubview(sendButton)
    }
    
    private func setupNavigationButtons() {
        // Enhanced 2D Mode button matching the chat view style exactly
        switchToChatButton.translatesAutoresizingMaskIntoConstraints = false
        switchToChatButton.backgroundColor = UIColor.white
        switchToChatButton.layer.cornerRadius = 22
        switchToChatButton.layer.cornerCurve = .continuous
        
        // Enhanced gradient with more depth (same as 3D button)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(red: 0.96, green: 0.94, blue: 0.92, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 22
        switchToChatButton.layer.insertSublayer(gradientLayer, at: 0)
        
        // Enhanced shadow for depth (same as 3D button)
        switchToChatButton.layer.shadowColor = UIColor.black.cgColor
        switchToChatButton.layer.shadowOpacity = 0.08
        switchToChatButton.layer.shadowRadius = 8
        switchToChatButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Subtle border for definition (same as 3D button)
        switchToChatButton.layer.borderWidth = 0.5
        switchToChatButton.layer.borderColor = UIColor(red: 0.85, green: 0.83, blue: 0.80, alpha: 0.4).cgColor
        
        // Create custom content view for the button
        let buttonContentView = UIView()
        buttonContentView.translatesAutoresizingMaskIntoConstraints = false
        buttonContentView.isUserInteractionEnabled = false
        switchToChatButton.addSubview(buttonContentView)
        
        // Enhanced icon stack (same as 3D button)
        let iconStackView = UIStackView()
        iconStackView.translatesAutoresizingMaskIntoConstraints = false
        iconStackView.axis = .horizontal
        iconStackView.alignment = .center
        iconStackView.spacing = 6
        iconStackView.isUserInteractionEnabled = false
        buttonContentView.addSubview(iconStackView)
        
        // 2D Icon using SF Symbols (matching size and weight as 3D button)
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "rectangle.on.rectangle")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        )
        iconImageView.tintColor = category.backgroundColor
        iconImageView.contentMode = .scaleAspectFit
        iconStackView.addArrangedSubview(iconImageView)
        
        // Enhanced label with better typography (same as 3D button)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2D Mode"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = category.backgroundColor
        iconStackView.addArrangedSubview(label)
        
        // Add a subtle shine effect (same as 3D button)
        let shineView = UIView()
        shineView.translatesAutoresizingMaskIntoConstraints = false
        shineView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        shineView.layer.cornerRadius = 22
        shineView.layer.cornerCurve = .continuous
        shineView.isUserInteractionEnabled = false
        switchToChatButton.insertSubview(shineView, at: 1)
        
        switchToChatButton.addTarget(self, action: #selector(switchToChatTapped), for: .touchUpInside)
        view.addSubview(switchToChatButton)
        
        // Update the gradient layer frame when the button's bounds change
        DispatchQueue.main.async {
            gradientLayer.frame = self.switchToChatButton.bounds
        }
        
        // Constraints for the enhanced button design (same as 3D button)
        NSLayoutConstraint.activate([
            // Button content view - centered
            buttonContentView.centerXAnchor.constraint(equalTo: switchToChatButton.centerXAnchor),
            buttonContentView.centerYAnchor.constraint(equalTo: switchToChatButton.centerYAnchor),
            
            // Icon stack view - perfectly centered
            iconStackView.centerXAnchor.constraint(equalTo: buttonContentView.centerXAnchor),
            iconStackView.centerYAnchor.constraint(equalTo: buttonContentView.centerYAnchor),
            
            // Icon dimensions
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // Shine effect overlay
            shineView.topAnchor.constraint(equalTo: switchToChatButton.topAnchor),
            shineView.leadingAnchor.constraint(equalTo: switchToChatButton.leadingAnchor),
            shineView.trailingAnchor.constraint(equalTo: switchToChatButton.trailingAnchor),
            shineView.heightAnchor.constraint(equalTo: switchToChatButton.heightAnchor, multiplier: 0.4)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Full-screen avatar (covers entire screen including tab bar area)
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 102), // Extend beyond to cover tab bar
            
            // Avatar glow (behind avatar)
            avatarGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            avatarGlowView.widthAnchor.constraint(equalToConstant: 100),
            avatarGlowView.heightAnchor.constraint(equalToConstant: 100),
            
            // Enhanced 2D Mode Button - Same size and positioning as 3D button
            switchToChatButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            switchToChatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            switchToChatButton.widthAnchor.constraint(equalToConstant: 100),
            switchToChatButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Controls container (bottom, above tab bar)
            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100), // Extra space for tab bar
            controlsContainer.heightAnchor.constraint(equalToConstant: 60),
            
            // Visual effect background
            visualEffectView.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 5),
            visualEffectView.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -5),
            
            // Input container (horizontal layout)
            inputContainer.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 5),
            inputContainer.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -5),
            
            // Input background
            inputBackground.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            inputBackground.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            inputBackground.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
            inputBackground.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
            
            // Recording container (appears above text box)
            recordingContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordingContainer.bottomAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: -20),
            recordingContainer.widthAnchor.constraint(equalToConstant: 120),
            recordingContainer.heightAnchor.constraint(equalToConstant: 150),
            
            // Recording pulse circle (outer)
            recordingPulseCircle.centerXAnchor.constraint(equalTo: recordingContainer.centerXAnchor),
            recordingPulseCircle.topAnchor.constraint(equalTo: recordingContainer.topAnchor),
            recordingPulseCircle.widthAnchor.constraint(equalToConstant: 120),
            recordingPulseCircle.heightAnchor.constraint(equalToConstant: 120),
            
            // Recording circle (main)
            recordingCircle.centerXAnchor.constraint(equalTo: recordingPulseCircle.centerXAnchor),
            recordingCircle.centerYAnchor.constraint(equalTo: recordingPulseCircle.centerYAnchor),
            recordingCircle.widthAnchor.constraint(equalToConstant: 100),
            recordingCircle.heightAnchor.constraint(equalToConstant: 100),
            
            // Recording mic icon
            recordingMicIcon.centerXAnchor.constraint(equalTo: recordingCircle.centerXAnchor),
            recordingMicIcon.centerYAnchor.constraint(equalTo: recordingCircle.centerYAnchor),
            recordingMicIcon.widthAnchor.constraint(equalToConstant: 40),
            recordingMicIcon.heightAnchor.constraint(equalToConstant: 40),
            
            // Recording label
            recordingLabel.centerXAnchor.constraint(equalTo: recordingContainer.centerXAnchor),
            recordingLabel.topAnchor.constraint(equalTo: recordingCircle.bottomAnchor, constant: 8),
            recordingLabel.leadingAnchor.constraint(equalTo: recordingContainer.leadingAnchor),
            recordingLabel.trailingAnchor.constraint(equalTo: recordingContainer.trailingAnchor),
            
            // Mic button (left side)
            micButton.leadingAnchor.constraint(equalTo: inputBackground.leadingAnchor, constant: 20),
            micButton.centerYAnchor.constraint(equalTo: inputBackground.centerYAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 24),
            micButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Text field (center, between mic and send)
            textField.leadingAnchor.constraint(equalTo: micButton.trailingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -15),
            textField.centerYAnchor.constraint(equalTo: inputBackground.centerYAnchor),
            
            // Send button (right side)
            sendButton.trailingAnchor.constraint(equalTo: inputBackground.trailingAnchor, constant: -20),
            sendButton.centerYAnchor.constraint(equalTo: inputBackground.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Animations
    private func startSparkleAnimation(_ sparklesView: UIImageView) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.duration = 20.0
        rotateAnimation.repeatCount = .infinity
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        sparklesView.layer.add(rotateAnimation, forKey: "sparkleRotation")
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.1, 1.0, 1.05, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        scaleAnimation.duration = 4.0
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        sparklesView.layer.add(scaleAnimation, forKey: "sparkleScale")
    }
    
    private func startAvatarGlow() {
        guard !isSpeaking else { return }
        isSpeaking = true
        
        // Glow animation around avatar
        let glowAnimation = CABasicAnimation(keyPath: "opacity")
        glowAnimation.fromValue = 0.0
        glowAnimation.toValue = 1.0
        glowAnimation.duration = 0.8
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        avatarGlowView.layer.add(glowAnimation, forKey: "avatarGlow")
        
        // Scale animation for glow
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.3
        scaleAnimation.duration = 0.8
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        avatarGlowView.layer.add(scaleAnimation, forKey: "avatarGlowScale")
        
        self.glowAnimation = glowAnimation
    }
    
    private func stopAvatarGlow() {
        isSpeaking = false
        avatarGlowView.layer.removeAllAnimations()
        avatarGlowView.alpha = 0
        self.glowAnimation = nil
    }
    
    // MARK: - Speech Synthesis
    private func speakWelcomeMessage() {
        let welcomeMessage = getCategorySpecificMessage()
        speakText(welcomeMessage)
    }
    
    private func speakText(_ text: String) {
        // Stop any current speech
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45 // Slower, more contemplative pace
        utterance.pitchMultiplier = 1.1 // Slightly higher pitch for feminine voice
        utterance.volume = 0.8
        
        startAvatarGlow()
        speechSynthesizer.speak(utterance)
    }
    
    private func getCategorySpecificMessage() -> String {
        switch category.title {
        case "What's my Purpose?":
            return "What deep calling is stirring in your soul? I'm here to explore your unique gifts and purpose with you."
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
            return "What's stirring in your heart today? I'm here to listen and guide you with love."
        }
    }
    
    // MARK: - Recording Animations
    private func startRecordingAnimation() {
        // Pulse animation for the outer circle
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        recordingPulseCircle.layer.add(pulseAnimation, forKey: "recordingPulse")
        
        // Opacity animation for breathing effect
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.3
        opacityAnimation.toValue = 0.6
        opacityAnimation.duration = 1.0
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        recordingPulseCircle.layer.add(opacityAnimation, forKey: "recordingOpacity")
        
        // Gentle bounce for mic icon
        let bounceAnimation = CABasicAnimation(keyPath: "transform.scale")
        bounceAnimation.fromValue = 1.0
        bounceAnimation.toValue = 1.1
        bounceAnimation.duration = 0.8
        bounceAnimation.autoreverses = true
        bounceAnimation.repeatCount = .infinity
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        recordingMicIcon.layer.add(bounceAnimation, forKey: "micBounce")
    }
    
    private func stopRecordingAnimation() {
        recordingPulseCircle.layer.removeAllAnimations()
        recordingMicIcon.layer.removeAllAnimations()
    }
    
    // MARK: - Recording Actions
    @objc private func micButtonTapped() {
        isRecording.toggle()
        
        if isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    private func startRecording() {
        // Stop any current speech
        speechSynthesizer.stopSpeaking(at: .immediate)
        stopAvatarGlow()
        
        // Show recording UI with animation
        recordingContainer.isHidden = false
        recordingContainer.alpha = 0
        recordingContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.recordingContainer.alpha = 1.0
            self.recordingContainer.transform = .identity
            self.inputContainer.alpha = 0.6
        }
        
        startRecordingAnimation()
        
        // Change mic button color to indicate recording
        micButton.tintColor = category.backgroundColor.withAlphaComponent(0.8)
        
        // Simulate recording ending after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.isRecording {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        isRecording = false
        
        // Hide recording UI with animation
        UIView.animate(withDuration: 0.3, animations: {
            self.recordingContainer.alpha = 0.0
            self.recordingContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.inputContainer.alpha = 1.0
        }) { _ in
            self.recordingContainer.isHidden = true
            self.recordingContainer.transform = .identity
        }
        
        stopRecordingAnimation()
        
        // Reset mic button color
        micButton.tintColor = category.backgroundColor
        
        // Simulate voice recognition and response
        simulateVoiceResponse()
    }
    
    private func simulateVoiceResponse() {
        let voiceResponses = [
            "I hear the depth in your voice. Tell me more about what you're experiencing.",
            "Your energy feels tender today. What would help nurture your spirit?",
            "There's wisdom in your words. What does your intuition tell you about this?",
            "I sense you're at a sacred crossroads. What path calls to your soul?",
            "Thank you for sharing that with me. How does this make you feel in your body?",
            "Your vulnerability is beautiful. What support do you need right now?"
        ]
        
        let response = voiceResponses.randomElement() ?? voiceResponses[0]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.speakText(response)
        }
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        textField.text = ""
        textField.resignFirstResponder()
        
        // Add user message to messages array
        let userMessage = ChatMessage(text: text, isFromIris: false, timestamp: getCurrentTimeString())
        messages.append(userMessage)
        
        // Generate and speak response
        let responses = [
            "Thank you for sharing that with me. How does this make you feel?",
            "I hear the truth in your words. What would healing look like for you?",
            "That takes courage to share. What support do you need right now?",
            "Your vulnerability is beautiful. What's your heart telling you?",
            "I sense there's more to explore here. What's calling for your attention?",
            "That's a beautiful insight. What step feels most aligned for you right now?"
        ]
        
        let response = responses.randomElement() ?? responses[0]
        let irisMessage = ChatMessage(text: response, isFromIris: true, timestamp: getCurrentTimeString())
        messages.append(irisMessage)
        
        // Speak the response instead of showing text
        speakText(response)
    }
    
    @objc private func switchToChatTapped() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        // Use the new dismiss method from CustomTabBarController
        customTabBarController?.dismissImmersiveChat()
    }
    
    @objc private func showTabBarTapped() {
        // Tab bar is now visible, so this button can be removed or repurposed
        speechSynthesizer.stopSpeaking(at: .immediate)
        customTabBarController?.dismissImmersiveChat()
    }
    
    private func getCurrentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}

// MARK: - Speech Synthesizer Delegate
extension ImmersiveChatViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        startAvatarGlow()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        stopAvatarGlow()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        stopAvatarGlow()
    }
}

// MARK: - Text Field Delegate
extension ImmersiveChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}
