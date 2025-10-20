-- =====================================================
-- IRIS LIGHT WITHIN - AMBASSADOR PROGRAM SCHEMA
-- Part 5: Ambassador Management, Referrals, Leads
-- =====================================================

-- =====================================================
-- ENUM TYPES
-- =====================================================

CREATE TYPE ambassador_status AS ENUM ('pending', 'active', 'inactive', 'suspended');
CREATE TYPE lead_status AS ENUM ('assigned', 'contacted', 'interested', 'trial_sent', 'converted', 'not_interested', 'no_response');
CREATE TYPE referral_status AS ENUM ('pending', 'active', 'expired', 'converted');

-- =====================================================
-- AMBASSADOR PROGRAM
-- =====================================================

CREATE TABLE ambassadors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,

    -- Application info
    application_text TEXT,
    why_join TEXT,
    social_media_reach TEXT, -- Platforms and follower counts
    media_contacts TEXT, -- Press/media connections

    -- Status
    status ambassador_status DEFAULT 'pending',
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES profiles(id), -- Admin who approved

    -- Performance metrics
    total_leads_assigned INTEGER DEFAULT 0,
    leads_contacted INTEGER DEFAULT 0,
    leads_converted INTEGER DEFAULT 0,
    referral_codes_created INTEGER DEFAULT 0,
    successful_referrals INTEGER DEFAULT 0,

    -- Monthly quota
    monthly_lead_quota INTEGER DEFAULT 15,
    current_month_leads INTEGER DEFAULT 0,
    last_quota_reset DATE,

    -- Notes
    admin_notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ambassadors_status ON ambassadors(status, created_at DESC);
CREATE INDEX idx_ambassadors_performance ON ambassadors(successful_referrals DESC);

-- Ambassador referral codes (60-day trial codes)
CREATE TABLE referral_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ambassador_id UUID NOT NULL REFERENCES ambassadors(id) ON DELETE CASCADE,

    -- Code details
    code TEXT NOT NULL UNIQUE,
    description TEXT, -- What this code is for (specific campaign, media outlet, etc.)

    -- Trial configuration
    trial_days INTEGER DEFAULT 60,
    max_uses INTEGER, -- NULL for unlimited
    current_uses INTEGER DEFAULT 0,

    -- Status
    status referral_status DEFAULT 'active',
    is_active BOOLEAN DEFAULT TRUE,

    -- Validity
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,

    -- Tracking
    total_signups INTEGER DEFAULT 0,
    total_conversions INTEGER DEFAULT 0, -- How many became paying customers

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_code_format CHECK (code ~ '^[A-Z0-9_-]+$'), -- Alphanumeric + dash/underscore
    CONSTRAINT positive_uses CHECK (current_uses <= COALESCE(max_uses, current_uses))
);

CREATE INDEX idx_referral_codes_active ON referral_codes(code, is_active);
CREATE INDEX idx_referral_codes_ambassador ON referral_codes(ambassador_id, status);

-- Referral code usage tracking
CREATE TABLE referral_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referral_code_id UUID NOT NULL REFERENCES referral_codes(id) ON DELETE CASCADE,
    code TEXT NOT NULL, -- Denormalized for easier queries

    -- User who used the code
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    user_email TEXT,

    -- Outcome
    trial_started_at TIMESTAMPTZ DEFAULT NOW(),
    trial_expires_at TIMESTAMPTZ,
    converted_to_paid BOOLEAN DEFAULT FALSE,
    converted_at TIMESTAMPTZ,
    subscription_id UUID REFERENCES user_subscriptions(id),

    -- Attribution
    source TEXT, -- Where they came from ('app_store', 'web', 'social', etc.)
    utm_campaign TEXT,
    utm_medium TEXT,
    utm_source TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_referral_usage_code ON referral_usage(referral_code_id, created_at DESC);
CREATE INDEX idx_referral_usage_user ON referral_usage(user_id);
CREATE INDEX idx_referral_usage_conversion ON referral_usage(converted_to_paid, converted_at DESC);

-- Ambassador leads (15 leads per month to contact)
CREATE TABLE ambassador_leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ambassador_id UUID NOT NULL REFERENCES ambassadors(id) ON DELETE CASCADE,

    -- Lead info
    lead_name TEXT NOT NULL,
    lead_email TEXT,
    lead_phone TEXT,
    organization TEXT, -- Media outlet, podcast, blog, etc.
    lead_type TEXT, -- 'media', 'influencer', 'podcast', 'blog', etc.

    -- Status tracking
    status lead_status DEFAULT 'assigned',
    assigned_date DATE DEFAULT CURRENT_DATE,

    -- Contact attempts
    first_contact_date DATE,
    last_contact_date DATE,
    contact_count INTEGER DEFAULT 0,

    -- Outcome
    trial_code_sent TEXT, -- Referral code sent to this lead
    trial_activated BOOLEAN DEFAULT FALSE,
    converted_to_user BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES profiles(id), -- If they signed up

    -- Testimonial collection
    provided_testimonial BOOLEAN DEFAULT FALSE,
    testimonial_text TEXT,
    testimonial_approved BOOLEAN DEFAULT FALSE,

    -- Notes
    notes TEXT,
    ambassador_notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_email CHECK (lead_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR lead_email IS NULL)
);

