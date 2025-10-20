-- =====================================================
-- IRIS LIGHT WITHIN - CONTENT LIBRARY SCHEMA
-- Part 3: Meditations, Affirmations, Horoscopes, Content
-- =====================================================

-- =====================================================
-- ENUM TYPES
-- =====================================================

CREATE TYPE content_type AS ENUM ('meditation', 'sleep', 'breathwork', 'music');
CREATE TYPE difficulty_level AS ENUM ('beginner', 'intermediate', 'advanced', 'all');
CREATE TYPE zodiac_sign AS ENUM ('aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces');

-- =====================================================
-- MEDITATION & SLEEP LIBRARY
-- =====================================================

CREATE TABLE meditation_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Basic info
    title TEXT NOT NULL,
    description TEXT,
    type content_type NOT NULL,

    -- Content
    audio_url TEXT, -- Supabase Storage URL
    video_url TEXT, -- Optional video version
    thumbnail_url TEXT,
    transcript TEXT, -- Full text of meditation

    -- Metadata
    duration_seconds INTEGER NOT NULL,
    difficulty difficulty_level DEFAULT 'all',
    voice_artist TEXT, -- Who recorded it

    -- Categorization
    tags TEXT[], -- ['anxiety', 'sleep', 'stress', etc.]
    categories TEXT[], -- ['Morning', 'Evening', 'Quick Break', etc.]

    -- Engagement
    play_count INTEGER DEFAULT 0,
    favorite_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2), -- 0.00 to 5.00

    -- Access control
    is_premium BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT TRUE,

    -- Localization
    language language_code DEFAULT 'en',

    -- Ordering
    display_order INTEGER DEFAULT 0,
    featured_order INTEGER, -- NULL if not featured

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_meditation_type ON meditation_content(type, display_order);
CREATE INDEX idx_meditation_tags ON meditation_content USING GIN(tags);
CREATE INDEX idx_meditation_language ON meditation_content(language, is_published);

-- User meditation progress
CREATE TABLE meditation_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    meditation_id UUID NOT NULL REFERENCES meditation_content(id) ON DELETE CASCADE,

    -- Session data
    completed BOOLEAN DEFAULT FALSE,
    progress_seconds INTEGER DEFAULT 0,
    completion_percentage INTEGER DEFAULT 0,

    -- Feedback
    rating INTEGER, -- 1-5 stars
    notes TEXT,

    session_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_rating CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT valid_percentage CHECK (completion_percentage >= 0 AND completion_percentage <= 100)
);

CREATE INDEX idx_meditation_sessions_user ON meditation_sessions(user_id, session_date DESC);
CREATE INDEX idx_meditation_sessions_content ON meditation_sessions(meditation_id);

-- User favorites
CREATE TABLE meditation_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    meditation_id UUID NOT NULL REFERENCES meditation_content(id) ON DELETE CASCADE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, meditation_id)
);

CREATE INDEX idx_meditation_favorites_user ON meditation_favorites(user_id);

-- =====================================================
-- DAILY AFFIRMATIONS
-- =====================================================

CREATE TABLE affirmations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Content
    text TEXT NOT NULL,
    author TEXT, -- Attribution if from someone specific
    category TEXT, -- 'Love', 'Abundance', 'Health', 'Purpose', etc.

    -- Localization
    language language_code DEFAULT 'en',
    cultural_variant cultural_variant,

    -- Metadata
    tags TEXT[],
    is_active BOOLEAN DEFAULT TRUE,

    -- Usage tracking
    times_shown INTEGER DEFAULT 0,
    times_shared INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_affirmations_language ON affirmations(language, is_active);
CREATE INDEX idx_affirmations_category ON affirmations(category);

-- User affirmation history (to avoid repeats)
CREATE TABLE user_affirmations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    affirmation_id UUID NOT NULL REFERENCES affirmations(id) ON DELETE CASCADE,

    -- Engagement
    was_favorited BOOLEAN DEFAULT FALSE,
    was_shared BOOLEAN DEFAULT FALSE,

    shown_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_affirmations ON user_affirmations(user_id, shown_date DESC);
