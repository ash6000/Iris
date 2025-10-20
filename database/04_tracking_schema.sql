-- =====================================================
-- IRIS LIGHT WITHIN - TRACKING & JOURNALING SCHEMA
-- Part 4: Mood Tracking, Journals, User Analytics
-- =====================================================

-- =====================================================
-- ENUM TYPES
-- =====================================================

CREATE TYPE mood_type AS ENUM ('very_bad', 'bad', 'neutral', 'good', 'excellent');
CREATE TYPE journal_type AS ENUM ('text', 'voice', 'both');
CREATE TYPE entry_privacy AS ENUM ('private', 'shared', 'diary'); -- diary = for loved ones feature

-- =====================================================
-- MOOD TRACKING
-- =====================================================

CREATE TABLE mood_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Mood data
    mood mood_type NOT NULL,
    mood_score INTEGER, -- 1-10 numeric value

    -- Context
    note TEXT,
    tags TEXT[], -- ['stressed', 'happy', 'anxious', 'grateful', etc.]
    activities TEXT[], -- What they were doing
    location TEXT, -- Where they were

    -- Associations
    related_conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,

    -- Time
    entry_date DATE DEFAULT CURRENT_DATE,
    entry_time TIME DEFAULT CURRENT_TIME,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_mood_score CHECK (mood_score >= 1 AND mood_score <= 10)
);

CREATE INDEX idx_mood_entries_user_date ON mood_entries(user_id, entry_date DESC);
CREATE INDEX idx_mood_entries_mood ON mood_entries(user_id, mood, entry_date DESC);
CREATE INDEX idx_mood_entries_tags ON mood_entries USING GIN(tags);

-- Mood insights/analytics (pre-calculated for performance)
CREATE TABLE mood_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Time period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    period_type TEXT NOT NULL, -- 'week', 'month', 'year'

    -- Statistics
    average_mood_score DECIMAL(4,2),
    total_entries INTEGER,
    best_mood mood_type,
    worst_mood mood_type,
    most_frequent_tags TEXT[],

    -- Trends
    trend_direction TEXT, -- 'improving', 'declining', 'stable'
    weekly_pattern JSONB, -- Day of week patterns

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, period_start, period_end, period_type)
);

CREATE INDEX idx_mood_analytics ON mood_analytics(user_id, period_start DESC);

-- =====================================================
-- JOURNAL ENTRIES
-- =====================================================

CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Entry data
    title TEXT,
    content TEXT NOT NULL,
    type journal_type DEFAULT 'text',
    privacy entry_privacy DEFAULT 'private',

    -- Voice journal metadata
    audio_url TEXT, -- Supabase Storage URL if voice journal
    audio_duration_seconds INTEGER,
    transcription TEXT, -- Auto-transcribed from voice

    -- Categorization
    tags TEXT[],
    mood_at_time mood_type,
    related_mood_entry_id UUID REFERENCES mood_entries(id) ON DELETE SET NULL,

    -- Diary for loved ones feature
    intended_recipient TEXT, -- Who this diary entry is for
    share_after_date DATE, -- When to make available (posthumous sharing)

    -- Engagement
    is_favorite BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,

    -- Metadata
    entry_date DATE DEFAULT CURRENT_DATE,
    word_count INTEGER,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_journal_entries_user ON journal_entries(user_id, entry_date DESC);
CREATE INDEX idx_journal_entries_privacy ON journal_entries(privacy, user_id);
CREATE INDEX idx_journal_entries_tags ON journal_entries USING GIN(tags);
CREATE INDEX idx_journal_entries_recipient ON journal_entries(user_id, intended_recipient, privacy);

-- Voice recordings metadata (for voice journals)
CREATE TABLE voice_recordings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- File info
    storage_path TEXT NOT NULL, -- Path in Supabase Storage
    file_size_bytes BIGINT,
    duration_seconds INTEGER,
    format TEXT, -- 'm4a', 'mp3', etc.

    -- Processing
    transcription TEXT,
    transcription_status TEXT, -- 'pending', 'completed', 'failed'
    transcription_language language_code,

    -- Association
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE CASCADE,
    conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,

    -- Metadata
    recorded_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_duration CHECK (duration_seconds > 0)
);

CREATE INDEX idx_voice_recordings_user ON voice_recordings(user_id, recorded_at DESC);
CREATE INDEX idx_voice_recordings_journal ON voice_recordings(journal_entry_id);

-- =====================================================
-- SHARING & SOCIAL FEATURES
-- =====================================================

