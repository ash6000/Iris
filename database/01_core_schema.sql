-- =====================================================
-- IRIS LIGHT WITHIN - CORE DATABASE SCHEMA
-- Part 1: Core Tables (Users, Subscriptions, Preferences)
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- ENUM TYPES
-- =====================================================

CREATE TYPE subscription_tier AS ENUM ('free', 'pro', 'ambassador');
CREATE TYPE subscription_status AS ENUM ('active', 'cancelled', 'expired', 'trial');
CREATE TYPE language_code AS ENUM ('en', 'es', 'fr', 'de', 'pt', 'it', 'zh', 'ja', 'ko', 'ar', 'hi');
CREATE TYPE cultural_variant AS ENUM ('western', 'latin', 'asian', 'middle_eastern', 'african', 'indian');
CREATE TYPE notification_type AS ENUM ('affirmation', 'horoscope', 'reminder', 'feature', 'ambassador');

-- =====================================================
-- CORE USER TABLES
-- =====================================================

-- User profiles (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    display_name TEXT,
    avatar_url TEXT,

    -- Preferences
    language language_code DEFAULT 'en',
    cultural_variant cultural_variant DEFAULT 'western',
    timezone TEXT DEFAULT 'UTC',

    -- Subscription info
    current_tier subscription_tier DEFAULT 'free',
    subscription_expires_at TIMESTAMPTZ,

    -- Onboarding
    has_completed_onboarding BOOLEAN DEFAULT FALSE,
    onboarding_completed_at TIMESTAMPTZ,

    -- Stats
    total_conversations INTEGER DEFAULT 0,
    total_messages INTEGER DEFAULT 0,
    total_mood_entries INTEGER DEFAULT 0,
    total_journal_entries INTEGER DEFAULT 0,
    current_streak_days INTEGER DEFAULT 0,
    longest_streak_days INTEGER DEFAULT 0,
    last_active_date DATE,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- User preferences (detailed settings)
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Notification preferences
    enable_push_notifications BOOLEAN DEFAULT TRUE,
    enable_affirmations BOOLEAN DEFAULT TRUE,
    enable_horoscopes BOOLEAN DEFAULT FALSE,
    affirmation_time TIME DEFAULT '09:00:00',
    horoscope_time TIME DEFAULT '07:00:00',

    -- Voice & Accessibility
    enable_voice_mode BOOLEAN DEFAULT TRUE,
    voice_speed DECIMAL(3,2) DEFAULT 1.0, -- 0.5 to 2.0
    enable_text_to_speech BOOLEAN DEFAULT FALSE,
    text_size_multiplier DECIMAL(3,2) DEFAULT 1.0,

    -- Privacy & Data
    allow_data_collection BOOLEAN DEFAULT TRUE,
    allow_personalization BOOLEAN DEFAULT TRUE,
    chat_retention_days INTEGER DEFAULT 60, -- 60 for free, unlimited for pro

    -- UI Preferences
    theme TEXT DEFAULT 'light', -- 'light', 'dark', 'auto'
    show_tutorial BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id)
);

-- =====================================================
-- SUBSCRIPTION MANAGEMENT
-- =====================================================

-- Subscription tiers definition
CREATE TABLE subscription_tiers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),

    -- Features
    max_conversations INTEGER, -- NULL = unlimited
    max_messages_per_day INTEGER, -- NULL = unlimited
    max_token_limit INTEGER, -- Per message or session
    chat_retention_days INTEGER, -- NULL = unlimited
    allow_export BOOLEAN DEFAULT FALSE,
    show_ads BOOLEAN DEFAULT TRUE,
    priority_access BOOLEAN DEFAULT FALSE,

    -- Limits
    free_minutes INTEGER, -- For free tier (60 minutes initially)
    ad_interval_minutes INTEGER, -- Show ad every X minutes for free tier

    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default tiers
INSERT INTO subscription_tiers (id, name, description, price_monthly, price_yearly, max_conversations, max_messages_per_day, chat_retention_days, allow_export, show_ads, free_minutes, ad_interval_minutes) VALUES
('free', 'Free Forever', 'Full access with ads, 60-day chat history', 0, 0, NULL, NULL, 60, FALSE, TRUE, 60, 30),
('pro', 'Pro', 'Ad-free, unlimited chat history, export chats', 9.95, 99.50, NULL, NULL, NULL, TRUE, FALSE, NULL, NULL),
('ambassador', 'Ambassador', 'Full access for volunteer ambassadors', 0, 0, NULL, NULL, NULL, TRUE, FALSE, NULL, NULL);

-- User subscriptions (history)
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    tier subscription_tier NOT NULL,
    status subscription_status DEFAULT 'active',

    -- Billing
    stripe_subscription_id TEXT UNIQUE,
    stripe_customer_id TEXT,

    -- Dates
    started_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    trial_ends_at TIMESTAMPTZ,

    -- Metadata
    is_trial BOOLEAN DEFAULT FALSE,
    is_annual BOOLEAN DEFAULT FALSE,
    discount_code TEXT,
    discount_percent INTEGER,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Token usage tracking (for cost management)
