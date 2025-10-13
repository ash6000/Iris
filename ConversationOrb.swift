import UIKit

enum ConversationOrbState {
    case idle
    case listening
    case processing
    case speaking
}

class ConversationOrb: UIView {

    // MARK: - Properties
    private var currentState: ConversationOrbState = .idle {
        didSet {
            updateStateAnimation()
        }
    }

    // Visual components
    private let backgroundGradientLayer = CAGradientLayer()
    private let mainOrbView = UIView()
    private let pulseLayer = CAShapeLayer()
    private let waveformContainer = UIView()
    private var waveformLayers: [CAShapeLayer] = []

    // Animation properties
    private var breathingAnimation: CABasicAnimation?
    private var pulseAnimation: CABasicAnimation?
    private var waveformTimer: Timer?
    private var processingAnimation: CABasicAnimation?

    // Audio visualization
    private var currentAudioLevel: Float = 0.0

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOrb()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOrb()
    }

    // MARK: - Setup
    private func setupOrb() {
        backgroundColor = UIColor.clear

        setupBackgroundGradient()
        setupMainOrb()
        setupPulseLayer()
        setupWaveformContainer()

        // Start with idle state
        setState(.idle)
    }

    private func setupBackgroundGradient() {
        backgroundGradientLayer.type = .radial
        backgroundGradientLayer.colors = [
            UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 0.3).cgColor,
            UIColor.clear.cgColor
        ]
        backgroundGradientLayer.locations = [0.0, 1.0]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.insertSublayer(backgroundGradientLayer, at: 0)
    }

    private func setupMainOrb() {
        mainOrbView.translatesAutoresizingMaskIntoConstraints = false
        mainOrbView.backgroundColor = UIColor.clear
        addSubview(mainOrbView)

        // Create gradient for the main orb
        let orbGradient = CAGradientLayer()
        orbGradient.type = .radial
        orbGradient.colors = [
            UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.8).cgColor,
            UIColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 0.9).cgColor,
            UIColor(red: 0.05, green: 0.15, blue: 0.4, alpha: 1.0).cgColor
        ]
        orbGradient.locations = [0.0, 0.7, 1.0]
        orbGradient.startPoint = CGPoint(x: 0.3, y: 0.3)
        orbGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        mainOrbView.layer.addSublayer(orbGradient)

        NSLayoutConstraint.activate([
            mainOrbView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainOrbView.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainOrbView.widthAnchor.constraint(equalToConstant: 120),
            mainOrbView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func setupPulseLayer() {
        pulseLayer.fillColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.2).cgColor
        pulseLayer.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.4).cgColor
        pulseLayer.lineWidth = 2
        layer.insertSublayer(pulseLayer, below: mainOrbView.layer)
    }

    private func setupWaveformContainer() {
        waveformContainer.translatesAutoresizingMaskIntoConstraints = false
        waveformContainer.backgroundColor = UIColor.clear
        addSubview(waveformContainer)

        NSLayoutConstraint.activate([
            waveformContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            waveformContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveformContainer.widthAnchor.constraint(equalToConstant: 160),
            waveformContainer.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - Public Methods
    func setState(_ state: ConversationOrbState) {
        currentState = state
    }

    func updateAudioLevel(_ level: Float) {
        currentAudioLevel = level
        if currentState == .listening {
            updateWaveformWithLevel(level)
        }
    }

    // MARK: - State Animations
    private func updateStateAnimation() {
        stopAllAnimations()

        switch currentState {
        case .idle:
            startIdleAnimation()
        case .listening:
            startListeningAnimation()
        case .processing:
            startProcessingAnimation()
        case .speaking:
            startSpeakingAnimation()
        }
    }

    private func startIdleAnimation() {
        // Gentle breathing animation
        let breathingAnimation = CABasicAnimation(keyPath: "transform.scale")
        breathingAnimation.fromValue = 1.0
        breathingAnimation.toValue = 1.05
        breathingAnimation.duration = 3.0
        breathingAnimation.autoreverses = true
        breathingAnimation.repeatCount = .infinity
        breathingAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        mainOrbView.layer.add(breathingAnimation, forKey: "breathing")

        // Subtle color pulse
        let colorAnimation = CABasicAnimation(keyPath: "opacity")
        colorAnimation.fromValue = 0.6
        colorAnimation.toValue = 0.9
        colorAnimation.duration = 2.0
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        backgroundGradientLayer.add(colorAnimation, forKey: "colorPulse")
    }

    private func startListeningAnimation() {
        // Faster pulsing to indicate active listening
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.duration = 0.5
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        mainOrbView.layer.add(pulseAnimation, forKey: "listening")

        // Setup waveform for real-time visualization
        setupWaveformLayers()
        startWaveformAnimation()

        // Brighter background
        backgroundGradientLayer.colors = [
            UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.5).cgColor,
            UIColor.clear.cgColor
        ]
    }

    private func startProcessingAnimation() {
        // Spinning/thinking animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 2.0
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        mainOrbView.layer.add(rotationAnimation, forKey: "processing")

        // Pulsing effect
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.9
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 1.0
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        mainOrbView.layer.add(scaleAnimation, forKey: "processingPulse")

        // Change color to indicate processing
        backgroundGradientLayer.colors = [
            UIColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 0.4).cgColor,
            UIColor.clear.cgColor
        ]
    }

    private func startSpeakingAnimation() {
        // Speaking waveform animation
        setupWaveformLayers()
        startSpeakingWaveform()

        // Gentle pulsing
        let speakingPulse = CABasicAnimation(keyPath: "transform.scale")
        speakingPulse.fromValue = 1.0
        speakingPulse.toValue = 1.08
        speakingPulse.duration = 0.6
        speakingPulse.autoreverses = true
        speakingPulse.repeatCount = .infinity
        mainOrbView.layer.add(speakingPulse, forKey: "speaking")

        // Green-ish color for speaking
        backgroundGradientLayer.colors = [
            UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 0.4).cgColor,
            UIColor.clear.cgColor
        ]
    }

    // MARK: - Waveform Animation
    private func setupWaveformLayers() {
        // Clear existing layers
        waveformLayers.forEach { $0.removeFromSuperlayer() }
        waveformLayers.removeAll()

        let numberOfBars = 8
        let barWidth: CGFloat = 4
        let barSpacing: CGFloat = 8
        let totalWidth = CGFloat(numberOfBars) * (barWidth + barSpacing) - barSpacing
        let startX = (160 - totalWidth) / 2

        for i in 0..<numberOfBars {
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.white.withAlphaComponent(0.8).cgColor
            layer.cornerRadius = barWidth / 2

            let x = startX + CGFloat(i) * (barWidth + barSpacing)
            layer.frame = CGRect(x: x, y: 35, width: barWidth, height: 10)

            waveformContainer.layer.addSublayer(layer)
            waveformLayers.append(layer)
        }
    }

    private func startWaveformAnimation() {
        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.animateWaveformBars()
        }
    }

    private func startSpeakingWaveform() {
        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            self?.animateSpeakingWaveform()
        }
    }

    private func animateWaveformBars() {
        for (index, layer) in waveformLayers.enumerated() {
            // Use audio level to influence animation
            let baseHeight: CGFloat = 4
            let maxHeight: CGFloat = 30
            let audioInfluence = CGFloat(currentAudioLevel) * 20
            let randomFactor = CGFloat.random(in: 0.3...1.0)
            let height = baseHeight + audioInfluence * randomFactor

            let animation = CABasicAnimation(keyPath: "bounds.size.height")
            animation.toValue = min(height, maxHeight)
            animation.duration = 0.1
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            // Stagger the animation slightly
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.02
            layer.add(animation, forKey: "waveform")

            // Also animate position to keep centered
            let yPosition = (80 - min(height, maxHeight)) / 2
            let positionAnimation = CABasicAnimation(keyPath: "position.y")
            positionAnimation.toValue = yPosition + min(height, maxHeight) / 2
            positionAnimation.duration = 0.1
            positionAnimation.fillMode = .forwards
            positionAnimation.isRemovedOnCompletion = false
            positionAnimation.beginTime = animation.beginTime
            layer.add(positionAnimation, forKey: "position")
        }
    }

    private func animateSpeakingWaveform() {
        for (index, layer) in waveformLayers.enumerated() {
            let baseHeight: CGFloat = 6
            let maxHeight: CGFloat = 25
            let randomHeight = baseHeight + CGFloat.random(in: 0...maxHeight - baseHeight)

            let animation = CABasicAnimation(keyPath: "bounds.size.height")
            animation.toValue = randomHeight
            animation.duration = 0.15
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            layer.add(animation, forKey: "speaking")

            // Center position
            let yPosition = (80 - randomHeight) / 2
            let positionAnimation = CABasicAnimation(keyPath: "position.y")
            positionAnimation.toValue = yPosition + randomHeight / 2
            positionAnimation.duration = 0.15
            positionAnimation.fillMode = .forwards
            positionAnimation.isRemovedOnCompletion = false
            layer.add(positionAnimation, forKey: "speakingPosition")
        }
    }

    private func updateWaveformWithLevel(_ level: Float) {
        guard !waveformLayers.isEmpty else { return }

        let normalizedLevel = max(0.1, min(1.0, level * 5)) // Amplify for visibility

        for layer in waveformLayers {
            let baseHeight: CGFloat = 4
            let maxHeight: CGFloat = 35
            let height = baseHeight + (CGFloat(normalizedLevel) * (maxHeight - baseHeight))

            layer.bounds.size.height = height
            layer.position.y = (80 - height) / 2 + height / 2
        }
    }

    // MARK: - Animation Management
    private func stopAllAnimations() {
        mainOrbView.layer.removeAllAnimations()
        backgroundGradientLayer.removeAllAnimations()
        waveformTimer?.invalidate()
        waveformTimer = nil
        waveformLayers.forEach { $0.removeAllAnimations() }
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        // Update gradient frames
        backgroundGradientLayer.frame = bounds
        if let orbGradient = mainOrbView.layer.sublayers?.first as? CAGradientLayer {
            orbGradient.frame = mainOrbView.bounds
        }

        // Update main orb shape
        mainOrbView.layer.cornerRadius = mainOrbView.bounds.width / 2

        // Update pulse layer
        let pulseRect = CGRect(
            x: bounds.midX - 80,
            y: bounds.midY - 80,
            width: 160,
            height: 160
        )
        pulseLayer.path = UIBezierPath(ovalIn: pulseRect).cgPath
    }

    deinit {
        stopAllAnimations()
    }
}