CREATE TABLE shared_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- What's being shared
    content_type TEXT NOT NULL, -- 'conversation', 'quote', 'affirmation', etc.
    content_id UUID, -- Reference to the content being shared
    content_text TEXT, -- Actual text being shared
    content_image_url TEXT, -- Generated branded image

    -- Sharing details
    share_platform TEXT, -- 'instagram', 'facebook', 'twitter', 'link', etc.
    share_url TEXT, -- Generated share link

    -- Analytics
    view_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,

    shared_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_content_type CHECK (content_type IN ('conversation', 'quote', 'affirmation', 'journal', 'insight'))
);

CREATE INDEX idx_shared_content_user ON shared_content(user_id, shared_at DESC);
CREATE INDEX idx_shared_content_type ON shared_content(content_type);

-- Share template configurations (for branded sharing)
CREATE TABLE share_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name TEXT NOT NULL,
    description TEXT,
    template_type TEXT NOT NULL, -- 'instagram_story', 'square_post', etc.

    -- Design
    background_image_url TEXT,
    logo_url TEXT,
    font_config JSONB, -- Font family, sizes, colors
    layout_config JSONB, -- Positioning, margins, etc.

    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- USER ANALYTICS & ENGAGEMENT
-- =====================================================

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Session info
    session_start TIMESTAMPTZ DEFAULT NOW(),
    session_end TIMESTAMPTZ,
    duration_seconds INTEGER,

    -- Activity
    screens_visited TEXT[],
    features_used TEXT[],
    messages_sent INTEGER DEFAULT 0,
    meditations_played INTEGER DEFAULT 0,

    -- Device
    device_type TEXT, -- 'ios', 'android', 'web'
    app_version TEXT,
    os_version TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_sessions ON user_sessions(user_id, session_start DESC);

-- Daily engagement metrics
CREATE TABLE daily_engagement (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    activity_date DATE DEFAULT CURRENT_DATE,

    -- Counts
    sessions_count INTEGER DEFAULT 0,
    total_time_seconds INTEGER DEFAULT 0,
    messages_sent INTEGER DEFAULT 0,
    mood_entries INTEGER DEFAULT 0,
    journal_entries INTEGER DEFAULT 0,
    meditations_completed INTEGER DEFAULT 0,

    -- Streaks
    is_active_day BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, activity_date)
);

CREATE INDEX idx_daily_engagement ON daily_engagement(user_id, activity_date DESC);

-- Feature usage tracking
CREATE TABLE feature_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    feature_name TEXT NOT NULL,
    usage_count INTEGER DEFAULT 1,

    first_used_at TIMESTAMPTZ DEFAULT NOW(),
    last_used_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, feature_name)
);

CREATE INDEX idx_feature_usage ON feature_usage(user_id, feature_name);

-- =====================================================
-- ONBOARDING TRACKING
-- =====================================================

CREATE TABLE onboarding_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Onboarding data
    question_id TEXT NOT NULL,
    question_text TEXT,
    answer_value TEXT,
    answer_index INTEGER,

    -- Personality assessment results
    personality_type TEXT,
    traits JSONB, -- Key insights about the user

    sequence_number INTEGER,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, question_id)
);

CREATE INDEX idx_onboarding_responses ON onboarding_responses(user_id, sequence_number);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to calculate user streak
CREATE OR REPLACE FUNCTION calculate_user_streak(p_user_id UUID)
RETURNS TABLE (
    current_streak INTEGER,
    longest_streak INTEGER,
    last_active_date DATE
) AS $$
DECLARE
    streak_count INTEGER := 0;
    max_streak INTEGER := 0;
    check_date DATE;
    has_activity BOOLEAN;
    last_date DATE;
BEGIN
    -- Get most recent activity date
    SELECT MAX(activity_date) INTO last_date
    FROM daily_engagement
    WHERE user_id = p_user_id AND is_active_day = TRUE;

    -- Calculate current streak
    check_date := CURRENT_DATE;
    LOOP
        SELECT EXISTS(
            SELECT 1 FROM daily_engagement
            WHERE user_id = p_user_id
              AND activity_date = check_date
              AND is_active_day = TRUE
        ) INTO has_activity;

        EXIT WHEN NOT has_activity;

        streak_count := streak_count + 1;
        check_date := check_date - INTERVAL '1 day';
    END LOOP;

    -- Calculate longest streak (this is simplified - would need more complex logic for full history)
    max_streak := GREATEST(streak_count, COALESCE((
        SELECT longest_streak_days FROM profiles WHERE id = p_user_id
    ), 0));

    RETURN QUERY SELECT streak_count, max_streak, last_date;
