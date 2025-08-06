import UIKit

// MARK: - Mood Tracking View Controller
class MoodTrackingViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedMoodIndex: Int?
    private var selectedTags: Set<String> = []
    
    // Original state for change detection
    private var originalMoodIndex: Int?
    private var originalJournalText: String = ""
    private var originalTags: Set<String> = []
    private var originalVoiceRecordingPath: String?
    private var hasChanges = false
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    
    // Streak Banner
    private let streakBanner = UIView()
    private let streakLabel = UILabel()
    
    // Past Week Section
    private let pastWeekCard = UIView()
    private let pastWeekTitleLabel = UILabel()
    private let weekScrollView = UIScrollView()
    private let weekStackView = UIStackView()
    
    // Mood Trend
    private let moodTrendCard = UIView()
    private let moodTrendTitleLabel = UILabel()
    private let chartView = UIView()
    private let chartShapeLayer = CAShapeLayer()
    
    // Mood Picker
    private let moodPickerCard = UIView()
    private let moodQuestionLabel = UILabel()
    private let moodSubtitleLabel = UILabel()
    private let moodGridStackView = UIStackView()
    private var moodButtons: [UIButton] = []
    
    // Journal Entry
    private let journalCard = UIView()
    private let journalTitleLabel = UILabel()
    private let journalSubtitleLabel = UILabel()
    private let journalTextView = UITextView()
    
    // Tags Section
    private let tagsHeaderLabel = UILabel()
    private let tagsContainerView = UIView()
    private var tagButtons: [UIButton] = []
    
    // Voice Journal
    private let voiceJournalCard = UIView()
    private let voiceJournalHeader = UIView()
    private let voiceJournalMicIcon = UIView()
    private let voiceJournalMicImageView = UIImageView()
    private let voiceJournalTitleLabel = UILabel()
    private let voiceJournalChevron = UIImageView()
    private let voiceJournalSeparator = UIView()
    
    // Voice Journal Expanded Content
    private let voiceJournalContentView = UIView()
    private let waveformView = WaveformView()
    private let timerLabel = UILabel()
    private let controlsStackView = UIStackView()
    private let recordButton = UIButton()
    private let playButton = UIButton()
    private let reRecordButton = UIButton()
    private let collapseHandle = UIImageView()
    
    private var isVoiceJournalExpanded = false
    private var voiceJournalHeightConstraint: NSLayoutConstraint!
    private var isRecording = false
    private var isPlaying = false
    private var hasRecording = false
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    private var recordingSeconds = 0
    private var totalRecordingSeconds = 0
    private var currentVoiceRecordingPath: String?
    
    // Voice recording manager
    private let voiceManager = VoiceRecordingManager.shared
    
    // Weekly Insights
    private let insightsCard = UIView()
    private let insightsTitleLabel = UILabel()
    private let insightsStackView = UIStackView()
    
    // Save Button
    private let saveButton = UIButton()
    private let viewCalendarButton = UIButton()
    
    private let moods = [
        ("😊", "Joyful"),
        ("😌", "Peaceful"),
        ("🤔", "Curious"),
        ("😰", "Anxious"),
        ("😔", "Sad"),
        ("🧘", "Calm"),
        ("🤩", "Excited"),
        ("😵", "Overwhelm")
    ]
    
    private var weekData: [(String, String)] = []
    private let tags = ["Work", "Sleep", "Family", "Social", "Self-care", "Exercise", "Creativity", "Stress"]
    private var insights: [(String, String)] = []
    
    // Data manager
    private let dataManager = MoodDataManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadRealData()
        updateSaveButtonState()
        setupVoiceRecording()
    }
    
    // MARK: - Real Data Loading
    private func loadRealData() {
        // Load current streak
        let currentStreak = dataManager.getCurrentStreak()
        streakLabel.text = currentStreak > 0 ? "🎖 \(currentStreak) days logged in a row! 🌟" : "🌟 Start your mood tracking streak today!"
        
        // Load past week data
        weekData = dataManager.getPastWeekMoods()
        updateWeekView()
        
        // Load insights
        insights = dataManager.generateInsights()
        updateInsightsView()
        
        // Update mood trend chart with real data
        DispatchQueue.main.async {
            self.drawRealMoodChart()
        }
        
        // Load existing mood entry for today if it exists
        loadTodaysMoodEntry()
        
        // Update UI to reflect completion status
        updateCompletionStatus()
    }
    
    private func updateWeekView() {
        // Clear existing day views
        weekStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new day views with real data
        for (day, emoji) in weekData {
            let dayView = createDayView(day: day, emoji: emoji)
            weekStackView.addArrangedSubview(dayView)
        }
    }
    
    private func updateInsightsView() {
        // Clear existing insight views
        insightsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new insight views with real data
        for (emoji, text) in insights {
            let insightView = createInsightView(emoji: emoji, text: text)
            insightsStackView.addArrangedSubview(insightView)
        }
    }
    
    private func drawRealMoodChart() {
        let trendData = dataManager.getMoodTrendData()
        
        guard !trendData.isEmpty else {
            // Show placeholder chart if no data
            drawMoodChart()
            return
        }
        
        // Clear existing chart
        chartShapeLayer.removeFromSuperlayer()
        chartView.layer.sublayers?.forEach { layer in
            if layer != chartShapeLayer {
                layer.removeFromSuperlayer()
            }
        }
        chartView.subviews.forEach { $0.removeFromSuperview() }
        
        let width = chartView.bounds.width
        let height = chartView.bounds.height
        
        // Create points from real data
        var points: [CGPoint] = []
        for (index, value) in trendData.enumerated() {
            let x = width * CGFloat(index) / CGFloat(max(trendData.count - 1, 1))
            let y = height * (1.0 - (value - 1.0) / 4.0) // Scale 1-5 to height
            points.append(CGPoint(x: x, y: y))
        }
        
        // Create path
        let path = UIBezierPath()
        if !points.isEmpty {
            path.move(to: points[0])
            for i in 1..<points.count {
                path.addLine(to: points[i])
            }
        }
        
        // Configure shape layer
        chartShapeLayer.path = path.cgPath
        chartShapeLayer.strokeColor = UIColor(red: 0.85, green: 0.4, blue: 0.6, alpha: 1.0).cgColor
        chartShapeLayer.fillColor = UIColor.clear.cgColor
        chartShapeLayer.lineWidth = 3
        chartShapeLayer.lineCap = .round
        chartShapeLayer.lineJoin = .round
        
        chartView.layer.addSublayer(chartShapeLayer)
        
        // Add dots
        for point in points {
            let dot = CAShapeLayer()
            let dotPath = UIBezierPath(arcCenter: point, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            dot.path = dotPath.cgPath
            dot.fillColor = UIColor(red: 0.85, green: 0.4, blue: 0.6, alpha: 1.0).cgColor
            chartView.layer.addSublayer(dot)
        }
        
        // Add day labels for past week
        let dayLabels = weekData.map { $0.0 }
        for (index, day) in dayLabels.enumerated() {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            label.translatesAutoresizingMaskIntoConstraints = false
            chartView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: chartView.leadingAnchor, constant: width * CGFloat(index) / CGFloat(max(dayLabels.count - 1, 1))),
                label.bottomAnchor.constraint(equalTo: chartView.bottomAnchor)
            ])
        }
    }
    
    private func loadTodaysMoodEntry() {
        let today = Calendar.current.startOfDay(for: Date())
        if let todayEntry = dataManager.getMoodEntry(for: today) {
            // Pre-select today's mood if already entered
            if let moodIndex = moods.firstIndex(where: { $0.1 == todayEntry.moodLabel }) {
                selectedMoodIndex = moodIndex
                originalMoodIndex = moodIndex  // Store original
                moodButtons[moodIndex].backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.2)
                moodButtons[moodIndex].layer.borderColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0).cgColor
                moodButtons[moodIndex].layer.borderWidth = 2
            }
            
            // Pre-fill journal text
            if !todayEntry.journalText.isEmpty {
                journalTextView.text = todayEntry.journalText
                journalTextView.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                originalJournalText = todayEntry.journalText  // Store original
            }
            
            // Pre-select tags
            selectedTags = Set(todayEntry.tags)
            originalTags = Set(todayEntry.tags)  // Store original
            for (index, tag) in tags.enumerated() {
                if selectedTags.contains(tag) {
                    tagButtons[index].backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.3)
                    tagButtons[index].setTitleColor(UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0), for: .normal)
                }
            }
            
            // Load existing voice recording if any
            if let voicePath = dataManager.getVoiceRecordingPath(for: today) {
                currentVoiceRecordingPath = voicePath
                originalVoiceRecordingPath = voicePath  // Store original
                totalRecordingSeconds = Int(dataManager.getVoiceRecordingDuration(for: today))
                hasRecording = true
                updateButtonStates(recording: false, playing: false, hasRecording: true)
                updateTimerDisplay(seconds: totalRecordingSeconds)
            }
            
            updateSaveButtonState()
        } else {
            // No existing entry - clear original state
            originalMoodIndex = nil
            originalJournalText = ""
            originalTags = []
            originalVoiceRecordingPath = nil
        }
    }
    
    private func updateCompletionStatus() {
        if dataManager.hasTodaysMoodEntry() {
            // User already logged mood today - update save button text
            saveButton.setTitle("Update Today's Reflection", for: .normal)
        } else {
            // User hasn't logged mood today - standard save button
            saveButton.setTitle("Save Today's Reflection", for: .normal)
        }
        
        // Always use standard styling - no green colors or checkmarks
        titleLabel.text = "Today's Mood"
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        // Standard streak styling
        let currentStreak = dataManager.getCurrentStreak()
        streakBanner.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        streakLabel.textColor = UIColor(red: 0.4, green: 0.3, blue: 0.3, alpha: 1.0)
        streakLabel.text = currentStreak > 0 ? "🎖 \(currentStreak) days logged in a row! 🌟" : "🌟 Start your mood tracking streak today!"
    }
    
    private func setupVoiceRecording() {
        voiceManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        cleanupVoiceJournal()
    }
    

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        setupHeader()
        setupStreakBanner()
        setupPastWeekSection()
        setupMoodTrendSection()
        setupMoodPicker()
        setupJournalSection()
        setupTagsSection()
        setupWeeklyInsights()
        setupViewCalendarButton()  // Add this line
        setupSaveButton()
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        contentView.addSubview(headerView)
        
        // Title (No back button)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Today's Mood"
        titleLabel.font = UIFont(name: "Georgia", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
    }
    
    @objc private func viewCalendarButtonTapped() {
        print("📅 View Calendar & History button tapped")
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Create and push MoodOverviewViewController
        let moodOverviewVC = MoodOverviewViewController()
        navigationController?.pushViewController(moodOverviewVC, animated: true)
    }
    
    private func setupViewCalendarButton() {
        viewCalendarButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Style the button to match app theme
        viewCalendarButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        viewCalendarButton.layer.cornerRadius = 20
        viewCalendarButton.layer.cornerCurve = .continuous
        
        // Add subtle shadow for depth
        viewCalendarButton.layer.shadowColor = UIColor.black.cgColor
        viewCalendarButton.layer.shadowOpacity = 0.05
        viewCalendarButton.layer.shadowRadius = 4
        viewCalendarButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Button content
        viewCalendarButton.setTitle("📅 View Calendar & History", for: .normal)
        viewCalendarButton.setTitleColor(UIColor(red: 0.4, green: 0.3, blue: 0.3, alpha: 1.0), for: .normal)
        viewCalendarButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Add target action
        viewCalendarButton.addTarget(self, action: #selector(viewCalendarButtonTapped), for: .touchUpInside)
        
        // Add to content view
        contentView.addSubview(viewCalendarButton)
    }
    
    private func setupStreakBanner() {
        streakBanner.translatesAutoresizingMaskIntoConstraints = false
        streakBanner.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        streakBanner.layer.cornerRadius = 20
        contentView.addSubview(streakBanner)
        
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.text = "🎖 3 days logged in a row! 🌟"
        streakLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        streakLabel.textColor = UIColor(red: 0.4, green: 0.3, blue: 0.3, alpha: 1.0)
        streakLabel.textAlignment = .center
        streakBanner.addSubview(streakLabel)
    }
    
    private func setupPastWeekSection() {
        // Card
        pastWeekCard.translatesAutoresizingMaskIntoConstraints = false
        pastWeekCard.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        pastWeekCard.layer.cornerRadius = 20
        contentView.addSubview(pastWeekCard)
        
        // Title
        pastWeekTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pastWeekTitleLabel.text = "📅 Past Week"
        pastWeekTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        pastWeekTitleLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        pastWeekCard.addSubview(pastWeekTitleLabel)
        
        // Week Scroll View
        weekScrollView.translatesAutoresizingMaskIntoConstraints = false
        weekScrollView.showsHorizontalScrollIndicator = false
        pastWeekCard.addSubview(weekScrollView)
        
        // Week Stack View
        weekStackView.translatesAutoresizingMaskIntoConstraints = false
        weekStackView.axis = .horizontal
        weekStackView.distribution = .fillEqually
        weekStackView.spacing = 16
        weekStackView.alignment = .center
        weekScrollView.addSubview(weekStackView)
        
        // Add day views
        for (day, emoji) in weekData {
            let dayView = createDayView(day: day, emoji: emoji)
            weekStackView.addArrangedSubview(dayView)
        }
    }
    
    private func createDayView(day: String, emoji: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Check if this is today
        let today = DateFormatter()
        today.dateFormat = "E"
        let todayString = today.string(from: Date())
        let isToday = (day == todayString)
        
        let dayLabel = UILabel()
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.text = isToday ? "Today" : day
        dayLabel.font = UIFont.systemFont(ofSize: isToday ? 12 : 14, weight: isToday ? .bold : .medium)
        dayLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        dayLabel.textAlignment = .center
        container.addSubview(dayLabel)
        
        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 24)
        emojiLabel.textAlignment = .center
        container.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 50),
            
            dayLabel.topAnchor.constraint(equalTo: container.topAnchor),
            dayLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 8),
            emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupMoodTrendSection() {
        // Card
        moodTrendCard.translatesAutoresizingMaskIntoConstraints = false
        moodTrendCard.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        moodTrendCard.layer.cornerRadius = 20
        contentView.addSubview(moodTrendCard)
        
        // Title
        moodTrendTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        moodTrendTitleLabel.text = "📈 Mood Trend"
        moodTrendTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        moodTrendTitleLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        moodTrendCard.addSubview(moodTrendTitleLabel)
        
        // Chart View
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .clear
        moodTrendCard.addSubview(chartView)
        
        DispatchQueue.main.async {
            self.drawMoodChart()
        }
    }
    
    private func drawMoodChart() {
        let width = chartView.bounds.width
        let height = chartView.bounds.height
        let points = [
            CGPoint(x: width * 0.1, y: height * 0.6),
            CGPoint(x: width * 0.25, y: height * 0.5),
            CGPoint(x: width * 0.4, y: height * 0.3),
            CGPoint(x: width * 0.55, y: height * 0.5),
            CGPoint(x: width * 0.7, y: height * 0.2),
            CGPoint(x: width * 0.85, y: height * 0.4),
            CGPoint(x: width * 0.95, y: height * 0.7)
        ]
        
        // Create path
        let path = UIBezierPath()
        path.move(to: points[0])
        
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        
        // Configure shape layer
        chartShapeLayer.path = path.cgPath
        chartShapeLayer.strokeColor = UIColor(red: 0.85, green: 0.4, blue: 0.6, alpha: 1.0).cgColor
        chartShapeLayer.fillColor = UIColor.clear.cgColor
        chartShapeLayer.lineWidth = 3
        chartShapeLayer.lineCap = .round
        chartShapeLayer.lineJoin = .round
        
        chartView.layer.addSublayer(chartShapeLayer)
        
        // Add dots
        for point in points {
            let dot = CAShapeLayer()
            let dotPath = UIBezierPath(arcCenter: point, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            dot.path = dotPath.cgPath
            dot.fillColor = UIColor(red: 0.85, green: 0.4, blue: 0.6, alpha: 1.0).cgColor
            chartView.layer.addSublayer(dot)
        }
        
        // Add day labels
        let days = ["Tue", "Wed", "Thu", "Fri", "Sat", "Today"]
        for (index, day) in days.enumerated() {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            label.translatesAutoresizingMaskIntoConstraints = false
            chartView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: chartView.leadingAnchor, constant: width * CGFloat(index + 1) / CGFloat(days.count + 1)),
                label.bottomAnchor.constraint(equalTo: chartView.bottomAnchor)
            ])
        }
    }
    
    private func setupMoodPicker() {
        // Card
        moodPickerCard.translatesAutoresizingMaskIntoConstraints = false
        moodPickerCard.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        moodPickerCard.layer.cornerRadius = 20
        contentView.addSubview(moodPickerCard)
        
        // Question Label
        moodQuestionLabel.translatesAutoresizingMaskIntoConstraints = false
        moodQuestionLabel.text = "How are you feeling right now?"
        moodQuestionLabel.font = UIFont(name: "Georgia", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        moodQuestionLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        moodQuestionLabel.textAlignment = .center
        moodPickerCard.addSubview(moodQuestionLabel)
        
        // Subtitle
        moodSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        moodSubtitleLabel.text = "Choose the emotion that resonates most\nwith your heart today"
        moodSubtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        moodSubtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        moodSubtitleLabel.textAlignment = .center
        moodSubtitleLabel.numberOfLines = 2
        moodPickerCard.addSubview(moodSubtitleLabel)
        
        // Mood Grid
        moodGridStackView.translatesAutoresizingMaskIntoConstraints = false
        moodGridStackView.axis = .vertical
        moodGridStackView.distribution = .fillEqually
        moodGridStackView.spacing = 16
        moodPickerCard.addSubview(moodGridStackView)
        
        // Create 2 rows of 4 moods each
        for row in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 16
            
            for col in 0..<4 {
                let index = row * 4 + col
                if index < moods.count {
                    let moodButton = createMoodButton(emoji: moods[index].0, label: moods[index].1, index: index)
                    moodButtons.append(moodButton)
                    rowStack.addArrangedSubview(moodButton)
                }
            }
            
            moodGridStackView.addArrangedSubview(rowStack)
        }
    }
    
    private func createMoodButton(emoji: String, label: String, index: Int) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.tag = index
        
        let container = UIView()
        container.isUserInteractionEnabled = false
        container.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(container)
        
        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        container.addSubview(emojiLabel)
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = label
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        textLabel.textAlignment = .center
        container.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 80),
            
            container.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: container.topAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            textLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 4),
            textLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        button.addTarget(self, action: #selector(moodButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func setupJournalSection() {
        // Card
        journalCard.translatesAutoresizingMaskIntoConstraints = false
        journalCard.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        journalCard.layer.cornerRadius = 20
        contentView.addSubview(journalCard)
        
        // Title
        journalTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        journalTitleLabel.text = "Write what you're feeling"
        journalTitleLabel.font = UIFont(name: "Georgia", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        journalTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        journalTitleLabel.textAlignment = .center
        journalCard.addSubview(journalTitleLabel)
        
        // Subtitle
        journalSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        journalSubtitleLabel.text = "Let your thoughts flow freely. This is your safe space."
        journalSubtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        journalSubtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        journalSubtitleLabel.textAlignment = .center
        journalSubtitleLabel.numberOfLines = 0
        journalCard.addSubview(journalSubtitleLabel)
        
        // Text View
        journalTextView.translatesAutoresizingMaskIntoConstraints = false
        journalTextView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        journalTextView.layer.cornerRadius = 12
        journalTextView.font = UIFont.systemFont(ofSize: 16)
        journalTextView.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        journalTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        journalTextView.delegate = self
        journalCard.addSubview(journalTextView)
        
        // Add placeholder
        journalTextView.text = "Today I feel... because..."
        journalTextView.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    }
    
    private func setupTagsSection() {
        // Tags Header
        tagsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsHeaderLabel.text = "🏷 Add tags to track patterns"
        tagsHeaderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tagsHeaderLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        journalCard.addSubview(tagsHeaderLabel)
        
        // Tags Container
        tagsContainerView.translatesAutoresizingMaskIntoConstraints = false
        journalCard.addSubview(tagsContainerView)
        
        // Create tag buttons with proper flow layout
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        let spacing: CGFloat = 8
        let maxWidth = UIScreen.main.bounds.width - 64 // Account for card margins
        
        for tag in tags {
            let tagButton = createTagButton(title: tag)
            tagButtons.append(tagButton)
            tagsContainerView.addSubview(tagButton)
            
            // Measure button width
            let size = tagButton.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 32))
            let buttonWidth = size.width
            
            // Check if button fits in current row
            if xOffset + buttonWidth > maxWidth {
                // Move to next row
                xOffset = 0
                yOffset += 32 + spacing
            }
            
            // Position button
            tagButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tagButton.leadingAnchor.constraint(equalTo: tagsContainerView.leadingAnchor, constant: xOffset),
                tagButton.topAnchor.constraint(equalTo: tagsContainerView.topAnchor, constant: yOffset),
                tagButton.widthAnchor.constraint(equalToConstant: buttonWidth),
                tagButton.heightAnchor.constraint(equalToConstant: 32)
            ])
            
            xOffset += buttonWidth + spacing
        }
        
        // Update container height constraint
        NSLayoutConstraint.activate([
            tagsContainerView.heightAnchor.constraint(equalToConstant: yOffset + 32)
        ])
        
        // Setup Voice Journal Card
        setupVoiceJournalCard()
    }
    
    // MARK: - Voice Journal Setup
    private func setupVoiceJournalCard() {
        // Voice Journal Card
        voiceJournalCard.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalCard.backgroundColor = UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1.0)
        voiceJournalCard.layer.cornerRadius = 16
        voiceJournalCard.layer.shadowColor = UIColor.black.cgColor
        voiceJournalCard.layer.shadowOpacity = 0.1
        voiceJournalCard.layer.shadowRadius = 8
        voiceJournalCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        journalCard.addSubview(voiceJournalCard)
        
        // Header View (always visible)
        voiceJournalHeader.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalHeader.backgroundColor = .clear
        voiceJournalCard.addSubview(voiceJournalHeader)
        
        // Mic Icon Background
        voiceJournalMicIcon.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalMicIcon.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        voiceJournalMicIcon.layer.cornerRadius = 16
        voiceJournalHeader.addSubview(voiceJournalMicIcon)
        
        // Mic Image
        voiceJournalMicImageView.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalMicImageView.image = UIImage(systemName: "mic.fill")
        voiceJournalMicImageView.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        voiceJournalMicImageView.contentMode = .scaleAspectFit
        voiceJournalMicIcon.addSubview(voiceJournalMicImageView)
        
        // Title Label
        voiceJournalTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalTitleLabel.text = "Voice Journal"
        voiceJournalTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        voiceJournalTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        voiceJournalHeader.addSubview(voiceJournalTitleLabel)
        
        // Chevron
        voiceJournalChevron.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalChevron.image = UIImage(systemName: "chevron.down")
        voiceJournalChevron.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        voiceJournalChevron.contentMode = .scaleAspectFit
        voiceJournalHeader.addSubview(voiceJournalChevron)
        
        // Add tap gesture to header - CLEAN VERSION
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(voiceJournalHeaderTapped))
        voiceJournalHeader.addGestureRecognizer(tapGesture)
        voiceJournalHeader.isUserInteractionEnabled = true
        
        // Separator Line
        voiceJournalSeparator.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalSeparator.backgroundColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 1.0)
        voiceJournalSeparator.alpha = 0
        voiceJournalCard.addSubview(voiceJournalSeparator)
        
        // Content View
        voiceJournalContentView.translatesAutoresizingMaskIntoConstraints = false
        voiceJournalContentView.alpha = 0
        voiceJournalContentView.backgroundColor = .clear
        voiceJournalCard.addSubview(voiceJournalContentView)
        
        // Waveform View
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.backgroundColor = .clear
        voiceJournalContentView.addSubview(waveformView)
        
        // Timer Label
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.text = "0:00"
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .medium)
        timerLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        timerLabel.textAlignment = .center
        voiceJournalContentView.addSubview(timerLabel)
        
        // Controls Stack
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        controlsStackView.axis = .horizontal
        controlsStackView.distribution = .equalSpacing
        controlsStackView.alignment = .center
        voiceJournalContentView.addSubview(controlsStackView)
        
        setupVoiceJournalButtons()
        
        // Collapse Handle
        collapseHandle.translatesAutoresizingMaskIntoConstraints = false
        collapseHandle.image = UIImage(systemName: "chevron.compact.up")
        collapseHandle.tintColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        collapseHandle.contentMode = .scaleAspectFit
        voiceJournalContentView.addSubview(collapseHandle)
        
        // Add tap gesture to collapse handle
        let collapseGesture = UITapGestureRecognizer(target: self, action: #selector(voiceJournalHeaderTapped))
        collapseHandle.addGestureRecognizer(collapseGesture)
        collapseHandle.isUserInteractionEnabled = true
    }
    
    // MARK: - Button Setup
    private func setupVoiceJournalButtons() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        recordButton.layer.cornerRadius = 22
        recordButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        recordButton.tintColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 1.0)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        controlsStackView.addArrangedSubview(recordButton)
        
        // Play Button
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        playButton.layer.cornerRadius = 22
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        playButton.isEnabled = false
        playButton.alpha = 0.5
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        controlsStackView.addArrangedSubview(playButton)
        
        // Re-record Button
        reRecordButton.translatesAutoresizingMaskIntoConstraints = false
        reRecordButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        reRecordButton.layer.cornerRadius = 22
        reRecordButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        reRecordButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        reRecordButton.isEnabled = false
        reRecordButton.alpha = 0.5
        reRecordButton.addTarget(self, action: #selector(reRecordButtonTapped), for: .touchUpInside)
        controlsStackView.addArrangedSubview(reRecordButton)
    }
    
    private func createTagButton(title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return button
    }
    
    private func setupWeeklyInsights() {
        // Card
        insightsCard.translatesAutoresizingMaskIntoConstraints = false
        insightsCard.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        insightsCard.layer.cornerRadius = 20
        contentView.addSubview(insightsCard)
        
        // Title
        insightsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        insightsTitleLabel.text = "Weekly Insights"
        insightsTitleLabel.font = UIFont(name: "Georgia", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        insightsTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        insightsCard.addSubview(insightsTitleLabel)
        
        // Insights Stack
        insightsStackView.translatesAutoresizingMaskIntoConstraints = false
        insightsStackView.axis = .vertical
        insightsStackView.spacing = 12
        insightsCard.addSubview(insightsStackView)
        
        // Add insights
        for (emoji, text) in insights {
            let insightView = createInsightView(emoji: emoji, text: text)
            insightsStackView.addArrangedSubview(insightView)
        }
    }
    
    private func createInsightView(emoji: String, text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 0.6)
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(emoji) \(text)"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        label.numberOfLines = 0
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.3)
        saveButton.layer.cornerRadius = 25
        saveButton.setTitle("Save Today's Reflection", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)
    }
    

    // MARK: - Complete setupConstraints method
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header (without back button)
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Title
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Streak Banner
            streakBanner.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            streakBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            streakBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            streakBanner.heightAnchor.constraint(equalToConstant: 50),
            
            streakLabel.centerXAnchor.constraint(equalTo: streakBanner.centerXAnchor),
            streakLabel.centerYAnchor.constraint(equalTo: streakBanner.centerYAnchor),
            streakLabel.leadingAnchor.constraint(equalTo: streakBanner.leadingAnchor, constant: 16),
            streakLabel.trailingAnchor.constraint(equalTo: streakBanner.trailingAnchor, constant: -16),
            
            // Past Week Card
            pastWeekCard.topAnchor.constraint(equalTo: streakBanner.bottomAnchor, constant: 16),
            pastWeekCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pastWeekCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            pastWeekTitleLabel.topAnchor.constraint(equalTo: pastWeekCard.topAnchor, constant: 16),
            pastWeekTitleLabel.leadingAnchor.constraint(equalTo: pastWeekCard.leadingAnchor, constant: 16),
            
            weekScrollView.topAnchor.constraint(equalTo: pastWeekTitleLabel.bottomAnchor, constant: 16),
            weekScrollView.leadingAnchor.constraint(equalTo: pastWeekCard.leadingAnchor, constant: 16),
            weekScrollView.trailingAnchor.constraint(equalTo: pastWeekCard.trailingAnchor, constant: -16),
            weekScrollView.heightAnchor.constraint(equalToConstant: 70),
            weekScrollView.bottomAnchor.constraint(equalTo: pastWeekCard.bottomAnchor, constant: -16),
            
            weekStackView.topAnchor.constraint(equalTo: weekScrollView.topAnchor),
            weekStackView.leadingAnchor.constraint(equalTo: weekScrollView.leadingAnchor),
            weekStackView.trailingAnchor.constraint(equalTo: weekScrollView.trailingAnchor),
            weekStackView.bottomAnchor.constraint(equalTo: weekScrollView.bottomAnchor),
            weekStackView.heightAnchor.constraint(equalTo: weekScrollView.heightAnchor),
            
            // Mood Trend Card
            moodTrendCard.topAnchor.constraint(equalTo: pastWeekCard.bottomAnchor, constant: 16),
            moodTrendCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            moodTrendCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            moodTrendTitleLabel.topAnchor.constraint(equalTo: moodTrendCard.topAnchor, constant: 16),
            moodTrendTitleLabel.leadingAnchor.constraint(equalTo: moodTrendCard.leadingAnchor, constant: 16),
            
            chartView.topAnchor.constraint(equalTo: moodTrendTitleLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: moodTrendCard.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: moodTrendCard.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 120),
            chartView.bottomAnchor.constraint(equalTo: moodTrendCard.bottomAnchor, constant: -16),
            
            // Mood Picker Card
            moodPickerCard.topAnchor.constraint(equalTo: moodTrendCard.bottomAnchor, constant: 16),
            moodPickerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            moodPickerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            moodQuestionLabel.topAnchor.constraint(equalTo: moodPickerCard.topAnchor, constant: 20),
            moodQuestionLabel.leadingAnchor.constraint(equalTo: moodPickerCard.leadingAnchor, constant: 16),
            moodQuestionLabel.trailingAnchor.constraint(equalTo: moodPickerCard.trailingAnchor, constant: -16),
            
            moodSubtitleLabel.topAnchor.constraint(equalTo: moodQuestionLabel.bottomAnchor, constant: 8),
            moodSubtitleLabel.leadingAnchor.constraint(equalTo: moodPickerCard.leadingAnchor, constant: 16),
            moodSubtitleLabel.trailingAnchor.constraint(equalTo: moodPickerCard.trailingAnchor, constant: -16),
            
            moodGridStackView.topAnchor.constraint(equalTo: moodSubtitleLabel.bottomAnchor, constant: 20),
            moodGridStackView.leadingAnchor.constraint(equalTo: moodPickerCard.leadingAnchor, constant: 16),
            moodGridStackView.trailingAnchor.constraint(equalTo: moodPickerCard.trailingAnchor, constant: -16),
            moodGridStackView.bottomAnchor.constraint(equalTo: moodPickerCard.bottomAnchor, constant: -20),
            
            // Journal Card
            journalCard.topAnchor.constraint(equalTo: moodPickerCard.bottomAnchor, constant: 16),
            journalCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            journalCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            journalTitleLabel.topAnchor.constraint(equalTo: journalCard.topAnchor, constant: 20),
            journalTitleLabel.leadingAnchor.constraint(equalTo: journalCard.leadingAnchor, constant: 16),
            journalTitleLabel.trailingAnchor.constraint(equalTo: journalCard.trailingAnchor, constant: -16),
            
            journalSubtitleLabel.topAnchor.constraint(equalTo: journalTitleLabel.bottomAnchor, constant: 8),
            journalSubtitleLabel.leadingAnchor.constraint(equalTo: journalCard.leadingAnchor, constant: 16),
            journalSubtitleLabel.trailingAnchor.constraint(equalTo: journalCard.trailingAnchor, constant: -16),
            
            journalTextView.topAnchor.constraint(equalTo: journalSubtitleLabel.bottomAnchor, constant: 16),
            journalTextView.leadingAnchor.constraint(equalTo: journalCard.leadingAnchor, constant: 16),
            journalTextView.trailingAnchor.constraint(equalTo: journalCard.trailingAnchor, constant: -16),
            journalTextView.heightAnchor.constraint(equalToConstant: 120),
            
            tagsHeaderLabel.topAnchor.constraint(equalTo: journalTextView.bottomAnchor, constant: 20),
            tagsHeaderLabel.leadingAnchor.constraint(equalTo: journalCard.leadingAnchor, constant: 16),
            
            tagsContainerView.topAnchor.constraint(equalTo: tagsHeaderLabel.bottomAnchor, constant: 12),
            tagsContainerView.leadingAnchor.constraint(equalTo: journalCard.leadingAnchor, constant: 16),
            tagsContainerView.trailingAnchor.constraint(equalTo: journalCard.trailingAnchor, constant: -16),
            tagsContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            // Voice Journal Card
            voiceJournalCard.topAnchor.constraint(equalTo: tagsContainerView.bottomAnchor, constant: 16),
            voiceJournalCard.leadingAnchor.constraint(equalTo: journalCard.leadingAnchor, constant: 16),
            voiceJournalCard.trailingAnchor.constraint(equalTo: journalCard.trailingAnchor, constant: -16),
            voiceJournalCard.bottomAnchor.constraint(lessThanOrEqualTo: journalCard.bottomAnchor, constant: -20),
            
            // Voice Journal Header (always visible)
            voiceJournalHeader.topAnchor.constraint(equalTo: voiceJournalCard.topAnchor),
            voiceJournalHeader.leadingAnchor.constraint(equalTo: voiceJournalCard.leadingAnchor),
            voiceJournalHeader.trailingAnchor.constraint(equalTo: voiceJournalCard.trailingAnchor),
            voiceJournalHeader.heightAnchor.constraint(equalToConstant: 50),
            
            // Mic Icon
            voiceJournalMicIcon.leadingAnchor.constraint(equalTo: voiceJournalHeader.leadingAnchor, constant: 12),
            voiceJournalMicIcon.centerYAnchor.constraint(equalTo: voiceJournalHeader.centerYAnchor),
            voiceJournalMicIcon.widthAnchor.constraint(equalToConstant: 32),
            voiceJournalMicIcon.heightAnchor.constraint(equalToConstant: 32),
            
            voiceJournalMicImageView.centerXAnchor.constraint(equalTo: voiceJournalMicIcon.centerXAnchor),
            voiceJournalMicImageView.centerYAnchor.constraint(equalTo: voiceJournalMicIcon.centerYAnchor),
            voiceJournalMicImageView.widthAnchor.constraint(equalToConstant: 24),
            voiceJournalMicImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title
            voiceJournalTitleLabel.leadingAnchor.constraint(equalTo: voiceJournalMicIcon.trailingAnchor, constant: 12),
            voiceJournalTitleLabel.centerYAnchor.constraint(equalTo: voiceJournalHeader.centerYAnchor),
            
            // Chevron
            voiceJournalChevron.trailingAnchor.constraint(equalTo: voiceJournalHeader.trailingAnchor, constant: -16),
            voiceJournalChevron.centerYAnchor.constraint(equalTo: voiceJournalHeader.centerYAnchor),
            voiceJournalChevron.widthAnchor.constraint(equalToConstant: 20),
            voiceJournalChevron.heightAnchor.constraint(equalToConstant: 20),
            
            // Separator
            voiceJournalSeparator.topAnchor.constraint(equalTo: voiceJournalHeader.bottomAnchor),
            voiceJournalSeparator.leadingAnchor.constraint(equalTo: voiceJournalCard.leadingAnchor, constant: 16),
            voiceJournalSeparator.trailingAnchor.constraint(equalTo: voiceJournalCard.trailingAnchor, constant: -16),
            voiceJournalSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            // Content View
            voiceJournalContentView.topAnchor.constraint(equalTo: voiceJournalSeparator.bottomAnchor),
            voiceJournalContentView.leadingAnchor.constraint(equalTo: voiceJournalCard.leadingAnchor),
            voiceJournalContentView.trailingAnchor.constraint(equalTo: voiceJournalCard.trailingAnchor),
            voiceJournalContentView.bottomAnchor.constraint(equalTo: voiceJournalCard.bottomAnchor),
            
            // Waveform
            waveformView.topAnchor.constraint(equalTo: voiceJournalContentView.topAnchor, constant: 16),
            waveformView.leadingAnchor.constraint(equalTo: voiceJournalContentView.leadingAnchor, constant: 20),
            waveformView.trailingAnchor.constraint(equalTo: voiceJournalContentView.trailingAnchor, constant: -20),
            waveformView.heightAnchor.constraint(equalToConstant: 40),
            
            // Timer
            timerLabel.topAnchor.constraint(equalTo: waveformView.bottomAnchor, constant: 16),
            timerLabel.centerXAnchor.constraint(equalTo: voiceJournalContentView.centerXAnchor),
            
            // Controls
            controlsStackView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20),
            controlsStackView.leadingAnchor.constraint(equalTo: voiceJournalContentView.leadingAnchor, constant: 60),
            controlsStackView.trailingAnchor.constraint(equalTo: voiceJournalContentView.trailingAnchor, constant: -60),
            
            recordButton.widthAnchor.constraint(equalToConstant: 44),
            recordButton.heightAnchor.constraint(equalToConstant: 44),
            playButton.widthAnchor.constraint(equalToConstant: 44),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            reRecordButton.widthAnchor.constraint(equalToConstant: 44),
            reRecordButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Collapse Handle
            collapseHandle.centerXAnchor.constraint(equalTo: voiceJournalContentView.centerXAnchor),
            collapseHandle.bottomAnchor.constraint(equalTo: voiceJournalContentView.bottomAnchor, constant: -8),
            collapseHandle.widthAnchor.constraint(equalToConstant: 30),
            collapseHandle.heightAnchor.constraint(equalToConstant: 20),
            
            // Weekly Insights
            insightsCard.topAnchor.constraint(equalTo: viewCalendarButton.bottomAnchor, constant: 16), // Changed to be below calendar button
            insightsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            insightsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            insightsTitleLabel.topAnchor.constraint(equalTo: insightsCard.topAnchor, constant: 20),
            insightsTitleLabel.leadingAnchor.constraint(equalTo: insightsCard.leadingAnchor, constant: 16),
            
            insightsStackView.topAnchor.constraint(equalTo: insightsTitleLabel.bottomAnchor, constant: 16),
            insightsStackView.leadingAnchor.constraint(equalTo: insightsCard.leadingAnchor, constant: 16),
            insightsStackView.trailingAnchor.constraint(equalTo: insightsCard.trailingAnchor, constant: -16),
            insightsStackView.bottomAnchor.constraint(equalTo: insightsCard.bottomAnchor, constant: -20),
            
            // View Calendar & History Button (positioned ABOVE Weekly Insights)
            viewCalendarButton.topAnchor.constraint(equalTo: journalCard.bottomAnchor, constant: 16), // Changed to be after journal card
            viewCalendarButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewCalendarButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            viewCalendarButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Save Button (now positioned below Weekly Insights)
            saveButton.topAnchor.constraint(equalTo: insightsCard.bottomAnchor, constant: 16), // Changed back to insights card
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        // Set up the height constraint for voice journal card
        voiceJournalHeightConstraint = voiceJournalCard.heightAnchor.constraint(equalToConstant: 50)
        voiceJournalHeightConstraint.priority = UILayoutPriority(999) // Lower priority to avoid conflicts
        voiceJournalHeightConstraint.isActive = true
    }
    
    // MARK: - Change Detection
    private func detectChanges() -> Bool {
        // Check if mood selection changed
        if selectedMoodIndex != originalMoodIndex {
            return true
        }
        
        // Check if journal text changed
        let currentJournalText = journalTextView.textColor == UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) ? "" : (journalTextView.text ?? "")
        if currentJournalText != originalJournalText {
            return true
        }
        
        // Check if tags changed
        if selectedTags != originalTags {
            return true
        }
        
        // Check if voice recording changed
        if currentVoiceRecordingPath != originalVoiceRecordingPath {
            return true
        }
        
        return false
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func moodButtonTapped(_ sender: UIButton) {
        // Deselect previous mood
        if let previousIndex = selectedMoodIndex {
            moodButtons[previousIndex].backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
            moodButtons[previousIndex].layer.borderWidth = 0
        }
        
        // Select new mood
        selectedMoodIndex = sender.tag
        sender.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.2)
        sender.layer.borderColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0).cgColor
        sender.layer.borderWidth = 2
        
        updateSaveButtonState()
    }
    
    @objc private func tagButtonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        
        if selectedTags.contains(title) {
            selectedTags.remove(title)
            sender.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
            sender.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
        } else {
            selectedTags.insert(title)
            sender.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.3)
            sender.setTitleColor(UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0), for: .normal)
        }
        
        updateSaveButtonState()
    }
    
    @objc private func saveButtonTapped() {
        guard let selectedIndex = selectedMoodIndex else {
            print("❌ No mood selected")
            return
        }
        
        let selectedMood = moods[selectedIndex]
        let journalText = journalTextView.textColor == UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) ? "" : journalTextView.text
        
        // Save to data manager
        let success = dataManager.saveMoodEntry(
            emoji: selectedMood.0,
            moodLabel: selectedMood.1,
            journalText: journalText ?? "",
            tags: Array(selectedTags),
            voiceRecordingPath: currentVoiceRecordingPath,
            voiceRecordingDuration: Double(totalRecordingSeconds)
        )
        
        if success {
            // Update completion status immediately
            updateCompletionStatus()
            
            // Show success animation or navigate back
            let alert = UIAlertController(title: "Reflection Saved!", message: "Your mood and thoughts have been recorded.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } else {
            // Show error alert
            let alert = UIAlertController(title: "Save Failed", message: "Could not save your mood entry. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: - Voice Journal Actions
    @objc private func voiceJournalHeaderTapped() {
        print("🎙️ Voice Journal Header Tapped!")
        
        // Prevent multiple simultaneous animations
        guard voiceJournalCard.layer.animationKeys()?.isEmpty ?? true else {
            print("⏸️ Animation already in progress, ignoring tap")
            return
        }
        
        isVoiceJournalExpanded.toggle()
        print("📱 Expanded state: \(isVoiceJournalExpanded)")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        voiceJournalHeader.isUserInteractionEnabled = false
        
        // Animate with proper completion handling
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            
            // Update height constraint
            self.voiceJournalHeightConstraint.constant = self.isVoiceJournalExpanded ? 220 : 50
            
            // Rotate chevron
            let rotation = self.isVoiceJournalExpanded ? CGFloat.pi : 0
            self.voiceJournalChevron.transform = CGAffineTransform(rotationAngle: rotation)
            
            // Fade separator and content
            self.voiceJournalSeparator.alpha = self.isVoiceJournalExpanded ? 1 : 0
            self.voiceJournalContentView.alpha = self.isVoiceJournalExpanded ? 1 : 0
            
            // Layout changes
            self.view.layoutIfNeeded()
            
        }) { completed in
            print("🎬 Animation completed: \(completed)")
            
            // Re-enable header interaction
            self.voiceJournalHeader.isUserInteractionEnabled = true
            
            // Ensure content view interaction is properly set
            self.voiceJournalContentView.isUserInteractionEnabled = self.isVoiceJournalExpanded
            
            // Force layout and interaction state
            if self.isVoiceJournalExpanded {
                self.voiceJournalContentView.layoutIfNeeded()
                self.ensureButtonInteraction()
            }
        }
    }
    
    // MARK: - Ensure Button Interaction Helper
    private func ensureButtonInteraction() {
        DispatchQueue.main.async {
            // Force enable all button interactions
            self.recordButton.isUserInteractionEnabled = true
            self.playButton.isUserInteractionEnabled = self.playButton.isEnabled
            self.reRecordButton.isUserInteractionEnabled = self.reRecordButton.isEnabled
            
            // Ensure buttons are properly configured
            self.controlsStackView.isUserInteractionEnabled = true
            
            print("✅ Button interaction ensured - Record: \(self.recordButton.isUserInteractionEnabled), Play: \(self.playButton.isUserInteractionEnabled), Re-record: \(self.reRecordButton.isUserInteractionEnabled)")
        }
    }
    
    // MARK: - Recording Actions
    @objc private func recordButtonTapped() {
        print("🎙️ Record Button Tapped!")
        
        // Immediate haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Stop any current playback first
        if isPlaying {
            stopPlayback()
        }
        
        if isRecording {
            // Stop recording
            voiceManager.stopRecording()
        } else {
            // Start recording
            voiceManager.startRecording()
        }
    }
    
    private func startRecording() {
        print("▶️ Starting recording...")
        
        // Update button appearance
        recordButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        recordButton.backgroundColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 0.3)
        recordButton.tintColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 1.0)
        
        updateButtonStates(recording: true, playing: false, hasRecording: hasRecording)
        
        // Reset and start timer
        recordingSeconds = 0
        recordingTimer?.invalidate() // Ensure no existing timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingSeconds += 1
            self.updateTimerDisplay(seconds: self.recordingSeconds)
        }
        
        // Update UI state
        voiceJournalTitleLabel.text = "Voice Journal • Recording"
        voiceJournalTitleLabel.textColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 1.0)
        
        // Start waveform animation
        waveformView.startAnimating(recordingMode: true)
        
        // Animate record button
        UIView.animate(withDuration: 0.2) {
            self.recordButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    
    private func stopRecording() {
        print("⏹️ Stopping recording...")
        
        // Clean up timer
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Save recording duration and mark as having recording
        totalRecordingSeconds = recordingSeconds
        hasRecording = totalRecordingSeconds > 0
        
        // Update button appearance
        recordButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        recordButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        recordButton.tintColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 1.0)
        
        // Reset button scale
        UIView.animate(withDuration: 0.2) {
            self.recordButton.transform = .identity
        }
        
        // Update button states
        updateButtonStates(recording: false, playing: false, hasRecording: hasRecording)
        
        // Stop waveform animation
        waveformView.stopAnimating()
        
        // Update title
        voiceJournalTitleLabel.text = hasRecording ? "Voice Journal • Ready" : "Voice Journal"
        voiceJournalTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        // Success feedback
        if hasRecording {
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }
        
        print("✅ Recording completed! Duration: \(totalRecordingSeconds) seconds")
    }
    
    @objc private func playButtonTapped() {
        print("▶️ Play Button Tapped!")
        guard hasRecording, let voicePath = currentVoiceRecordingPath else {
            print("❌ No recording to play")
            return
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        if isPlaying {
            voiceManager.stopPlayback()
        } else {
            voiceManager.playRecording(filePath: voicePath)
        }
    }
    
    private func startPlayback() {
        print("▶️ Starting playback...")
        
        // Update button appearance
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playButton.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 0.3)
        playButton.tintColor = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        
        // Update button states
        updateButtonStates(recording: false, playing: true, hasRecording: hasRecording)
        
        // Start playback timer
        recordingSeconds = 0
        playbackTimer?.invalidate() // Ensure no existing timer
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingSeconds += 1
            self.updateTimerDisplay(seconds: self.recordingSeconds)
            
            // Auto-stop when reaching total duration
            if self.recordingSeconds >= self.totalRecordingSeconds {
                self.stopPlayback()
            }
        }
        
        // Start waveform animation
        waveformView.startAnimating(recordingMode: false)
        
        // Update title
        voiceJournalTitleLabel.text = "Voice Journal • Playing"
        voiceJournalTitleLabel.textColor = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        
        // Animate button
        UIView.animate(withDuration: 0.2) {
            self.playButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    
    private func stopPlayback() {
        isPlaying = false
        
        // Clean up timer
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        // Reset button appearance
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        playButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        
        // Reset button scale
        UIView.animate(withDuration: 0.2) {
            self.playButton.transform = .identity
        }
        
        // Update button states
        updateButtonStates(recording: false, playing: false, hasRecording: hasRecording)
        
        // Reset timer to show total duration
        updateTimerDisplay(seconds: totalRecordingSeconds)
        
        // Stop waveform animation
        waveformView.stopAnimating()
        
        // Update title
        voiceJournalTitleLabel.text = "Voice Journal • Ready"
        voiceJournalTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    }
    
    @objc private func reRecordButtonTapped() {
        print("🔄 Re-record Button Tapped!")
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Stop any current operations
        if isPlaying {
            stopPlayback()
        }
        if isRecording {
            recordingTimer?.invalidate()
            recordingTimer = nil
            isRecording = false
        }
        
        // Reset all recording state
        hasRecording = false
        totalRecordingSeconds = 0
        recordingSeconds = 0
        
        // Reset timer display
        updateTimerDisplay(seconds: 0)
        
        // Update button states
        updateButtonStates(recording: false, playing: false, hasRecording: false)
        
        // Reset record button appearance
        recordButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        recordButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        recordButton.tintColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 1.0)
        recordButton.transform = .identity
        
        // Stop waveform
        waveformView.stopAnimating()
        
        // Animate re-record button
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut) {
            self.reRecordButton.transform = CGAffineTransform(rotationAngle: .pi * 2)
        } completion: { _ in
            self.reRecordButton.transform = .identity
        }
        
        // Reset title
        voiceJournalTitleLabel.text = "Voice Journal"
        voiceJournalTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        // Update save button state since recording was cleared
        updateSaveButtonState()
    }
    
    // MARK: - Helper Methods
    private func updateButtonStates(recording: Bool, playing: Bool, hasRecording: Bool) {
        // Record button
        recordButton.isEnabled = !playing
        recordButton.alpha = recordButton.isEnabled ? 1.0 : 0.5
        
        // Play button
        playButton.isEnabled = hasRecording && !recording
        playButton.alpha = playButton.isEnabled ? 1.0 : 0.5
        
        // Re-record button
        reRecordButton.isEnabled = hasRecording && !recording && !playing
        reRecordButton.alpha = reRecordButton.isEnabled ? 1.0 : 0.5
        
        // Ensure interaction is enabled for all buttons
        recordButton.isUserInteractionEnabled = true
        playButton.isUserInteractionEnabled = true
        reRecordButton.isUserInteractionEnabled = true
    }
    
    private func updateTimerDisplay(seconds: Int) {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        timerLabel.text = String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // MARK: - Cleanup
    private func cleanupVoiceJournal() {
        // Stop and invalidate all timers
        recordingTimer?.invalidate()
        recordingTimer = nil
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        // Stop animations
        waveformView.stopAnimating()
        
        // Reset states
        isRecording = false
        isPlaying = false
    }
    
    private func updateSaveButtonState() {
        // For existing entries, enable only if there are changes
        if dataManager.hasTodaysMoodEntry() {
            let hasChanges = detectChanges()
            saveButton.isEnabled = hasChanges
            saveButton.backgroundColor = hasChanges ?
                UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) :
                UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.3)
        } else {
            // For new entries, just check if mood is selected
            let isValid = selectedMoodIndex != nil
            saveButton.isEnabled = isValid
            saveButton.backgroundColor = isValid ?
                UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) :
                UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.3)
        }
    }
}

