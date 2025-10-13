import UIKit
import AVFoundation

enum VoiceConversationState {
    case idle           // Waiting for user to speak
    case listening      // User is speaking
    case processing     // Transcribing and getting AI response
    case speaking       // AI is speaking back
    case paused         // Temporarily paused
}

protocol VoiceConversationDelegate: AnyObject {
    func voiceConversationDidFinish(messages: [(text: String, isFromUser: Bool)])
    func voiceConversationDidCancel()
}

class VoiceConversationViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: VoiceConversationDelegate?

    private var currentState: VoiceConversationState = .idle {
        didSet {
            updateStateUI()
        }
    }

    // Conversation data
    private var conversationMessages: [(text: String, isFromUser: Bool)] = []
    private var isFirstMessage = true

    // Voice Activity Detection
    private var vadTimer: Timer?
    private var speechStartTime: Date?
    private let minimumSpeechDuration: TimeInterval = 0.5

    // Enhanced VAD for echo cancellation
    private var voiceDetectionEnabled = true
    private var recoveryTimer: Timer?
    private let voiceDetectionThreshold: Float = 0.08 // Much lower threshold for natural speech
    private var lastVoiceDetectionTime: Date?

    // Complex 5-second silence detection
    private var audioLevelHistory: [Float] = []
    private let audioHistorySize = 15 // Longer history for better smoothing (1.5 seconds)
    private var silenceStartTime: Date?
    private let requiredSilenceDuration: TimeInterval = 5.0 // Fixed 5 seconds

    // UI Components
    private let backgroundView = UIView()
    private let contentView = UIView()
    private let closeButton = UIButton()
    private let conversationOrb = ConversationOrb()
    private let statusLabel = UILabel()
    private let instructionLabel = UILabel()
    private let transcriptLabel = UILabel()

    // Gesture recognition
    private var longPressGesture: UILongPressGestureRecognizer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
        setupAudio()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startVoiceConversation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopVoiceConversation()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.clear

        // Background with blur effect
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        view.addSubview(backgroundView)

        // Content container
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)

        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor.white.withAlphaComponent(0.7)
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        contentView.addSubview(closeButton)

        // Conversation orb
        conversationOrb.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(conversationOrb)

        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        statusLabel.textColor = UIColor.white
        statusLabel.textAlignment = .center
        statusLabel.text = "Listening..."
        contentView.addSubview(statusLabel)

        // Instruction label
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        instructionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.text = "Start speaking naturally"
        contentView.addSubview(instructionLabel)

        // Transcript label (for real-time feedback)
        transcriptLabel.translatesAutoresizingMaskIntoConstraints = false
        transcriptLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        transcriptLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        transcriptLabel.textAlignment = .center
        transcriptLabel.numberOfLines = 0
        transcriptLabel.alpha = 0
        contentView.addSubview(transcriptLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Close button
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            // Conversation orb (centered)
            conversationOrb.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            conversationOrb.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -40),
            conversationOrb.widthAnchor.constraint(equalToConstant: 200),
            conversationOrb.heightAnchor.constraint(equalToConstant: 200),

            // Status label
            statusLabel.topAnchor.constraint(equalTo: conversationOrb.bottomAnchor, constant: 40),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Instruction label
            instructionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Transcript label
            transcriptLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 24),
            transcriptLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            transcriptLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }

    private func setupGestures() {
        // Add tap gesture to orb for manual trigger if needed
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(orbTapped))
        conversationOrb.addGestureRecognizer(tapGesture)
    }

    private func setupAudio() {
        VoiceService.shared.delegate = self
    }

    // MARK: - Voice Conversation Control
    private func startVoiceConversation() {
        // Request microphone permission first
        VoiceService.shared.requestMicrophonePermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.beginListening()
                } else {
                    self?.showPermissionError()
                }
            }
        }
    }

    private func stopVoiceConversation() {
        vadTimer?.invalidate()
        recoveryTimer?.invalidate()
        VoiceService.shared.stopVoiceActivityDetection()
        VoiceService.shared.stopRecording()
        VoiceService.shared.stopPlayback()
    }

    private func beginListening() {
        currentState = .idle
        voiceDetectionEnabled = true // Ensure voice detection is enabled from start
        audioLevelHistory.removeAll() // Clear audio history for fresh start
        startVoiceActivityDetection()
    }

    // MARK: - Voice Activity Detection
    private func startVoiceActivityDetection() {
        // Start VoiceService VAD for continuous audio monitoring
        VoiceService.shared.startVoiceActivityDetection()

        // Start timer with moderate polling - not too sensitive
        vadTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkVoiceActivity()
        }
    }

    private func checkVoiceActivity() {
        // Get raw audio level from VoiceService VAD
        let rawAudioLevel = VoiceService.shared.getCurrentAudioLevel()

        // Add to history and maintain rolling average for smoothing
        audioLevelHistory.append(rawAudioLevel)
        if audioLevelHistory.count > audioHistorySize {
            audioLevelHistory.removeFirst()
        }

        // Use smoothed average to prevent false silence detection
        let smoothedAudioLevel = audioLevelHistory.reduce(0, +) / Float(audioLevelHistory.count)

        // Always update orb with raw level for immediate visual feedback
        conversationOrb.updateAudioLevel(rawAudioLevel)

        // Skip voice detection if disabled (during AI playback or recovery)
        guard voiceDetectionEnabled else { return }

        // Use smoothed level for voice detection to prevent false cutoffs
        let isVoiceDetected = smoothedAudioLevel > voiceDetectionThreshold

        // Handle voice detection based on current state
        switch currentState {
        case .idle:
            if isVoiceDetected {
                // Voice detected, start recording IMMEDIATELY
                startListening()
            }

        case .listening:
            if isVoiceDetected {
                // Voice detected - reset silence tracking
                lastVoiceDetectionTime = Date()
                silenceStartTime = nil
            } else {
                // Check if we have enough recent silence samples before starting timer
                let recentSilentSamples = audioLevelHistory.suffix(8).filter { $0 <= voiceDetectionThreshold }.count
                if recentSilentSamples >= 6 { // Require 6 out of last 8 samples to be silent (0.6 seconds)
                    checkForFiveSecondSilence()
                } else {
                    // Reset silence timer if not enough sustained silence
                    silenceStartTime = nil
                }
            }

        case .processing:
            // During processing, ignore voice input
            break

        case .speaking:
            // During AI speech, DISABLE interruption to prevent echo
            break

        case .paused:
            // During pause, ignore voice input
            break
        }
    }

    private func startListening() {
        guard currentState == .idle else { return }

        currentState = .listening
        speechStartTime = Date()
        lastVoiceDetectionTime = Date()
        audioLevelHistory.removeAll()
        silenceStartTime = nil
        VoiceService.shared.startRecording()
    }

    private func checkForFiveSecondSilence() {
        let now = Date()

        // Start tracking silence if not already
        if silenceStartTime == nil {
            silenceStartTime = now
            return
        }

        // Check if we've had 5 seconds of silence
        if let silenceStart = silenceStartTime {
            let silenceDuration = now.timeIntervalSince(silenceStart)

            if silenceDuration >= requiredSilenceDuration {
                // 5 seconds of silence - process the speech
                finishListening()
            }
        }
    }

    private func finishListening() {
        silenceStartTime = nil
        VoiceService.shared.stopRecording()
        currentState = .processing
    }


    // MARK: - State Management
    private func updateStateUI() {
        DispatchQueue.main.async {
            switch self.currentState {
            case .idle:
                self.setIdleState()
            case .listening:
                self.setListeningState()
            case .processing:
                self.setProcessingState()
            case .speaking:
                self.setSpeakingState()
            case .paused:
                self.setPausedState()
            }
        }
    }

    private func setIdleState() {
        statusLabel.text = isFirstMessage ? "Start speaking" : "I'm listening..."
        instructionLabel.text = isFirstMessage ? "I'll wait 5 seconds after you stop" : "Speak as long as you need - 5 sec pause to process"
        conversationOrb.setState(.idle)
        hideTranscript()
    }

    private func setListeningState() {
        statusLabel.text = "Listening..."
        instructionLabel.text = "Pause for 5 seconds when you're done"
        conversationOrb.setState(.listening)
        hideTranscript()
    }

    private func setProcessingState() {
        statusLabel.text = "Thinking..."
        instructionLabel.text = "Processing your message"
        conversationOrb.setState(.processing)
    }

    private func setSpeakingState() {
        statusLabel.text = "Iris is speaking"
        instructionLabel.text = "You can interrupt at any time"
        conversationOrb.setState(.speaking)
    }

    private func setPausedState() {
        statusLabel.text = "Paused"
        instructionLabel.text = "Tap to continue"
        conversationOrb.setState(.idle)
    }

    private func showTranscript(_ text: String) {
        transcriptLabel.text = text
        UIView.animate(withDuration: 0.3) {
            self.transcriptLabel.alpha = 1.0
        }
    }

    private func hideTranscript() {
        UIView.animate(withDuration: 0.3) {
            self.transcriptLabel.alpha = 0.0
        }
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        stopVoiceConversation()
        delegate?.voiceConversationDidCancel()
        dismiss(animated: true)
    }

    @objc private func orbTapped() {
        // Manual trigger for listening if in idle state
        if currentState == .idle {
            startListening()
        }
    }

    private func showPermissionError() {
        let alert = UIAlertController(
            title: "Microphone Access Required",
            message: "To have a voice conversation with Iris, please enable microphone access in Settings.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.closeButtonTapped()
        })

        present(alert, animated: true)
    }

    // MARK: - AI Conversation
    private func processVoiceMessage(audioData: Data) {
        // Transcribe audio
        OpenAIService.shared.transcribeAudio(audioData: audioData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcript):
                    self?.handleTranscript(transcript)
                case .failure(let error):
                    self?.handleError("Failed to transcribe: \(error.localizedDescription)")
                }
            }
        }
    }

    private func handleTranscript(_ transcript: String) {
        // Add to conversation history
        conversationMessages.append((text: transcript, isFromUser: true))

        // Show transcript briefly
        showTranscript("You: \(transcript)")

        // Send to ChatGPT
        OpenAIService.shared.sendMessage(transcript) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.generateVoiceResponse(response)
                case .failure(let error):
                    self?.handleError("AI response failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func generateVoiceResponse(_ text: String) {
        // Add to conversation history
        conversationMessages.append((text: text, isFromUser: false))

        // Show AI response text
        showTranscript("Iris: \(text)")

        // Convert to speech
        OpenAIService.shared.textToSpeech(text: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioData):
                    self?.playAIResponse(audioData)
                case .failure(let error):
                    // Fallback to text display only
                    self?.handleError("Voice synthesis failed: \(error.localizedDescription)")
                    self?.returnToListening()
                }
            }
        }
    }

    private func playAIResponse(_ audioData: Data) {
        currentState = .speaking
        disableVoiceDetection() // Prevent echo/feedback during AI speech
        VoiceService.shared.playAudio(data: audioData)
    }


    private func returnToListening() {
        isFirstMessage = false
        currentState = .idle

        // Ensure VAD is still running for continuous conversation
        if vadTimer == nil {
            startVoiceActivityDetection()
        }

        // Re-enable voice detection after recovery delay
        enableVoiceDetectionWithDelay()

        // Hide transcript after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hideTranscript()
        }
    }

    private func handleError(_ message: String) {
        print("Voice Conversation Error: \(message)")
        showTranscript("Error: \(message)")

        // Re-enable voice detection in case error occurred during AI speech
        enableVoiceDetectionWithDelay()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.returnToListening()
        }
    }

    // MARK: - Voice Detection Control
    private func disableVoiceDetection() {
        voiceDetectionEnabled = false
        silenceStartTime = nil // Reset any ongoing silence timing
        recoveryTimer?.invalidate()
        recoveryTimer = nil
    }

    private func enableVoiceDetectionWithDelay() {
        recoveryTimer?.invalidate()
        recoveryTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            self?.voiceDetectionEnabled = true
            self?.silenceStartTime = nil
        }
    }

    deinit {
        stopVoiceConversation()
        recoveryTimer?.invalidate()
    }
}

// MARK: - VoiceServiceDelegate
extension VoiceConversationViewController: VoiceServiceDelegate {
    func voiceServiceDidStartRecording() {
        // Recording started
    }

    func voiceServiceDidStopRecording() {
        // Recording stopped
    }

    func voiceServiceDidFinishRecording(audioData: Data?, success: Bool) {
        if success, let audioData = audioData {
            processVoiceMessage(audioData: audioData)
        } else {
            handleError("Recording failed")
        }
    }

    func voiceServiceDidStartPlaying() {
        currentState = .speaking
        disableVoiceDetection() // Extra safety - disable detection during playback
    }

    func voiceServiceDidFinishPlaying() {
        returnToListening()
    }

    func voiceServiceRecordingTimeDidUpdate(_ time: TimeInterval) {
        // Update UI if needed
    }

    func voiceServiceDidFailWithError(_ error: Error) {
        handleError(error.localizedDescription)
    }
}