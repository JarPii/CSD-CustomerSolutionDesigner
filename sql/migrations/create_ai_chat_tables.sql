-- AI Chat Tables Migration
-- This script drops and recreates the chat_session and chat_message tables
-- with correct column definitions

-- Drop tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS chat_message CASCADE;
DROP TABLE IF EXISTS chat_session CASCADE;

-- Create chat_session table
CREATE TABLE chat_session (
    id SERIAL PRIMARY KEY,
    session_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create chat_message table
CREATE TABLE chat_message (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES chat_session(id) ON DELETE CASCADE,
    message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('user', 'assistant')),
    content TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    tokens_used INTEGER,
    model_name VARCHAR(100)
);

-- Create indexes
CREATE INDEX idx_chat_session_is_active ON chat_session(is_active);
CREATE INDEX idx_chat_session_updated_at ON chat_session(updated_at);
CREATE INDEX idx_chat_message_session_id ON chat_message(session_id);
CREATE INDEX idx_chat_message_timestamp ON chat_message(timestamp);

-- Insert sample data for testing
INSERT INTO chat_session (session_name, created_at, updated_at, is_active) VALUES 
('Welcome Chat', NOW(), NOW(), TRUE),
('Technical Discussion', NOW(), NOW(), TRUE);

INSERT INTO chat_message (session_id, message_type, content, timestamp, tokens_used, model_name) VALUES 
(1, 'user', 'Hello, can you help me with surface treatment plants?', NOW(), NULL, NULL),
(1, 'assistant', 'Hello! I''d be happy to help you with surface treatment plants. What specific information are you looking for?', NOW(), 150, 'gpt-4'),
(2, 'user', 'What are the key considerations for tank design?', NOW(), NULL, NULL),
(2, 'assistant', 'Key tank design considerations include: material compatibility, capacity requirements, heating/cooling systems, agitation mechanisms, and maintenance access. What specific application are you planning?', NOW(), 200, 'gpt-4');

COMMIT;
