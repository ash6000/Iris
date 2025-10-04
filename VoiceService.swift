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

        // Remove existing recording
        try? FileManager.default.removeItem(at: recordingURL)

        // Configure audio recorder
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

            // Start recording timer
            recordingStartTime = Date()
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateRecordingTime()
            }

            delegate?.voiceServiceDidStartRecording()

        } catch {
            delegate?.voiceServiceDidFailWithError(error)
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartTime = nil

        delegate?.voiceServiceDidStopRecording()
    }

    private func updateRecordingTime() {
        guard let startTime = recordingStartTime else { return }
        let recordingTime = Date().timeIntervalSince(startTime)
        delegate?.voiceServiceRecordingTimeDidUpdate(recordingTime)

        // Auto-stop after 60 seconds to prevent too long recordings
        if recordingTime >= 60.0 {
            stopRecording()
        }
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
        return audioRecorder?.isRecording ?? false
    }

    // MARK: - Audio Level Monitoring
    func getAudioLevel() -> Float {
        guard let recorder = audioRecorder, recorder.isRecording else { return 0.0 }
        recorder.updateMeters()
        let normalizedLevel = pow(10.0, recorder.averagePower(forChannel: 0) / 20.0)
        return normalizedLevel
    }
}

// MARK: - AVAudioRecorderDelegate
extension VoiceService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let audioData = flag ? getRecordingData() : nil
        delegate?.voiceServiceDidFinishRecording(audioData: audioData, success: flag)
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