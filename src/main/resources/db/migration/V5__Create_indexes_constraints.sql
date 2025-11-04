-- V5__Create_performance_indexes.sql

-- =============================================
-- 1. CORE PERFORMANCE INDEXES
-- =============================================

-- Users table performance indexes
CREATE INDEX IF NOT EXISTS idx_users_role_status ON users(role, status) WHERE status = 'ACTIVE';
CREATE INDEX IF NOT EXISTS idx_users_email_lower ON users(LOWER(email));
CREATE INDEX IF NOT EXISTS idx_users_username_lower ON users(LOWER(username));

-- Posts table performance indexes
CREATE INDEX IF NOT EXISTS idx_posts_author_status ON posts(author_id, is_published) WHERE is_published = true;
CREATE INDEX IF NOT EXISTS idx_posts_category_published ON posts(category_id, created_at DESC) WHERE is_published = true;
CREATE INDEX IF NOT EXISTS idx_posts_privacy_published ON posts(privacy_level, created_at DESC) WHERE is_published = true;
CREATE INDEX IF NOT EXISTS idx_posts_featured ON posts(is_featured, created_at DESC) WHERE is_featured = true AND is_published = true;

-- =============================================
-- 2. CHAT PERFORMANCE INDEXES
-- =============================================

-- Chat performance indexes
CREATE INDEX IF NOT EXISTS idx_chats_created_by ON chats(created_by);
CREATE INDEX IF NOT EXISTS idx_chats_is_group ON chats(is_group) WHERE is_group = true;
CREATE INDEX IF NOT EXISTS idx_chats_updated_at ON chats(updated_at DESC);

-- Chat participants performance
CREATE INDEX IF NOT EXISTS idx_chat_participants_chat_role ON chat_participants(chat_id, role);
CREATE INDEX IF NOT EXISTS idx_chat_participants_joined_at ON chat_participants(joined_at DESC);

-- Messages performance indexes
CREATE INDEX IF NOT EXISTS idx_messages_sender_created ON messages(sender_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_chat_created ON messages(chat_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_type ON messages(message_type);
CREATE INDEX IF NOT EXISTS idx_messages_media ON messages(media_id) WHERE media_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_messages_edited ON messages(is_edited) WHERE is_edited = true;
CREATE INDEX IF NOT EXISTS idx_messages_parent ON messages(parent_message_id) WHERE parent_message_id IS NOT NULL;

-- Message reads performance
CREATE INDEX IF NOT EXISTS idx_message_reads_read_at ON message_reads(read_at DESC);
CREATE INDEX IF NOT EXISTS idx_message_reads_message_user ON message_reads(message_id, user_id);

-- =============================================
-- 3. SECURITY & AUDIT PERFORMANCE INDEXES
-- =============================================

-- Refresh tokens performance
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_revoked ON refresh_tokens(expires_at, revoked) WHERE revoked = false;
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_revoked ON refresh_tokens(user_id, revoked);

-- Audit logs performance
CREATE INDEX IF NOT EXISTS idx_audit_logs_action_date ON audit_logs(action, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_ip_date ON audit_logs(ip_address, created_at DESC);

-- Permissions performance
CREATE INDEX IF NOT EXISTS idx_user_permissions_granted_at ON user_permissions(granted_at DESC);

-- =============================================
-- 4. MEDIA PERFORMANCE INDEXES
-- =============================================

CREATE INDEX IF NOT EXISTS idx_media_files_mime_type ON media_files(mime_type);
CREATE INDEX IF NOT EXISTS idx_media_files_created_at ON media_files(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_media_files_storage_type ON media_files(storage_type);
CREATE INDEX IF NOT EXISTS idx_media_files_size ON media_files(file_size) WHERE file_size > 1048576; -- Large files

-- =============================================
-- 5. COMPOSITE INDEXES FOR COMMON QUERIES
-- =============================================

-- For user activity queries
CREATE INDEX IF NOT EXISTS idx_users_activity ON users(last_login_at DESC, created_at DESC) WHERE status = 'ACTIVE';

-- For post discovery queries
CREATE INDEX IF NOT EXISTS idx_posts_discovery ON posts(created_at DESC, like_count DESC, comment_count DESC)
    WHERE is_published = true AND privacy_level = 'PUBLIC';

-- For chat list queries
CREATE INDEX IF NOT EXISTS idx_chats_recent_active ON chats(updated_at DESC, created_at DESC)
    WHERE is_group = true;

-- =============================================
-- 6. PARTIAL INDEXES FOR OPTIMIZATION
-- =============================================

-- Only index active users
CREATE INDEX IF NOT EXISTS idx_users_active_only ON users(id) WHERE status = 'ACTIVE';

-- Only index published posts
CREATE INDEX IF NOT EXISTS idx_posts_published_only ON posts(id) WHERE is_published = true;

-- Only index non-deleted messages
CREATE INDEX IF NOT EXISTS idx_messages_non_deleted ON messages(id) WHERE is_deleted = false;

-- Only index unrevoked tokens
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_active ON refresh_tokens(id) WHERE revoked = false;

-- =============================================
-- 7. FOREIGN KEY PERFORMANCE
-- =============================================

-- These indexes help with JOIN operations and foreign key constraints
CREATE INDEX IF NOT EXISTS idx_posts_author_fk ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_messages_chat_fk ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_fk ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_user_fk ON chat_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_fk ON user_profiles(user_id);

COMMENT ON INDEX idx_posts_discovery IS 'Optimized for post discovery feeds - recent, popular public posts';
COMMENT ON INDEX idx_messages_chat_created IS 'Optimized for loading chat messages in chronological order';
COMMENT ON INDEX idx_users_activity IS 'Optimized for user activity and engagement queries';