//
//  DatabaseModels.swift
//  irisOne
//
//  Swift models matching Supabase database schema
//

import Foundation

// MARK: - Enums

enum SubscriptionTier: String, Codable {
    case free
    case pro
    case ambassador
}

enum SubscriptionStatus: String, Codable {
    case active
    case cancelled
    case expired
    case trial
}

enum LanguageCode: String, Codable {
    case en, es, fr, de, pt, it, zh, ja, ko, ar, hi
}

enum CulturalVariant: String, Codable {
    case western
    case latin
    case asian
    case middle_eastern
    case african
    case indian
}

enum NotificationType: String, Codable {
    case affirmation
    case horoscope
    case reminder
    case feature
    case ambassador
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

enum MessageFormat: String, Codable {
    case text
    case voice
    case image
}

enum MoodType: String, Codable {
    case very_bad
    case bad
    case neutral
    case good
    case excellent
}

enum JournalType: String, Codable {
    case text
    case voice
    case both
}

enum EntryPrivacy: String, Codable {
    case `private`
    case shared
    case diary
}

enum ContentType: String, Codable {
    case meditation
    case sleep
    case breathwork
    case music
}

enum DifficultyLevel: String, Codable {
    case beginner
    case intermediate
    case advanced
    case all
}

enum ZodiacSign: String, Codable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces
}

enum AmbassadorStatus: String, Codable {
    case pending
    case active
    case inactive
    case suspended
}

enum LeadStatus: String, Codable {
    case assigned
    case contacted
    case interested
    case trial_sent
    case converted
    case not_interested
    case no_response
}

enum ReferralStatus: String, Codable {
    case pending
    case active
    case expired
    case converted
}

// MARK: - Core Models

struct UserProfile: Codable, Identifiable {
    let id: UUID
    let email: String
    var fullName: String?
    var displayName: String?
    var avatarUrl: String?

    // Preferences
    var language: LanguageCode
    var culturalVariant: CulturalVariant
    var timezone: String

    // Subscription
    var currentTier: SubscriptionTier
    var subscriptionExpiresAt: Date?

    // Onboarding
    var hasCompletedOnboarding: Bool
    var onboardingCompletedAt: Date?

    // Stats
    var totalConversations: Int
    var totalMessages: Int
    var totalMoodEntries: Int
    var totalJournalEntries: Int
    var currentStreakDays: Int
    var longestStreakDays: Int
    var lastActiveDate: Date?

    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email, language, timezone
        case fullName = "full_name"
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case culturalVariant = "cultural_variant"
        case currentTier = "current_tier"
        case subscriptionExpiresAt = "subscription_expires_at"
        case hasCompletedOnboarding = "has_completed_onboarding"
        case onboardingCompletedAt = "onboarding_completed_at"
        case totalConversations = "total_conversations"
        case totalMessages = "total_messages"
        case totalMoodEntries = "total_mood_entries"
        case totalJournalEntries = "total_journal_entries"
        case currentStreakDays = "current_streak_days"
        case longestStreakDays = "longest_streak_days"
        case lastActiveDate = "last_active_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserPreferences: Codable, Identifiable {
    let id: UUID
    let userId: UUID

    // Notifications
    var enablePushNotifications: Bool
    var enableAffirmations: Bool
    var enableHoroscopes: Bool
    var affirmationTime: String // Time as "HH:MM:SS"
    var horoscopeTime: String

    // Voice & Accessibility
    var enableVoiceMode: Bool
    var voiceSpeed: Double
    var enableTextToSpeech: Bool
    var textSizeMultiplier: Double

    // Privacy
    var allowDataCollection: Bool
    var allowPersonalization: Bool
    var chatRetentionDays: Int

