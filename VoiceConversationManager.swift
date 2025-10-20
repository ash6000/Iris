//
//  VoiceConversationManager.swift
//  irisOne
//
//  Created by Claude Code
//  Natural voice conversation manager with VAD and interruption handling
//

import Foundation
import AVFoundation

// MARK: - Conversation State
enum ConversationState {
    case idle           // Ready to start listening
    case listening      // User is speaking
    case processing     // Converting speech to text and getting AI response
    case speaking       // AI is responding
    case interrupted    // User interrupted AI response
}

// MARK: - Conversation Message
struct ConversationMessage {
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

// MARK: - Voice Conversation Manager Delegate
protocol VoiceConversationManagerDelegate: AnyObject {
    func voiceManager(_ manager: VoiceConversationManager, didChangeState state: ConversationState)
    func voiceManager(_ manager: VoiceConversationManager, didDetectSpeech energy: Float)
    func voiceManager(_ manager: VoiceConversationManager, didAddMessage message: ConversationMessage)
    func voiceManager(_ manager: VoiceConversationManager, didEncounterError error: Error)
    func voiceManager(_ manager: VoiceConversationManager, didUpdateTranscription text: String)
}

// MARK: - Voice Conversation Manager
class VoiceConversationManager: NSObject {

    // MARK: - Configuration
    struct Configuration {
        var silenceThreshold: TimeInterval = 1.5       // Seconds of silence before processing
        var speechEnergyThreshold: Float = -40.0       // dB threshold for speech detection
        var minimumSpeechDuration: TimeInterval = 0.5  // Minimum speech duration to process
        var interruptEnergyThreshold: Float = -35.0    // dB threshold for interrupting AI
        var enableInterruption: Bool = true             // Allow interrupting AI responses
    }

    // MARK: - Properties
    weak var delegate: VoiceConversationManagerDelegate?
    private(set) var currentState: ConversationState = .idle {
        didSet {
            if oldValue != currentState {
                DispatchQueue.main.async {
                    self.delegate?.voiceManager(self, didChangeState: self.currentState)
                }
            }
        }
    }

    private(set) var messages: [ConversationMessage] = []
    var configuration = Configuration()

    // Audio components
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    // Voice Activity Detection
    private var speechStartTime: Date?
    private var lastSpeechTime: Date?
    private var silenceTimer: Timer?
    private var isSpeechDetected = false

    // Recording
    private var recordedAudioData = Data()
    private var isRecording = false

    // Playback
    private var audioPlayer: AVAudioPlayer?

    // MARK: - Initialization
    override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Public Methods

    /// Start continuous voice monitoring
    func startConversation() {
        print("🎤 Starting conversation...")
        currentState = .idle
        startAudioMonitoring()
    }

    /// Stop conversation and cleanup
    func stopConversation() {
        print("🛑 Stopping conversation...")
        stopAudioMonitoring()
        stopRecording()
        stopPlayback()
        currentState = .idle
    }

    /// Clear conversation history
    func clearMessages() {
        messages.removeAll()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            print("✅ Audio session configured")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
            notifyError(error)
        }
    }

    // MARK: - Audio Monitoring (VAD)

