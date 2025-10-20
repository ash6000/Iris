//
//  SupabaseHelpers.swift
//  irisOne
//
//  Convenience extensions and helpers for Supabase operations
//

import Foundation
import UIKit
import Supabase

// MARK: - Authentication Helpers

extension SupabaseManager {

    /// Check if user has active subscription
    func hasActiveSubscription() async throws -> Bool {
        let profile = try await fetchProfile()

        guard let expiresAt = profile.subscriptionExpiresAt else {
            // Pro/Ambassador with no expiration = active
            return profile.currentTier != .free
        }

        return expiresAt > Date()
    }

    /// Check if user is on free tier
    func isFreeTier() async throws -> Bool {
        let profile = try await fetchProfile()
        return profile.currentTier == .free
    }

    /// Check if user is pro
    func isProTier() async throws -> Bool {
        let profile = try await fetchProfile()
        return profile.currentTier == .pro
    }
}

// MARK: - Conversation Helpers

extension SupabaseManager {

    /// Quick send user message
    func sendUserMessage(_ content: String, in conversationId: UUID) async throws -> DBChatMessage {
        return try await sendMessage(
            conversationId: conversationId,
            role: .user,
            content: content,
            format: .text
        )
    }

    /// Quick send assistant message
    func sendAssistantMessage(
        _ content: String,
        in conversationId: UUID,
        modelUsed: String? = nil,
        tokensUsed: Int? = nil
    ) async throws -> DBChatMessage {
        return try await sendMessage(
            conversationId: conversationId,
            role: .assistant,
            content: content,
            format: .text,
            modelUsed: modelUsed,
            tokensUsed: tokensUsed
        )
    }

    /// Get or create conversation for category
    func getOrCreateConversation(categoryId: String) async throws -> Conversation {
        // Check if there's an existing non-archived conversation for this category
        let existingConversations = try await fetchConversations(archived: false)

        if let existing = existingConversations.first(where: { $0.categoryId == categoryId && !$0.isArchived }) {
            return existing
        }

        // Create new conversation
        return try await createConversation(categoryId: categoryId)
    }

    /// Fetch recent conversations (most recent first)
    func fetchRecentConversations(limit: Int = 20) async throws -> [Conversation] {
        return try await fetchConversations(limit: limit, archived: false)
    }

    /// Pin/unpin conversation
    func togglePinConversation(_ conversationId: UUID, isPinned: Bool) async throws {
        try await client.database
            .from("conversations")
            .update(["is_pinned": isPinned])
            .eq("id", value: conversationId)
            .execute()
    }

    /// Favorite/unfavorite conversation
    func toggleFavoriteConversation(_ conversationId: UUID, isFavorite: Bool) async throws {
        try await client.database
            .from("conversations")
            .update(["is_favorite": isFavorite])
            .eq("id", value: conversationId)
            .execute()
    }
}

// MARK: - Mood & Journal Helpers

extension SupabaseManager {

    /// Create quick mood entry with just mood type
    func logMood(_ mood: MoodType, note: String? = nil) async throws {
        let moodScore = moodTypeToScore(mood)
        _ = try await createMoodEntry(
            mood: mood,
            moodScore: moodScore,
            note: note
        )
    }

    /// Convert mood type to numeric score (1-10)
    private func moodTypeToScore(_ mood: MoodType) -> Int {
        switch mood {
        case .very_bad: return 2
        case .bad: return 4
        case .neutral: return 6
        case .good: return 8
        case .excellent: return 10
        }
    }

    /// Fetch mood entries for current week
    func fetchWeekMoods() async throws -> [DBMoodEntry] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

        return try await fetchMoodEntries(startDate: startOfWeek, endDate: today)
    }

    /// Fetch mood entries for current month
    func fetchMonthMoods() async throws -> [DBMoodEntry] {
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        return try await fetchMoodEntries(startDate: startOfMonth, endDate: today)
    }

    /// Calculate average mood for date range
    func calculateAverageMood(from startDate: Date, to endDate: Date) async throws -> Double? {
        let moods = try await fetchMoodEntries(startDate: startDate, endDate: endDate)

        guard !moods.isEmpty else { return nil }

        let scores = moods.compactMap { $0.moodScore }
        guard !scores.isEmpty else { return nil }

        let sum = scores.reduce(0, +)
        return Double(sum) / Double(scores.count)
    }

    /// Get current streak
    func getCurrentStreak() async throws -> Int {
        let profile = try await fetchProfile()
        return profile.currentStreakDays
    }
}

// MARK: - Content Helpers

extension SupabaseManager {

    /// Fetch free meditations only
    func fetchFreeMeditations() async throws -> [MeditationContent] {
        return try await fetchMeditations(isPremium: false)
    }

    /// Fetch featured meditations
    func fetchFeaturedMeditations() async throws -> [MeditationContent] {
        let meditations: [MeditationContent] = try await client.database
            .from("meditation_content")
            .select()
            .eq("is_published", value: true)
            .not("featured_order", operator: .is, value: AnyJSON.null)
            .order("featured_order", ascending: true)
            .execute()
            .value

        return meditations
    }

    /// Check if user can access premium content
    func canAccessPremiumContent() async throws -> Bool {
        let profile = try await fetchProfile()
        return profile.currentTier != .free
    }

