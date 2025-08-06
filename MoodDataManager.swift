import Foundation
import UIKit

// MARK: - Extended MoodEntry for persistence (using existing struct)
extension MoodEntry {
    var hasVoiceRecording: Bool {
        return voiceRecordingPath != nil && !voiceRecordingPath!.isEmpty
    }
    
    // Additional properties for voice recording (we'll store these separately)
    var voiceRecordingPath: String? {
        // This will be handled by the data manager
        return nil
    }
    
    var voiceRecordingDuration: Double {
        // This will be handled by the data manager
        return 0
    }
}

// MARK: - Codable MoodEntry for UserDefaults persistence
struct PersistentMoodEntry: Codable {
    let id: String
    let date: Date
    let emoji: String
    let moodLabel: String
    let journalText: String
    let tags: [String]
    let voiceRecordingPath: String?
    let voiceRecordingDuration: Double
    
    init(from moodEntry: MoodEntry, voiceRecordingPath: String? = nil, voiceRecordingDuration: Double = 0) {
        self.id = moodEntry.id
        self.date = moodEntry.date
        self.emoji = moodEntry.emoji
        self.moodLabel = moodEntry.moodLabel
        self.journalText = moodEntry.journalText
        self.tags = moodEntry.tags
        self.voiceRecordingPath = voiceRecordingPath
        self.voiceRecordingDuration = voiceRecordingDuration
    }
    
    init(id: String, date: Date, emoji: String, moodLabel: String, journalText: String, tags: [String], voiceRecordingPath: String? = nil, voiceRecordingDuration: Double = 0) {
        self.id = id
        self.date = date
        self.emoji = emoji
        self.moodLabel = moodLabel
        self.journalText = journalText
        self.tags = tags
        self.voiceRecordingPath = voiceRecordingPath
        self.voiceRecordingDuration = voiceRecordingDuration
    }
    
    func toMoodEntry() -> MoodEntry {
        return MoodEntry(
            id: id,
            date: date,
            emoji: emoji,
            moodLabel: moodLabel,
            journalText: journalText,
            tags: tags
        )
    }
}

// MARK: - MoodDataManager
class MoodDataManager {
    static let shared = MoodDataManager()
    
    private init() {}
    
    // MARK: - UserDefaults Storage
    private let userDefaults = UserDefaults.standard
    private let moodEntriesKey = "SavedMoodEntries"
    private let voiceRecordingsKey = "VoiceRecordings"
    
    // MARK: - Helper Methods
    private func saveMoodEntries(_ entries: [PersistentMoodEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            userDefaults.set(data, forKey: moodEntriesKey)
            print("✅ Mood data saved successfully")
        } catch {
            print("❌ Failed to save mood data: \(error)")
        }
    }
    
