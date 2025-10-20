//
//  ModelConverters.swift
//  irisOne
//
//  Converters between local UI models and Supabase database models
//

import Foundation

// MARK: - MoodEntry Converters

extension DBMoodEntry {
    /// Convert database mood entry to local UI model
    func toLocalMoodEntry() -> MoodEntry {
        return MoodEntry(
            id: id.uuidString,
            date: entryDate,
            emoji: moodToEmoji(mood),
            moodLabel: moodToLabel(mood),
            journalText: note ?? "",
            tags: tags ?? []
        )
    }

    /// Convert mood type to emoji
    internal func moodToEmoji(_ mood: MoodType) -> String {
        switch mood {
        case .excellent: return "😊"
        case .good: return "🙂"
        case .neutral: return "😐"
        case .bad: return "😔"
        case .very_bad: return "😢"
        }
    }

    /// Convert mood type to user-friendly label
    internal func moodToLabel(_ mood: MoodType) -> String {
        switch mood {
        case .excellent: return "Joyful"
        case .good: return "Peaceful"
        case .neutral: return "Calm"
        case .bad: return "Anxious"
        case .very_bad: return "Sad"
        }
    }
}

extension MoodEntry {
    /// Convert local UI model to database mood entry
    /// Note: This creates the data structure but doesn't save to database
    func toDatabaseModel(userId: UUID) -> (mood: MoodType, moodScore: Int?, note: String?, tags: [String]?) {
        let moodType = emojiToMoodType(emoji)
        let score = moodLabelToScore(moodLabel)

        return (
            mood: moodType,
            moodScore: score,
            note: journalText.isEmpty ? nil : journalText,
            tags: tags.isEmpty ? nil : tags
        )
    }

    /// Convert emoji back to mood type
    private func emojiToMoodType(_ emoji: String) -> MoodType {
        switch emoji {
        case "😊": return .excellent
        case "🙂": return .good
        case "😐": return .neutral
        case "😔": return .bad
        case "😢": return .very_bad
        default: return .neutral
        }
    }

    /// Convert mood label to numeric score (1-10)
    private func moodLabelToScore(_ label: String) -> Int {
        switch label.lowercased() {
        case "joyful", "excited": return 10
        case "peaceful", "happy": return 8
        case "calm", "content": return 6
        case "anxious", "stressed": return 4
        case "sad", "overwhelm": return 2
        default: return 5
        }
    }
}

// MARK: - JournalEntry Converters

extension DBJournalEntry {
    /// Convert database journal entry to local UI model
    func toLocalJournalEntry() -> JournalEntry {
        let emoji = getMoodEmoji()
        let dateString = formatDate(entryDate)
        let timeAgo = getTimeAgo(entryDate)
        let typeString = formatType(type)
        let readTime = calculateReadTime(wordCount ?? 0)

        return JournalEntry(
            emoji: emoji,
            title: timeAgo,
            date: dateString,
            content: content,
            type: typeString,
            readTime: readTime
        )
    }

    /// Get emoji based on mood at time of entry
    private func getMoodEmoji() -> String {
        guard let mood = moodAtTime else {
            // Default emoji based on journal type
            switch type {
            case .voice: return "🎙️"
            case .text: return "📝"
            case .both: return "✨"
            }
        }

        switch mood {
        case .excellent: return "😊"
        case .good: return "🙂"
        case .neutral: return "😐"
        case .bad: return "😔"
        case .very_bad: return "😢"
        }
    }

    /// Format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    /// Get "time ago" string (Today, Yesterday, 2 days ago)
    private func getTimeAgo(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            return "\(days) days ago"
        }
    }

    /// Format journal type for display
    private func formatType(_ type: JournalType) -> String {
        switch type {
        case .voice: return "Voice Entry"
        case .text: return "Text Entry"
        case .both: return "Guided Entry"
        }
    }

    /// Calculate estimated read time
    private func calculateReadTime(_ words: Int) -> String {
        let wordsPerMinute = 200
        let minutes = max(1, words / wordsPerMinute)
        return "\(minutes) min read"
    }
}

