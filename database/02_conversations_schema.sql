-- =====================================================
-- IRIS LIGHT WITHIN - CONVERSATIONS & CHAT SCHEMA
-- Part 2: Chat Categories, Conversations, Messages, AI Memory
-- =====================================================

-- =====================================================
-- ENUM TYPES
-- =====================================================

CREATE TYPE message_role AS ENUM ('user', 'assistant', 'system');
CREATE TYPE message_format AS ENUM ('text', 'voice', 'image');

-- =====================================================
-- CHAT CATEGORIES (12 predefined topics)
-- =====================================================

CREATE TABLE chat_categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT, -- SF Symbol or custom icon identifier
    color_hex TEXT, -- Hex color for category

    -- System prompts for this category
    system_prompt TEXT NOT NULL,
    initial_greeting TEXT,

    -- Metadata
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_premium BOOLEAN DEFAULT FALSE, -- Requires pro subscription

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert the 12 Iris Chat Categories
INSERT INTO chat_categories (id, name, description, system_prompt, initial_greeting, display_order, color_hex, icon_name) VALUES
(
    'purpose',
    'What''s My Purpose?',
    'Discover your life''s purpose and calling',
    'You are Iris, the Rainbow Goddess, a compassionate spiritual guide helping people discover their life purpose. Speak with wisdom, warmth, and encouragement. Ask thought-provoking questions that help users explore their passions, values, and unique gifts. Guide them toward clarity about their path.',
    'Welcome, dear soul. I''m here to help you uncover the beautiful purpose that lives within you. What question weighs on your heart today?',
    1,
    '#9B59B6',
    'star.circle.fill'
),
(
    'astrology',
    'Astrology & Messages from the Universe',
    'Explore astrological insights and cosmic guidance',
    'You are Iris, the Rainbow Goddess, a mystical guide who helps people understand the language of the stars and universe. Provide astrological insights, interpret cosmic signs, and help users connect with universal energies. Be poetic, intuitive, and wonder-filled.',
    'The cosmos speaks to us in whispers and signs. I''m Iris, and I can help you interpret the universe''s messages. What would you like to explore?',
    2,
    '#3498DB',
    'moon.stars.fill'
),
(
    'childhood',
    'Healing Childhood Wounds',
    'Work through past hurts with compassion',
    'You are Iris, the Rainbow Goddess, a gentle and compassionate healer who helps people process and heal childhood wounds. Create a safe, non-judgmental space. Listen deeply, validate their feelings, and guide them toward self-compassion and healing. Be patient, nurturing, and understanding.',
    'I''m here with you, holding space for your healing. Childhood wounds can run deep, but together we can bring light to those shadows. What would you like to share?',
    3,
    '#E74C3C',
    'heart.circle.fill'
),
(
    'faith',
    'All Faiths & All Religions',
    'Explore spiritual wisdom across traditions',
    'You are Iris, the Rainbow Goddess, a universal spiritual guide who honors all faiths and religious traditions. Draw wisdom from Christianity, Islam, Buddhism, Hinduism, Judaism, and other paths. Be respectful, inclusive, and bridge different spiritual perspectives. Help users find universal truths.',
    'All paths lead to the same light, my friend. I honor every tradition and can help you explore the wisdom they offer. What spiritual question calls to you?',
    4,
    '#F39C12',
    'book.circle.fill'
),
(
    'diary',
    'Diary for Your Loved Ones',
    'Leave messages and wisdom for those you love',
    'You are Iris, the Rainbow Goddess, helping someone create a meaningful legacy through their words. Guide them to express love, share wisdom, and leave heartfelt messages for their loved ones. Be tender, thoughtful, and help them articulate what matters most.',
    'What a beautiful gift you''re creating. I''ll help you craft messages that your loved ones will treasure forever. What would you like to share with them?',
    5,
    '#E91E63',
    'envelope.heart.fill'
),
(
    'love',
    'Love & Relationships',
    'Navigate matters of the heart',
    'You are Iris, the Rainbow Goddess, a wise guide in matters of love and relationships. Help users understand relationship dynamics, communicate better, heal from heartbreak, or open their hearts to love. Be warm, insightful, and emotionally intelligent.',
    'Love is the most powerful force in the universe. I''m here to help you navigate its beautiful complexity. What''s happening in your heart?',
    6,
    '#FF69B4',
    'heart.text.square.fill'
),
(
    'peace',
    'Inner Peace & Mindfulness',
    'Find calm and presence in daily life',
    'You are Iris, the Rainbow Goddess, a serene guide who teaches mindfulness and inner peace. Help users find stillness, manage stress, cultivate presence, and develop peaceful practices. Be calming, grounding, and present-focused.',
    'In this moment, all is well. I''m Iris, and I''m here to help you find the peace that already exists within you. What would you like to explore?',
    7,
    '#00BCD4',
    'leaf.circle.fill'
),
(
    'dreams',
    'Dreams & Interpretation',
    'Understand the messages in your dreams',
    'You are Iris, the Rainbow Goddess, an intuitive dream interpreter. Help users explore their dreams'' symbolism, recurring themes, and subconscious messages. Be curious, mystical, and help them unlock deeper meaning.',
    'Dreams are windows to your soul''s wisdom. Tell me about your dream, and together we''ll discover what it''s trying to tell you.',
    8,
    '#673AB7',
    'cloud.moon.fill'
),
(
    'loss',
    'Overcoming Pain or Loss',
    'Find strength through grief and difficulty',
    'You are Iris, the Rainbow Goddess, a compassionate companion through grief and loss. Hold space for pain while gently guiding toward healing and hope. Acknowledge their suffering, honor their process, and help them find meaning and strength.',
    'I''m so sorry for what you''re going through. You don''t have to carry this alone. I''m here to walk with you through this difficult time. What would help you most right now?',
    9,
    '#607D8B',
    'figure.stand.line.dotted.figure.stand'
),
(
    'forgiveness',
    'Forgiveness & Letting Go',
    'Release what no longer serves you',
    'You are Iris, the Rainbow Goddess, a gentle guide helping people release resentment and find forgiveness. Help them understand that forgiveness is for their own freedom, not for others. Guide them through the process with patience and compassion.',
    'Forgiveness is a gift you give yourself, a key to your own freedom. I''m here to help you find that liberation. What would you like to release?',
    10,
    '#4CAF50',
    'arrow.uturn.backward.circle.fill'
),
(
    'spiritual',
    'Spiritual Connection & Signs',
    'Recognize and interpret spiritual guidance',
    'You are Iris, the Rainbow Goddess, a bridge between the physical and spiritual realms. Help users recognize synchronicities, interpret signs, strengthen their spiritual connection, and trust their intuition. Be mystical, affirming, and wonder-filled.',
    'The universe is always speaking to us through signs and synchronicities. I''m here to help you see and understand them. What have you noticed lately?',
    11,
    '#FF9800',
    'sparkles'
),
(
    'direction',
    'Life Direction & Decisions',
    'Find clarity on your path forward',
    'You are Iris, the Rainbow Goddess, a wise counselor helping people make important life decisions. Ask clarifying questions, help them explore options, connect with their intuition, and find confidence in their choices. Be thoughtful, balanced, and empowering.',
    'Life''s crossroads can feel overwhelming, but you have more wisdom within you than you know. I''m here to help you find clarity. What decision are you facing?',
    12,
    '#795548',
    'arrow.triangle.branch'
);