    private func loadMoodEntries() -> [PersistentMoodEntry] {
        guard let data = userDefaults.data(forKey: moodEntriesKey),
              let entries = try? JSONDecoder().decode([PersistentMoodEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    // MARK: - CRUD Operations
    
    func saveMoodEntry(
        emoji: String,
        moodLabel: String,
        journalText: String,
        tags: [String],
        voiceRecordingPath: String? = nil,
        voiceRecordingDuration: Double = 0
    ) -> Bool {
        
        var entries = loadMoodEntries()
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if entry for today already exists
        if let existingIndex = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            // Update existing entry
            entries[existingIndex] = PersistentMoodEntry(
                id: entries[existingIndex].id,
                date: today,
                emoji: emoji,
                moodLabel: moodLabel,
                journalText: journalText,
                tags: tags,
                voiceRecordingPath: voiceRecordingPath,
                voiceRecordingDuration: voiceRecordingDuration
            )
        } else {
            // Create new entry
            let newEntry = PersistentMoodEntry(
                id: UUID().uuidString,
                date: today,
                emoji: emoji,
                moodLabel: moodLabel,
                journalText: journalText,
                tags: tags,
                voiceRecordingPath: voiceRecordingPath,
                voiceRecordingDuration: voiceRecordingDuration
            )
            entries.append(newEntry)
        }
        
        saveMoodEntries(entries)
        return true
    }
    
    func getMoodEntry(for date: Date) -> MoodEntry? {
        let entries = loadMoodEntries()
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        if let persistentEntry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfDay) }) {
            return persistentEntry.toMoodEntry()
        }
        return nil
    }
    
    func getAllMoodEntries() -> [MoodEntry] {
        let entries = loadMoodEntries()
        return entries.sorted { $0.date > $1.date }.map { $0.toMoodEntry() }
    }
    
    func getMoodEntries(from startDate: Date, to endDate: Date) -> [MoodEntry] {
        let entries = loadMoodEntries()
        return entries
            .filter { $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date > $1.date }
            .map { $0.toMoodEntry() }
    }
    
    // Helper method to get persistent entry (for voice recordings)
    private func getPersistentMoodEntry(for date: Date) -> PersistentMoodEntry? {
        let entries = loadMoodEntries()
        let startOfDay = Calendar.current.startOfDay(for: date)
        return entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfDay) })
    }
    
    // MARK: - Analytics & Insights
    
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentStreak = 0
        var checkDate = today
        
        while true {
            if getMoodEntry(for: checkDate) != nil {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        return currentStreak
    }
    
    func getPastWeekMoods() -> [(String, String)] {
        let calendar = Calendar.current
        let today = Date()
        var weekData: [(String, String)] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E" // Short day name
        
        // Find the most recent Sunday (start of week)
        let todayWeekday = calendar.component(.weekday, from: today) // 1 = Sunday, 2 = Monday, etc.
        let daysFromSunday = todayWeekday - 1 // 0 = Sunday, 1 = Monday, etc.
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) else {
            return []
        }
        
        // Generate 7 days starting from Sunday
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }
            let dayName = dateFormatter.string(from: date)
            let moodEntry = getMoodEntry(for: date)
            
            // Mark today's entry specially if it exists
            let emoji = moodEntry?.emoji ?? ""
            weekData.append((dayName, emoji))
        }
        
        return weekData
    }
    
    func generateInsights() -> [(String, String)] {
        let entries = getAllMoodEntries()
        var insights: [(String, String)] = []
        
        guard !entries.isEmpty else {
            return [("📝", "Start tracking your mood to see insights!")]
        }
        
        // Most frequent mood this week
        let weekEntries = getMoodEntries(from: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, to: Date())
        let moodCounts = Dictionary(grouping: weekEntries, by: { $0.moodLabel }).mapValues { $0.count }
        if let mostFrequentMood = moodCounts.max(by: { $0.value < $1.value }) {
            insights.append(("💙", "You've felt \(mostFrequentMood.key.lowercased()) \(mostFrequentMood.value) time\(mostFrequentMood.value > 1 ? "s" : "") this week"))
        }
        
        // Day of week pattern
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let dayMoods = Dictionary(grouping: entries, by: { dayFormatter.string(from: $0.date) })
        for (day, dayEntries) in dayMoods {
            let dayMoodCounts = Dictionary(grouping: dayEntries, by: { $0.moodLabel }).mapValues { $0.count }
            if let preferredMood = dayMoodCounts.max(by: { $0.value < $1.value }), preferredMood.value >= 2 {
                insights.append(("✨", "You tend to feel \(preferredMood.key.lowercased()) on \(day)s"))
                break
            }
        }
        
        // Tag correlation
        let allTags = entries.flatMap { $0.tags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0 }).mapValues { $0.count }
        if let popularTag = tagCounts.max(by: { $0.value < $1.value }), popularTag.value >= 3 {
            insights.append(("🏷️", "\"\(popularTag.key)\" appears often in your entries"))
        }
        
        return insights.isEmpty ? [("📊", "Keep tracking to unlock personalized insights!")] : insights
    }
    
    func getMoodTrendData() -> [CGFloat] {
        let calendar = Calendar.current
        let today = Date()
        var trendData: [CGFloat] = []
        
        // Map mood labels to numerical values for trend calculation
        let moodValues: [String: CGFloat] = [
            "Joyful": 5.0,
            "Excited": 4.5,
            "Peaceful": 4.0,
            "Calm": 3.5,
            "Curious": 3.0,
            "Overwhelm": 2.0,
            "Anxious": 1.5,
            "Sad": 1.0
        ]
        
        // Get last 7 days of data
        for i in (0...6).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let entry = getMoodEntry(for: date)
            let value = entry != nil ? (moodValues[entry!.moodLabel] ?? 3.0) : 3.0
            trendData.append(value)
        }
        
        return trendData
    }
}

// MARK: - Voice Recording Helpers
extension MoodDataManager {
    func getVoiceRecordingPath(for date: Date) -> String? {
        return getPersistentMoodEntry(for: date)?.voiceRecordingPath
    }
    
    func getVoiceRecordingDuration(for date: Date) -> Double {
        return getPersistentMoodEntry(for: date)?.voiceRecordingDuration ?? 0
    }
    
    // MARK: - Helper Methods for UI
    func hasTodaysMoodEntry() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return getMoodEntry(for: today) != nil
    }
    
    func getTodaysMoodEntry() -> MoodEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return getMoodEntry(for: today)
    }
}