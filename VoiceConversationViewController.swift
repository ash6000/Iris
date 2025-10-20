//
//  VoiceConversationViewController.swift
//  irisOne
//
//  Updated to use VoiceConversationManager for natural ChatGPT-like voice mode
//

import UIKit
import AVFoundation

protocol VoiceConversationDelegate: AnyObject {
    func voiceConversationDidFinish(messages: [(text: String, isFromUser: Bool)])
    func voiceConversationDidCancel()
}

class VoiceConversationViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: VoiceConversationDelegate?

    private let voiceManager = VoiceConversationManager()

    // UI Components
    private let backgroundView = UIView()
    private let contentView = UIView()
    private let closeButton = UIButton()
    private let conversationOrb = ConversationOrb()
    private let statusLabel = UILabel()
    private let instructionLabel = UILabel()

    // Transcript view
    private let transcriptScrollView = UIScrollView()
    private let transcriptStackView = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupVoiceManager()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startConversation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        voiceManager.stopConversation()
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
        statusLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        statusLabel.textColor = UIColor.white
        statusLabel.textAlignment = .center
        statusLabel.text = "Ready to listen"
        contentView.addSubview(statusLabel)

        // Instruction label
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        instructionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.text = "Just start speaking naturally"
        contentView.addSubview(instructionLabel)

        // Transcript scroll view
        transcriptScrollView.translatesAutoresizingMaskIntoConstraints = false
        transcriptScrollView.showsVerticalScrollIndicator = false
        transcriptScrollView.alpha = 0
        contentView.addSubview(transcriptScrollView)

        // Transcript stack view
        transcriptStackView.translatesAutoresizingMaskIntoConstraints = false
        transcriptStackView.axis = .vertical
        transcriptStackView.spacing = 12
        transcriptStackView.alignment = .fill
        transcriptScrollView.addSubview(transcriptStackView)
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
            conversationOrb.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 60),
            conversationOrb.widthAnchor.constraint(equalToConstant: 200),
            conversationOrb.heightAnchor.constraint(equalToConstant: 200),

            // Status label
            statusLabel.topAnchor.constraint(equalTo: conversationOrb.bottomAnchor, constant: 40),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Instruction label
            instructionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Transcript scroll view
            transcriptScrollView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 24),
            transcriptScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            transcriptScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            transcriptScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Transcript stack view
            transcriptStackView.topAnchor.constraint(equalTo: transcriptScrollView.topAnchor),
            transcriptStackView.leadingAnchor.constraint(equalTo: transcriptScrollView.leadingAnchor),
            transcriptStackView.trailingAnchor.constraint(equalTo: transcriptScrollView.trailingAnchor),
            transcriptStackView.bottomAnchor.constraint(equalTo: transcriptScrollView.bottomAnchor),
            transcriptStackView.widthAnchor.constraint(equalTo: transcriptScrollView.widthAnchor)
        ])
    }

    private func setupVoiceManager() {
        voiceManager.delegate = self

        // Configure for natural conversation (you can tune these)
        voiceManager.configuration.silenceThreshold = 1.5              // 1.5 seconds of silence
        voiceManager.configuration.speechEnergyThreshold = -40.0       // dB threshold
        voiceManager.configuration.minimumSpeechDuration = 0.5         // Minimum 0.5s speech
        voiceManager.configuration.enableInterruption = true            // Allow interrupting AI
    }

    // MARK: - Conversation Control
    private func startConversation() {
        // Check microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.voiceManager.startConversation()
                } else {
                    self?.showPermissionError()
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        voiceManager.stopConversation()

        // Pass conversation history back to delegate
        let messages = voiceManager.messages.map { ($0.text, $0.isFromUser) }
        if !messages.isEmpty {
            delegate?.voiceConversationDidFinish(messages: messages)
        } else {
            delegate?.voiceConversationDidCancel()
        }

        dismiss(animated: true)
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

    // MARK: - Transcript UI
    private func addTranscriptMessage(_ message: ConversationMessage) {
        let messageView = createTranscriptMessageView(message)
        transcriptStackView.addArrangedSubview(messageView)

        // Show transcript if hidden
        if transcriptScrollView.alpha == 0 {
            UIView.animate(withDuration: 0.3) {
                self.transcriptScrollView.alpha = 1.0
            }
        }

        // Scroll to bottom
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let bottomOffset = CGPoint(x: 0, y: max(0, self.transcriptScrollView.contentSize.height - self.transcriptScrollView.bounds.height))
            self.transcriptScrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

    private func createTranscriptMessageView(_ message: ConversationMessage) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: message.isFromUser ? .medium : .regular)
        label.textColor = message.isFromUser ? UIColor.white : UIColor.white.withAlphaComponent(0.8)
        label.numberOfLines = 0

        let prefix = message.isFromUser ? "You: " : "Iris: "
        label.text = prefix + message.text

        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }
}

// MARK: - VoiceConversationManagerDelegate
extension VoiceConversationViewController: VoiceConversationManagerDelegate {

    func voiceManager(_ manager: VoiceConversationManager, didChangeState state: ConversationState) {
        DispatchQueue.main.async {
            self.updateUIForState(state)
        }
    }

    func voiceManager(_ manager: VoiceConversationManager, didDetectSpeech energy: Float) {
        // Update orb visualization with audio level
        DispatchQueue.main.async {
            // Convert dB to 0-1 range for visualization
            let normalizedEnergy = max(0, min(1, (energy + 60) / 60)) // -60dB to 0dB mapped to 0-1
            self.conversationOrb.updateAudioLevel(normalizedEnergy)
        }
    }

    func voiceManager(_ manager: VoiceConversationManager, didAddMessage message: ConversationMessage) {
        DispatchQueue.main.async {
            self.addTranscriptMessage(message)
        }
    }

    func voiceManager(_ manager: VoiceConversationManager, didEncounterError error: Error) {
        DispatchQueue.main.async {
            print("Voice conversation error: \(error.localizedDescription)")
            self.showError(error.localizedDescription)
        }
    }

    func voiceManager(_ manager: VoiceConversationManager, didUpdateTranscription text: String) {
        // Optionally show live transcription
        print("Transcription: \(text)")
    }

    // MARK: - UI State Updates
    private func updateUIForState(_ state: ConversationState) {
        switch state {
        case .idle:
            statusLabel.text = voiceManager.messages.isEmpty ? "Ready to listen" : "I'm listening..."
            instructionLabel.text = "Just start speaking naturally"
            conversationOrb.setState(.idle)

        case .listening:
            statusLabel.text = "Listening..."
            instructionLabel.text = "Pause for 1.5 seconds when done"
            conversationOrb.setState(.listening)

        case .processing:
            statusLabel.text = "Thinking..."
            instructionLabel.text = "Processing your message"
            conversationOrb.setState(.processing)

        case .speaking:
            statusLabel.text = "Iris is speaking"
            instructionLabel.text = "You can interrupt by speaking"
            conversationOrb.setState(.speaking)

        case .interrupted:
            statusLabel.text = "Listening..."
            instructionLabel.text = "You interrupted - keep going"
            conversationOrb.setState(.listening)
        }
    }

    private func showError(_ message: String) {
        statusLabel.text = "Error"
        instructionLabel.text = message

        // Return to idle after showing error
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateUIForState(.idle)
        }
    }
}
