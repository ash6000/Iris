
import UIKit

// MARK: - Data Models
struct MoodEntry {
    let id: String
    let date: Date
    let emoji: String
    let moodLabel: String
    let journalText: String
    let tags: [String]
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
    }
    

}

struct CalendarDay {
    let date: Date
    let moodEntry: MoodEntry?
    let isCurrentMonth: Bool
    let isToday: Bool
}

enum HistoryFilterPeriod: CaseIterable {
    case thisWeek
    case thisMonth
    case allTime
    
    var title: String {
        switch self {
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .allTime: return "All Time"
        }
    }
}

// MARK: - MoodOverviewViewController
class MoodOverviewViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedSegmentIndex = 0
    private var currentMonth = Date()
    private var selectedFilterPeriod: HistoryFilterPeriod = .thisWeek // Changed to thisWeek to show data by default
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    
    // Custom Tab Switcher
    private let segmentedControl = UISegmentedControl()
    
    // Content Container
    private let calendarView = UIView()
    private let historyView = UIView()
    
    // Calendar Tab Components
    private let monthNavigationView = UIView()
    private let previousMonthButton = UIButton()
    private let monthLabel = UILabel()
    private let nextMonthButton = UIButton()
    private let calendarCollectionView: UICollectionView
    private let calendarMessageLabel = UILabel()
    
    // History Tab Components
    private let filterView = UIView()
    private let filterLabel = UILabel()
    private let filterStackView = UIStackView()
    private var filterButtons: [UIButton] = []
    private let historyTableView = UITableView()
    
    // Data
    private var moodEntries: [MoodEntry] = []
    private var calendarDays: [CalendarDay] = []
    private var groupedEntries: [String: [MoodEntry]] = [:]
    
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Initialize collection view with custom layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupMockData()
//        debugData()
//        setupUI()
//        setupConstraints()
//        setupCollectionView()
//        setupTableView()
//        debugTableViewSetup() // Add this line
//        generateCalendarDays()
//        updateHistoryData()
//        showCalendarTab()
//        
//        // Force a manual check for the History tab
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            print("🔄 Delayed check - switching to history tab for test")
//            self.segmentedControl.selectedSegmentIndex = 1
//            self.segmentChanged(self.segmentedControl)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMockData()
        debugData()
        setupUI()
        setupConstraints()
        setupCollectionView()
        setupTableView()
        debugTableViewSetup()
        generateCalendarDays()
        updateHistoryData()
        showCalendarTab()
        
        // Force layout update to ensure proper sizing
        forceLayoutUpdate()
        
        // Test switching to history tab after layout is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("🔄 Delayed check - switching to history tab for test")
            self.segmentedControl.selectedSegmentIndex = 1
            self.segmentChanged(self.segmentedControl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    
    private func setupMockData() {
        let calendar = Calendar.current
        let today = Date()
        
        print("🔧 Setting up mock data...")
        print("🔧 Today is: \(today)")
        
        moodEntries = [
            // TODAY - to ensure This Week has data
            MoodEntry(
                id: "today",
                date: today,
                emoji: "🌟",
                moodLabel: "Energized",
                journalText: "What an amazing day! Feeling on top of the world today. Everything seems to be going perfectly.",
                tags: ["Energy", "Productivity", "Happiness"]
            ),
            
            // YESTERDAY
            MoodEntry(
                id: "yesterday",
                date: calendar.date(byAdding: .day, value: -1, to: today)!,
                emoji: "🧘",
                moodLabel: "Calm",
                journalText: "Morning meditation really helped center me. Feeling peaceful and ready for whatever comes my way.",
                tags: ["Self-care", "Meditation", "Peace"]
            ),
            
            // 2 DAYS AGO
            MoodEntry(
                id: "2days",
                date: calendar.date(byAdding: .day, value: -2, to: today)!,
                emoji: "🤩",
                moodLabel: "Excited",
                journalText: "Got amazing news about my project! The client loved our proposal and we're moving forward.",
                tags: ["Work", "Achievement", "Success"]
            ),
            
            // 3 DAYS AGO
            MoodEntry(
                id: "3days",
                date: calendar.date(byAdding: .day, value: -3, to: today)!,
                emoji: "😌",
                moodLabel: "Peaceful",
                journalText: "Spent time in nature today at the local park. The fresh air really restored my energy.",
                tags: ["Nature", "Self-care", "Relaxation"]
            ),
            
            // 4 DAYS AGO
            MoodEntry(
                id: "4days",
                date: calendar.date(byAdding: .day, value: -4, to: today)!,
                emoji: "💪",
                moodLabel: "Motivated",
                journalText: "Great workout session this morning! Hit a new personal record. Feeling strong and accomplished.",
                tags: ["Exercise", "Health", "Achievement"]
            ),
            
            // 5 DAYS AGO
            MoodEntry(
                id: "5days",
                date: calendar.date(byAdding: .day, value: -5, to: today)!,
                emoji: "😊",
                moodLabel: "Joyful",
                journalText: "Had lunch with my best friend today. We laughed so much! Grateful for wonderful friendships.",
                tags: ["Social", "Friendship", "Gratitude"]
            ),
            
            // 6 DAYS AGO
            MoodEntry(
                id: "6days",
                date: calendar.date(byAdding: .day, value: -6, to: today)!,
                emoji: "🤔",
                moodLabel: "Thoughtful",
                journalText: "Started reading a fascinating book about psychology. My mind is buzzing with new ideas.",
                tags: ["Learning", "Books", "Growth"]
            ),
            
            // LAST WEEK ENTRIES
            MoodEntry(
                id: "lastweek1",
                date: calendar.date(byAdding: .day, value: -8, to: today)!,
                emoji: "🎉",
                moodLabel: "Celebratory",
                journalText: "My sister got engaged! So happy for her and excited about the upcoming wedding planning.",
                tags: ["Family", "Celebration", "Love"]
            ),
            
            MoodEntry(
                id: "lastweek2",
                date: calendar.date(byAdding: .day, value: -10, to: today)!,
                emoji: "🌈",
                moodLabel: "Hopeful",
                journalText: "Saw the most beautiful rainbow today. It felt like a sign that good things are coming.",
                tags: ["Hope", "Nature", "Optimism"]
            ),
            
            MoodEntry(
                id: "lastweek3",
                date: calendar.date(byAdding: .day, value: -12, to: today)!,
                emoji: "🎨",
                moodLabel: "Creative",
                journalText: "Spent the afternoon painting. Lost track of time completely - that flow state is magical.",
                tags: ["Art", "Creativity", "Flow"]
            ),
            
            // EARLIER THIS MONTH
            MoodEntry(
                id: "earlier1",
                date: calendar.date(byAdding: .day, value: -18, to: today)!,
                emoji: "🧘‍♀️",
                moodLabel: "Centered",
                journalText: "Yoga class was exactly what I needed. Feeling centered and grateful for this practice.",
                tags: ["Exercise", "Self-care", "Balance"]
            ),
            
            MoodEntry(
                id: "earlier2",
                date: calendar.date(byAdding: .day, value: -22, to: today)!,
                emoji: "💡",
                moodLabel: "Inspired",
                journalText: "Had a breakthrough moment during my morning walk. Sometimes the best ideas come when you're not trying.",
                tags: ["Ideas", "Walking", "Innovation"]
            ),
            
            MoodEntry(
                id: "earlier3",
                date: calendar.date(byAdding: .day, value: -25, to: today)!,
                emoji: "🍕",
                moodLabel: "Satisfied",
                journalText: "Perfect lazy Sunday with pizza, movies, and no agenda. Sometimes the best self-care is being unproductive.",
                tags: ["Rest", "Self-care", "Movies"]
            ),
            
            // OLDER ENTRIES (for All Time filter)
            MoodEntry(
                id: "older1",
                date: calendar.date(byAdding: .day, value: -35, to: today)!,
                emoji: "🏆",
                moodLabel: "Accomplished",
                journalText: "Finished my first 10K run! Six months of training paid off. Proud of my dedication.",
                tags: ["Exercise", "Achievement", "Goals"]
            ),
            
            MoodEntry(
                id: "older2",
                date: calendar.date(byAdding: .day, value: -45, to: today)!,
                emoji: "📚",
                moodLabel: "Studious",
                journalText: "Completed an online course on digital marketing. Learning new skills always feels rewarding.",
                tags: ["Learning", "Skills", "Career"]
            )
        ]
        
        // Sort entries by date (newest first)
        moodEntries = moodEntries.sorted { $0.date > $1.date }
        
        print("🔧 Created \(moodEntries.count) mock entries")
        print("🔧 Date range: \(moodEntries.last?.date ?? Date()) to \(moodEntries.first?.date ?? Date())")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        setupHeader()
        setupSegmentedControl()
        setupCalendarTab()
        setupHistoryTab()
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        contentView.addSubview(headerView)
        
        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Mood Overview"
        titleLabel.font = UIFont(name: "Georgia", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
    }
    
    private func setupSegmentedControl() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "Calendar", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "History", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        
        // Style matching RelaxViewController
        segmentedControl.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ], for: .selected)
        
        segmentedControl.layer.cornerRadius = 18
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        contentView.addSubview(segmentedControl)
    }
    
    private func setupCalendarTab() {
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.alpha = 1.0
        contentView.addSubview(calendarView)
        
        // Month Navigation
        setupMonthNavigation()
        
        // Calendar Collection View
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        calendarCollectionView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        calendarCollectionView.layer.cornerRadius = 20
        calendarCollectionView.isScrollEnabled = false
        // Add padding inside the collection view
        calendarCollectionView.contentInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        calendarView.addSubview(calendarCollectionView)
        
        // Message Label
        calendarMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarMessageLabel.text = "Tap on any day with an emoji to view your\nmood entry 💜"
        calendarMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        calendarMessageLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        calendarMessageLabel.textAlignment = .center
        calendarMessageLabel.numberOfLines = 2
        calendarView.addSubview(calendarMessageLabel)
        
        // Motivational message - positioned between month navigation and calendar
        let motivationalLabel = UILabel()
        motivationalLabel.translatesAutoresizingMaskIntoConstraints = false
        motivationalLabel.text = "Your journey of self-awareness is beautiful. Keep\ngrowing! 💜"
        motivationalLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        motivationalLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        motivationalLabel.textAlignment = .center
        motivationalLabel.numberOfLines = 2
        calendarView.addSubview(motivationalLabel)
        
        // Add constraints for motivational message
        NSLayoutConstraint.activate([
            motivationalLabel.topAnchor.constraint(equalTo: monthNavigationView.bottomAnchor, constant: 8),
            motivationalLabel.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            motivationalLabel.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupMonthNavigation() {
        monthNavigationView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(monthNavigationView)
        
        // Previous Month Button
        previousMonthButton.translatesAutoresizingMaskIntoConstraints = false
        previousMonthButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        previousMonthButton.layer.cornerRadius = 20
        previousMonthButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousMonthButton.tintColor = .white
        previousMonthButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        monthNavigationView.addSubview(previousMonthButton)
        
        // Month Label
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = UIFont(name: "Georgia", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        monthLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        monthLabel.textAlignment = .center
        updateMonthLabel()
        monthNavigationView.addSubview(monthLabel)
        
        // Next Month Button
        nextMonthButton.translatesAutoresizingMaskIntoConstraints = false
        nextMonthButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        nextMonthButton.layer.cornerRadius = 20
        nextMonthButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextMonthButton.tintColor = .white
        nextMonthButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        monthNavigationView.addSubview(nextMonthButton)
    }
    
    private func setupHistoryTab() {
        historyView.translatesAutoresizingMaskIntoConstraints = false
        historyView.alpha = 0.0
        contentView.addSubview(historyView)
        
        // Filter Section
        setupFilterSection()
        
        // History Table View
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.backgroundColor = .clear
        historyTableView.separatorStyle = .none
        historyTableView.showsVerticalScrollIndicator = false
        historyView.addSubview(historyTableView)
    }
    
    private func setupFilterSection() {
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        filterView.layer.cornerRadius = 20
        historyView.addSubview(filterView)
        
        // Filter Label
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        filterLabel.text = "📊 View Period"
        filterLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        filterLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        filterView.addSubview(filterLabel)
        
        // Filter Stack View
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        filterStackView.axis = .horizontal
        filterStackView.distribution = .fillEqually
        filterStackView.spacing = 12
        filterView.addSubview(filterStackView)
        
        // Create filter buttons
        for period in HistoryFilterPeriod.allCases {
            let button = createFilterButton(period: period)
            filterButtons.append(button)
            filterStackView.addArrangedSubview(button)
        }
    }
    
    private func createFilterButton(period: HistoryFilterPeriod) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(period.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 16
        button.tag = HistoryFilterPeriod.allCases.firstIndex(of: period) ?? 0
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        
        updateFilterButtonAppearance(button, isSelected: period == selectedFilterPeriod)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return button
    }
    
    private func updateFilterButtonAppearance(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
            button.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
        }
    }
    
    
  
    private func forceLayoutUpdate() {
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            print("🎯 === FORCED LAYOUT UPDATE ===")
            print("🎯 historyView frame after force layout: \(self.historyView.frame)")
            print("🎯 historyTableView frame after force layout: \(self.historyTableView.frame)")
            print("🎯 === FORCED LAYOUT UPDATE END ===")
        }
    }


//    private func debugTableViewSetup() {
//        print("🔧 === TABLE VIEW DEBUG ===")
//        print("🔧 historyTableView delegate: \(historyTableView.delegate != nil ? "SET" : "NIL")")
//        print("🔧 historyTableView dataSource: \(historyTableView.dataSource != nil ? "SET" : "NIL")")
//        print("🔧 historyTableView frame: \(historyTableView.frame)")
//        print("🔧 historyTableView superview: \(historyTableView.superview != nil ? "SET" : "NIL")")
//        print("🔧 === TABLE VIEW DEBUG END ===")
//    }
    
    private func debugTableViewSetup() {
        print("🔧 === TABLE VIEW DEBUG ===")
        print("🔧 historyTableView delegate: \(historyTableView.delegate != nil ? "SET" : "NIL")")
        print("🔧 historyTableView dataSource: \(historyTableView.dataSource != nil ? "SET" : "NIL")")
        print("🔧 historyTableView frame: \(historyTableView.frame)")
        print("🔧 historyTableView superview: \(historyTableView.superview != nil ? "SET" : "NIL")")
        print("🔧 historyView frame: \(historyView.frame)")
        print("🔧 contentView frame: \(contentView.frame)")
        print("🔧 view frame: \(view.frame)")
        
        // Check if table view is actually visible
        print("🔧 historyTableView isHidden: \(historyTableView.isHidden)")
        print("🔧 historyView isHidden: \(historyView.isHidden)")
        print("🔧 historyView alpha: \(historyView.alpha)")
        print("🔧 === TABLE VIEW DEBUG END ===")
    }
    
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        calendarCollectionView.register(CalendarHeaderCell.self, forCellWithReuseIdentifier: "CalendarHeaderCell")
    }
    
    // MARK: - Table View Setup
//    private func setupTableView() {
//        historyTableView.delegate = self
//        historyTableView.dataSource = self
//        historyTableView.register(MoodEntryCell.self, forCellReuseIdentifier: "MoodEntryCell")
//        historyTableView.register(SectionHeaderCell.self, forCellReuseIdentifier: "SectionHeaderCell")
//    }
    
    private func setupTableView() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(MoodEntryCell.self, forCellReuseIdentifier: "MoodEntryCell")
        historyTableView.register(SectionHeaderCell.self, forCellReuseIdentifier: "SectionHeaderCell")
        
        // Add tighter section spacing
        historyTableView.sectionHeaderHeight = 0
        historyTableView.sectionFooterHeight = 0
        historyTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Constraints
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Scroll View
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            
//            // Content View
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            
//            // Header
//            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            headerView.heightAnchor.constraint(equalToConstant: 60),
//            
//            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            backButton.widthAnchor.constraint(equalToConstant: 30),
//            backButton.heightAnchor.constraint(equalToConstant: 30),
//            
//            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
//            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            
//            // Segmented Control
//            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
//            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
//            
//            // Calendar View
//            calendarView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
//            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
//            
//            // Month Navigation
//            monthNavigationView.topAnchor.constraint(equalTo: calendarView.topAnchor),
//            monthNavigationView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
//            monthNavigationView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
//            monthNavigationView.heightAnchor.constraint(equalToConstant: 60),
//            
//            previousMonthButton.leadingAnchor.constraint(equalTo: monthNavigationView.leadingAnchor),
//            previousMonthButton.centerYAnchor.constraint(equalTo: monthNavigationView.centerYAnchor),
//            previousMonthButton.widthAnchor.constraint(equalToConstant: 40),
//            previousMonthButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            monthLabel.centerXAnchor.constraint(equalTo: monthNavigationView.centerXAnchor),
//            monthLabel.centerYAnchor.constraint(equalTo: monthNavigationView.centerYAnchor),
//            
//            nextMonthButton.trailingAnchor.constraint(equalTo: monthNavigationView.trailingAnchor),
//            nextMonthButton.centerYAnchor.constraint(equalTo: monthNavigationView.centerYAnchor),
//            nextMonthButton.widthAnchor.constraint(equalToConstant: 40),
//            nextMonthButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Calendar Collection View - Now positioned below the motivational message
//            calendarCollectionView.topAnchor.constraint(equalTo: monthNavigationView.bottomAnchor, constant: 64), // More space for the message
//            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
//            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
//            calendarCollectionView.heightAnchor.constraint(equalToConstant: 320),
//            
//            // Calendar Message - Better positioning
//            calendarMessageLabel.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 20),
//            calendarMessageLabel.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
//            calendarMessageLabel.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
//            
//            // History View
//            historyView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
//            historyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            historyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            historyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
//            
//            // Filter View
//            filterView.topAnchor.constraint(equalTo: historyView.topAnchor),
//            filterView.leadingAnchor.constraint(equalTo: historyView.leadingAnchor, constant: 16),
//            filterView.trailingAnchor.constraint(equalTo: historyView.trailingAnchor, constant: -16),
//            
//            filterLabel.topAnchor.constraint(equalTo: filterView.topAnchor, constant: 16),
//            filterLabel.leadingAnchor.constraint(equalTo: filterView.leadingAnchor, constant: 16),
//            
//            filterStackView.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 12),
//            filterStackView.leadingAnchor.constraint(equalTo: filterView.leadingAnchor, constant: 16),
//            filterStackView.trailingAnchor.constraint(equalTo: filterView.trailingAnchor, constant: -16),
//            filterStackView.bottomAnchor.constraint(equalTo: filterView.bottomAnchor, constant: -16),
//            
//            // History Table View
//            historyTableView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 16),
//            historyTableView.leadingAnchor.constraint(equalTo: historyView.leadingAnchor, constant: 16),
//            historyTableView.trailingAnchor.constraint(equalTo: historyView.trailingAnchor, constant: -16),
//            historyTableView.bottomAnchor.constraint(equalTo: historyView.bottomAnchor)
//        ])
//    }
    
    // MARK: - Data Methods
    private func generateCalendarDays() {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start,
              let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end else {
            return
        }
        
        guard let startOfCalendar = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start,
              let endOfCalendar = calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .day, value: -1, to: endOfMonth)!)?.end else {
            return
        }
        
        var days: [CalendarDay] = []
        var currentDate = startOfCalendar
        let today = Date()
        
        while currentDate < endOfCalendar {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month)
            let isToday = calendar.isDate(currentDate, equalTo: today, toGranularity: .day)
            
            let moodEntry = moodEntries.first { calendar.isDate($0.date, equalTo: currentDate, toGranularity: .day) }
            
            days.append(CalendarDay(
                date: currentDate,
                moodEntry: moodEntry,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        calendarDays = days
        calendarCollectionView.reloadData()
    }
    

    

    
    private func updateHistoryData() {
        print("🔄 === UPDATING HISTORY DATA ===")
        let filteredEntries = getFilteredEntries()
        print("📊 Filter: \(selectedFilterPeriod.title), Found: \(filteredEntries.count) entries")
        
        // Debug: Print each filtered entry and its weekGroup
        for entry in filteredEntries {
            print("📅 Entry: '\(entry.moodLabel)' (\(entry.dateString)) -> weekGroup: '\(entry.weekGroup)'")
        }
        
        groupedEntries = Dictionary(grouping: filteredEntries) { $0.weekGroup }
        print("📊 Groups created: \(groupedEntries.keys.sorted())")
        
        // Debug: Print contents of each group
        for (groupName, entries) in groupedEntries {
            print("📦 Group '\(groupName)': \(entries.count) entries")
        }
        
        print("📋 Table view sections will be: \(groupedEntries.keys.count)")
        historyTableView.reloadData()
        print("🔄 === HISTORY DATA UPDATE COMPLETE ===")
    }
    

    
    private func getFilteredEntries() -> [MoodEntry] {
        let calendar = Calendar.current
        let today = Date()
        
        print("📊 Filtering for: \(selectedFilterPeriod.title)")
        print("📊 Total entries available: \(moodEntries.count)")
        
        let filtered: [MoodEntry]
        
        switch selectedFilterPeriod {
        case .thisWeek:
            // Get entries from this week (Sunday to Saturday)
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
                print("❌ Could not get week interval for today")
                return []
            }
            
            filtered = moodEntries.filter { entry in
                let isInThisWeek = entry.date >= weekInterval.start && entry.date < weekInterval.end
                if isInThisWeek {
                    print("✅ Entry '\(entry.moodLabel)' from \(entry.dateString) is in this week")
                }
                return isInThisWeek
            }
            
        case .thisMonth:
            // Get entries from this month
            guard let monthInterval = calendar.dateInterval(of: .month, for: today) else {
                print("❌ Could not get month interval for today")
                return []
            }
            
            filtered = moodEntries.filter { entry in
                let isInThisMonth = entry.date >= monthInterval.start && entry.date < monthInterval.end
                if isInThisMonth {
                    print("✅ Entry '\(entry.moodLabel)' from \(entry.dateString) is in this month")
                }
                return isInThisMonth
            }
            
        case .allTime:
            filtered = moodEntries
            print("✅ Showing all \(moodEntries.count) entries for All Time")
        }
        
        print("📊 Filtered result: \(filtered.count) entries")
        return filtered.sorted { $0.date > $1.date } // Sort newest first
    }
    
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: currentMonth)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            if self.selectedSegmentIndex == 0 {
                self.showCalendarTab()
            } else {
                self.showHistoryTab()
            }
        }
    }
    
    private func showCalendarTab() {
        calendarView.alpha = 1.0
        historyView.alpha = 0.0
    }
    