CREATE TABLE token_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Usage metrics
    tokens_used INTEGER NOT NULL,
    tokens_limit INTEGER, -- Daily or session limit
    estimated_cost DECIMAL(10,4), -- In USD

    -- Context
    context_type TEXT, -- 'chat', 'voice', 'meditation', etc.
    conversation_id UUID, -- Reference to conversation if applicable

    -- Time tracking
    usage_date DATE DEFAULT CURRENT_DATE,
    session_duration_seconds INTEGER,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT positive_tokens CHECK (tokens_used >= 0)
);

-- Create indexes for performance
CREATE INDEX idx_token_usage_user_date ON token_usage(user_id, usage_date DESC);
CREATE INDEX idx_token_usage_date ON token_usage(usage_date DESC);

-- =====================================================
-- LANGUAGE & CULTURAL VARIANTS
-- =====================================================

-- Languages available
CREATE TABLE languages (
    code language_code PRIMARY KEY,
    name TEXT NOT NULL,
    native_name TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert supported languages
INSERT INTO languages (code, name, native_name, display_order) VALUES
('en', 'English', 'English', 1),
('es', 'Spanish', 'Español', 2),
('fr', 'French', 'Français', 3),
('de', 'German', 'Deutsch', 4),
('pt', 'Portuguese', 'Português', 5),
('it', 'Italian', 'Italiano', 6),
('zh', 'Chinese', '中文', 7),
('ja', 'Japanese', '日本語', 8),
('ko', 'Korean', '한국어', 9),
('ar', 'Arabic', 'العربية', 10),
('hi', 'Hindi', 'हिन्दी', 11);

-- Cultural variants (Iris appearance/tone variations)
CREATE TABLE cultural_variants (
    id cultural_variant PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,

    -- Visual assets
    avatar_2d_url TEXT,
    avatar_3d_url TEXT,
    color_scheme JSONB, -- { "primary": "#hex", "secondary": "#hex" }

    -- Tone adjustments
    tone_description TEXT, -- How Iris should speak in this variant

    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert cultural variants
INSERT INTO cultural_variants (id, name, description, display_order) VALUES
('western', 'Western', 'Modern, warm, and approachable style', 1),
('latin', 'Latin American', 'Vibrant, warm, and family-oriented', 2),
('asian', 'East Asian', 'Harmonious, respectful, and contemplative', 3),
('middle_eastern', 'Middle Eastern', 'Wise, poetic, and deeply spiritual', 4),
('african', 'African', 'Community-focused, rhythmic, and ancestral', 5),
('indian', 'South Asian', 'Philosophical, colorful, and holistic', 6);

-- =====================================================
-- COMPLIANCE & LEGAL
-- =====================================================

-- Terms and conditions acceptance log
CREATE TABLE terms_acceptances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    document_type TEXT NOT NULL, -- 'terms', 'privacy', 'disclaimer'
    document_version TEXT NOT NULL,

    accepted_at TIMESTAMPTZ DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,

    CONSTRAINT valid_document_type CHECK (document_type IN ('terms', 'privacy', 'disclaimer', 'medical_disclaimer'))
);

CREATE INDEX idx_terms_user ON terms_acceptances(user_id, document_type, accepted_at DESC);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_tiers_updated_at BEFORE UPDATE ON subscription_tiers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at BEFORE UPDATE ON user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', '')
    );

    INSERT INTO public.user_preferences (user_id)
    VALUES (NEW.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create profile on auth.users insert
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE token_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE terms_acceptances ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can only see/update their own profile
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- User preferences: Users can only manage their own preferences
CREATE POLICY "Users can view own preferences"
    ON user_preferences FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
    ON user_preferences FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences"
    ON user_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Subscriptions: Users can only view their own subscription history
CREATE POLICY "Users can view own subscriptions"
    ON user_subscriptions FOR SELECT
    USING (auth.uid() = user_id);

-- Token usage: Users can view own usage
CREATE POLICY "Users can view own token usage"
    ON token_usage FOR SELECT
    USING (auth.uid() = user_id);

-- Terms acceptances: Users can view own acceptances
CREATE POLICY "Users can view own terms acceptances"
    ON terms_acceptances FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own terms acceptances"
    ON terms_acceptances FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Public read access for reference tables
ALTER TABLE subscription_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
ALTER TABLE cultural_variants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Subscription tiers are publicly readable"
    ON subscription_tiers FOR SELECT
    USING (TRUE);

CREATE POLICY "Languages are publicly readable"
    ON languages FOR SELECT
    USING (TRUE);

CREATE POLICY "Cultural variants are publicly readable"
    ON cultural_variants FOR SELECT
    USING (TRUE);