END;
$$ LANGUAGE plpgsql;

-- Function to update daily engagement
CREATE OR REPLACE FUNCTION update_daily_engagement(
    p_user_id UUID,
    p_activity_type TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO daily_engagement (user_id, activity_date, sessions_count, is_active_day)
    VALUES (p_user_id, CURRENT_DATE, 1, TRUE)
    ON CONFLICT (user_id, activity_date)
    DO UPDATE SET
        sessions_count = daily_engagement.sessions_count + 1,
        is_active_day = TRUE,
        total_time_seconds = CASE
            WHEN p_activity_type = 'session_end' THEN daily_engagement.total_time_seconds + 1
            ELSE daily_engagement.total_time_seconds
        END,
        messages_sent = CASE
            WHEN p_activity_type = 'message' THEN daily_engagement.messages_sent + 1
            ELSE daily_engagement.messages_sent
        END,
        mood_entries = CASE
            WHEN p_activity_type = 'mood' THEN daily_engagement.mood_entries + 1
            ELSE daily_engagement.mood_entries
        END,
        journal_entries = CASE
            WHEN p_activity_type = 'journal' THEN daily_engagement.journal_entries + 1
            ELSE daily_engagement.journal_entries
        END;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update streak when mood entry is created
CREATE OR REPLACE FUNCTION update_streak_on_mood_entry()
RETURNS TRIGGER AS $$
DECLARE
    streak_data RECORD;
BEGIN
    -- Update daily engagement
    PERFORM update_daily_engagement(NEW.user_id, 'mood');

    -- Recalculate streak
    SELECT * INTO streak_data FROM calculate_user_streak(NEW.user_id);

    -- Update user profile
    UPDATE profiles
    SET
        current_streak_days = streak_data.current_streak,
        longest_streak_days = streak_data.longest_streak,
        last_active_date = CURRENT_DATE,
        total_mood_entries = total_mood_entries + 1
    WHERE id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_mood_entry_created
    AFTER INSERT ON mood_entries
    FOR EACH ROW EXECUTE FUNCTION update_streak_on_mood_entry();

-- Trigger to update journal count
CREATE OR REPLACE FUNCTION update_journal_count()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_daily_engagement(NEW.user_id, 'journal');

    UPDATE profiles
    SET total_journal_entries = total_journal_entries + 1
    WHERE id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_journal_entry_created
    AFTER INSERT ON journal_entries
    FOR EACH ROW EXECUTE FUNCTION update_journal_count();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE mood_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE mood_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_recordings ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE share_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_engagement ENABLE ROW LEVEL SECURITY;
ALTER TABLE feature_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_responses ENABLE ROW LEVEL SECURITY;

-- Mood entries: Users can only access their own
CREATE POLICY "Users can manage own mood entries"
    ON mood_entries FOR ALL
    USING (auth.uid() = user_id);

-- Mood analytics
CREATE POLICY "Users can view own mood analytics"
    ON mood_analytics FOR SELECT
    USING (auth.uid() = user_id);

-- Journal entries: Users can only access their own (with privacy controls)
CREATE POLICY "Users can manage own journal entries"
    ON journal_entries FOR ALL
    USING (auth.uid() = user_id);

-- Voice recordings
CREATE POLICY "Users can manage own voice recordings"
    ON voice_recordings FOR ALL
    USING (auth.uid() = user_id);

-- Shared content
CREATE POLICY "Users can manage own shared content"
    ON shared_content FOR ALL
    USING (auth.uid() = user_id);

-- Public can view shared content via public links
CREATE POLICY "Public can view shared content"
    ON shared_content FOR SELECT
    USING (TRUE);

-- Share templates: Publicly readable
CREATE POLICY "Share templates are publicly readable"
    ON share_templates FOR SELECT
    USING (is_active = TRUE);

-- User sessions
CREATE POLICY "Users can view own sessions"
    ON user_sessions FOR ALL
    USING (auth.uid() = user_id);

-- Daily engagement
CREATE POLICY "Users can view own engagement"
    ON daily_engagement FOR ALL
    USING (auth.uid() = user_id);

-- Feature usage
CREATE POLICY "Users can view own feature usage"
    ON feature_usage FOR ALL
    USING (auth.uid() = user_id);

-- Onboarding responses
CREATE POLICY "Users can manage own onboarding responses"
    ON onboarding_responses FOR ALL
    USING (auth.uid() = user_id);

-- Create updated_at triggers
CREATE TRIGGER update_mood_entries_updated_at BEFORE UPDATE ON mood_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_journal_entries_updated_at BEFORE UPDATE ON journal_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