CREATE INDEX idx_ambassador_leads ON ambassador_leads(ambassador_id, status, assigned_date DESC);
CREATE INDEX idx_ambassador_leads_status ON ambassador_leads(status, assigned_date DESC);

-- Testimonials (from lead collection)
CREATE TABLE testimonials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Source
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    lead_id UUID REFERENCES ambassador_leads(id) ON DELETE SET NULL,
    ambassador_id UUID REFERENCES ambassadors(id),

    -- Content
    testimonial_text TEXT NOT NULL,
    author_name TEXT,
    author_title TEXT, -- Their role/title
    author_organization TEXT,
    author_photo_url TEXT,

    -- Rating
    rating INTEGER, -- 1-5 stars

    -- Status
    is_approved BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,

    -- Metadata
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_rating CHECK (rating >= 1 AND rating <= 5 OR rating IS NULL)
);

CREATE INDEX idx_testimonials_status ON testimonials(is_published, is_featured, created_at DESC);

-- Ambassador communication log
CREATE TABLE ambassador_communications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ambassador_id UUID NOT NULL REFERENCES ambassadors(id) ON DELETE CASCADE,

    -- Communication details
    communication_type TEXT NOT NULL, -- 'email', 'sms', 'in-app', 'phone'
    subject TEXT,
    message TEXT NOT NULL,

    -- Lead context (if related to specific lead)
    related_lead_id UUID REFERENCES ambassador_leads(id),

    -- Status
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    opened_at TIMESTAMPTZ,
    clicked_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ambassador_comms ON ambassador_communications(ambassador_id, sent_at DESC);

-- Ambassador rewards/incentives (future feature)
CREATE TABLE ambassador_rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ambassador_id UUID NOT NULL REFERENCES ambassadors(id) ON DELETE CASCADE,

    -- Reward details
    reward_type TEXT NOT NULL, -- 'ebook', 'print_book', 'swag', 'recognition', etc.
    reward_description TEXT,

    -- Qualifying criteria
    qualified_at TIMESTAMPTZ,
    criteria_met TEXT, -- What they did to earn it

    -- Fulfillment
    is_fulfilled BOOLEAN DEFAULT FALSE,
    fulfilled_at TIMESTAMPTZ,
    tracking_number TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ambassador_rewards ON ambassador_rewards(ambassador_id, is_fulfilled);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to generate unique referral code