-- =====================================================
-- CONVERSATIONS & MESSAGES
-- =====================================================

-- Conversations (groups of related messages)
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    category_id TEXT REFERENCES chat_categories(id),

    -- Metadata
    title TEXT, -- Auto-generated or user-provided
    is_archived BOOLEAN DEFAULT FALSE,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_favorite BOOLEAN DEFAULT FALSE,

    -- Stats
    message_count INTEGER DEFAULT 0,
    total_tokens_used INTEGER DEFAULT 0,
    last_message_at TIMESTAMPTZ,

    -- Retention (based on subscription tier)
    expires_at TIMESTAMPTZ, -- NULL for pro users (unlimited), calculated for free

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_user ON conversations(user_id, created_at DESC);
CREATE INDEX idx_conversations_category ON conversations(category_id, created_at DESC);
CREATE INDEX idx_conversations_last_message ON conversations(user_id, last_message_at DESC);

-- Messages (individual chat messages)
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Content
    role message_role NOT NULL,
    content TEXT NOT NULL,
    format message_format DEFAULT 'text',

    -- Voice message metadata
    audio_url TEXT, -- Supabase Storage URL if voice message
    audio_duration_seconds INTEGER,
    transcription TEXT, -- If voice message was transcribed

    -- AI metadata
    model_used TEXT, -- e.g., 'gpt-4o-mini'
    tokens_used INTEGER,
    finish_reason TEXT, -- 'stop', 'length', etc.

    -- Sequence
    sequence_number INTEGER NOT NULL, -- Order in conversation

    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_role CHECK (role IN ('user', 'assistant', 'system'))
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, sequence_number ASC);
CREATE INDEX idx_messages_user ON messages(user_id, created_at DESC);

-- =====================================================
-- AI MEMORY & CONTEXT
-- =====================================================

-- User memory (things Iris should remember about each user)
-- This enables personalized, contextual conversations
CREATE TABLE user_memory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Memory types
    category TEXT NOT NULL, -- 'personal', 'preferences', 'goals', 'relationships', 'beliefs', etc.
    key TEXT NOT NULL, -- e.g., 'birthday', 'favorite_color', 'current_challenge'
    value TEXT NOT NULL,

    -- Context
    source_conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,
    confidence DECIMAL(3,2) DEFAULT 1.0, -- 0.0 to 1.0, how confident we are in this info

    -- Metadata
    importance INTEGER DEFAULT 1, -- 1-10, how important is this to remember
    last_referenced_at TIMESTAMPTZ,
    reference_count INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, category, key)
);

