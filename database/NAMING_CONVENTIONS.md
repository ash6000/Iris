# Supabase Database Model Naming Conventions

## Overview

To avoid naming conflicts with existing models in the irisOne project, Supabase database models use specific prefixes.

---

## Model Name Mappings

### Renamed Models (to avoid conflicts)

| Database Table | Swift Model Name | Original Conflict |
|---------------|------------------|-------------------|
| `messages` | `ChatMessage` | Conflicted with `OpenAIService.Message` |
| `mood_entries` | `DBMoodEntry` | Conflicted with `MoodDataManager.MoodEntry` |
| `journal_entries` | `DBJournalEntry` | Conflicted with `JournalViewController.JournalEntry` |

### Other Models (no conflicts)

All other models use their natural names:

- `UserProfile`
- `UserPreferences`
- `UserSubscription`
- `ChatCategory`
- `Conversation`
- `UserMemory`
- `MeditationContent`
- `Affirmation`
- `Horoscope`
- `Ambassador`
- `ReferralCode`
- `AmbassadorLead`
- etc.

---

## Usage Examples

### Working with Messages

```swift
// OLD (conflicted):
let message: Message = ...

// NEW (use ChatMessage for database):
let chatMessage: ChatMessage = try await SupabaseManager.shared.sendMessage(...)

// OpenAI Message still works as before:
struct Message: Codable {  // OpenAIService.swift
    let role: String
    let content: String
}
```

### Working with Mood Entries

```swift
// Local UI model (existing):
struct MoodEntry {  // MoodDataManager.swift
    let id: String
    let date: Date
    let emoji: String
    let moodLabel: String
    let journalText: String
    let tags: [String]
}

// Database model (new):
let dbMoodEntry: DBMoodEntry = try await SupabaseManager.shared.createMoodEntry(
    mood: .good,
    moodScore: 8,
    note: "Feeling great today!"
)
```

### Working with Journal Entries

```swift
// Local UI model (existing):
struct JournalEntry {  // JournalViewController.swift
    let emoji: String
    let title: String
    let date: String
    let content: String
    let type: String
    let readTime: String
}

// Database model (new):
let dbJournalEntry: DBJournalEntry = try await SupabaseManager.shared.createJournalEntry(
    title: "My Day",
    content: "Today was wonderful...",
    type: .text
)
```

---

## Migration Strategy

When moving from local storage to Supabase:

### 1. Keep Both Models Temporarily

```swift
// Local model for UI (existing)
struct MoodEntry {
    let id: String
    let emoji: String
    let moodLabel: String
    // ... UI-specific fields
}

// Database model (new)
struct DBMoodEntry: Codable {
    let id: UUID
    let mood: MoodType
    let moodScore: Int?
    // ... database fields
}
```

### 2. Create Converters

```swift
extension DBMoodEntry {
    func toLocalMoodEntry() -> MoodEntry {
        return MoodEntry(
            id: id.uuidString,
            date: entryDate,
            emoji: moodToEmoji(mood),
            moodLabel: mood.rawValue,
            journalText: note ?? "",
            tags: tags ?? []
        )
    }

    private func moodToEmoji(_ mood: MoodType) -> String {
        switch mood {
        case .excellent: return "😊"
        case .good: return "🙂"
        case .neutral: return "😐"
        case .bad: return "😔"
        case .very_bad: return "😢"
        }
    }
}
```

### 3. Gradual Migration

```swift
class MoodDataManager {
    // Phase 1: Save to both
    func saveMoodEntry(...) async {
        // Save locally (existing)
        saveToUserDefaults(...)

        // Also save to Supabase
        do {
            try await SupabaseManager.shared.createMoodEntry(...)
        } catch {
            print("Failed to sync to cloud: \(error)")
        }
    }

    // Phase 2: Load from Supabase, fallback to local
    func getMoodEntry(for date: Date) async -> MoodEntry? {
        do {
            // Try cloud first
            let dbEntries = try await SupabaseManager.shared.fetchMoodEntries(
                startDate: date.startOfDay,
                endDate: date.endOfDay
            )
            return dbEntries.first?.toLocalMoodEntry()
        } catch {
            // Fallback to local
            return getLocalMoodEntry(for: date)
        }
    }

    // Phase 3: Remove local storage (future)
}
```

---

## API Reference

### ChatMessage (messages table)

```swift
func sendMessage(
    conversationId: UUID,
    role: MessageRole,
    content: String,
    format: MessageFormat = .text,
    audioUrl: String? = nil,
    transcription: String? = nil,
    modelUsed: String? = nil,
    tokensUsed: Int? = nil
) async throws -> ChatMessage

func fetchMessages(conversationId: UUID) async throws -> [ChatMessage]

// Helpers
func sendUserMessage(_ content: String, in conversationId: UUID) async throws -> ChatMessage
func sendAssistantMessage(_ content: String, in conversationId: UUID, modelUsed: String?, tokensUsed: Int?) async throws -> ChatMessage
```

### DBMoodEntry (mood_entries table)

```swift
func createMoodEntry(
    mood: MoodType,
    moodScore: Int?,
    note: String? = nil,
    tags: [String]? = nil,
    activities: [String]? = nil
) async throws -> DBMoodEntry

func fetchMoodEntries(startDate: Date, endDate: Date) async throws -> [DBMoodEntry]

// Helpers
func logMood(_ mood: MoodType, note: String? = nil) async throws
func fetchWeekMoods() async throws -> [DBMoodEntry]
func fetchMonthMoods() async throws -> [DBMoodEntry]
func calculateAverageMood(from startDate: Date, to endDate: Date) async throws -> Double?
```

### DBJournalEntry (journal_entries table)

```swift
func createJournalEntry(
    title: String?,
    content: String,
    type: JournalType = .text,
    privacy: EntryPrivacy = .private,
    tags: [String]? = nil,
    moodAtTime: MoodType? = nil
) async throws -> DBJournalEntry

func fetchJournalEntries(limit: Int = 50) async throws -> [DBJournalEntry]
```

---

## Important Notes

### ⚠️ Don't Mix Types

```swift
// ❌ WRONG - mixing types
let message: Message = try await SupabaseManager.shared.sendMessage(...)  // Won't compile!

// ✅ CORRECT
let chatMessage: ChatMessage = try await SupabaseManager.shared.sendMessage(...)
```

### ⚠️ Type Inference

Swift's type inference usually handles this automatically:

```swift
// ✅ Type inferred correctly
let messages = try await SupabaseManager.shared.fetchMessages(conversationId: id)
// messages is [ChatMessage]

let entries = try await SupabaseManager.shared.fetchMoodEntries(startDate: start, endDate: end)
// entries is [DBMoodEntry]
```

### ⚠️ When Errors Occur

If you see "ambiguous for type lookup":

```swift
// ❌ ERROR: 'MoodEntry' is ambiguous
let mood: MoodEntry = ...

// ✅ FIX: Be explicit
let mood: DBMoodEntry = ...  // For database
// or
let mood: MoodDataManager.MoodEntry = ...  // For local UI
```

---

## Summary

- **ChatMessage** = Database messages (from Supabase)
- **Message** = OpenAI API messages (existing)
- **DBMoodEntry** = Database mood entries (from Supabase)
- **MoodEntry** = Local UI mood entries (existing)
- **DBJournalEntry** = Database journal entries (from Supabase)
- **JournalEntry** = Local UI journal entries (existing)

All other models use their natural table names without prefixes.

---

**Last Updated**: 2025-01-19