CREATE OR REPLACE FUNCTION generate_referral_code(
    p_ambassador_id UUID,
    p_description TEXT DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    new_code TEXT;
    code_exists BOOLEAN;
BEGIN
    -- Generate code from ambassador ID + random suffix
    LOOP
        new_code := 'IRIS' || UPPER(SUBSTRING(p_ambassador_id::TEXT, 1, 4)) || FLOOR(RANDOM() * 1000)::TEXT;

        -- Check if code already exists
        SELECT EXISTS(SELECT 1 FROM referral_codes WHERE code = new_code) INTO code_exists;

        EXIT WHEN NOT code_exists;
    END LOOP;

    -- Insert the code
    INSERT INTO referral_codes (ambassador_id, code, description)
    VALUES (p_ambassador_id, new_code, p_description);

    -- Update ambassador stats
    UPDATE ambassadors
    SET referral_codes_created = referral_codes_created + 1
    WHERE id = p_ambassador_id;

    RETURN new_code;
END;
$$ LANGUAGE plpgsql;

-- Function to apply referral code
CREATE OR REPLACE FUNCTION apply_referral_code(
    p_user_id UUID,
    p_code TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    code_record RECORD;
    trial_duration INTEGER;
BEGIN
    -- Get referral code details
    SELECT * INTO code_record
    FROM referral_codes
    WHERE code = UPPER(p_code)
      AND is_active = TRUE
      AND (valid_until IS NULL OR valid_until > NOW())
      AND (max_uses IS NULL OR current_uses < max_uses);

    -- If code not found or invalid
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    -- Record usage
    INSERT INTO referral_usage (
        referral_code_id,
        code,
        user_id,
        user_email,
        trial_expires_at
    )
    SELECT
        code_record.id,
        code_record.code,
        p_user_id,
        (SELECT email FROM profiles WHERE id = p_user_id),
        NOW() + (code_record.trial_days || ' days')::INTERVAL;

    -- Create trial subscription
    INSERT INTO user_subscriptions (
        user_id,
        tier,
        status,
        is_trial,
        trial_ends_at,
        expires_at
    )
    VALUES (
        p_user_id,
        'pro',
        'active',
        TRUE,
        NOW() + (code_record.trial_days || ' days')::INTERVAL,
        NOW() + (code_record.trial_days || ' days')::INTERVAL
    );

    -- Update user profile
    UPDATE profiles
    SET
        current_tier = 'pro',
        subscription_expires_at = NOW() + (code_record.trial_days || ' days')::INTERVAL
    WHERE id = p_user_id;

    -- Update referral code stats
    UPDATE referral_codes
    SET
        current_uses = current_uses + 1,
        total_signups = total_signups + 1
    WHERE id = code_record.id;

    -- Update ambassador stats
    UPDATE ambassadors
    SET successful_referrals = successful_referrals + 1
    WHERE id = code_record.ambassador_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to reset monthly lead quota
CREATE OR REPLACE FUNCTION reset_monthly_lead_quota()
RETURNS VOID AS $$
BEGIN
    UPDATE ambassadors
    SET
        current_month_leads = 0,
        last_quota_reset = CURRENT_DATE
    WHERE
        status = 'active'
        AND (
            last_quota_reset IS NULL
            OR DATE_TRUNC('month', last_quota_reset) < DATE_TRUNC('month', CURRENT_DATE)
        );
END;
$$ LANGUAGE plpgsql;

-- Function to assign lead to ambassador
CREATE OR REPLACE FUNCTION assign_lead_to_ambassador(
    p_ambassador_id UUID,
    p_lead_name TEXT,
    p_lead_email TEXT,
    p_organization TEXT
)
RETURNS UUID AS $$
DECLARE
    new_lead_id UUID;
    current_quota INTEGER;
BEGIN
    -- Check if ambassador has quota remaining
    SELECT current_month_leads INTO current_quota
    FROM ambassadors
    WHERE id = p_ambassador_id AND status = 'active';

    IF current_quota >= 15 THEN
        RAISE EXCEPTION 'Ambassador has reached monthly lead quota';
    END IF;

    -- Create lead
    INSERT INTO ambassador_leads (
        ambassador_id,
        lead_name,
        lead_email,
        organization,
        status
    )
    VALUES (
        p_ambassador_id,
        p_lead_name,
        p_lead_email,
        p_organization,
        'assigned'
    )
    RETURNING id INTO new_lead_id;

    -- Update ambassador stats
    UPDATE ambassadors
    SET
        total_leads_assigned = total_leads_assigned + 1,
        current_month_leads = current_month_leads + 1
    WHERE id = p_ambassador_id;

    RETURN new_lead_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE ambassadors ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE ambassador_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE ambassador_communications ENABLE ROW LEVEL SECURITY;
ALTER TABLE ambassador_rewards ENABLE ROW LEVEL SECURITY;

-- Ambassadors: Can only view/update their own record
CREATE POLICY "Ambassadors can view own profile"
    ON ambassadors FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Ambassadors can update own profile"
    ON ambassadors FOR UPDATE
    USING (auth.uid() = user_id);

-- Referral codes: Ambassadors can manage their own codes
CREATE POLICY "Ambassadors can view own referral codes"
    ON referral_codes FOR SELECT
    USING (
        ambassador_id IN (SELECT id FROM ambassadors WHERE user_id = auth.uid())
    );

CREATE POLICY "Ambassadors can create own referral codes"
    ON referral_codes FOR INSERT
    WITH CHECK (
        ambassador_id IN (SELECT id FROM ambassadors WHERE user_id = auth.uid())
    );

-- Public can verify referral codes
CREATE POLICY "Public can verify referral codes"
    ON referral_codes FOR SELECT
    USING (is_active = TRUE);

-- Referral usage: Ambassadors can view their code usage
CREATE POLICY "Ambassadors can view own code usage"
    ON referral_usage FOR SELECT
    USING (
        referral_code_id IN (
            SELECT rc.id FROM referral_codes rc
            INNER JOIN ambassadors a ON rc.ambassador_id = a.id
            WHERE a.user_id = auth.uid()
        )
    );

-- Ambassador leads: Ambassadors can manage their own leads
CREATE POLICY "Ambassadors can manage own leads"
    ON ambassador_leads FOR ALL
    USING (
        ambassador_id IN (SELECT id FROM ambassadors WHERE user_id = auth.uid())
    );

-- Testimonials: Published testimonials are publicly readable
CREATE POLICY "Published testimonials are publicly readable"
    ON testimonials FOR SELECT
    USING (is_published = TRUE);

-- Ambassador communications
CREATE POLICY "Ambassadors can view own communications"
    ON ambassador_communications FOR SELECT
    USING (
        ambassador_id IN (SELECT id FROM ambassadors WHERE user_id = auth.uid())
    );

-- Ambassador rewards
CREATE POLICY "Ambassadors can view own rewards"
    ON ambassador_rewards FOR SELECT
    USING (
        ambassador_id IN (SELECT id FROM ambassadors WHERE user_id = auth.uid())
    );

-- Create updated_at triggers
CREATE TRIGGER update_ambassadors_updated_at BEFORE UPDATE ON ambassadors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_referral_codes_updated_at BEFORE UPDATE ON referral_codes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ambassador_leads_updated_at BEFORE UPDATE ON ambassador_leads
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
