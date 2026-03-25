-- =============================================================
-- Survey Gate — Supabase Setup
-- Run this in your Supabase SQL Editor (SQL Editor > New Query)
-- =============================================================

-- Table to track verified participants (stores hashed emails, not raw)
CREATE TABLE IF NOT EXISTS survey_participants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email_hash TEXT UNIQUE NOT NULL,
    token UUID NOT NULL,
    verified_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Allow anonymous inserts (the gate page inserts before signing out)
ALTER TABLE survey_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anonymous insert" ON survey_participants
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

-- No one can read the table from the client (admin-only via dashboard)
CREATE POLICY "No public read" ON survey_participants
    FOR SELECT USING (false);

-- Index on email_hash for fast duplicate checks
CREATE INDEX idx_participants_email_hash ON survey_participants (email_hash);

-- =============================================================
-- OPTIONAL: Email whitelist (only if USE_WHITELIST = true)
-- =============================================================

-- Uncomment the block below if you want to restrict to pre-approved emails

/*
CREATE TABLE IF NOT EXISTS allowed_emails (
    email TEXT PRIMARY KEY,
    added_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE allowed_emails ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read allowed emails" ON allowed_emails
    FOR SELECT USING (true);

-- Add participants:
-- INSERT INTO allowed_emails (email) VALUES ('participant1@example.com');
-- INSERT INTO allowed_emails (email) VALUES ('participant2@example.com');
*/