//    private func showHistoryTab() {
//        calendarView.alpha = 0.0
//        historyView.alpha = 1.0
//    }
    // MARK: - Fixed setupConstraints method
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            // Calendar View
            calendarView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Month Navigation
            monthNavigationView.topAnchor.constraint(equalTo: calendarView.topAnchor),
            monthNavigationView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            monthNavigationView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            monthNavigationView.heightAnchor.constraint(equalToConstant: 60),
            
            previousMonthButton.leadingAnchor.constraint(equalTo: monthNavigationView.leadingAnchor),
            previousMonthButton.centerYAnchor.constraint(equalTo: monthNavigationView.centerYAnchor),
            previousMonthButton.widthAnchor.constraint(equalToConstant: 40),
            previousMonthButton.heightAnchor.constraint(equalToConstant: 40),
            
            monthLabel.centerXAnchor.constraint(equalTo: monthNavigationView.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: monthNavigationView.centerYAnchor),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: monthNavigationView.trailingAnchor),
            nextMonthButton.centerYAnchor.constraint(equalTo: monthNavigationView.centerYAnchor),
            nextMonthButton.widthAnchor.constraint(equalToConstant: 40),
            nextMonthButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Calendar Collection View - Now positioned below the motivational message
            calendarCollectionView.topAnchor.constraint(equalTo: monthNavigationView.bottomAnchor, constant: 64), // More space for the message
            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            calendarCollectionView.heightAnchor.constraint(equalToConstant: 320),
            
            // Calendar Message - Better positioning
            calendarMessageLabel.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 20),
            calendarMessageLabel.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            calendarMessageLabel.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            
            // History View - FIXED: Give it proper size constraints
            historyView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
            historyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            historyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            historyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            // CRITICAL: Add explicit height constraint to ensure the view has size
            historyView.heightAnchor.constraint(greaterThanOrEqualToConstant: 500),
            
            // Filter View - FIXED: Better constraints
            filterView.topAnchor.constraint(equalTo: historyView.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: historyView.leadingAnchor, constant: 16),
            filterView.trailingAnchor.constraint(equalTo: historyView.trailingAnchor, constant: -16),
            filterView.heightAnchor.constraint(equalToConstant: 80), // Explicit height
            
            filterLabel.topAnchor.constraint(equalTo: filterView.topAnchor, constant: 16),
            filterLabel.leadingAnchor.constraint(equalTo: filterView.leadingAnchor, constant: 16),
            
            filterStackView.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 12),
            filterStackView.leadingAnchor.constraint(equalTo: filterView.leadingAnchor, constant: 16),
            filterStackView.trailingAnchor.constraint(equalTo: filterView.trailingAnchor, constant: -16),
            filterStackView.bottomAnchor.constraint(equalTo: filterView.bottomAnchor, constant: -16),
            
            // History Table View - FIXED: Proper constraints with explicit height
            historyTableView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 16),
            historyTableView.leadingAnchor.constraint(equalTo: historyView.leadingAnchor, constant: 16),
            historyTableView.trailingAnchor.constraint(equalTo: historyView.trailingAnchor, constant: -16),
            historyTableView.bottomAnchor.constraint(equalTo: historyView.bottomAnchor, constant: -16),
            // CRITICAL: Ensure table view has minimum height
            historyTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400)
        ])
    }

    // MARK: - Enhanced showHistoryTab method with layout debugging
    private func showHistoryTab() {
        calendarView.alpha = 0.0
        historyView.alpha = 1.0
        
        // Force layout update after switching tabs
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // Debug the table view frame after layout
        DispatchQueue.main.async {
            print("🎯 === POST-LAYOUT DEBUG ===")
            print("🎯 historyView frame: \(self.historyView.frame)")
            print("🎯 historyTableView frame: \(self.historyTableView.frame)")
            print("🎯 historyTableView contentSize: \(self.historyTableView.contentSize)")
            print("🎯 === POST-LAYOUT DEBUG END ===")
            
            // Force table view reload after layout
            self.historyTableView.reloadData()
        }
    }
    
    @objc private func previousMonthTapped() {
        let calendar = Calendar.current
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
        updateMonthLabel()
        generateCalendarDays()
    }
    
    @objc private func nextMonthTapped() {
        let calendar = Calendar.current
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        updateMonthLabel()
        generateCalendarDays()
    }
    

    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        let newPeriod = HistoryFilterPeriod.allCases[sender.tag]
        selectedFilterPeriod = newPeriod
        
        print("🔄 Filter changed to: \(newPeriod.title)")
        
        // Update button appearances
        for (index, button) in filterButtons.enumerated() {
            updateFilterButtonAppearance(button, isSelected: index == sender.tag)
        }
        
        updateHistoryData()
    }
    
    
    private func debugData() {
        print("🐛 DEBUG: Total mock entries created: \(moodEntries.count)")
        print("🐛 DEBUG: Selected filter period: \(selectedFilterPeriod.title)")
        
        let today = Date()
        let calendar = Calendar.current
        
        print("🐛 DEBUG: Today is: \(DateFormatter().string(from: today))")
        
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
            print("🐛 DEBUG: This week spans: \(DateFormatter().string(from: weekInterval.start)) to \(DateFormatter().string(from: weekInterval.end))")
        }
        
        // Print first few entries
        for (index, entry) in moodEntries.prefix(5).enumerated() {
            print("🐛 DEBUG: Entry \(index): \(entry.moodLabel) - \(DateFormatter().string(from: entry.date))")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MoodOverviewViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Header row + calendar days
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 7 // Days of week
        } else {
            return calendarDays.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarHeaderCell", for: indexPath) as! CalendarHeaderCell
            let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            cell.configure(with: dayNames[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
            cell.configure(with: calendarDays[indexPath.item])
            return cell
        }
    }
}