CREATE UNIQUE INDEX idx_user_affirmation_date ON user_affirmations(user_id, affirmation_id, shown_date);

-- =====================================================
-- HOROSCOPES
-- =====================================================

CREATE TABLE horoscopes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    zodiac_sign zodiac_sign NOT NULL,
    horoscope_date DATE NOT NULL,

    -- Content
    daily_message TEXT NOT NULL,
    love_forecast TEXT,
    career_forecast TEXT,
    wellness_forecast TEXT,
    lucky_numbers INTEGER[],
    lucky_color TEXT,

    -- Metadata
    language language_code DEFAULT 'en',
    is_published BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(zodiac_sign, horoscope_date, language)
);

CREATE INDEX idx_horoscopes_date ON horoscopes(horoscope_date DESC, is_published);
CREATE INDEX idx_horoscopes_sign ON horoscopes(zodiac_sign, horoscope_date DESC);

-- User horoscope subscriptions
CREATE TABLE user_horoscope_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    zodiac_sign zodiac_sign NOT NULL,
    birth_date DATE, -- Optional, for more personalized readings

    is_active BOOLEAN DEFAULT TRUE,
    notification_enabled BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, zodiac_sign)
);

CREATE INDEX idx_user_horoscope_subs ON user_horoscope_subscriptions(user_id, is_active);

-- =====================================================
-- PUSH NOTIFICATIONS
-- =====================================================

CREATE TABLE push_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Targeting
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE, -- NULL for broadcast
    target_tier subscription_tier, -- NULL for all tiers

    -- Content
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB, -- Additional payload for deep linking, etc.

    -- Related content
    affirmation_id UUID REFERENCES affirmations(id) ON DELETE SET NULL,
    horoscope_id UUID REFERENCES horoscopes(id) ON DELETE SET NULL,

    -- Scheduling
    scheduled_for TIMESTAMPTZ NOT NULL,
    sent_at TIMESTAMPTZ,
    is_sent BOOLEAN DEFAULT FALSE,

    -- Engagement
    opened_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_push_notifications_scheduled ON push_notifications(scheduled_for, is_sent);
CREATE INDEX idx_push_notifications_user ON push_notifications(user_id, scheduled_for DESC);

