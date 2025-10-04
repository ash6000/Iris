import UIKit

enum VoiceButtonState {
    case idle           // Ready to record
    case recording      // Currently recording
    case processing     // Uploading/processing audio
    case playing        // Playing audio response
}

protocol VoiceButtonDelegate: AnyObject {
    func voiceButtonDidStartRecording()
    func voiceButtonDidStopRecording()
    func voiceButtonDidCancel()
}

class VoiceButton: UIView {

    // MARK: - Properties
    weak var delegate: VoiceButtonDelegate?

    private var currentState: VoiceButtonState = .idle {
        didSet {
            updateAppearance()
        }
    }

    // UI Components
    private let backgroundView = UIView()
    private let iconImageView = UIImageView()
    private let pulseLayer = CAShapeLayer()
    private let waveformView = UIView()
    private var waveformLayers: [CAShapeLayer] = []

    // Animation properties
    private var pulseAnimation: CABasicAnimation?
    private var waveformTimer: Timer?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }

    // MARK: - Setup
    private func setupUI() {
        // Background view
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        backgroundView.layer.cornerRadius = 30
        addSubview(backgroundView)

        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "mic.fill")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        backgroundView.addSubview(iconImageView)

        // Waveform view (hidden initially)
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.isHidden = true
        addSubview(waveformView)

        // Pulse layer for recording state
        pulseLayer.fillColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.3).cgColor
        pulseLayer.isHidden = true
        layer.insertSublayer(pulseLayer, at: 0)

        setupConstraints()
        updateAppearance()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 60),
            backgroundView.heightAnchor.constraint(equalToConstant: 60),

            iconImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            waveformView.centerXAnchor.constraint(equalTo: centerXAnchor),
            waveformView.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveformView.widthAnchor.constraint(equalToConstant: 120),
            waveformView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.2
        addGestureRecognizer(longPressGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    // MARK: - Public Methods
    func setState(_ state: VoiceButtonState) {
        currentState = state
    }

    func updateAudioLevel(_ level: Float) {
        guard currentState == .recording else { return }
        updateWaveform(level: level)
    }

    // MARK: - Private Methods
    private func updateAppearance() {
        switch currentState {
        case .idle:
            setIdleAppearance()
        case .recording:
            setRecordingAppearance()
        case .processing:
            setProcessingAppearance()
        case .playing:
            setPlayingAppearance()
        }
    }

    private func setIdleAppearance() {
        stopAllAnimations()
        backgroundView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        iconImageView.image = UIImage(systemName: "mic.fill")
        iconImageView.tintColor = .white
        waveformView.isHidden = true
        pulseLayer.isHidden = true
    }

    private func setRecordingAppearance() {
        backgroundView.backgroundColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        iconImageView.image = UIImage(systemName: "stop.fill")
        iconImageView.tintColor = .white
        waveformView.isHidden = false
        startPulseAnimation()
        startWaveformAnimation()
    }

    private func setProcessingAppearance() {
        stopAllAnimations()
        backgroundView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        iconImageView.image = UIImage(systemName: "ellipsis")
        iconImageView.tintColor = .white
        waveformView.isHidden = true
        pulseLayer.isHidden = true
        startProcessingAnimation()
    }

    private func setPlayingAppearance() {
        stopAllAnimations()
        backgroundView.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        iconImageView.image = UIImage(systemName: "speaker.wave.2.fill")
        iconImageView.tintColor = .white
        waveformView.isHidden = true
        pulseLayer.isHidden = true
    }

    // MARK: - Animations
    private func startPulseAnimation() {
        pulseLayer.isHidden = false
        pulseLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 80, height: 80)).cgPath
        pulseLayer.position = CGPoint(x: bounds.midX - 40, y: bounds.midY - 40)

        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 1.2
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseLayer.add(pulseAnimation, forKey: "pulse")
    }

    private func startWaveformAnimation() {
        setupWaveformLayers()

        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.animateWaveform()
        }
    }

    private func setupWaveformLayers() {
        // Clear existing layers
        waveformLayers.forEach { $0.removeFromSuperlayer() }
        waveformLayers.removeAll()

        // Create new waveform layers
        let numberOfBars = 5
        let barWidth: CGFloat = 4
        let barSpacing: CGFloat = 6
        let totalWidth = CGFloat(numberOfBars) * barWidth + CGFloat(numberOfBars - 1) * barSpacing
        let startX = (waveformView.bounds.width - totalWidth) / 2

        for i in 0..<numberOfBars {
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.white.cgColor
            layer.frame = CGRect(
                x: startX + CGFloat(i) * (barWidth + barSpacing),
                y: waveformView.bounds.height / 2,
                width: barWidth,
                height: 2
            )
            layer.cornerRadius = barWidth / 2
            waveformView.layer.addSublayer(layer)
            waveformLayers.append(layer)
        }
    }

    private func animateWaveform() {
        for (index, layer) in waveformLayers.enumerated() {
            let randomHeight = CGFloat.random(in: 4...30)
            let animation = CABasicAnimation(keyPath: "bounds.size.height")
            animation.toValue = randomHeight
            animation.duration = 0.1
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            // Offset animation timing for wave effect
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.02
            layer.add(animation, forKey: "waveform")
        }
    }

    private func updateWaveform(level: Float) {
        guard !waveformLayers.isEmpty else { return }

        let normalizedLevel = max(0.1, min(1.0, level * 3)) // Amplify and clamp

        for layer in waveformLayers {
            let height = 4 + (normalizedLevel * 26) // 4-30 range
            layer.bounds.size.height = CGFloat(height)
        }
    }

    private func startProcessingAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        iconImageView.layer.add(rotation, forKey: "processing")
    }

    private func stopAllAnimations() {
        pulseLayer.removeAllAnimations()
        pulseLayer.isHidden = true
        iconImageView.layer.removeAllAnimations()
        waveformTimer?.invalidate()
        waveformTimer = nil
        waveformLayers.forEach { $0.removeAllAnimations() }
    }

    // MARK: - Gesture Handlers
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if currentState == .idle {
                currentState = .recording
                delegate?.voiceButtonDidStartRecording()
            }
        case .ended, .cancelled:
            if currentState == .recording {
                currentState = .processing
                delegate?.voiceButtonDidStopRecording()
            }
        default:
            break
        }
    }

    @objc private func handleTap() {
        switch currentState {
        case .recording:
            currentState = .processing
            delegate?.voiceButtonDidStopRecording()
        case .processing:
            currentState = .idle
            delegate?.voiceButtonDidCancel()
        default:
            break
        }
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        if currentState == .recording {
            pulseLayer.position = CGPoint(x: bounds.midX - 40, y: bounds.midY - 40)
        }
    }

    deinit {
        stopAllAnimations()
    }
}