extension MoodEntry {
    var weekGroup: String {
        let calendar = Calendar.current
        let today = Date()
        
        print("🗓️ Calculating weekGroup for '\(moodLabel)' on \(dateString)")
        
        // Check if it's in the current week
        if let thisWeekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
            print("🗓️ This week interval: \(thisWeekInterval.start) to \(thisWeekInterval.end)")
            if date >= thisWeekInterval.start && date < thisWeekInterval.end {
                print("✅ Entry is in This Week")
                return "This Week"
            }
        }
        
        // Check if it's in the previous week
        if let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today),
           let lastWeekInterval = calendar.dateInterval(of: .weekOfYear, for: lastWeek) {
            print("🗓️ Last week interval: \(lastWeekInterval.start) to \(lastWeekInterval.end)")
            if date >= lastWeekInterval.start && date < lastWeekInterval.end {
                print("✅ Entry is in Last Week")
                return "Last Week"
            }
        }
        
        // Check if it's earlier this month
        if let thisMonthInterval = calendar.dateInterval(of: .month, for: today),
           let thisWeekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
            print("🗓️ This month interval: \(thisMonthInterval.start) to \(thisMonthInterval.end)")
            print("🗓️ Checking if \(date) is between \(thisMonthInterval.start) and \(thisWeekInterval.start)")
            if date >= thisMonthInterval.start && date < thisWeekInterval.start {
                print("✅ Entry is in Earlier This Month")
                return "Earlier This Month"
            }
        }
        
        // For older entries, group by month
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthYear = formatter.string(from: date)
        print("✅ Entry is in older month: \(monthYear)")
        return monthYear
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MoodOverviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate proper cell size accounting for content insets
        let totalWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let cellWidth = totalWidth / 7
        
        if indexPath.section == 0 {
            // Header cells (days of week)
            return CGSize(width: cellWidth, height: 35)
        } else {
            // Calendar day cells - taller for better emoji visibility
            return CGSize(width: cellWidth, height: 42)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 8 : 4 // More space between header and calendar, less between calendar rows
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // No horizontal spacing to maintain 7-column grid
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        
        let day = calendarDays[indexPath.item]
        if let moodEntry = day.moodEntry {
            // Navigate to MoodDetailViewController (simulate for now)
            print("Navigate to mood detail for: \(moodEntry.moodLabel) on \(moodEntry.dateString)")
            
            // TODO: Push to MoodDetailViewController
            let alert = UIAlertController(
                title: "\(moodEntry.emoji) \(moodEntry.moodLabel)",
                message: "\(moodEntry.dateString)\n\n\(moodEntry.journalText)\n\nTags: \(moodEntry.tags.joined(separator: ", "))",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}


extension MoodOverviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = groupedEntries.keys.count
        print("📋 numberOfSections called: returning \(sections)")
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedKeys = getSortedGroupKeys()
        print("📋 numberOfRowsInSection called for section \(section)")
        print("📋 sortedKeys: \(sortedKeys)")
        
        if section >= sortedKeys.count {
            print("❌ Section \(section) is out of bounds for sortedKeys count \(sortedKeys.count)")
            return 0
        }
        
        let sectionKey = sortedKeys[section]
        let entryCount = groupedEntries[sectionKey]?.count ?? 0
        let totalRows = entryCount + 1 // +1 for header
        print("📋 Section '\(sectionKey)' has \(entryCount) entries, returning \(totalRows) rows")
        return totalRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("📋 cellForRowAt called: section \(indexPath.section), row \(indexPath.row)")
        
        let sortedKeys = getSortedGroupKeys()
        
        if indexPath.section >= sortedKeys.count {
            print("❌ Section out of bounds in cellForRowAt")
            return UITableViewCell()
        }
        
        let sectionKey = sortedKeys[indexPath.section]
        print("📋 Processing section '\(sectionKey)'")
        
        if indexPath.row == 0 {
            // Section header
            print("📋 Creating section header for '\(sectionKey)'")
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell", for: indexPath) as! SectionHeaderCell
            cell.configure(with: sectionKey)
            return cell
        } else {
            // Mood entry
            guard let entries = groupedEntries[sectionKey] else {
                print("❌ No entries found for section '\(sectionKey)'")
                return UITableViewCell()
            }
            
            let sortedEntries = entries.sorted { $0.date > $1.date }
            let entryIndex = indexPath.row - 1
            
            if entryIndex >= sortedEntries.count {
                print("❌ Entry index \(entryIndex) out of bounds for \(sortedEntries.count) entries")
                return UITableViewCell()
            }
            
            let entry = sortedEntries[entryIndex]
            print("📋 Creating mood entry cell for '\(entry.moodLabel)'")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoodEntryCell", for: indexPath) as! MoodEntryCell
            cell.configure(with: entry)
            return cell
        }
    }
    
    private func getSortedGroupKeys() -> [String] {
        let keys = groupedEntries.keys.sorted { key1, key2 in
            if key1 == "This Week" { return true }
            if key2 == "This Week" { return false }
            if key1 == "Last Week" { return true }
            if key2 == "Last Week" { return false }
            if key1 == "Earlier This Month" { return true }
            if key2 == "Earlier This Month" { return false }
            return key1 > key2
        }
        print("📋 getSortedGroupKeys: \(keys)")
        return keys
    }
}



