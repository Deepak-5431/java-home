-- V4__Insert_admin_users.sql

-- Insert admin users (already works)
INSERT INTO users (username, email, password_hash, role, status, email_verified_at, created_at, updated_at)
VALUES
    ('admin', 'admin@industrychat.com', '$2a$12$K1d7qLzT7cQ2W8nY5vR8E.5qW9rS2dF3gH4jK5lM6nV7bC8xZ0yA', 'ADMIN'::user_role, 'ACTIVE'::user_status, NOW(), NOW(), NOW()),
    ('moderator', 'moderator@industrychat.com', '$2a$12$P2e8rM9sT0uV1wX2yZ3A4.B5c6D7eF8gH9jK0lM1nV2bC3xZ4yA5B', 'MODERATOR'::user_role, 'ACTIVE'::user_status, NOW(), NOW(), NOW());

-- Insert profiles
INSERT INTO user_profiles (user_id, first_name, last_name, display_name, bio, created_at, updated_at)
VALUES
    ((SELECT id FROM users WHERE username = 'admin'), 'System', 'Administrator', 'Admin', 'System Administrator Account', NOW(), NOW()),
    ((SELECT id FROM users WHERE username = 'moderator'), 'Content', 'Moderator', 'Moderator', 'Content Moderator Account', NOW(), NOW());

-- Create default chat
INSERT INTO chats (name, description, is_group, created_by, created_at, updated_at)
VALUES
    ('General Chat', 'Default chat room for all users', true, (SELECT id FROM users WHERE username = 'admin'), NOW(), NOW());

-- FIXED: Add users to chat with ENUM casting
INSERT INTO chat_participants (chat_id, user_id, role, joined_at)
SELECT
    (SELECT id FROM chats WHERE name = 'General Chat'),
    u.id,
    'USER'::user_role,  -- CAST TO ENUM
    NOW()
FROM users u;