    // UI
    var theme: String // 'light', 'dark', 'auto'
    var showTutorial: Bool

    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case enablePushNotifications = "enable_push_notifications"
        case enableAffirmations = "enable_affirmations"
        case enableHoroscopes = "enable_horoscopes"
        case affirmationTime = "affirmation_time"
        case horoscopeTime = "horoscope_time"
        case enableVoiceMode = "enable_voice_mode"
        case voiceSpeed = "voice_speed"
        case enableTextToSpeech = "enable_text_to_speech"
        case textSizeMultiplier = "text_size_multiplier"
        case allowDataCollection = "allow_data_collection"
        case allowPersonalization = "allow_personalization"
        case chatRetentionDays = "chat_retention_days"
        case theme
        case showTutorial = "show_tutorial"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserSubscription: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let tier: SubscriptionTier
    var status: SubscriptionStatus

    // Billing
    var stripeSubscriptionId: String?
    var stripeCustomerId: String?

    // Dates
    var startedAt: Date
    var expiresAt: Date?
    var cancelledAt: Date?
    var trialEndsAt: Date?

    // Metadata
    var isTrial: Bool
    var isAnnual: Bool
    var discountCode: String?
    var discountPercent: Int?

    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case tier, status
        case stripeSubscriptionId = "stripe_subscription_id"
        case stripeCustomerId = "stripe_customer_id"
        case startedAt = "started_at"
        case expiresAt = "expires_at"
        case cancelledAt = "cancelled_at"
        case trialEndsAt = "trial_ends_at"
        case isTrial = "is_trial"
        case isAnnual = "is_annual"
        case discountCode = "discount_code"
        case discountPercent = "discount_percent"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Chat Models

struct ChatCategory: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let iconName: String?
    let colorHex: String?

    let systemPrompt: String
    let initialGreeting: String?

    let displayOrder: Int
    let isActive: Bool
    let isPremium: Bool

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case iconName = "icon_name"
        case colorHex = "color_hex"
        case systemPrompt = "system_prompt"
        case initialGreeting = "initial_greeting"
        case displayOrder = "display_order"
        case isActive = "is_active"
        case isPremium = "is_premium"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Conversation: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let categoryId: String?

    var title: String?
    var isArchived: Bool
    var isPinned: Bool
    var isFavorite: Bool

    var messageCount: Int
    var totalTokensUsed: Int
    var lastMessageAt: Date?

    var expiresAt: Date?

    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case title
        case isArchived = "is_archived"
        case isPinned = "is_pinned"
        case isFavorite = "is_favorite"
        case messageCount = "message_count"
        case totalTokensUsed = "total_tokens_used"
        case lastMessageAt = "last_message_at"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DBChatMessage: Codable, Identifiable {
    let id: UUID
    let conversationId: UUID
    let userId: UUID

    let role: MessageRole
    let content: String
    let format: MessageFormat

    // Voice metadata
    var audioUrl: String?
    var audioDurationSeconds: Int?
    var transcription: String?

    // AI metadata
    var modelUsed: String?
    var tokensUsed: Int?
    var finishReason: String?

    let sequenceNumber: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case userId = "user_id"
        case role, content, format
        case audioUrl = "audio_url"
        case audioDurationSeconds = "audio_duration_seconds"
        case transcription
        case modelUsed = "model_used"
        case tokensUsed = "tokens_used"
        case finishReason = "finish_reason"
        case sequenceNumber = "sequence_number"
        case createdAt = "created_at"
    }
}

struct UserMemory: Codable, Identifiable {
    let id: UUID
    let userId: UUID

    let category: String
    let key: String
    let value: String

    let sourceConversationId: UUID?
    let confidence: Double

    let importance: Int
    var lastReferencedAt: Date?
    var referenceCount: Int

    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case category, key, value
        case sourceConversationId = "source_conversation_id"
        case confidence, importance
        case lastReferencedAt = "last_referenced_at"
        case referenceCount = "reference_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Tracking Models

struct DBMoodEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID

    let mood: MoodType
    let moodScore: Int?

    let note: String?
    let tags: [String]?
    let activities: [String]?
    let location: String?

    let relatedConversationId: UUID?