    /// Fetch today's affirmation (caches daily)
    func getTodaysAffirmation() async throws -> Affirmation {
        // Check if we have cached affirmation for today
        let cacheKey = "daily_affirmation_\(Date().formatted(.dateTime.year().month().day()))"

        if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode(Affirmation.self, from: cachedData) {
            return cached
        }

        // Fetch new affirmation
        let affirmation = try await fetchDailyAffirmation()

        // Cache it
        if let encoded = try? JSONEncoder().encode(affirmation) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }

        return affirmation
    }

    /// Share affirmation to social media
    func shareAffirmation(_ affirmation: Affirmation) {
        let shareText = "\"\(affirmation.text)\"\n\n— Iris Light Within"

        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )

        // Get the key window's root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Storage Helpers

extension SupabaseManager {

    /// Upload audio recording
    func uploadAudioRecording(_ audioData: Data, filename: String) async throws -> String {
        let path = "audio_recordings/\(currentUserId?.uuidString ?? "unknown")/\(filename)"
        return try await uploadFile(
            data: audioData,
            bucket: "audio",
            path: path,
            contentType: "audio/m4a"
        )
    }

    /// Upload profile photo
    func uploadProfilePhoto(_ imageData: Data) async throws -> String {
        let filename = "profile_\(currentUserId?.uuidString ?? "unknown").jpg"
        let path = "avatars/\(filename)"

        return try await uploadFile(
            data: imageData,
            bucket: "avatars",
            path: path,
            contentType: "image/jpeg"
        )
    }

    /// Upload journal voice recording
    func uploadJournalVoice(_ audioData: Data, journalId: UUID) async throws -> String {
        let filename = "\(journalId.uuidString).m4a"
        let path = "journal_audio/\(currentUserId?.uuidString ?? "unknown")/\(filename)"

        return try await uploadFile(
            data: audioData,
            bucket: "journal_audio",
            path: path,
            contentType: "audio/m4a"
        )
    }
}

// MARK: - Date Helpers

extension Date {
    /// Format date for database queries
    var databaseFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    /// Get start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// Get end of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

// MARK: - UserDefaults Helpers

extension UserDefaults {
    private enum Keys {
        static let lastSyncDate = "last_sync_date"
        static let offlineMode = "offline_mode"
        static let pendingUploads = "pending_uploads"
    }

    var lastSyncDate: Date? {
        get { object(forKey: Keys.lastSyncDate) as? Date }
        set { set(newValue, forKey: Keys.lastSyncDate) }
    }

    var isOfflineMode: Bool {
        get { bool(forKey: Keys.offlineMode) }
        set { set(newValue, forKey: Keys.offlineMode) }
    }
}

// MARK: - Error Handling Helpers

extension SupabaseManager {

    /// Show error alert in view controller
    static func showError(_ error: Error, in viewController: UIViewController) {
        let title = "Error"
        let message = error.localizedDescription

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        viewController.present(alert, animated: true)
    }

    /// Handle common errors with user-friendly messages
    static func handleError(_ error: Error) -> String {
        if let supabaseError = error as? SupabaseError {
            return supabaseError.localizedDescription
        }

        // Handle other common errors
        if error.localizedDescription.contains("network") {
            return "Network connection issue. Please check your internet."
        }

        if error.localizedDescription.contains("401") || error.localizedDescription.contains("403") {
            return "Session expired. Please sign in again."
        }

        return "Something went wrong. Please try again."
    }
}

// MARK: - Async/Await UI Helpers

extension UIViewController {

    /// Execute async task with loading indicator
    func executeWithLoading<T>(
        _ task: @escaping () async throws -> T,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // Show loading indicator
        let loadingView = createLoadingView()
        view.addSubview(loadingView)

        Task {
            do {
                let result = try await task()
                await MainActor.run {
                    loadingView.removeFromSuperview()
                    completion(.success(result))
                }
            } catch {
                await MainActor.run {
                    loadingView.removeFromSuperview()
                    completion(.failure(error))
                }
            }
        }
    }

    private func createLoadingView() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.frame = view.bounds

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = container.center
        activityIndicator.startAnimating()

        container.addSubview(activityIndicator)

        return container
    }
}

// MARK: - Realtime Helpers (for future implementation)

extension SupabaseManager {

    /// Subscribe to conversation messages (realtime)
    func subscribeToConversation(_ conversationId: UUID, onMessage: @escaping (Message) -> Void) {
        // Placeholder for realtime subscriptions
        // Implementation requires Supabase Realtime setup
        print("⚠️ Realtime subscriptions not yet implemented")

        // Example implementation:
        // let channel = client.realtime.channel("messages:\(conversationId)")
        // channel.on(.insert) { message in
        //     if let decoded = try? JSONDecoder().decode(Message.self, from: message.payload) {
        //         onMessage(decoded)
        //     }
        // }
        // channel.subscribe()
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension SupabaseManager {

    /// Print current user info
    func debugPrintUser() async {
        do {
            let profile = try await fetchProfile()
            print("🔍 Current User Debug Info:")
            print("   ID: \(profile.id)")
            print("   Email: \(profile.email)")
            print("   Name: \(profile.fullName ?? "N/A")")
            print("   Tier: \(profile.currentTier)")
            print("   Streak: \(profile.currentStreakDays) days")
            print("   Total Messages: \(profile.totalMessages)")
        } catch {
            print("❌ Failed to fetch user: \(error)")
        }
    }

    /// Clear all cached data
    func clearAllCache() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()

        dictionary.keys.forEach { key in
            if key.starts(with: "daily_") {
                defaults.removeObject(forKey: key)
            }
        }

        print("✅ Cache cleared")
    }
}
#endif