// MARK: - UITableViewDelegate
//extension MoodOverviewViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return indexPath.row == 0 ? 50 : 120
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        guard indexPath.row > 0 else { return }
//        
//        let sortedKeys = getSortedGroupKeys()
//        let sectionKey = sortedKeys[indexPath.section]
//        let entries = groupedEntries[sectionKey]!.sorted { $0.date > $1.date }
//        let moodEntry = entries[indexPath.row - 1]
//        
//        // Navigate to MoodDetailViewController (simulate for now)
//        print("Navigate to mood detail for: \(moodEntry.moodLabel)")
//        
//        // TODO: Push to MoodDetailViewController
//        let alert = UIAlertController(
//            title: "\(moodEntry.emoji) \(moodEntry.moodLabel)",
//            message: "\(moodEntry.dateString)\n\n\(moodEntry.journalText)\n\nTags: \(moodEntry.tags.joined(separator: ", "))",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//extension MoodOverviewViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        // Make section headers smaller and mood entries more compact
//        return indexPath.row == 0 ? 45 : 100 // Reduced from 50 and 120
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        guard indexPath.row > 0 else { return }
//        
//        let sortedKeys = getSortedGroupKeys()
//        let sectionKey = sortedKeys[indexPath.section]
//        let entries = groupedEntries[sectionKey]!.sorted { $0.date > $1.date }
//        let moodEntry = entries[indexPath.row - 1]
//        
//        // Navigate to MoodDetailViewController (simulate for now)
//        print("Navigate to mood detail for: \(moodEntry.moodLabel)")
//        
//        // TODO: Push to MoodDetailViewController
//        let alert = UIAlertController(
//            title: "\(moodEntry.emoji) \(moodEntry.moodLabel)",
//            message: "\(moodEntry.dateString)\n\n\(moodEntry.journalText)\n\nTags: \(moodEntry.tags.joined(separator: ", "))",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//extension MoodOverviewViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        // Increase mood entry height to allow more internal space, keep section headers compact
//        return indexPath.row == 0 ? 45 : 115 // Increased mood entries from 100 to 115
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        guard indexPath.row > 0 else { return }
//        
//        let sortedKeys = getSortedGroupKeys()
//        let sectionKey = sortedKeys[indexPath.section]
//        let entries = groupedEntries[sectionKey]!.sorted { $0.date > $1.date }
//        let moodEntry = entries[indexPath.row - 1]
//        
//        // Navigate to MoodDetailViewController (simulate for now)
//        print("Navigate to mood detail for: \(moodEntry.moodLabel)")
//        
//        // TODO: Push to MoodDetailViewController
//        let alert = UIAlertController(
//            title: "\(moodEntry.emoji) \(moodEntry.moodLabel)",
//            message: "\(moodEntry.dateString)\n\n\(moodEntry.journalText)\n\nTags: \(moodEntry.tags.joined(separator: ", "))",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//extension MoodOverviewViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        // Increase height even more to ensure journal text and tags are fully visible
//        return indexPath.row == 0 ? 45 : 130 // Increased from 115 to 130
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        guard indexPath.row > 0 else { return }
//        
//        let sortedKeys = getSortedGroupKeys()
//        let sectionKey = sortedKeys[indexPath.section]
//        let entries = groupedEntries[sectionKey]!.sorted { $0.date > $1.date }
//        let moodEntry = entries[indexPath.row - 1]
//        
//        // Navigate to MoodDetailViewController (simulate for now)
//        print("Navigate to mood detail for: \(moodEntry.moodLabel)")
//        
//        // TODO: Push to MoodDetailViewController
//        let alert = UIAlertController(
//            title: "\(moodEntry.emoji) \(moodEntry.moodLabel)",
//            message: "\(moodEntry.dateString)\n\n\(moodEntry.journalText)\n\nTags: \(moodEntry.tags.joined(separator: ", "))",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
 //MARK: - Update cell height for the new design