    let entryDate: Date
    let entryTime: String

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mood
        case moodScore = "mood_score"
        case note, tags, activities, location
        case relatedConversationId = "related_conversation_id"
        case entryDate = "entry_date"
        case entryTime = "entry_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DBJournalEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID

    let title: String?
    let content: String
    let type: JournalType
    let privacy: EntryPrivacy

    // Voice metadata
    let audioUrl: String?
    let audioDurationSeconds: Int?
    let transcription: String?

    let tags: [String]?
    let moodAtTime: MoodType?
    let relatedMoodEntryId: UUID?

    // Diary for loved ones
    let intendedRecipient: String?
    let shareAfterDate: Date?

    var isFavorite: Bool
    var isArchived: Bool

    let entryDate: Date
    let wordCount: Int?

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title, content, type, privacy
        case audioUrl = "audio_url"
        case audioDurationSeconds = "audio_duration_seconds"
        case transcription, tags
        case moodAtTime = "mood_at_time"
        case relatedMoodEntryId = "related_mood_entry_id"
        case intendedRecipient = "intended_recipient"
        case shareAfterDate = "share_after_date"
        case isFavorite = "is_favorite"
        case isArchived = "is_archived"
        case entryDate = "entry_date"
        case wordCount = "word_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DailyEngagement: Codable, Identifiable {
    let id: UUID
    let userId: UUID

    let activityDate: Date

    var sessionsCount: Int
    var totalTimeSeconds: Int
    var messagesSent: Int
    var moodEntries: Int
    var journalEntries: Int
    var meditationsCompleted: Int

    var isActiveDay: Bool

    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case activityDate = "activity_date"
        case sessionsCount = "sessions_count"
        case totalTimeSeconds = "total_time_seconds"
        case messagesSent = "messages_sent"
        case moodEntries = "mood_entries"
        case journalEntries = "journal_entries"
        case meditationsCompleted = "meditations_completed"
        case isActiveDay = "is_active_day"
        case createdAt = "created_at"
    }
}

// MARK: - Content Models

struct MeditationContent: Codable, Identifiable {
    let id: UUID

    let title: String
    let description: String?
    let type: ContentType

    let audioUrl: String?
    let videoUrl: String?
    let thumbnailUrl: String?
    let transcript: String?

    let durationSeconds: Int
    let difficulty: DifficultyLevel
    let voiceArtist: String?

    let tags: [String]?
    let categories: [String]?

    var playCount: Int
    var favoriteCount: Int
    var averageRating: Double?

    let isPremium: Bool
    let isPublished: Bool

    let language: LanguageCode

    let displayOrder: Int
    let featuredOrder: Int?

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description, type
        case audioUrl = "audio_url"
        case videoUrl = "video_url"
        case thumbnailUrl = "thumbnail_url"
        case transcript
        case durationSeconds = "duration_seconds"
        case difficulty
        case voiceArtist = "voice_artist"
        case tags, categories
        case playCount = "play_count"
        case favoriteCount = "favorite_count"
        case averageRating = "average_rating"
        case isPremium = "is_premium"
        case isPublished = "is_published"
        case language
        case displayOrder = "display_order"
        case featuredOrder = "featured_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Affirmation: Codable, Identifiable {
    let id: UUID

    let text: String
    let author: String?
    let category: String?

    let language: LanguageCode
    let culturalVariant: CulturalVariant?

    let tags: [String]?
    let isActive: Bool

    var timesShown: Int
    var timesShared: Int

    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, text, author, category, language
        case culturalVariant = "cultural_variant"
        case tags
        case isActive = "is_active"
        case timesShown = "times_shown"
        case timesShared = "times_shared"
        case createdAt = "created_at"
    }
}

struct Horoscope: Codable, Identifiable {
    let id: UUID

    let zodiacSign: ZodiacSign
    let horoscopeDate: Date

    let dailyMessage: String
    let loveForecast: String?
    let careerForecast: String?
    let wellnessForecast: String?
    let luckyNumbers: [Int]?
    let luckyColor: String?

