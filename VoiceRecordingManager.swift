import Foundation
import AVFoundation
import UIKit

protocol VoiceRecordingManagerDelegate: AnyObject {
    func recordingDidStart()
    func recordingDidStop(success: Bool, filePath: String?, duration: TimeInterval)
    func playbackDidStart()
    func playbackDidStop()
    func recordingPermissionDenied()
}

class VoiceRecordingManager: NSObject {
    static let shared = VoiceRecordingManager()
    
    weak var delegate: VoiceRecordingManagerDelegate?
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private var recordingTimer: Timer?
    private var currentRecordingPath: String?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Permission Management
    
    func requestRecordingPermission(completion: @escaping (Bool) -> Void) {
        recordingSession.requestRecordPermission { allowed in
            DispatchQueue.main.async {
                if allowed {
                    print("✅ Recording permission granted")
                    completion(true)
                } else {
                    print("❌ Recording permission denied")
                    self.delegate?.recordingPermissionDenied()
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Recording Functions
    
    func startRecording() {
        guard audioRecorder == nil else {
            print("❌ Already recording")
            return
        }
        
        requestRecordingPermission { [weak self] granted in
            guard granted else { return }
            self?.beginRecording()
        }
    }
    
    private func beginRecording() {
        // Create unique file path
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("voice_\(Date().timeIntervalSince1970).m4a")
        currentRecordingPath = audioFilename.path
        
        // Setup recording settings
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            delegate?.recordingDidStart()
            print("✅ Recording started: \(audioFilename.path)")
            
        } catch {
            print("❌ Could not start recording: \(error)")
            delegate?.recordingDidStop(success: false, filePath: nil, duration: 0)
        }
    }
    
    func stopRecording() {
        guard let recorder = audioRecorder else {
            print("❌ No active recording")
            return
        }
        
        let duration = recorder.currentTime
        recorder.stop()
        audioRecorder = nil
        
        // Notify delegate
        delegate?.recordingDidStop(success: true, filePath: currentRecordingPath, duration: duration)
        print("✅ Recording stopped. Duration: \(duration)s")
    }
    
    // MARK: - Playback Functions
    
    func playRecording(filePath: String) {
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("❌ Recording file not found: \(filePath)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            delegate?.playbackDidStart()
            print("✅ Playback started: \(filePath)")
            
        } catch {
            print("❌ Could not play recording: \(error)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        delegate?.playbackDidStop()
        print("⏹️ Playback stopped")
    }
    
    // MARK: - Utility Functions
    
    func deleteRecording(filePath: String) {
        do {
            try FileManager.default.removeItem(atPath: filePath)
            print("✅ Recording deleted: \(filePath)")
        } catch {
            print("❌ Could not delete recording: \(error)")
        }
    }
    
    func isRecording() -> Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    func getCurrentRecordingTime() -> TimeInterval {
        return audioRecorder?.currentTime ?? 0
    }
    
    func getCurrentPlaybackTime() -> TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    func getRecordingDuration(filePath: String) -> TimeInterval {
        guard FileManager.default.fileExists(atPath: filePath) else { return 0 }
        
        do {
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            return player.duration
        } catch {
            print("❌ Could not get recording duration: \(error)")
            return 0
        }
    }
}

// MARK: - AVAudioRecorderDelegate

extension VoiceRecordingManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("✅ Recording finished successfully")
        } else {
            print("❌ Recording failed")
            currentRecordingPath = nil
            delegate?.recordingDidStop(success: false, filePath: nil, duration: 0)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("❌ Recording encoding error: \(error?.localizedDescription ?? "Unknown error")")
        currentRecordingPath = nil
        delegate?.recordingDidStop(success: false, filePath: nil, duration: 0)
    }
}

// MARK: - AVAudioPlayerDelegate

extension VoiceRecordingManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
        delegate?.playbackDidStop()
        print("✅ Playback finished")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("❌ Playback decode error: \(error?.localizedDescription ?? "Unknown error")")
        audioPlayer = nil
        delegate?.playbackDidStop()
    }
}