extension MoodOverviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Increased height to accommodate the beautiful new design
        return indexPath.row == 0 ? 50 : 145 // More height for better spacing
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row > 0 else { return }
        
        let sortedKeys = getSortedGroupKeys()
        let sectionKey = sortedKeys[indexPath.section]
        let entries = groupedEntries[sectionKey]!.sorted { $0.date > $1.date }
        let moodEntry = entries[indexPath.row - 1]
        
        // Navigate to MoodDetailViewController (simulate for now)
        print("Navigate to mood detail for: \(moodEntry.moodLabel)")
        
        let alert = UIAlertController(
            title: "\(moodEntry.emoji) \(moodEntry.moodLabel)",
            message: "\(moodEntry.dateString)\n\n\(moodEntry.journalText)\n\nTags: \(moodEntry.tags.joined(separator: ", "))",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}




// MARK: - Custom Cells

// Calendar Header Cell (Days of Week)
class CalendarHeaderCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dayLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        dayLabel.textAlignment = .center
        contentView.addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with day: String) {
        dayLabel.text = day
    }
}

// Calendar Day Cell
class CalendarDayCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let moodEmojiLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dayLabel.textAlignment = .center
        contentView.addSubview(dayLabel)
        
        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        moodEmojiLabel.font = UIFont.systemFont(ofSize: 14) // Slightly larger emoji
        moodEmojiLabel.textAlignment = .center
        contentView.addSubview(moodEmojiLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4), // Better spacing
            
            moodEmojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moodEmojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4) // Better spacing
        ])
    }
    
    func configure(with day: CalendarDay) {
        let calendar = Calendar.current
        let dayNumber = calendar.component(.day, from: day.date)
        dayLabel.text = "\(dayNumber)"
        
        // Style based on state
        if day.isToday {
            contentView.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.3)
            contentView.layer.cornerRadius = 8
            dayLabel.textColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
            dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        } else if day.isCurrentMonth {
            contentView.backgroundColor = .clear
            dayLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        } else {
            contentView.backgroundColor = .clear
            dayLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }
        
        // Show mood emoji if available
        if let moodEntry = day.moodEntry {
            moodEmojiLabel.text = moodEntry.emoji
        } else {
            moodEmojiLabel.text = ""
        }
    }
}