    let language: LanguageCode
    let isPublished: Bool

    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case zodiacSign = "zodiac_sign"
        case horoscopeDate = "horoscope_date"
        case dailyMessage = "daily_message"
        case loveForecast = "love_forecast"
        case careerForecast = "career_forecast"
        case wellnessForecast = "wellness_forecast"
        case luckyNumbers = "lucky_numbers"
        case luckyColor = "lucky_color"
        case language
        case isPublished = "is_published"
        case createdAt = "created_at"
    }
}

// MARK: - Ambassador Models

struct Ambassador: Codable, Identifiable {
    let id: UUID
    let userId: UUID

    let applicationText: String?
    let whyJoin: String?
    let socialMediaReach: String?
    let mediaContacts: String?

    var status: AmbassadorStatus
    var approvedAt: Date?
    var approvedBy: UUID?

    var totalLeadsAssigned: Int
    var leadsContacted: Int
    var leadsConverted: Int
    var referralCodesCreated: Int
    var successfulReferrals: Int

    var monthlyLeadQuota: Int
    var currentMonthLeads: Int
    var lastQuotaReset: Date?

    var adminNotes: String?

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case applicationText = "application_text"
        case whyJoin = "why_join"
        case socialMediaReach = "social_media_reach"
        case mediaContacts = "media_contacts"
        case status
        case approvedAt = "approved_at"
        case approvedBy = "approved_by"
        case totalLeadsAssigned = "total_leads_assigned"
        case leadsContacted = "leads_contacted"
        case leadsConverted = "leads_converted"
        case referralCodesCreated = "referral_codes_created"
        case successfulReferrals = "successful_referrals"
        case monthlyLeadQuota = "monthly_lead_quota"
        case currentMonthLeads = "current_month_leads"
        case lastQuotaReset = "last_quota_reset"
        case adminNotes = "admin_notes"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ReferralCode: Codable, Identifiable {
    let id: UUID
    let ambassadorId: UUID

    let code: String
    let description: String?

    let trialDays: Int
    let maxUses: Int?
    var currentUses: Int

    var status: ReferralStatus
    var isActive: Bool

    let validFrom: Date
    let validUntil: Date?

    var totalSignups: Int
    var totalConversions: Int

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case ambassadorId = "ambassador_id"
        case code, description
        case trialDays = "trial_days"
        case maxUses = "max_uses"
        case currentUses = "current_uses"
        case status
        case isActive = "is_active"
        case validFrom = "valid_from"
        case validUntil = "valid_until"
        case totalSignups = "total_signups"
        case totalConversions = "total_conversions"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AmbassadorLead: Codable, Identifiable {
    let id: UUID
    let ambassadorId: UUID

    let leadName: String
    let leadEmail: String?
    let leadPhone: String?
    let organization: String?
    let leadType: String?

    var status: LeadStatus
    let assignedDate: Date

    var firstContactDate: Date?
    var lastContactDate: Date?
    var contactCount: Int

    var trialCodeSent: String?
    var trialActivated: Bool
    var convertedToUser: Bool
    var userId: UUID?

    var providedTestimonial: Bool
    var testimonialText: String?
    var testimonialApproved: Bool

    var notes: String?
    var ambassadorNotes: String?

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case ambassadorId = "ambassador_id"
        case leadName = "lead_name"
        case leadEmail = "lead_email"
        case leadPhone = "lead_phone"
        case organization
        case leadType = "lead_type"
        case status
        case assignedDate = "assigned_date"
        case firstContactDate = "first_contact_date"
        case lastContactDate = "last_contact_date"
        case contactCount = "contact_count"
        case trialCodeSent = "trial_code_sent"
        case trialActivated = "trial_activated"
        case convertedToUser = "converted_to_user"
        case userId = "user_id"
        case providedTestimonial = "provided_testimonial"
        case testimonialText = "testimonial_text"
        case testimonialApproved = "testimonial_approved"
        case notes
        case ambassadorNotes = "ambassador_notes"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