// MARK: - UITextViewDelegate
extension MoodTrackingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) {
            textView.text = ""
            textView.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Today I feel... because..."
            textView.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        }
        updateSaveButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
    }
}

// MARK: - WaveformView
class WaveformView: UIView {
    
    private var displayLink: CADisplayLink?
    private var phase: CGFloat = 0
    private let recordingColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 0.6)
    private let playbackColor = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.6)
    private let lineWidth: CGFloat = 2.5
    private var isAnimating = false
    private var isRecordingMode = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let path = UIBezierPath()
        let midY = bounds.height / 2
        let baseAmplitude: CGFloat = isAnimating ? (isRecordingMode ? 12 : 8) : 0
        let phaseShift = phase
        
        // Draw waveform or straight line
        path.move(to: CGPoint(x: 0, y: midY))
        
        if isAnimating {
            // Draw more complex waveform
            for x in stride(from: 0, to: bounds.width, by: 1.5) {
                let relativeX = x / bounds.width
                
                // Create multiple sine waves for more realistic effect
                let primaryWave = sin(relativeX * .pi * 6 + phaseShift)
                let secondaryWave = sin(relativeX * .pi * 12 + phaseShift * 0.7) * 0.3
                let tertiaryWave = sin(relativeX * .pi * 18 + phaseShift * 1.3) * 0.15
                
                // Combine waves with slight randomness for recording
                var amplitude = baseAmplitude
                if isRecordingMode {
                    let randomVariation = CGFloat.random(in: 0.7...1.3)
                    amplitude *= randomVariation
                }
                
                let combinedWave = (primaryWave + secondaryWave + tertiaryWave)
                let y = midY + combinedWave * amplitude
                path.addLine(to: CGPoint(x: x, y: y))
            }
        } else {
            // Draw dashed line when not animating
            context.setLineDash(phase: 0, lengths: [4, 4])
            path.addLine(to: CGPoint(x: bounds.width, y: midY))
        }
        
        // Style the path
        let currentColor = isRecordingMode ? recordingColor : playbackColor
        context.setStrokeColor(currentColor.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        // Draw the path
        context.addPath(path.cgPath)
        context.strokePath()
    }
    
    func startAnimating(recordingMode: Bool = true) {
        isAnimating = true
        isRecordingMode = recordingMode
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func stopAnimating() {
        isAnimating = false
        displayLink?.invalidate()
        displayLink = nil
        phase = 0
        setNeedsDisplay()
    }
    
    @objc private func updateWave() {
        // Different animation speeds for recording vs playback
        let speed: CGFloat = isRecordingMode ? 0.18 : 0.12
        phase += speed
        setNeedsDisplay()
    }
    
    deinit {
        displayLink?.invalidate()
    }
}

// MARK: - VoiceRecordingManagerDelegate
extension MoodTrackingViewController: VoiceRecordingManagerDelegate {
    func recordingDidStart() {
        DispatchQueue.main.async {
            self.isRecording = true
            self.startRecording()
        }
    }
    
    func recordingDidStop(success: Bool, filePath: String?, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.isRecording = false
            
            if success, let path = filePath {
                self.currentVoiceRecordingPath = path
                self.totalRecordingSeconds = Int(duration)
                self.hasRecording = true
            } else {
                self.currentVoiceRecordingPath = nil
                self.hasRecording = false
            }
            
            self.stopRecording()
            self.updateSaveButtonState()
        }
    }
    
    func playbackDidStart() {
        DispatchQueue.main.async {
            self.isPlaying = true
            self.startPlayback()
        }
    }
    
    func playbackDidStop() {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.stopPlayback()
        }
    }
    
    func recordingPermissionDenied() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Microphone Permission Required",
                message: "Please allow microphone access in Settings to record voice journals.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }
}