-- Notification delivery tracking
CREATE TABLE notification_delivery (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID NOT NULL REFERENCES push_notifications(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Status
    delivered_at TIMESTAMPTZ,
    opened_at TIMESTAMPTZ,
    clicked_at TIMESTAMPTZ,

    -- Device info
    device_token TEXT, -- FCM/APNs token
    platform TEXT, -- 'ios', 'android'

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notification_delivery ON notification_delivery(notification_id, user_id);

-- =====================================================
-- QUOTES & SPIRITUAL CONTENT
-- =====================================================

CREATE TABLE spiritual_quotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    quote TEXT NOT NULL,
    author TEXT,
    source TEXT, -- Book, tradition, etc.

    -- Categorization
    category TEXT, -- 'Wisdom', 'Love', 'Peace', etc.
    tradition TEXT, -- 'Buddhism', 'Christianity', 'Universal', etc.
    tags TEXT[],

    -- Localization
    language language_code DEFAULT 'en',

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_spiritual_quotes ON spiritual_quotes(language, is_active);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to get random affirmation for user (avoiding recent ones)
CREATE OR REPLACE FUNCTION get_random_affirmation(
    p_user_id UUID,
    p_language language_code DEFAULT 'en',
    p_days_to_avoid INTEGER DEFAULT 30
)
RETURNS TABLE (
    affirmation_id UUID,
    text TEXT,
    category TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.text, a.category
    FROM affirmations a
    WHERE a.language = p_language
      AND a.is_active = TRUE
      AND a.id NOT IN (
          -- Exclude affirmations shown in last N days
          SELECT ua.affirmation_id
          FROM user_affirmations ua
          WHERE ua.user_id = p_user_id
            AND ua.shown_date > CURRENT_DATE - p_days_to_avoid
      )
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to get today's horoscope for user
CREATE OR REPLACE FUNCTION get_todays_horoscope(
    p_user_id UUID
)
RETURNS TABLE (
    zodiac_sign zodiac_sign,
    daily_message TEXT,
    love_forecast TEXT,
    career_forecast TEXT,
    wellness_forecast TEXT,
    lucky_numbers INTEGER[],
    lucky_color TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.zodiac_sign,
        h.daily_message,
        h.love_forecast,
        h.career_forecast,
        h.wellness_forecast,
        h.lucky_numbers,
        h.lucky_color
    FROM horoscopes h
    INNER JOIN user_horoscope_subscriptions uhs
        ON h.zodiac_sign = uhs.zodiac_sign
    WHERE uhs.user_id = p_user_id
      AND uhs.is_active = TRUE
      AND h.horoscope_date = CURRENT_DATE
      AND h.is_published = TRUE
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to update meditation engagement stats
CREATE OR REPLACE FUNCTION update_meditation_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update play count
    UPDATE meditation_content
    SET play_count = play_count + 1
    WHERE id = NEW.meditation_id;

    -- Update average rating if rating was provided
    IF NEW.rating IS NOT NULL THEN
        UPDATE meditation_content
        SET average_rating = (
            SELECT AVG(rating)::DECIMAL(3,2)
            FROM meditation_sessions
            WHERE meditation_id = NEW.meditation_id
              AND rating IS NOT NULL
        )
        WHERE id = NEW.meditation_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_meditation_session_created
    AFTER INSERT ON meditation_sessions
    FOR EACH ROW EXECUTE FUNCTION update_meditation_stats();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE meditation_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE meditation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE meditation_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE affirmations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_affirmations ENABLE ROW LEVEL SECURITY;
ALTER TABLE horoscopes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_horoscope_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE spiritual_quotes ENABLE ROW LEVEL SECURITY;

-- Meditation content: Publicly readable (premium check done in app)
CREATE POLICY "Meditation content is publicly readable"
    ON meditation_content FOR SELECT
    USING (is_published = TRUE);

-- Meditation sessions: Users can only access their own
CREATE POLICY "Users can view own meditation sessions"
    ON meditation_sessions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own meditation sessions"
    ON meditation_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meditation sessions"
    ON meditation_sessions FOR UPDATE
    USING (auth.uid() = user_id);

-- Meditation favorites
CREATE POLICY "Users can manage own favorites"
    ON meditation_favorites FOR ALL
    USING (auth.uid() = user_id);

-- Affirmations: Publicly readable
CREATE POLICY "Affirmations are publicly readable"
    ON affirmations FOR SELECT
    USING (is_active = TRUE);

-- User affirmations
CREATE POLICY "Users can view own affirmation history"
    ON user_affirmations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own affirmation records"
    ON user_affirmations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Horoscopes: Publicly readable
CREATE POLICY "Horoscopes are publicly readable"
    ON horoscopes FOR SELECT
    USING (is_published = TRUE);

-- Horoscope subscriptions
CREATE POLICY "Users can manage own horoscope subscriptions"
    ON user_horoscope_subscriptions FOR ALL
    USING (auth.uid() = user_id);

-- Spiritual quotes: Publicly readable
CREATE POLICY "Spiritual quotes are publicly readable"
    ON spiritual_quotes FOR SELECT
    USING (is_active = TRUE);

-- Create updated_at triggers
CREATE TRIGGER update_meditation_content_updated_at BEFORE UPDATE ON meditation_content
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_horoscope_subs_updated_at BEFORE UPDATE ON user_horoscope_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
