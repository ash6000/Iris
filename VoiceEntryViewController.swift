//
//  VoiceEntryViewController.swift
//  irisOne
//
//  Created by Test User on 9/21/25.
//

import UIKit
import AVFoundation

class VoiceEntryViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let modeDropdown = UIButton()
    private let menuButton = UIButton()

    // Date
    private let dateLabel = UILabel()

    // Mood Selector
    private let moodStackView = UIStackView()
    private var moodButtons: [UIButton] = []
    private var selectedMoodIndex = 2 // Default to happy emoji (index 2)

    // Voice Recording Section
    private let recordingContainerView = UIView()
    private let recordingCircleView = UIView()
    private let recordingInnerCircleView = UIView()
    private let recordingCenterDotView = UIView()
    private let recordingIndicatorView = UIView()

    // Waveform
    private let waveformContainerView = UIView()
    private let waveformStackView = UIStackView()
    private var waveformBars: [UIView] = []

    // Recording Info
    private let recordingLabel = UILabel()
    private let recordingTimeLabel = UILabel()

    // Live Transcription
    private let transcriptionTitleLabel = UILabel()
    private let transcriptionTextView = UITextView()

    // Audio Controls
    private let audioControlsStackView = UIStackView()
    private let playButton = UIButton()
    private let stopButton = UIButton()
    private let pauseButton = UIButton()

    // Footer Instructions
    private let footerInstructionLabel = UILabel()

    // Bottom Actions
    private let saveButton = UIButton()
    private let editTextButton = UIButton()
    private let finishButton = UIButton()

    // Recording State
    private var isRecording = false
    private var recordingDuration: TimeInterval = 0
    private var recordingTimer: Timer?
    private var waveformTimer: Timer?

    // Sample transcription text
    private let sampleTranscription = "Today I'm feeling grateful for the quiet morning. The way the sunlight streamed through my window reminded me to slow down and appreciate these peaceful moments..."

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupInitialState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        setupHeader()
        setupDate()
        setupMoodSelector()
        setupRecordingSection()
        setupWaveform()
        setupRecordingInfo()
        setupTranscription()
        setupAudioControls()
        setupFooterInstruction()
        setupBottomActions()
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        view.addSubview(headerView)

        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.setTitle(" Back", for: .normal)
        backButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal)
        backButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        headerView.addSubview(backButton)

        // Mode Dropdown
        modeDropdown.translatesAutoresizingMaskIntoConstraints = false
        modeDropdown.setTitle("Voice", for: .normal)
        modeDropdown.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        modeDropdown.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal)
        modeDropdown.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        modeDropdown.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        modeDropdown.semanticContentAttribute = .forceRightToLeft
        modeDropdown.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        headerView.addSubview(modeDropdown)

        // Menu Button
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        headerView.addSubview(menuButton)
    }

    private func setupDate() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "January 15, 2025"
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        dateLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        dateLabel.textAlignment = .center
        contentView.addSubview(dateLabel)
    }

    private func setupMoodSelector() {
        moodStackView.translatesAutoresizingMaskIntoConstraints = false
        moodStackView.axis = .horizontal
        moodStackView.distribution = .equalSpacing
        moodStackView.alignment = .center
        contentView.addSubview(moodStackView)

        let moods = ["😢", "😔", "😐", "😊", "😄"]

        for (index, mood) in moods.enumerated() {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(mood, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            button.tag = index
            button.addTarget(self, action: #selector(moodButtonTapped(_:)), for: .touchUpInside)

            if index == selectedMoodIndex {
                button.backgroundColor = UIColor.white
                button.layer.cornerRadius = 25
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
            }

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 50),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])

            moodButtons.append(button)
            moodStackView.addArrangedSubview(button)
        }
    }

    private func setupRecordingSection() {
        recordingContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recordingContainerView)

        // Outer circle
        recordingCircleView.translatesAutoresizingMaskIntoConstraints = false
        recordingCircleView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        recordingCircleView.layer.cornerRadius = 100
        recordingContainerView.addSubview(recordingCircleView)

        // Inner circle
        recordingInnerCircleView.translatesAutoresizingMaskIntoConstraints = false
        recordingInnerCircleView.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        recordingInnerCircleView.layer.cornerRadius = 60
        recordingContainerView.addSubview(recordingInnerCircleView)

        // Center dot
        recordingCenterDotView.translatesAutoresizingMaskIntoConstraints = false
        recordingCenterDotView.backgroundColor = UIColor.white
        recordingCenterDotView.layer.cornerRadius = 15
        recordingContainerView.addSubview(recordingCenterDotView)

        // Recording indicator (small dot at bottom)
        recordingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        recordingIndicatorView.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        recordingIndicatorView.layer.cornerRadius = 3
        recordingContainerView.addSubview(recordingIndicatorView)

        // Add tap gesture to recording circle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(recordingCircleTapped))
        recordingContainerView.addGestureRecognizer(tapGesture)
        recordingContainerView.isUserInteractionEnabled = true
    }

    private func setupWaveform() {
        waveformContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(waveformContainerView)

        waveformStackView.translatesAutoresizingMaskIntoConstraints = false
        waveformStackView.axis = .horizontal
        waveformStackView.distribution = .equalSpacing
        waveformStackView.alignment = .center
        waveformContainerView.addSubview(waveformStackView)

        // Create waveform bars
        for _ in 0..<20 {
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            bar.layer.cornerRadius = 1
            bar.widthAnchor.constraint(equalToConstant: 3).isActive = true
            bar.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 8...32)).isActive = true

            waveformBars.append(bar)
            waveformStackView.addArrangedSubview(bar)
        }
    }

    private func setupRecordingInfo() {
        recordingLabel.translatesAutoresizingMaskIntoConstraints = false
        recordingLabel.text = "Recording: 0:23"
        recordingLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        recordingLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        recordingLabel.textAlignment = .center
        contentView.addSubview(recordingLabel)
    }

    private func setupTranscription() {
        transcriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        transcriptionTitleLabel.text = "Live transcription:"
        transcriptionTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        transcriptionTitleLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentView.addSubview(transcriptionTitleLabel)

        transcriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        transcriptionTextView.text = sampleTranscription
        transcriptionTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        transcriptionTextView.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        transcriptionTextView.backgroundColor = UIColor.clear
        transcriptionTextView.isEditable = false
        transcriptionTextView.isScrollEnabled = false
        transcriptionTextView.textContainer.lineFragmentPadding = 0
        transcriptionTextView.textContainerInset = .zero
        contentView.addSubview(transcriptionTextView)
    }

    private func setupAudioControls() {
        audioControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        audioControlsStackView.axis = .horizontal
        audioControlsStackView.distribution = .equalSpacing
        audioControlsStackView.alignment = .center
        contentView.addSubview(audioControlsStackView)

        // Play Button
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        playButton.backgroundColor = UIColor.clear
        audioControlsStackView.addArrangedSubview(playButton)

        // Stop Button (larger, centered)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        stopButton.tintColor = UIColor.white
        stopButton.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        stopButton.layer.cornerRadius = 30
        stopButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        stopButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        audioControlsStackView.addArrangedSubview(stopButton)

        // Pause Button
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        pauseButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        pauseButton.backgroundColor = UIColor.clear
        audioControlsStackView.addArrangedSubview(pauseButton)

        NSLayoutConstraint.activate([
            playButton.widthAnchor.constraint(equalToConstant: 44),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            pauseButton.widthAnchor.constraint(equalToConstant: 44),
            pauseButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupFooterInstruction() {
        footerInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        footerInstructionLabel.text = "🔇 Tap to stop recording"
        footerInstructionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        footerInstructionLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        footerInstructionLabel.textAlignment = .center
        contentView.addSubview(footerInstructionLabel)
    }

    private func setupBottomActions() {
        // Save Button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("💾 Save Entry", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        saveButton.layer.cornerRadius = 12
        contentView.addSubview(saveButton)

        // Edit Text Button
        editTextButton.translatesAutoresizingMaskIntoConstraints = false
        editTextButton.setTitle("✏️ Edit Text", for: .normal)
        editTextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        editTextButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal)
        editTextButton.backgroundColor = UIColor.clear
        contentView.addSubview(editTextButton)

        // Finish Button (floating)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.setTitle("Say \"I'm done\" to finish", for: .normal)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        finishButton.setTitleColor(UIColor.white, for: .normal)
        finishButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        finishButton.layer.cornerRadius = 20
        view.addSubview(finishButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            modeDropdown.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            modeDropdown.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            menuButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            menuButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Date
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Mood Selector
            moodStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            moodStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moodStackView.widthAnchor.constraint(equalToConstant: 280),

            // Recording Section
            recordingContainerView.topAnchor.constraint(equalTo: moodStackView.bottomAnchor, constant: 40),
            recordingContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            recordingContainerView.widthAnchor.constraint(equalToConstant: 200),
            recordingContainerView.heightAnchor.constraint(equalToConstant: 200),

            recordingCircleView.centerXAnchor.constraint(equalTo: recordingContainerView.centerXAnchor),
            recordingCircleView.centerYAnchor.constraint(equalTo: recordingContainerView.centerYAnchor),
            recordingCircleView.widthAnchor.constraint(equalToConstant: 200),
            recordingCircleView.heightAnchor.constraint(equalToConstant: 200),

            recordingInnerCircleView.centerXAnchor.constraint(equalTo: recordingContainerView.centerXAnchor),
            recordingInnerCircleView.centerYAnchor.constraint(equalTo: recordingContainerView.centerYAnchor),
            recordingInnerCircleView.widthAnchor.constraint(equalToConstant: 120),
            recordingInnerCircleView.heightAnchor.constraint(equalToConstant: 120),

            recordingCenterDotView.centerXAnchor.constraint(equalTo: recordingContainerView.centerXAnchor),
            recordingCenterDotView.centerYAnchor.constraint(equalTo: recordingContainerView.centerYAnchor),
            recordingCenterDotView.widthAnchor.constraint(equalToConstant: 30),
            recordingCenterDotView.heightAnchor.constraint(equalToConstant: 30),

            recordingIndicatorView.centerXAnchor.constraint(equalTo: recordingContainerView.centerXAnchor),
            recordingIndicatorView.topAnchor.constraint(equalTo: recordingCircleView.bottomAnchor, constant: 8),
            recordingIndicatorView.widthAnchor.constraint(equalToConstant: 6),
            recordingIndicatorView.heightAnchor.constraint(equalToConstant: 6),

            // Waveform
            waveformContainerView.topAnchor.constraint(equalTo: recordingContainerView.bottomAnchor, constant: 32),
            waveformContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            waveformContainerView.widthAnchor.constraint(equalToConstant: 200),
            waveformContainerView.heightAnchor.constraint(equalToConstant: 40),

            waveformStackView.centerXAnchor.constraint(equalTo: waveformContainerView.centerXAnchor),
            waveformStackView.centerYAnchor.constraint(equalTo: waveformContainerView.centerYAnchor),
            waveformStackView.widthAnchor.constraint(equalToConstant: 180),

            // Recording Info
            recordingLabel.topAnchor.constraint(equalTo: waveformContainerView.bottomAnchor, constant: 16),
            recordingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Transcription
            transcriptionTitleLabel.topAnchor.constraint(equalTo: recordingLabel.bottomAnchor, constant: 32),
            transcriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            transcriptionTextView.topAnchor.constraint(equalTo: transcriptionTitleLabel.bottomAnchor, constant: 8),
            transcriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            transcriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Audio Controls
            audioControlsStackView.topAnchor.constraint(equalTo: transcriptionTextView.bottomAnchor, constant: 32),
            audioControlsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            audioControlsStackView.widthAnchor.constraint(equalToConstant: 200),

            // Footer Instruction
            footerInstructionLabel.topAnchor.constraint(equalTo: audioControlsStackView.bottomAnchor, constant: 24),
            footerInstructionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Save Button
            saveButton.topAnchor.constraint(equalTo: footerInstructionLabel.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            // Edit Text Button
            editTextButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            editTextButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            editTextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),

            // Finish Button (floating)
            finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            finishButton.widthAnchor.constraint(equalToConstant: 200),
            finishButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        modeDropdown.addTarget(self, action: #selector(modeDropdownTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)

        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        editTextButton.addTarget(self, action: #selector(editTextButtonTapped), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
    }

    private func setupInitialState() {
        startRecording()
    }

    // MARK: - Recording Methods
    private func startRecording() {
        isRecording = true
        recordingDuration = 23 // Start with 23 seconds as shown in design

        // Start timers
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.recordingDuration += 1
            self.updateRecordingTime()
        }

        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.animateWaveform()
        }

        updateRecordingTime()
        animateRecordingIndicator()
    }

    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        waveformTimer?.invalidate()

        // Update UI
        recordingLabel.text = "Recording stopped"
        footerInstructionLabel.text = "Recording complete"

        // Stop animation
        recordingIndicatorView.layer.removeAllAnimations()
    }

    private func updateRecordingTime() {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        recordingLabel.text = "Recording: \(minutes):\(String(format: "%02d", seconds))"
    }

    private func animateWaveform() {
        for bar in waveformBars {
            let newHeight = CGFloat.random(in: 8...32)
            UIView.animate(withDuration: 0.1) {
                bar.constraints.first { $0.firstAttribute == .height }?.constant = newHeight
                bar.superview?.layoutIfNeeded()
            }
        }
    }

    private func animateRecordingIndicator() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.3
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity

        recordingIndicatorView.layer.add(pulseAnimation, forKey: "pulse")
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func modeDropdownTapped() {
        print("Mode dropdown tapped")
    }

    @objc private func menuButtonTapped() {
        print("Menu button tapped")
    }

    @objc private func moodButtonTapped(_ sender: UIButton) {
        // Update selected mood
        for (index, button) in moodButtons.enumerated() {
            if index == sender.tag {
                button.backgroundColor = UIColor.white
                button.layer.cornerRadius = 25
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
                selectedMoodIndex = index
            } else {
                button.backgroundColor = UIColor.clear
                button.layer.cornerRadius = 0
                button.layer.borderWidth = 0
            }
        }
    }

    @objc private func recordingCircleTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    @objc private func playButtonTapped() {
        print("Play button tapped")
    }

    @objc private func stopButtonTapped() {
        stopRecording()
    }

    @objc private func pauseButtonTapped() {
        print("Pause button tapped")
    }

    @objc private func saveButtonTapped() {
        print("Save entry tapped")
        // Navigate back to journal
        navigationController?.popViewController(animated: true)
    }

    @objc private func editTextButtonTapped() {
        print("Edit text tapped")
    }

    @objc private func finishButtonTapped() {
        print("Finish recording tapped")
        saveButtonTapped()
    }
}