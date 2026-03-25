-- =============================================================
-- Survey Gate — Supabase Setup
-- Run this in your Supabase SQL Editor (SQL Editor > New Query)
-- =============================================================

-- Drop old table if upgrading from v1
DROP TABLE IF EXISTS survey_participants;

-- Participants: tracks verified users and their allowed/used survey accesses
CREATE TABLE IF NOT EXISTS survey_participants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email_hash TEXT UNIQUE NOT NULL,
    allowed_count INTEGER NOT NULL DEFAULT 1,
    used_count INTEGER NOT NULL DEFAULT 0,
    verified_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE survey_participants ENABLE ROW LEVEL SECURITY;

-- Allow anon to insert (new participants)
CREATE POLICY "Allow anon insert participants" ON survey_participants
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

-- Allow anon to select (to check existing participant)
CREATE POLICY "Allow anon select participants" ON survey_participants
    FOR SELECT TO anon, authenticated
    USING (true);

-- Allow anon to update (to increment used_count)
CREATE POLICY "Allow anon update participants" ON survey_participants
    FOR UPDATE TO anon, authenticated
    USING (true)
    WITH CHECK (true);

CREATE INDEX idx_participants_email_hash ON survey_participants (email_hash);

-- =============================================================
-- IP Rate Limiting
-- =============================================================

CREATE TABLE IF NOT EXISTS ip_rate_limits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ip_hash TEXT NOT NULL,
    verified_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE ip_rate_limits ENABLE ROW LEVEL SECURITY;

-- Allow anon to insert (record IP usage)
CREATE POLICY "Allow anon insert ip" ON ip_rate_limits
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

-- Allow anon to select (to check rate limit)
CREATE POLICY "Allow anon select ip" ON ip_rate_limits
    FOR SELECT TO anon, authenticated
    USING (true);

CREATE INDEX idx_ip_rate_limits_hash_time ON ip_rate_limits (ip_hash, verified_at);

-- =============================================================
-- OPTIONAL: Email whitelist (only if USE_WHITELIST = true)
-- =============================================================

/*
CREATE TABLE IF NOT EXISTS allowed_emails (
    email TEXT PRIMARY KEY,
    added_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE allowed_emails ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read allowed emails" ON allowed_emails
    FOR SELECT USING (true);
*/
