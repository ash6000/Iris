//
//  SupabaseManager.swift
//  irisOne
//
//  Supabase database manager for Iris Light Within
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    // MARK: - Properties

    internal var client: SupabaseClient!
    private var _supabaseURL: String = "https://placeholder.supabase.co"

    // Current authenticated user ID (cached)
    private var _cachedUserId: UUID?

    var currentUserId: UUID? {
        return _cachedUserId
    }

    /// Get configured Supabase URL
    var configuredURL: String {
        return _supabaseURL
    }

    /// Get current user (async)
    func getCurrentUser() async -> User? {
        return try? await client.auth.session.user
    }

    /// Update cached user ID after authentication
    private func updateCachedUserId(_ user: User) {
        _cachedUserId = UUID(uuidString: user.id.uuidString)
    }

    // MARK: - Initialization

    private init() {
        // Initialize with temporary placeholder
        // IMPORTANT: Call configure(url:anonKey:) with your actual Supabase credentials before using
        let supabaseURL = URL(string: "https://placeholder.supabase.co")!
        let supabaseKey = "placeholder-key"

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }

    // Configure with actual credentials (call this in AppDelegate or SceneDelegate)
    func configure(url: String, anonKey: String) {
        guard let supabaseURL = URL(string: url) else {
            print("❌ Invalid Supabase URL")
            return
        }

        _supabaseURL = url
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: anonKey
        )

        print("✅ Supabase configured successfully")
        print("   URL: \(url)")
    }

    // MARK: - Authentication

    /// Sign up new user with email and password
    func signUp(email: String, password: String, fullName: String? = nil) async throws -> User {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(fullName ?? "")]
        )

        let user = response.user
        updateCachedUserId(user)
        print("✅ User signed up: \(user.email ?? "")")
        return user
    }

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws -> User {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )

        updateCachedUserId(session.user)
        print("✅ User signed in: \(session.user.email ?? "")")
        return session.user
    }

    /// Sign in with Apple (requires Apple Sign In setup)
    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )

        updateCachedUserId(session.user)
        print("✅ User signed in with Apple: \(session.user.email ?? "")")
        return session.user
    }

    /// Sign out current user
    func signOut() async throws {
        try await client.auth.signOut()
        _cachedUserId = nil
        print("✅ User signed out")
    }

    /// Reset password for email
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
        print("✅ Password reset email sent to: \(email)")
    }

    /// Get current session (async)
    func getCurrentSession() async throws -> Session {
        return try await client.auth.session
    }

    /// Check if user is authenticated
    var isAuthenticated: Bool {
        return _cachedUserId != nil
    }

    // MARK: - Connection Testing

    /// Test Supabase connection (call this to verify setup)
    func testConnection() async {
        print("🔍 Testing Supabase connection...")
        print("   URL: \(configuredURL)")
        print("   Authenticated: \(isAuthenticated ? "Yes" : "No")")

        do {
            // Try to fetch chat categories as a simple test
            let categories = try await fetchChatCategories()
            print("✅ Connection successful!")
            print("   Found \(categories.count) chat categories")
        } catch {
            print("❌ Connection failed!")
            print("   Error: \(error.localizedDescription)")
            print("")
            print("💡 Troubleshooting:")
            print("   1. Check your Supabase URL in SupabaseConfig.swift")
            print("   2. Check your anon key in SupabaseConfig.swift")
            print("   3. Make sure you called configure(url:anonKey:) in AppDelegate")
            print("   4. Verify your database tables exist in Supabase")
        }
    }

    // MARK: - Profile Operations

    /// Fetch current user's profile
    func fetchProfile() async throws -> UserProfile {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let profile: UserProfile = try await client.database
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value

        return profile
    }

    /// Update user profile
    func updateProfile(_ profile: UserProfile) async throws {
        try await client.database
            .from("profiles")
            .update(profile)
            .eq("id", value: profile.id)
            .execute()

        print("✅ Profile updated")
    }

    /// Fetch user preferences
    func fetchPreferences() async throws -> UserPreferences {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let preferences: UserPreferences = try await client.database
            .from("user_preferences")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        return preferences
    }

    /// Update user preferences
    func updatePreferences(_ preferences: UserPreferences) async throws {
        try await client.database
            .from("user_preferences")
            .update(preferences)
            .eq("user_id", value: preferences.userId)
            .execute()

        print("✅ Preferences updated")
    }

    // MARK: - Conversation Operations

    /// Fetch all chat categories
    func fetchChatCategories() async throws -> [ChatCategory] {
        let categories: [ChatCategory] = try await client.database
            .from("chat_categories")
            .select()
            .eq("is_active", value: true)
            .order("display_order", ascending: true)
            .execute()
            .value

        return categories
    }

    /// Create new conversation
    func createConversation(categoryId: String?, title: String? = nil) async throws -> Conversation {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let newConversation = [
            "user_id": userId.uuidString,
            "category_id": categoryId ?? "",
            "title": title ?? ""
        ]

        let conversation: Conversation = try await client.database
            .from("conversations")
            .insert(newConversation)
            .single()
            .execute()
            .value

        print("✅ Conversation created: \(conversation.id)")
        return conversation
    }

    /// Fetch user's conversations
    func fetchConversations(limit: Int = 50, archived: Bool = false) async throws -> [Conversation] {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let conversations: [Conversation] = try await client.database
            .from("conversations")
            .select()
            .eq("user_id", value: userId)
            .eq("is_archived", value: archived)
            .order("last_message_at", ascending: false)
            .limit(limit)
            .execute()
            .value

        return conversations
    }

    /// Fetch messages for a conversation
    func fetchMessages(conversationId: UUID) async throws -> [DBChatMessage] {
        let messages: [DBChatMessage] = try await client.database
            .from("messages")
            .select()
            .eq("conversation_id", value: conversationId)
            .order("sequence_number", ascending: true)
            .execute()
            .value

        return messages
    }

    /// Send a message
    func sendMessage(
        conversationId: UUID,
        role: MessageRole,
        content: String,
        format: MessageFormat = .text,
        audioUrl: String? = nil,
        transcription: String? = nil,
        modelUsed: String? = nil,
        tokensUsed: Int? = nil
    ) async throws -> DBChatMessage {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        // Get next sequence number
        let existingMessages: [DBChatMessage] = try await fetchMessages(conversationId: conversationId)
        let sequenceNumber = existingMessages.count + 1

        let newMessage: [String: AnyJSON] = [
            "conversation_id": .string(conversationId.uuidString),
            "user_id": .string(userId.uuidString),
            "role": .string(role.rawValue),
            "content": .string(content),
            "format": .string(format.rawValue),
            "audio_url": audioUrl.map { .string($0) } ?? .null,
            "transcription": transcription.map { .string($0) } ?? .null,
            "model_used": modelUsed.map { .string($0) } ?? .null,
            "tokens_used": tokensUsed.map { .integer($0) } ?? .null,
            "sequence_number": .integer(sequenceNumber)
        ]

        let message: DBChatMessage = try await client.database
            .from("messages")
            .insert(newMessage)
            .single()
            .execute()
            .value

        print("✅ Message sent: \(message.id)")
        return message
    }

    /// Delete conversation
    func deleteConversation(_ conversationId: UUID) async throws {
        try await client.database
            .from("conversations")
            .delete()
            .eq("id", value: conversationId)
            .execute()

        print("✅ Conversation deleted: \(conversationId)")
    }

    /// Archive conversation
    func archiveConversation(_ conversationId: UUID) async throws {
        try await client.database
            .from("conversations")
            .update(["is_archived": true])
            .eq("id", value: conversationId)
            .execute()

        print("✅ Conversation archived: \(conversationId)")
    }

    // MARK: - User Memory Operations

    /// Save user memory
    func saveMemory(category: String, key: String, value: String, importance: Int = 5) async throws {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let memory: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "category": .string(category),
            "key": .string(key),
            "value": .string(value),
            "importance": .integer(importance)
        ]

        try await client.database
            .from("user_memory")
            .upsert(memory)
            .execute()

        print("✅ Memory saved: \(category).\(key)")
    }

    /// Fetch user memories
    func fetchMemories(category: String? = nil) async throws -> [UserMemory] {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        var query = client.database
            .from("user_memory")
            .select()
            .eq("user_id", value: userId)

        if let category = category {
            query = query.eq("category", value: category)
        }

        let memories: [UserMemory] = try await query
            .order("importance", ascending: false)
            .execute()
            .value

        return memories
    }

    // MARK: - Mood & Journal Operations

    /// Create mood entry
    func createMoodEntry(
        mood: MoodType,
        moodScore: Int?,
        note: String? = nil,
        tags: [String]? = nil,
        activities: [String]? = nil
    ) async throws -> DBMoodEntry {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let entry: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "mood": .string(mood.rawValue),
            "mood_score": moodScore.map { .integer($0) } ?? .null,
            "note": note.map { .string($0) } ?? .null,
            "tags": tags.map { .array($0.map { .string($0) }) } ?? .null,
            "activities": activities.map { .array($0.map { .string($0) }) } ?? .null
        ]

        let moodEntry: DBMoodEntry = try await client.database
            .from("mood_entries")
            .insert(entry)
            .single()
            .execute()
            .value

        print("✅ Mood entry created: \(moodEntry.mood)")
        return moodEntry
    }

    /// Fetch mood entries for date range
    func fetchMoodEntries(startDate: Date, endDate: Date) async throws -> [DBMoodEntry] {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let entries: [DBMoodEntry] = try await client.database
            .from("mood_entries")
            .select()
            .eq("user_id", value: userId)
            .gte("entry_date", value: startDate)
            .lte("entry_date", value: endDate)
            .order("entry_date", ascending: false)
            .execute()
            .value

        return entries
    }

    /// Create journal entry
    func createJournalEntry(
        title: String?,
        content: String,
        type: JournalType = .text,
        privacy: EntryPrivacy = .private,
        tags: [String]? = nil,
        moodAtTime: MoodType? = nil
    ) async throws -> DBJournalEntry {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let wordCount = content.split(separator: " ").count

        let entry: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "title": title.map { .string($0) } ?? .null,
            "content": .string(content),
            "type": .string(type.rawValue),
            "privacy": .string(privacy.rawValue),
            "tags": tags.map { .array($0.map { .string($0) }) } ?? .null,
            "mood_at_time": moodAtTime.map { .string($0.rawValue) } ?? .null,
            "word_count": .integer(wordCount)
        ]

        let journalEntry: DBJournalEntry = try await client.database
            .from("journal_entries")
            .insert(entry)
            .single()
            .execute()
            .value

        print("✅ Journal entry created: \(journalEntry.id)")
        return journalEntry
    }

    /// Fetch journal entries
    func fetchJournalEntries(limit: Int = 50) async throws -> [DBJournalEntry] {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let entries: [DBJournalEntry] = try await client.database
            .from("journal_entries")
            .select()
            .eq("user_id", value: userId)
            .eq("is_archived", value: false)
            .order("entry_date", ascending: false)
            .limit(limit)
            .execute()
            .value

        return entries
    }

    // MARK: - Content Operations

    /// Fetch meditation content
    func fetchMeditations(type: ContentType? = nil, isPremium: Bool? = nil) async throws -> [MeditationContent] {
        var query = client.database
            .from("meditation_content")
            .select()
            .eq("is_published", value: true)

        if let type = type {
            query = query.eq("type", value: type.rawValue)
        }

        if let isPremium = isPremium {
            query = query.eq("is_premium", value: isPremium)
        }

        let meditations: [MeditationContent] = try await query
            .order("display_order", ascending: true)
            .execute()
            .value

        return meditations
    }

    /// Record meditation session
    func recordMeditationSession(
        meditationId: UUID,
        completed: Bool,
        progressSeconds: Int,
        rating: Int? = nil
    ) async throws {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let completionPercentage = completed ? 100 : 0

        let session: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "meditation_id": .string(meditationId.uuidString),
            "completed": .bool(completed),
            "progress_seconds": .integer(progressSeconds),
            "completion_percentage": .integer(completionPercentage),
            "rating": rating.map { .integer($0) } ?? .null
        ]

        try await client.database
            .from("meditation_sessions")
            .insert(session)
            .execute()

        print("✅ Meditation session recorded")
    }

    /// Fetch daily affirmation
    func fetchDailyAffirmation(language: LanguageCode = .en) async throws -> Affirmation {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        // Call the database function to get random affirmation
        let result = try await client.database
            .rpc("get_random_affirmation", params: [
                "p_user_id": userId.uuidString,
                "p_language": language.rawValue
            ])
            .single()
            .execute()

        let affirmation: Affirmation = try JSONDecoder().decode(Affirmation.self, from: result.data)

        // Record that user saw this affirmation
        try await recordAffirmationView(affirmationId: affirmation.id)

        return affirmation
    }

    /// Record affirmation view
    private func recordAffirmationView(affirmationId: UUID) async throws {
        guard let userId = currentUserId else { return }

        let record: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "affirmation_id": .string(affirmationId.uuidString)
        ]

        try await client.database
            .from("user_affirmations")
            .insert(record)
            .execute()
    }

    /// Fetch today's horoscope
    func fetchTodaysHoroscope(zodiacSign: ZodiacSign, language: LanguageCode = .en) async throws -> Horoscope {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)

        let horoscope: Horoscope = try await client.database
            .from("horoscopes")
            .select()
            .eq("zodiac_sign", value: zodiacSign.rawValue)
            .eq("horoscope_date", value: todayString)
            .eq("language", value: language.rawValue)
            .eq("is_published", value: true)
            .single()
            .execute()
            .value

        return horoscope
    }

    // MARK: - Ambassador Operations

    /// Apply to become ambassador
    func applyForAmbassador(
        applicationText: String,
        whyJoin: String,
        socialMediaReach: String?,
        mediaContacts: String?
    ) async throws -> Ambassador {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let application: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "application_text": .string(applicationText),
            "why_join": .string(whyJoin),
            "social_media_reach": socialMediaReach.map { .string($0) } ?? .null,
            "media_contacts": mediaContacts.map { .string($0) } ?? .null,
            "status": .string(AmbassadorStatus.pending.rawValue)
        ]

        let ambassador: Ambassador = try await client.database
            .from("ambassadors")
            .insert(application)
            .single()
            .execute()
            .value

        print("✅ Ambassador application submitted")
        return ambassador
    }

    /// Fetch ambassador profile
    func fetchAmbassadorProfile() async throws -> Ambassador {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        let ambassador: Ambassador = try await client.database
            .from("ambassadors")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        return ambassador
    }

    /// Fetch ambassador referral codes
    func fetchReferralCodes() async throws -> [ReferralCode] {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        // First get ambassador ID
        let ambassador = try await fetchAmbassadorProfile()

        let codes: [ReferralCode] = try await client.database
            .from("referral_codes")
            .select()
            .eq("ambassador_id", value: ambassador.id)
            .order("created_at", ascending: false)
            .execute()
            .value

        return codes
    }

    /// Apply referral code
    func applyReferralCode(_ code: String) async throws -> Bool {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }

        // Call database function to apply code
        let result = try await client.database
            .rpc("apply_referral_code", params: [
                "p_user_id": userId.uuidString,
                "p_code": code.uppercased()
            ])
            .execute()

        // Parse boolean result
        let success = try JSONDecoder().decode(Bool.self, from: result.data)

        if success {
            print("✅ Referral code applied successfully")
        } else {
            print("❌ Referral code invalid or expired")
        }

        return success
    }

    // MARK: - Storage Operations

    /// Upload file to Supabase Storage
    func uploadFile(
        data: Data,
        bucket: String,
        path: String,
        contentType: String = "application/octet-stream"
    ) async throws -> String {
        try await client.storage
            .from(bucket)
            .upload(path: path, file: data, options: FileOptions(contentType: contentType))

        // Get public URL
        let url = try client.storage
            .from(bucket)
            .getPublicURL(path: path)

        print("✅ File uploaded: \(url)")
        return url.absoluteString
    }

    /// Download file from Supabase Storage
    func downloadFile(bucket: String, path: String) async throws -> Data {
        let data = try await client.storage
            .from(bucket)
            .download(path: path)

        print("✅ File downloaded: \(path)")
        return data
    }

    /// Delete file from Supabase Storage
    func deleteFile(bucket: String, path: String) async throws {
        try await client.storage
            .from(bucket)
            .remove(paths: [path])

        print("✅ File deleted: \(path)")
    }
}

// MARK: - Errors

enum SupabaseError: Error, LocalizedError {
    case notAuthenticated
    case authenticationFailed
    case invalidData
    case networkError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated. Please sign in."
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .invalidData:
            return "Invalid data received from server."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
