import Foundation
import AVFoundation
import UIKit

protocol VoiceServiceDelegate: AnyObject {
    func voiceServiceDidStartRecording()
    func voiceServiceDidStopRecording()
    func voiceServiceDidFinishRecording(audioData: Data?, success: Bool)
    func voiceServiceDidStartPlaying()
    func voiceServiceDidFinishPlaying()
    func voiceServiceRecordingTimeDidUpdate(_ time: TimeInterval)
    func voiceServiceDidFailWithError(_ error: Error)
}

class VoiceService: NSObject {

    // MARK: - Singleton
    static let shared = VoiceService()

    // MARK: - Properties
    weak var delegate: VoiceServiceDelegate?

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?

    // Single recorder for both VAD and recording
    private var isVADActive = false
    private var isActuallyRecording = false

    private var recordingURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("voice_recording.m4a")
    }


    // MARK: - Audio Session Setup
    private override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Permission Handling
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func hasMicrophonePermission() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }

    // MARK: - Recording Functions
    func startRecording() {
        guard hasMicrophonePermission() else {
            delegate?.voiceServiceDidFailWithError(VoiceServiceError.microphonePermissionDenied)
            return
        }

        // Stop any current playback
        stopPlayback()

        // If no recorder is running (VAD not active), start one
        if audioRecorder == nil {
            startContinuousRecorder()
        }

        // Mark as actually recording and start tracking time
        isActuallyRecording = true
        recordingStartTime = Date()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateRecordingTime()
        }

        delegate?.voiceServiceDidStartRecording()
    }

    private func startContinuousRecorder() {
        // Remove existing recording
        try? FileManager.default.removeItem(at: recordingURL)

        // Configure audio recorder for continuous operation
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
        } catch {
            delegate?.voiceServiceDidFailWithError(error)
        }
    }

    func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartTime = nil
        isActuallyRecording = false

        // Stop the recorder which will trigger audioRecorderDidFinishRecording
        audioRecorder?.stop()
        audioRecorder = nil

        delegate?.voiceServiceDidStopRecording()
    }

    private func updateRecordingTime() {
        guard let startTime = recordingStartTime else { return }
        let recordingTime = Date().timeIntervalSince(startTime)
        delegate?.voiceServiceRecordingTimeDidUpdate(recordingTime)

        // No time limit - let user talk as long as they want
    }

    func getRecordingData() -> Data? {
        return try? Data(contentsOf: recordingURL)
    }

    // MARK: - Playback Functions
    func playAudio(data: Data) {
        stopPlayback() // Stop any current playback

        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            delegate?.voiceServiceDidStartPlaying()

        } catch {
            delegate?.voiceServiceDidFailWithError(error)
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }

    func isRecording() -> Bool {
        return isActuallyRecording && (audioRecorder?.isRecording ?? false)
    }

    // MARK: - Audio Level Monitoring
    func getAudioLevel() -> Float {
        // Use single recorder for both VAD and recording
        guard let recorder = audioRecorder, recorder.isRecording else { return 0.0 }
        recorder.updateMeters()
        let normalizedLevel = pow(10.0, recorder.averagePower(forChannel: 0) / 20.0)
        return normalizedLevel
    }

    // MARK: - Voice Activity Detection
    func startVoiceActivityDetection() {
        guard hasMicrophonePermission() else {
            delegate?.voiceServiceDidFailWithError(VoiceServiceError.microphonePermissionDenied)
            return
        }

        guard !isVADActive else { return }

        // Start continuous recorder if not already running
        if audioRecorder == nil {
            startContinuousRecorder()
        }

        isVADActive = true
    }

    func stopVoiceActivityDetection() {
        isVADActive = false

        // Only stop recorder if not actually recording
        if !isActuallyRecording {
            audioRecorder?.stop()
            audioRecorder = nil
        }
    }

    func isVADRunning() -> Bool {
        return isVADActive && (audioRecorder?.isRecording ?? false)
    }

    // Enhanced audio level for VAD
    func getCurrentAudioLevel() -> Float {
        return getAudioLevel()
    }
}

// MARK: - AVAudioRecorderDelegate
extension VoiceService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let audioData = flag ? getRecordingData() : nil
        delegate?.voiceServiceDidFinishRecording(audioData: audioData, success: flag)

        // Restart recorder for VAD if still active and not actually recording
        if isVADActive && !isActuallyRecording {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.startContinuousRecorder()
            }
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            delegate?.voiceServiceDidFailWithError(error)
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension VoiceService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.voiceServiceDidFinishPlaying()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            delegate?.voiceServiceDidFailWithError(error)
        }
    }
}

// MARK: - Custom Errors
enum VoiceServiceError: Error, LocalizedError {
    case microphonePermissionDenied
    case recordingFailed
    case playbackFailed
    case noRecordingData

    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone permission is required to record voice messages"
        case .recordingFailed:
            return "Failed to record audio"
        case .playbackFailed:
            return "Failed to play audio"
        case .noRecordingData:
            return "No recording data available"
        }
    }
}