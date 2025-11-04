-- V3__Add_security_audit_tables.sql

-- Refresh tokens for JWT rotation
CREATE TABLE refresh_tokens (
                                id BIGSERIAL PRIMARY KEY,
                                user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                                token VARCHAR(512) NOT NULL UNIQUE,
                                expires_at TIMESTAMPTZ NOT NULL,
                                created_at TIMESTAMPTZ DEFAULT NOW(),
                                revoked BOOLEAN DEFAULT FALSE
);

-- Audit logs for security tracking
CREATE TABLE audit_logs (
                            id BIGSERIAL PRIMARY KEY,
                            user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
                            action VARCHAR(100) NOT NULL,
                            resource_type VARCHAR(50),
                            resource_id BIGINT,
                            description TEXT,
                            ip_address INET,
                            user_agent TEXT,
                            created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Permissions/Roles system
CREATE TABLE permissions (
                             id BIGSERIAL PRIMARY KEY,
                             name VARCHAR(100) NOT NULL UNIQUE,
                             description TEXT,
                             created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User-Permission mapping (many-to-many)
CREATE TABLE user_permissions (
                                  id BIGSERIAL PRIMARY KEY,
                                  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                                  permission_id BIGINT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
                                  granted_at TIMESTAMPTZ DEFAULT NOW(),
                                  granted_by BIGINT REFERENCES users(id),
                                  UNIQUE(user_id, permission_id)
);

-- Insert default permissions
INSERT INTO permissions (name, description) VALUES
                                                ('USER_READ', 'Read user information'),
                                                ('USER_WRITE', 'Modify user information'),
                                                ('USER_DELETE', 'Delete users'),
                                                ('POST_READ', 'Read posts'),
                                                ('POST_WRITE', 'Create and edit posts'),
                                                ('POST_DELETE', 'Delete posts'),
                                                ('CHAT_MANAGE', 'Manage chat rooms'),
                                                ('MESSAGE_DELETE', 'Delete any message'),
                                                ('ADMIN_ACCESS', 'Full administrative access');

-- Add security indexes
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

CREATE INDEX idx_user_permissions_user_id ON user_permissions(user_id);
CREATE INDEX idx_user_permissions_permission_id ON user_permissions(permission_id);