// Section Header Cell
//class SectionHeaderCell: UITableViewCell {
//    private let titleLabel = UILabel()
//    private let iconView = UIImageView()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupCell() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        iconView.image = UIImage(systemName: "calendar")
//        iconView.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        contentView.addSubview(iconView)
//        
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        titleLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
//        contentView.addSubview(titleLabel)
//        
//        NSLayoutConstraint.activate([
//            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
//            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            iconView.widthAnchor.constraint(equalToConstant: 20),
//            iconView.heightAnchor.constraint(equalToConstant: 20),
//            
//            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
//            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
//        ])
//    }
//    
//    func configure(with title: String) {
//        titleLabel.text = title
//    }
//}

class SectionHeaderCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let iconView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "calendar")
        iconView.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        contentView.addSubview(iconView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold) // Slightly smaller
        titleLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4), // Reduced padding
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18), // Slightly smaller
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6), // Reduced spacing
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}

// Mood Entry Cell
//class MoodEntryCell: UITableViewCell {
//    private let cardView = UIView()
//    private let moodEmojiLabel = UILabel()
//    private let moodTitleLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let journalLabel = UILabel()
//    private let tagsStackView = UIStackView()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupCell() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        cardView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
//        cardView.layer.cornerRadius = 16
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.05
//        cardView.layer.shadowRadius = 4
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        contentView.addSubview(cardView)
//        
//        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodEmojiLabel.font = UIFont.systemFont(ofSize: 32)
//        moodEmojiLabel.textAlignment = .center
//        cardView.addSubview(moodEmojiLabel)
//        
//        moodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        moodTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        cardView.addSubview(moodTitleLabel)
//        
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        dateLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        cardView.addSubview(dateLabel)
//        
//        journalLabel.translatesAutoresizingMaskIntoConstraints = false
//        journalLabel.font = UIFont.systemFont(ofSize: 15)
//        journalLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
//        journalLabel.numberOfLines = 2
//        cardView.addSubview(journalLabel)
//        
//        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
//        tagsStackView.axis = .horizontal
//        tagsStackView.spacing = 6
//        tagsStackView.alignment = .leading
//        cardView.addSubview(tagsStackView)
//        
//        NSLayoutConstraint.activate([
//            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
//            
//            moodEmojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
//            moodEmojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            moodEmojiLabel.widthAnchor.constraint(equalToConstant: 40),
//            
//            moodTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
//            moodTitleLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 12),
//            moodTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            
//            dateLabel.topAnchor.constraint(equalTo: moodTitleLabel.bottomAnchor, constant: 2),
//            dateLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 12),
//            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            
//            journalLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
//            journalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            journalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            
//            tagsStackView.topAnchor.constraint(equalTo: journalLabel.bottomAnchor, constant: 8),
//            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            tagsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            tagsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
//        ])
//    }
//    
//    func configure(with entry: MoodEntry) {
//        moodEmojiLabel.text = entry.emoji
//        moodTitleLabel.text = entry.moodLabel
//        dateLabel.text = entry.dateString
//        journalLabel.text = entry.journalText
//        
//        // Clear existing tags
//        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        // Add tag labels
//        for tag in entry.tags.prefix(3) { // Show max 3 tags
//            let tagLabel = UILabel()
//            tagLabel.text = tag
//            tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//            tagLabel.textColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
//            tagLabel.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.2)
//            tagLabel.layer.cornerRadius = 8
//            tagLabel.textAlignment = .center
//            tagLabel.layer.masksToBounds = true
//            tagLabel.setContentHuggingPriority(.required, for: .horizontal)
//            
//            // Add padding
//            tagLabel.translatesAutoresizingMaskIntoConstraints = false
//            let containerView = UIView()
//            containerView.addSubview(tagLabel)
//            
//            NSLayoutConstraint.activate([
//                tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
//                tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
//                tagLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
//                tagLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
//            ])
//            
//            tagsStackView.addArrangedSubview(containerView)
//        }
//    }
//}

//class MoodEntryCell: UITableViewCell {
//    private let cardView = UIView()
//    private let moodEmojiLabel = UILabel()
//    private let moodTitleLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let journalLabel = UILabel()
//    private let tagsStackView = UIStackView()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupCell() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        cardView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
//        cardView.layer.cornerRadius = 16
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.05
//        cardView.layer.shadowRadius = 4
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        contentView.addSubview(cardView)
//        
//        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodEmojiLabel.font = UIFont.systemFont(ofSize: 28) // Slightly smaller emoji
//        moodEmojiLabel.textAlignment = .center
//        cardView.addSubview(moodEmojiLabel)
//        
//        moodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold) // Smaller title
//        moodTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        cardView.addSubview(moodTitleLabel)
//        
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium) // Smaller date
//        dateLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        cardView.addSubview(dateLabel)
//        
//        journalLabel.translatesAutoresizingMaskIntoConstraints = false
//        journalLabel.font = UIFont.systemFont(ofSize: 14) // Smaller journal text
//        journalLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
//        journalLabel.numberOfLines = 2
//        cardView.addSubview(journalLabel)
//        
//        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
//        tagsStackView.axis = .horizontal
//        tagsStackView.spacing = 4 // Tighter tag spacing
//        tagsStackView.alignment = .leading
//        cardView.addSubview(tagsStackView)
//        
//        NSLayoutConstraint.activate([
//            // Much tighter card margins - closer to mockup
//            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2), // Reduced from 4
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2), // Reduced from -4
//            
//            // Tighter internal spacing
//            moodEmojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8), // Reduced from 12
//            moodEmojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12), // Reduced from 16
//            moodEmojiLabel.widthAnchor.constraint(equalToConstant: 36), // Reduced from 40
//            
//            moodTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8), // Reduced from 12
//            moodTitleLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 8), // Reduced from 12
//            moodTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12), // Reduced from -16
//            
//            dateLabel.topAnchor.constraint(equalTo: moodTitleLabel.bottomAnchor, constant: 1), // Tighter spacing
//            dateLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 8),
//            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
//            
//            journalLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4), // Reduced from 8
//            journalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12), // Reduced from 16
//            journalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12), // Reduced from -16
//            
//            tagsStackView.topAnchor.constraint(equalTo: journalLabel.bottomAnchor, constant: 4), // Reduced from 8
//            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12), // Reduced from 16
//            tagsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12), // Reduced from -16
//            tagsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8) // Reduced from -12
//        ])
//    }
//    
//    func configure(with entry: MoodEntry) {
//        moodEmojiLabel.text = entry.emoji
//        moodTitleLabel.text = entry.moodLabel
//        dateLabel.text = entry.dateString
//        journalLabel.text = entry.journalText
//        
//        // Clear existing tags
//        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        // Add tag labels with tighter spacing
//        for tag in entry.tags.prefix(3) { // Show max 3 tags
//            let tagLabel = UILabel()
//            tagLabel.text = tag
//            tagLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium) // Smaller tags
//            tagLabel.textColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
//            tagLabel.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.2)
//            tagLabel.layer.cornerRadius = 6 // Smaller corner radius
//            tagLabel.textAlignment = .center
//            tagLabel.layer.masksToBounds = true
//            tagLabel.setContentHuggingPriority(.required, for: .horizontal)
//            
//            // Tighter tag padding
//            tagLabel.translatesAutoresizingMaskIntoConstraints = false
//            let containerView = UIView()
//            containerView.addSubview(tagLabel)
//            
//            NSLayoutConstraint.activate([
//                tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2), // Reduced from 4
//                tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6), // Reduced from 8
//                tagLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6), // Reduced from -8
//                tagLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2) // Reduced from -4
//            ])
//            
//            tagsStackView.addArrangedSubview(containerView)
//        }
//    }
//}

