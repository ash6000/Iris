import UIKit

class LunarCalendarViewController: UIViewController {

    // MARK: - UI Components
    private let backgroundView = UIView()
    private let contentView = UIView()
    private let closeButton = UIButton()
    private let monthLabel = UILabel()
    private let prevButton = UIButton()
    private let nextButton = UIButton()
    private let weekdayStackView = UIStackView()
    private let calendarStackView = UIStackView()

    // MARK: - Data
    private var currentDate = Date()
    private let calendar = Calendar.current

    // Moon phase data for each day (simplified - in real app this would come from API)
    private let moonPhases: [String] = [
        "🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘",  // Week 1
        "🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘",  // Week 2
        "🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘",  // Week 3
        "🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘",  // Week 4
        "🌑", "🌒", "🌓"  // Extra days
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        updateCalendar()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Background view
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.white
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundView.layer.shadowRadius = 16
        backgroundView.layer.shadowOpacity = 0.15
        view.addSubview(backgroundView)

        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(contentView)

        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentView.addSubview(closeButton)

        // Month header
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        monthLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        monthLabel.textAlignment = .center
        contentView.addSubview(monthLabel)

        // Navigation buttons
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentView.addSubview(prevButton)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentView.addSubview(nextButton)

        // Weekday labels
        setupWeekdayLabels()

        // Calendar grid
        setupCalendarGrid()
    }

    private func setupWeekdayLabels() {
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        weekdayStackView.axis = .horizontal
        weekdayStackView.distribution = .fillEqually
        weekdayStackView.spacing = 0
        contentView.addSubview(weekdayStackView)

        let weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            label.textAlignment = .center
            weekdayStackView.addArrangedSubview(label)
        }
    }

    private func setupCalendarGrid() {
        calendarStackView.translatesAutoresizingMaskIntoConstraints = false
        calendarStackView.axis = .vertical
        calendarStackView.distribution = .fillEqually
        calendarStackView.spacing = 12
        contentView.addSubview(calendarStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 340),
            backgroundView.heightAnchor.constraint(equalToConstant: 500),

            contentView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -20),

            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            prevButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            prevButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            prevButton.widthAnchor.constraint(equalToConstant: 24),
            prevButton.heightAnchor.constraint(equalToConstant: 24),

            monthLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            monthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 24),
            nextButton.heightAnchor.constraint(equalToConstant: 24),

            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 30),
            weekdayStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            weekdayStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 20),

            calendarStackView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 16),
            calendarStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            calendarStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            calendarStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevMonthTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)

        // Add tap gesture to dismiss when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Calendar Logic
    private func updateCalendar() {
        // Update month label
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: currentDate)
        print("Updated month to: \(formatter.string(from: currentDate))")

        // Clear existing calendar
        calendarStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Get first day of month and number of days
        let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let numberOfDays = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        // Adjust for Monday start (weekday 1 = Sunday, we want Monday = 0)
        let mondayOffset = (firstWeekday == 1) ? 6 : firstWeekday - 2

        var dayIndex = 0

        // Create weeks
        for week in 0..<6 {
            let weekStackView = UIStackView()
            weekStackView.axis = .horizontal
            weekStackView.distribution = .fillEqually
            weekStackView.spacing = 4

            // Create days for this week
            for day in 0..<7 {
                let dayView = createDayView(week: week, day: day, mondayOffset: mondayOffset, numberOfDays: numberOfDays, dayIndex: &dayIndex)
                weekStackView.addArrangedSubview(dayView)
            }

            calendarStackView.addArrangedSubview(weekStackView)

            // Stop if we've shown all days
            if dayIndex >= numberOfDays + mondayOffset {
                break
            }
        }
    }

    private func createDayView(week: Int, day: Int, mondayOffset: Int, numberOfDays: Int, dayIndex: inout Int) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])

        let absoluteDay = week * 7 + day

        // Check if this day should show a date
        if absoluteDay >= mondayOffset && absoluteDay < mondayOffset + numberOfDays {
            let dayNumber = absoluteDay - mondayOffset + 1

            // Moon phase view
            let moonLabel = UILabel()
            moonLabel.translatesAutoresizingMaskIntoConstraints = false
            moonLabel.font = UIFont.systemFont(ofSize: 20)
            moonLabel.textAlignment = .center

            // Use moon phase from array (cycling through)
            let moonIndex = (dayNumber - 1) % moonPhases.count
            moonLabel.text = moonPhases[moonIndex]

            containerView.addSubview(moonLabel)

            // Day number label
            let dayLabel = UILabel()
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            dayLabel.text = "\(dayNumber)"
            dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            dayLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            dayLabel.textAlignment = .center
            containerView.addSubview(dayLabel)

            // Check if today
            let today = calendar.component(.day, from: Date())
            let currentMonth = calendar.component(.month, from: currentDate)
            let todayMonth = calendar.component(.month, from: Date())

            if dayNumber == today && currentMonth == todayMonth {
                // Add highlight for today
                let highlightView = UIView()
                highlightView.translatesAutoresizingMaskIntoConstraints = false
                highlightView.backgroundColor = UIColor.orange
                highlightView.layer.cornerRadius = 2
                containerView.insertSubview(highlightView, at: 0)

                NSLayoutConstraint.activate([
                    highlightView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    highlightView.bottomAnchor.constraint(equalTo: dayLabel.topAnchor, constant: -2),
                    highlightView.widthAnchor.constraint(equalToConstant: 8),
                    highlightView.heightAnchor.constraint(equalToConstant: 4)
                ])
            }

            NSLayoutConstraint.activate([
                moonLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                moonLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
                moonLabel.heightAnchor.constraint(equalToConstant: 24),

                dayLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                dayLabel.topAnchor.constraint(equalTo: moonLabel.bottomAnchor, constant: 4),
                dayLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -4)
            ])

            dayIndex += 1
        }

        return containerView
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func prevMonthTapped() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        updateCalendar()
    }

    @objc private func nextMonthTapped() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        updateCalendar()
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !backgroundView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
}