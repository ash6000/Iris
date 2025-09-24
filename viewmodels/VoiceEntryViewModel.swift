import Foundation
import AVFoundation

class VoiceEntryViewModel: BaseViewModel, ViewModelProtocol {
    struct Input {
        let startRecording: () -> Void
        let stopRecording: () -> Void
        let saveEntry: () -> Void
    }

    struct Output {
        let isRecording: Observable<Bool>
        let recordingTime: Observable<String>
        let waveformAmplitude: Observable<Float>
        let canSave: Observable<Bool>
    }

    @Observable var isRecording: Bool = false
    @Observable var recordingTime: String = "00:00"
    @Observable var waveformAmplitude: Float = 0.0
    @Observable var canSave: Bool = false

    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var waveformTimer: Timer?

    func transform(input: Input) -> Output {
        return Output(
            isRecording: $isRecording,
            recordingTime: $recordingTime,
            waveformAmplitude: $waveformAmplitude,
            canSave: $canSave
        )
    }

    func startRecording() {
        guard !isRecording else { return }

        setupAudioSession()
        setupRecorder()

        audioRecorder?.record()
        isRecording = true
        recordingStartTime = Date()
        canSave = false

        startTimers()
    }

    func stopRecording() {
        guard isRecording else { return }

        audioRecorder?.stop()
        isRecording = false
        canSave = true

        stopTimers()
    }

    func updateMood(_ mood: Int) {
        // Store the selected mood for the entry
        // This could be added to the entry data when saving
    }

    func saveEntry() {
        guard canSave else { return }

        // Here you would implement actual saving logic
        canSave = false
        recordingTime = "00:00"
        waveformAmplitude = 0.0
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            handleError(error)
        }
    }

    private func setupRecorder() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
        } catch {
            handleError(error)
        }
    }

    private func startTimers() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRecordingTime()
        }

        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateWaveform()
        }
    }

    private func stopTimers() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        waveformTimer?.invalidate()
        waveformTimer = nil
    }

    private func updateRecordingTime() {
        guard let startTime = recordingStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        recordingTime = String(format: "%02d:%02d", minutes, seconds)
    }

    private func updateWaveform() {
        audioRecorder?.updateMeters()
        let power = audioRecorder?.averagePower(forChannel: 0) ?? -160
        let normalizedPower = max(0, (power + 160) / 160)
        waveformAmplitude = normalizedPower
    }

    deinit {
        stopTimers()
    }
}