extension JournalEntry {
    /// Convert local UI model to database parameters
    /// Note: This creates the data structure but doesn't save to database
    func toDatabaseModel(userId: UUID) -> (
        title: String?,
        content: String,
        type: JournalType,
        privacy: EntryPrivacy,
        tags: [String]?,
        moodAtTime: MoodType?
    ) {
        // Infer type from the type string
        let journalType: JournalType
        switch type.lowercased() {
        case "voice entry": journalType = .voice
        case "text entry": journalType = .text
        case "guided entry": journalType = .both
        default: journalType = .text
        }

        // Default to private privacy
        let privacy: EntryPrivacy = .private

        // Try to extract mood from emoji
        let mood: MoodType?
        switch emoji {
        case "😊": mood = .excellent
        case "🙂": mood = .good
        case "😐": mood = .neutral
        case "😔": mood = .bad
        case "😢": mood = .very_bad
        default: mood = nil
        }

        return (
            title: title == "Today" || title == "Yesterday" ? nil : title,
            content: content,
            type: journalType,
            privacy: privacy,
            tags: nil,
            moodAtTime: mood
        )
    }
}

// MARK: - Batch Converters

extension Array where Element == DBMoodEntry {
    /// Convert array of database mood entries to local models
    func toLocalMoodEntries() -> [MoodEntry] {
        return self.map { $0.toLocalMoodEntry() }
    }
}

extension Array where Element == DBJournalEntry {
    /// Convert array of database journal entries to local models
    func toLocalJournalEntries() -> [JournalEntry] {
        return self.map { $0.toLocalJournalEntry() }
    }
}

// MARK: - PersistentMoodEntry Converters (for UserDefaults compatibility)

extension DBMoodEntry {
    /// Convert database mood entry to persistent local model (for UserDefaults)
    func toPersistentMoodEntry() -> PersistentMoodEntry {
        return PersistentMoodEntry(
            id: id.uuidString,
            date: entryDate,
            emoji: moodToEmoji(mood),
            moodLabel: moodToLabel(mood),
            journalText: note ?? "",
            tags: tags ?? [],
            voiceRecordingPath: nil,  // Mood entries don't have audio in database
            voiceRecordingDuration: 0
        )
    }
}

extension PersistentMoodEntry {
    /// Convert persistent local model to database parameters
    func toDatabaseParameters(userId: UUID) -> (
        mood: MoodType,
        moodScore: Int?,
        note: String?,
        tags: [String]?,
        activities: [String]?
    ) {
        let moodType = emojiToMoodType(emoji)
        let score = moodLabelToScore(moodLabel)

        return (
            mood: moodType,
            moodScore: score,
            note: journalText.isEmpty ? nil : journalText,
            tags: tags.isEmpty ? nil : tags,
            activities: nil
        )
    }

    private func emojiToMoodType(_ emoji: String) -> MoodType {
        switch emoji {
        case "😊": return .excellent
        case "🙂": return .good
        case "😐": return .neutral
        case "😔": return .bad
        case "😢": return .very_bad
        default: return .neutral
        }
    }

    private func moodLabelToScore(_ label: String) -> Int {
        switch label.lowercased() {
        case "joyful", "excited": return 10
        case "peaceful", "happy": return 8
        case "calm", "content": return 6
        case "anxious", "stressed": return 4
        case "sad", "overwhelm": return 2
        default: return 5
        }
    }
}

// MARK: - Sync Status Tracking

/// Track sync status for local entries
struct SyncStatus {
    var localEntryId: String
    var isSynced: Bool
    var lastSyncAttempt: Date?
    var cloudEntryId: UUID?
    var syncError: String?
}

extension UserDefaults {
    private enum SyncKeys {
        static let moodSyncStatus = "mood_sync_status"
        static let journalSyncStatus = "journal_sync_status"
    }

    /// Save mood sync status
    func saveMoodSyncStatus(_ status: [String: SyncStatus]) {
        if let encoded = try? JSONEncoder().encode(status) {
            set(encoded, forKey: SyncKeys.moodSyncStatus)
        }
    }

    /// Load mood sync status
    func loadMoodSyncStatus() -> [String: SyncStatus] {
        guard let data = data(forKey: SyncKeys.moodSyncStatus),
              let status = try? JSONDecoder().decode([String: SyncStatus].self, from: data) else {
            return [:]
        }
        return status
    }

    /// Save journal sync status
    func saveJournalSyncStatus(_ status: [String: SyncStatus]) {
        if let encoded = try? JSONEncoder().encode(status) {
            set(encoded, forKey: SyncKeys.journalSyncStatus)
        }
    }

    /// Load journal sync status
    func loadJournalSyncStatus() -> [String: SyncStatus] {
        guard let data = data(forKey: SyncKeys.journalSyncStatus),
              let status = try? JSONDecoder().decode([String: SyncStatus].self, from: data) else {
            return [:]
        }
        return status
    }
}

// Make SyncStatus Codable
extension SyncStatus: Codable {}