    private func startAudioMonitoring() {
        stopAudioMonitoring() // Stop any existing monitoring

        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }

        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else { return }

        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Install tap to monitor audio levels
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer)
        }

        do {
            try audioEngine.start()
            print("✅ Audio monitoring started")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
            notifyError(error)
        }
    }

    private func stopAudioMonitoring() {
        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        inputNode = nil
    }

    // MARK: - Audio Buffer Processing (VAD Logic)

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }

        // Calculate RMS (Root Mean Square) energy
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let decibels = 20 * log10(rms)

        // Notify delegate of audio levels (for visualization)
        DispatchQueue.main.async {
            self.delegate?.voiceManager(self, didDetectSpeech: decibels)
        }

        // Voice Activity Detection logic
        processVoiceActivity(decibels: decibels)
    }

    private func processVoiceActivity(decibels: Float) {
        let threshold: Float

        // Different thresholds based on state
        switch currentState {
        case .idle, .listening:
            threshold = configuration.speechEnergyThreshold
        case .speaking:
            threshold = configuration.interruptEnergyThreshold // More sensitive during AI speech
        case .processing, .interrupted:
            return // Don't process VAD during these states
        }

        let isSpeaking = decibels > threshold

        if isSpeaking {
            handleSpeechDetected()
        } else {
            handleSilenceDetected()
        }
    }

    // MARK: - Speech Detection Handlers

    private func handleSpeechDetected() {
        let now = Date()
        lastSpeechTime = now

        // Cancel any pending silence timer
        silenceTimer?.invalidate()
        silenceTimer = nil

        switch currentState {
        case .idle:
            // Speech detected, start listening
            if !isSpeechDetected {
                isSpeechDetected = true
                speechStartTime = now
                startRecording()
            }

        case .listening:
            // Continue listening
            break

        case .speaking:
            // User interrupted AI response
            if configuration.enableInterruption {
                handleInterruption()
            }

        default:
            break
        }
    }

    private func handleSilenceDetected() {
        guard currentState == .listening else { return }
        guard isSpeechDetected else { return }
        guard let speechStart = speechStartTime else { return }

        // Start silence timer if not already running
        if silenceTimer == nil {
            silenceTimer = Timer.scheduledTimer(withTimeInterval: configuration.silenceThreshold, repeats: false) { [weak self] _ in
                self?.handleSilenceTimeout()
            }
        }
    }

    private func handleSilenceTimeout() {
        guard currentState == .listening else { return }
        guard let speechStart = speechStartTime else { return }

        let speechDuration = Date().timeIntervalSince(speechStart)

        // Check if speech duration meets minimum
        if speechDuration >= configuration.minimumSpeechDuration {
            print("✅ Silence detected, processing speech (duration: \(String(format: "%.1f", speechDuration))s)")
            finishRecording()
        } else {
            print("⚠️ Speech too short (\(String(format: "%.1f", speechDuration))s), ignoring")
            resetRecording()
        }

        // Reset VAD state
        isSpeechDetected = false
        speechStartTime = nil
        lastSpeechTime = nil
    }

    private func handleInterruption() {
        print("⚡ User interrupted AI response")
        currentState = .interrupted
        stopPlayback()

        // Reset and start listening again
        isSpeechDetected = true
        speechStartTime = Date()
        startRecording()
    }

    // MARK: - Recording

    private func startRecording() {
        guard !isRecording else { return }

        print("🎙️ Started recording...")
        currentState = .listening
        isRecording = true
        recordedAudioData = Data()

        // Setup recording
        let tempDir = FileManager.default.temporaryDirectory
        recordingURL = tempDir.appendingPathComponent(UUID().uuidString + ".m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.record()
        } catch {
            print("❌ Failed to start recording: \(error)")
            notifyError(error)
            resetRecording()
        }
    }

    private func stopRecording() {
        guard isRecording else { return }

        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        print("⏹️ Stopped recording")
    }

    private func finishRecording() {
        stopRecording()

        guard let recordingURL = recordingURL else {
            resetRecording()
            return
        }

        // Process the recorded audio
        processRecordedAudio(at: recordingURL)
    }

    private func resetRecording() {
        stopRecording()
        recordingURL = nil
        currentState = .idle
    }

    // MARK: - Audio Processing Pipeline

    private func processRecordedAudio(at url: URL) {
        currentState = .processing

        // Read audio file
        guard let audioData = try? Data(contentsOf: url) else {
            print("❌ Failed to read audio file")
            resetRecording()
            return
        }

        // Step 1: Transcribe audio with Whisper
        transcribeAudio(data: audioData)
    }

    private func transcribeAudio(data: Data) {
        print("🔄 Transcribing audio...")

        OpenAIService.shared.transcribeAudio(audioData: data) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let transcription):
                print("✅ Transcription: \(transcription)")
                self.handleTranscription(transcription)

            case .failure(let error):
                print("❌ Transcription failed: \(error)")
                self.notifyError(error)
                self.currentState = .idle
            }
        }
    }

    private func handleTranscription(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Empty transcription, ignoring")
            currentState = .idle
            return
        }

        // Add user message
        let userMessage = ConversationMessage(text: text, isFromUser: true, timestamp: Date())
        addMessage(userMessage)

        // Notify delegate
        DispatchQueue.main.async {
            self.delegate?.voiceManager(self, didUpdateTranscription: text)
        }

        // Step 2: Get AI response
        getAIResponse(for: text)
    }

    private func getAIResponse(for userMessage: String) {
        print("🤖 Getting AI response...")

        // Build conversation context
        var conversationContext = ""
        for message in messages.suffix(5) { // Last 5 messages for context
            let role = message.isFromUser ? "User" : "Iris"
            conversationContext += "\(role): \(message.text)\n"
        }

        OpenAIService.shared.sendMessage(userMessage) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                print("✅ AI response: \(response)")
                self.handleAIResponse(response)

            case .failure(let error):
                print("❌ AI response failed: \(error)")
                self.notifyError(error)
                self.currentState = .idle
            }
        }
    }

    private func handleAIResponse(_ text: String) {
        // Add AI message
        let aiMessage = ConversationMessage(text: text, isFromUser: false, timestamp: Date())
        addMessage(aiMessage)

        // Step 3: Convert to speech and play
        convertToSpeech(text)
    }

    private func convertToSpeech(_ text: String) {
        print("🔊 Converting to speech...")

        OpenAIService.shared.textToSpeech(text: text, voice: .nova) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let audioData):
                print("✅ TTS generated")
                self.playAIResponse(audioData: audioData)

            case .failure(let error):
                print("❌ TTS failed: \(error)")
                self.notifyError(error)
                self.currentState = .idle
            }
        }
    }

    // MARK: - Playback

    private func playAIResponse(audioData: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self

            currentState = .speaking
            audioPlayer?.play()

            print("🔊 Playing AI response...")

        } catch {
            print("❌ Failed to play audio: \(error)")
            notifyError(error)
            currentState = .idle
        }
    }

    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Message Management

    private func addMessage(_ message: ConversationMessage) {
        messages.append(message)
        DispatchQueue.main.async {
            self.delegate?.voiceManager(self, didAddMessage: message)
        }
    }

    // MARK: - Error Handling

    private func notifyError(_ error: Error) {
        DispatchQueue.main.async {
            self.delegate?.voiceManager(self, didEncounterError: error)
        }
    }

    // MARK: - Cleanup

    deinit {
        stopConversation()
    }
}

// MARK: - AVAudioPlayerDelegate
extension VoiceConversationManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("✅ AI response finished playing")

        // Return to idle state, ready to listen again
        currentState = .idle
    }
}