//class MoodEntryCell: UITableViewCell {
//    private let cardView = UIView()
//    private let moodEmojiLabel = UILabel()
//    private let moodTitleLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let journalLabel = UILabel()
//    private let tagsStackView = UIStackView()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupCell() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        cardView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
//        cardView.layer.cornerRadius = 16
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.05
//        cardView.layer.shadowRadius = 4
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        contentView.addSubview(cardView)
//        
//        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodEmojiLabel.font = UIFont.systemFont(ofSize: 32) // Back to larger emoji like mockup
//        moodEmojiLabel.textAlignment = .center
//        cardView.addSubview(moodEmojiLabel)
//        
//        moodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold) // Larger title like mockup
//        moodTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        cardView.addSubview(moodTitleLabel)
//        
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium) // Larger date like mockup
//        dateLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        cardView.addSubview(dateLabel)
//        
//        journalLabel.translatesAutoresizingMaskIntoConstraints = false
//        journalLabel.font = UIFont.systemFont(ofSize: 15) // Back to larger journal text
//        journalLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
//        journalLabel.numberOfLines = 2
//        cardView.addSubview(journalLabel)
//        
//        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
//        tagsStackView.axis = .horizontal
//        tagsStackView.spacing = 8 // More generous tag spacing like mockup
//        tagsStackView.alignment = .leading
//        cardView.addSubview(tagsStackView)
//        
//        NSLayoutConstraint.activate([
//            // Keep cards close together vertically but add more internal space
//            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
//            
//            // More generous internal spacing like the mockup
//            moodEmojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16), // Increased from 8
//            moodEmojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16), // Increased from 12
//            moodEmojiLabel.widthAnchor.constraint(equalToConstant: 40), // Back to original size
//            
//            moodTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16), // Increased from 8
//            moodTitleLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 12), // More space
//            moodTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16), // More margin
//            
//            dateLabel.topAnchor.constraint(equalTo: moodTitleLabel.bottomAnchor, constant: 2), // Small space between title and date
//            dateLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 12),
//            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            
//            journalLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8), // More space before journal
//            journalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16), // More margin
//            journalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16), // More margin
//            
//            tagsStackView.topAnchor.constraint(equalTo: journalLabel.bottomAnchor, constant: 8), // More space before tags
//            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16), // More margin
//            tagsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16), // More margin
//            tagsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16) // More bottom margin
//        ])
//    }
//    
//    func configure(with entry: MoodEntry) {
//        moodEmojiLabel.text = entry.emoji
//        moodTitleLabel.text = entry.moodLabel
//        dateLabel.text = entry.dateString
//        journalLabel.text = entry.journalText
//        
//        // Clear existing tags
//        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        // Add tag labels with more generous spacing like the mockup
//        for tag in entry.tags.prefix(3) { // Show max 3 tags
//            let tagLabel = UILabel()
//            tagLabel.text = tag
//            tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium) // Slightly larger tags
//            tagLabel.textColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
//            tagLabel.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.2)
//            tagLabel.layer.cornerRadius = 8 // Back to larger corner radius
//            tagLabel.textAlignment = .center
//            tagLabel.layer.masksToBounds = true
//            tagLabel.setContentHuggingPriority(.required, for: .horizontal)
//            
//            // More generous tag padding like the mockup
//            tagLabel.translatesAutoresizingMaskIntoConstraints = false
//            let containerView = UIView()
//            containerView.addSubview(tagLabel)
//            
//            NSLayoutConstraint.activate([
//                tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4), // More padding
//                tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8), // More padding
//                tagLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8), // More padding
//                tagLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4) // More padding
//            ])
//            
//            tagsStackView.addArrangedSubview(containerView)
//        }
//    }
//}

//class MoodEntryCell: UITableViewCell {
//    private let cardView = UIView()
//    private let moodEmojiLabel = UILabel()
//    private let moodTitleLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let journalLabel = UILabel()
//    private let tagsStackView = UIStackView()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupCell() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        cardView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
//        cardView.layer.cornerRadius = 16
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.05
//        cardView.layer.shadowRadius = 4
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        contentView.addSubview(cardView)
//        
//        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodEmojiLabel.font = UIFont.systemFont(ofSize: 32)
//        moodEmojiLabel.textAlignment = .center
//        cardView.addSubview(moodEmojiLabel)
//        
//        moodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        moodTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        cardView.addSubview(moodTitleLabel)
//        
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        dateLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        cardView.addSubview(dateLabel)
//        
//        // FIXED: Make journal text more prominent and ensure it shows
//        journalLabel.translatesAutoresizingMaskIntoConstraints = false
//        journalLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular) // Slightly bolder
//        journalLabel.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) // Darker for better visibility
//        journalLabel.numberOfLines = 2
//        journalLabel.lineBreakMode = .byTruncatingTail
//        cardView.addSubview(journalLabel)
//        
//        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
//        tagsStackView.axis = .horizontal
//        tagsStackView.spacing = 8
//        tagsStackView.alignment = .leading
//        cardView.addSubview(tagsStackView)
//        
//        NSLayoutConstraint.activate([
//            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
//            
//            moodEmojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
//            moodEmojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            moodEmojiLabel.widthAnchor.constraint(equalToConstant: 40),
//            
//            moodTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
//            moodTitleLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 12),
//            moodTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            
//            dateLabel.topAnchor.constraint(equalTo: moodTitleLabel.bottomAnchor, constant: 2),
//            dateLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 12),
//            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            
//            // FIXED: Ensure journal label has proper constraints and visibility
//            journalLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10), // More space from date
//            journalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            journalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            
//            tagsStackView.topAnchor.constraint(equalTo: journalLabel.bottomAnchor, constant: 10), // More space from journal
//            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            tagsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            tagsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
//        ])
//    }
//    
//    func configure(with entry: MoodEntry) {
//        moodEmojiLabel.text = entry.emoji
//        moodTitleLabel.text = entry.moodLabel
//        dateLabel.text = entry.dateString
//        
//        // FIXED: Ensure journal text is set and visible
//        journalLabel.text = entry.journalText
//        print("🔍 Setting journal text: '\(entry.journalText)' for entry: \(entry.moodLabel)")
//        
//        // Clear existing tags
//        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        // FIXED: Make tags much more visible with better contrast
//        for tag in entry.tags.prefix(3) {
//            let tagLabel = UILabel()
//            tagLabel.text = tag
//            tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold) // Bolder font
//            tagLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) // Much darker text
//            tagLabel.backgroundColor = UIColor(red: 0.75, green: 0.6, blue: 0.7, alpha: 0.4) // More opaque background
//            tagLabel.layer.cornerRadius = 8
//            tagLabel.textAlignment = .center
//            tagLabel.layer.masksToBounds = true
//            tagLabel.setContentHuggingPriority(.required, for: .horizontal)
//            
//            // Add subtle border for more definition
//            tagLabel.layer.borderWidth = 0.5
//            tagLabel.layer.borderColor = UIColor(red: 0.65, green: 0.5, blue: 0.6, alpha: 0.6).cgColor
//            
//            tagLabel.translatesAutoresizingMaskIntoConstraints = false
//            let containerView = UIView()
//            containerView.addSubview(tagLabel)
//            
//            NSLayoutConstraint.activate([
//                tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
//                tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10), // More horizontal padding
//                tagLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
//                tagLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
//            ])
//            
//            tagsStackView.addArrangedSubview(containerView)
//        }
//        
//        // Force layout update to ensure everything shows
//        setNeedsLayout()
//        layoutIfNeeded()
//    }
//}

