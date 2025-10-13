import UIKit

protocol AudioMessageBubbleDelegate: AnyObject {
    func audioMessageBubbleDidTapPlay(_ bubble: AudioMessageBubble)
    func audioMessageBubbleDidTapPause(_ bubble: AudioMessageBubble)
}

class AudioMessageBubble: UIView {

    // MARK: - Properties
    weak var delegate: AudioMessageBubbleDelegate?

    private let isFromIris: Bool
    private let audioData: Data?
    private let transcript: String
    private let duration: TimeInterval

    private var isPlaying: Bool = false {
        didSet {
            updatePlayButtonState()
        }
    }

    // UI Components
    private let containerView = UIView()
    private let playButton = UIButton()
    private let waveformView = UIView()
    private let transcriptLabel = UILabel()
    private let durationLabel = UILabel()
    private let avatarView = UIView()

    private var waveformLayers: [CAShapeLayer] = []

    // MARK: - Initialization
    init(isFromIris: Bool, audioData: Data?, transcript: String, duration: TimeInterval) {
        self.isFromIris = isFromIris
        self.audioData = audioData
        self.transcript = transcript
        self.duration = duration
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        // Container setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 16
        containerView.layer.cornerCurve = .continuous
        addSubview(containerView)

        // Set colors based on sender
        if isFromIris {
            containerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            setupIrisLayout()
        } else {
            containerView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            setupUserLayout()
        }

        setupPlayButton()
        setupWaveform()
        setupTranscriptLabel()
        setupDurationLabel()

        if isFromIris {
            setupAvatar()
        }

        setupConstraints()
        generateWaveformPath()
    }

    private func setupIrisLayout() {
        // Iris messages align to the left with avatar
    }

    private func setupUserLayout() {
        // User messages align to the right without avatar
    }

    private func setupPlayButton() {
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = isFromIris ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) : .white
        playButton.backgroundColor = isFromIris ? UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) : UIColor(white: 1.0, alpha: 0.2)
        playButton.layer.cornerRadius = 18
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        containerView.addSubview(playButton)
    }

    private func setupWaveform() {
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(waveformView)
    }

    private func setupTranscriptLabel() {
        transcriptLabel.translatesAutoresizingMaskIntoConstraints = false
        transcriptLabel.text = transcript
        transcriptLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        transcriptLabel.textColor = isFromIris ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) : .white
        transcriptLabel.numberOfLines = 0
        containerView.addSubview(transcriptLabel)
    }

    private func setupDurationLabel() {
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = formatDuration(duration)
        durationLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = isFromIris ? UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) : UIColor(white: 1.0, alpha: 0.7)
        containerView.addSubview(durationLabel)
    }

    private func setupAvatar() {
        guard isFromIris else { return }

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 16
        addSubview(avatarView)

        let avatarIcon = UIImageView()
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.image = UIImage(systemName: "sparkles")
        avatarIcon.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        avatarIcon.contentMode = .scaleAspectFit
        avatarView.addSubview(avatarIcon)

        NSLayoutConstraint.activate([
            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 16),
            avatarIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    private func setupConstraints() {
        if isFromIris {
            // Iris message layout (left-aligned with avatar)
            NSLayoutConstraint.activate([
                avatarView.leadingAnchor.constraint(equalTo: leadingAnchor),
                avatarView.topAnchor.constraint(equalTo: topAnchor),
                avatarView.widthAnchor.constraint(equalToConstant: 32),
                avatarView.heightAnchor.constraint(equalToConstant: 32),

                containerView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
                containerView.topAnchor.constraint(equalTo: topAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -60),
                containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 280)
            ])
        } else {
            // User message layout (right-aligned without avatar)
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 60),
                containerView.topAnchor.constraint(equalTo: topAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 280)
            ])
        }

        // Container content constraints
        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            playButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            playButton.widthAnchor.constraint(equalToConstant: 36),
            playButton.heightAnchor.constraint(equalToConstant: 36),

            waveformView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            waveformView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            waveformView.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -12),
            waveformView.heightAnchor.constraint(equalToConstant: 24),

            durationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            durationLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            durationLabel.widthAnchor.constraint(equalToConstant: 44),

            transcriptLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 12),
            transcriptLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            transcriptLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            transcriptLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    private func generateWaveformPath() {
        // Clear existing layers
        waveformLayers.forEach { $0.removeFromSuperlayer() }
        waveformLayers.removeAll()

        let numberOfBars = 16
        let barWidth: CGFloat = 2
        let barSpacing: CGFloat = 2
        let maxHeight: CGFloat = 16

        for i in 0..<numberOfBars {
            let layer = CAShapeLayer()

            // Generate pseudo-random heights based on duration and index for consistent waveform
            let seed = duration + Double(i)
            let sin1 = sin(seed)
            let sin2 = sin(seed * 1.5)
            let sin3 = sin(seed * 2.3)
            let amplitude = sin1 * sin2 * sin3
            let height: CGFloat = 3 + CGFloat(amplitude) * (maxHeight - 3)

            let x = CGFloat(i) * (barWidth + barSpacing)
            let y = (24 - abs(height)) / 2

            let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: abs(height)), cornerRadius: barWidth / 2)
            layer.path = path.cgPath
            layer.fillColor = (isFromIris ? UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) : UIColor(white: 1.0, alpha: 0.7)).cgColor

            waveformView.layer.addSublayer(layer)
            waveformLayers.append(layer)
        }
    }

    // MARK: - Public Methods
    func setPlayingState(_ playing: Bool) {
        isPlaying = playing
    }

    func updatePlaybackProgress(_ progress: Float) {
        // Update waveform to show progress
        let progressIndex = Int(Float(waveformLayers.count) * progress)

        for (index, layer) in waveformLayers.enumerated() {
            if index <= progressIndex {
                layer.fillColor = (isFromIris ? UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0) : UIColor.white).cgColor
            } else {
                layer.fillColor = (isFromIris ? UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) : UIColor(white: 1.0, alpha: 0.7)).cgColor
            }
        }
    }

    // MARK: - Private Methods
    private func updatePlayButtonState() {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: iconName), for: .normal)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    @objc private func playButtonTapped() {
        if isPlaying {
            delegate?.audioMessageBubbleDidTapPause(self)
        } else {
            delegate?.audioMessageBubbleDidTapPlay(self)
        }
    }

    // MARK: - Public Interface
    func getAudioData() -> Data? {
        return audioData
    }
}