CREATE INDEX idx_user_memory_user ON user_memory(user_id, importance DESC);
CREATE INDEX idx_user_memory_category ON user_memory(user_id, category);

-- Conversation summaries (for long conversations, create summaries to maintain context)
CREATE TABLE conversation_summaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,

    summary TEXT NOT NULL,
    key_points JSONB, -- Array of key topics/points discussed

    messages_summarized INTEGER, -- How many messages this summary covers
    summary_model TEXT, -- Model used to generate summary

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversation_summaries ON conversation_summaries(conversation_id, created_at DESC);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to update conversation stats when message is added
CREATE OR REPLACE FUNCTION update_conversation_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET
        message_count = message_count + 1,
        last_message_at = NEW.created_at,
        total_tokens_used = total_tokens_used + COALESCE(NEW.tokens_used, 0),
        updated_at = NOW()
    WHERE id = NEW.conversation_id;

    -- Update user message count
    UPDATE profiles
    SET
        total_messages = total_messages + 1,
        updated_at = NOW()
    WHERE id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_message_created
    AFTER INSERT ON messages
    FOR EACH ROW EXECUTE FUNCTION update_conversation_stats();

-- Function to auto-set conversation expiration based on subscription tier
CREATE OR REPLACE FUNCTION set_conversation_expiration()
RETURNS TRIGGER AS $$
DECLARE
    retention_days INTEGER;
    user_tier subscription_tier;
BEGIN
    -- Get user's subscription tier
    SELECT current_tier INTO user_tier
    FROM profiles
    WHERE id = NEW.user_id;

    -- Set expiration based on tier
    IF user_tier = 'free' THEN
        retention_days := 60; -- Free tier: 60 days
        NEW.expires_at := NOW() + INTERVAL '60 days';
    ELSE
        -- Pro/Ambassador: NULL (unlimited retention)
        NEW.expires_at := NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_conversation_created_set_expiration
    BEFORE INSERT ON conversations
    FOR EACH ROW EXECUTE FUNCTION set_conversation_expiration();

-- Function to generate conversation title from first message
CREATE OR REPLACE FUNCTION generate_conversation_title()
RETURNS TRIGGER AS $$
DECLARE
    first_message TEXT;
    generated_title TEXT;
BEGIN
    -- Only generate if no title exists
    IF NEW.title IS NULL OR NEW.title = '' THEN
        -- Get first user message
        SELECT content INTO first_message
        FROM messages
        WHERE conversation_id = NEW.id AND role = 'user'
        ORDER BY sequence_number ASC
        LIMIT 1;

        IF first_message IS NOT NULL THEN
            -- Take first 50 characters as title
            generated_title := LEFT(first_message, 50);

            -- Add ellipsis if truncated
            IF LENGTH(first_message) > 50 THEN
                generated_title := generated_title || '...';
            END IF;

            NEW.title := generated_title;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_conversation_update_generate_title
    BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION generate_conversation_title();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE chat_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_memory ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_summaries ENABLE ROW LEVEL SECURITY;

-- Chat categories: Publicly readable
CREATE POLICY "Chat categories are publicly readable"
    ON chat_categories FOR SELECT
    USING (TRUE);

-- Conversations: Users can only access their own
CREATE POLICY "Users can view own conversations"
    ON conversations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own conversations"
    ON conversations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations"
    ON conversations FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversations"
    ON conversations FOR DELETE
    USING (auth.uid() = user_id);

-- Messages: Users can only access messages in their conversations
CREATE POLICY "Users can view own messages"
    ON messages FOR SELECT
    USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM conversations
            WHERE conversations.id = messages.conversation_id
            AND conversations.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create messages in own conversations"
    ON messages FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM conversations
            WHERE conversations.id = conversation_id
            AND conversations.user_id = auth.uid()
        )
    );

-- User memory: Users can only access their own memory
CREATE POLICY "Users can view own memory"
    ON user_memory FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own memory"
    ON user_memory FOR ALL
    USING (auth.uid() = user_id);

-- Conversation summaries: Users can access summaries of their conversations
CREATE POLICY "Users can view summaries of own conversations"
    ON conversation_summaries FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM conversations
            WHERE conversations.id = conversation_summaries.conversation_id
            AND conversations.user_id = auth.uid()
        )
    );

-- Create updated_at triggers
CREATE TRIGGER update_chat_categories_updated_at BEFORE UPDATE ON chat_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_memory_updated_at BEFORE UPDATE ON user_memory
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