//class MoodEntryCell: UITableViewCell {
//    private let cardView = UIView()
//    private let moodEmojiLabel = UILabel()
//    private let moodTitleLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let journalLabel = UILabel()
//    private let tagsStackView = UIStackView()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupCell() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        
//        // Card view with soft shadow and rounded corners like screenshot
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        cardView.backgroundColor = UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0) // Soft beige like screenshot
//        cardView.layer.cornerRadius = 20 // More rounded like screenshot
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.08 // Soft shadow
//        cardView.layer.shadowRadius = 8
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
//        contentView.addSubview(cardView)
//        
//        // Emoji - positioned like screenshot
//        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodEmojiLabel.font = UIFont.systemFont(ofSize: 32)
//        moodEmojiLabel.textAlignment = .center
//        cardView.addSubview(moodEmojiLabel)
//        
//        // Mood title - clean and prominent like screenshot
//        moodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        moodTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold) // Slightly larger like screenshot
//        moodTitleLabel.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // Dark text
//        cardView.addSubview(moodTitleLabel)
//        
//        // Date - subtle gray like screenshot
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium) // Clean readable size
//        dateLabel.textColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0) // Medium gray
//        cardView.addSubview(dateLabel)
//        
//        // Journal text - readable and well-spaced like screenshot
//        journalLabel.translatesAutoresizingMaskIntoConstraints = false
//        journalLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular) // Good readable size
//        journalLabel.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) // Dark enough to read easily
//        journalLabel.numberOfLines = 3 // Allow more lines like screenshot
//        journalLabel.lineBreakMode = .byTruncatingTail
//        cardView.addSubview(journalLabel)
//        
//        // Tags stack view - horizontal layout like screenshot
//        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
//        tagsStackView.axis = .horizontal
//        tagsStackView.spacing = 10 // Nice spacing between tags
//        tagsStackView.alignment = .leading
//        cardView.addSubview(tagsStackView)
//        
//        NSLayoutConstraint.activate([
//            // Card with generous margins like screenshot
//            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6), // More space between cards
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
//            
//            // Emoji positioning like screenshot
//            moodEmojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
//            moodEmojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
//            moodEmojiLabel.widthAnchor.constraint(equalToConstant: 44),
//            moodEmojiLabel.heightAnchor.constraint(equalToConstant: 44),
//            
//            // Title next to emoji like screenshot
//            moodTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
//            moodTitleLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 15),
//            moodTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
//            
//            // Date below title like screenshot
//            dateLabel.topAnchor.constraint(equalTo: moodTitleLabel.bottomAnchor, constant: 3),
//            dateLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 15),
//            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
//            
//            // Journal text with good spacing like screenshot
//            journalLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
//            journalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
//            journalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
//            
//            // Tags at bottom like screenshot
//            tagsStackView.topAnchor.constraint(equalTo: journalLabel.bottomAnchor, constant: 16),
//            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
//            tagsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
//            tagsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
//        ])
//    }
//    
//    func configure(with entry: MoodEntry) {
//        moodEmojiLabel.text = entry.emoji
//        moodTitleLabel.text = entry.moodLabel
//        dateLabel.text = entry.dateString
//        journalLabel.text = entry.journalText
//        
//        // Clear existing tags
//        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        // Create beautiful pill-shaped tags like screenshot
//        let tagColors: [(background: UIColor, text: UIColor)] = [
//            // Soft beige/brown tones like screenshot
//            (UIColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 0.7), UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)),
//            // Soft purple/pink tones like screenshot
//            (UIColor(red: 0.82, green: 0.7, blue: 0.78, alpha: 0.7), UIColor(red: 0.4, green: 0.25, blue: 0.35, alpha: 1.0)),
//            // Another soft beige variation
//            (UIColor(red: 0.88, green: 0.82, blue: 0.72, alpha: 0.7), UIColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0))
//        ]
//        
//        for (index, tag) in entry.tags.prefix(3).enumerated() {
//            let tagButton = UIButton(type: .custom)
//            tagButton.setTitle(tag, for: .normal)
//            tagButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
//            
//            // Use different colors for variety like screenshot
//            let colorPair = tagColors[index % tagColors.count]
//            tagButton.backgroundColor = colorPair.background
//            tagButton.setTitleColor(colorPair.text, for: .normal)
//            
//            // Perfect pill shape like screenshot
//            tagButton.layer.cornerRadius = 14
//            tagButton.contentEdgeInsets = UIEdgeInsets(top: 8, left:16, bottom: 8, right: 16)
//            
//            // Subtle shadow for depth
//            tagButton.layer.shadowColor = UIColor.black.cgColor
//            tagButton.layer.shadowOpacity = 0.05
//            tagButton.layer.shadowRadius = 2
//            tagButton.layer.shadowOffset = CGSize(width: 0, height: 1)
//            
//            tagButton.translatesAutoresizingMaskIntoConstraints = false
//            tagButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
//            
//            tagsStackView.addArrangedSubview(tagButton)
//        }
//        
//        // Ensure layout updates
//        setNeedsLayout()
//        layoutIfNeeded()
//    }
//}


class MoodEntryCell: UITableViewCell {
    private let cardView = UIView()
    private let moodEmojiLabel = UILabel()
    private let moodTitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let journalLabel = UILabel()
    private let tagsStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Compact card with soft shadow
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 0.925, green: 0.91, blue: 0.895, alpha: 1.0)
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 6
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(cardView)
        
        // Emoji - compact size
        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        moodEmojiLabel.font = UIFont.systemFont(ofSize: 28)
        moodEmojiLabel.textAlignment = .center
        cardView.addSubview(moodEmojiLabel)
        
        // Mood title - prominent but not too large
        moodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        moodTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        moodTitleLabel.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        cardView.addSubview(moodTitleLabel)
        
        // Date - subtle and compact
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        cardView.addSubview(dateLabel)
        
        // Journal text - ONE LINE with ellipsis like you requested
        journalLabel.translatesAutoresizingMaskIntoConstraints = false
        journalLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        journalLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        journalLabel.numberOfLines = 1 // ONE LINE ONLY
        journalLabel.lineBreakMode = .byTruncatingTail // ADD ... IF TOO LONG
        cardView.addSubview(journalLabel)
        
        // Tags - compact horizontal layout
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .leading
        cardView.addSubview(tagsStackView)
        
        NSLayoutConstraint.activate([
            // Compact card with minimal margins
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Emoji - compact positioning
            moodEmojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            moodEmojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            moodEmojiLabel.widthAnchor.constraint(equalToConstant: 36),
            moodEmojiLabel.heightAnchor.constraint(equalToConstant: 36),
            
            // Title next to emoji
            moodTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            moodTitleLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 12),
            moodTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Date right below title with tight spacing
            dateLabel.topAnchor.constraint(equalTo: moodTitleLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: moodEmojiLabel.trailingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Journal text - ONE LINE with good spacing
            journalLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            journalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            journalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Tags at bottom with compact spacing
            tagsStackView.topAnchor.constraint(equalTo: journalLabel.bottomAnchor, constant: 10),
            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            tagsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            tagsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with entry: MoodEntry) {
        moodEmojiLabel.text = entry.emoji
        moodTitleLabel.text = entry.moodLabel
        dateLabel.text = entry.dateString
        
        // SET THE DESCRIPTION TEXT - this was missing!
        journalLabel.text = entry.journalText
        print("🔍 Setting journal text: '\(entry.journalText)' for entry: \(entry.moodLabel)")
        
        // Clear existing tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create beautiful compact tags
        let tagColors: [(background: UIColor, text: UIColor)] = [
            // Soft beige like in screenshot
            (UIColor(red: 0.85, green: 0.78, blue: 0.68, alpha: 0.8), UIColor(red: 0.4, green: 0.35, blue: 0.25, alpha: 1.0)),
            // Soft purple like in screenshot
            (UIColor(red: 0.82, green: 0.72, blue: 0.8, alpha: 0.8), UIColor(red: 0.4, green: 0.3, blue: 0.38, alpha: 1.0)),
            // Another soft beige variation
            (UIColor(red: 0.88, green: 0.83, blue: 0.75, alpha: 0.8), UIColor(red: 0.38, green: 0.33, blue: 0.28, alpha: 1.0))
        ]
        
        for (index, tag) in entry.tags.prefix(3).enumerated() {
            let tagButton = UIButton(type: .custom)
            tagButton.setTitle(tag, for: .normal)
            tagButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            
            // Use different colors for variety
            let colorPair = tagColors[index % tagColors.count]
            tagButton.backgroundColor = colorPair.background
            tagButton.setTitleColor(colorPair.text, for: .normal)
            
            // Compact pill shape
            tagButton.layer.cornerRadius = 12
            tagButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            
            // Subtle shadow
            tagButton.layer.shadowColor = UIColor.black.cgColor
            tagButton.layer.shadowOpacity = 0.04
            tagButton.layer.shadowRadius = 2
            tagButton.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            tagButton.translatesAutoresizingMaskIntoConstraints = false
            tagButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            tagsStackView.addArrangedSubview(tagButton)
        }
        
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
}
