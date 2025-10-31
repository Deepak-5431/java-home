

-- User roles for permission management
CREATE TYPE user_role AS ENUM ('ADMIN', 'MODERATOR', 'USER');

-- User account status
CREATE TYPE user_status AS ENUM ('ACTIVE', 'SUSPENDED', 'PENDING', 'DELETED');

-- Post content types
CREATE TYPE content_type AS ENUM ('TEXT', 'IMAGE', 'VIDEO', 'LINK', 'POLL');

-- Post privacy levels
CREATE TYPE privacy_level AS ENUM ('PUBLIC', 'FRIENDS_ONLY', 'PRIVATE');

-- =============================================
-- Core Users Table
-- =============================================
CREATE TABLE users (
                       id BIGSERIAL PRIMARY KEY,
                       username VARCHAR(50) UNIQUE NOT NULL,
                       email VARCHAR(255) UNIQUE NOT NULL,
                       password_hash VARCHAR(255) NOT NULL,
                       role user_role DEFAULT 'USER' NOT NULL,
                       status user_status DEFAULT 'PENDING' NOT NULL,

    -- Security fields
                       login_attempts INTEGER DEFAULT 0 NOT NULL,
                       last_login_at TIMESTAMPTZ,
                       email_verified_at TIMESTAMPTZ,

    -- Timestamps
                       created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
                       updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Constraints
                       CONSTRAINT chk_username_length CHECK (LENGTH(username) >= 3),
                       CONSTRAINT chk_username_format CHECK (username ~ '^[a-zA-Z0-9_]+$'),
                       CONSTRAINT chk_email_format CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

COMMENT ON TABLE users IS 'Stores user authentication and basic account information';
COMMENT ON COLUMN users.username IS 'Unique username for display and login';
COMMENT ON COLUMN users.password_hash IS 'BCrypt hashed password';
COMMENT ON COLUMN users.login_attempts IS 'Track failed login attempts for security';

CREATE TABLE user_profiles (
                               user_id BIGINT PRIMARY KEY,
                               first_name VARCHAR(100),
                               last_name VARCHAR(100),
                               display_name VARCHAR(100),

    -- Profile information
                               bio TEXT,
                               avatar_url TEXT,
                               cover_image_url TEXT,

    -- Personal details
                               date_of_birth DATE,
                               location VARCHAR(100),
                               website VARCHAR(255),
                               company VARCHAR(100),
                               job_title VARCHAR(100),

    -- Social metrics (denormalized for performance)
                               follower_count INTEGER DEFAULT 0 NOT NULL,
                               following_count INTEGER DEFAULT 0 NOT NULL,

    -- Timestamps
                               created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
                               updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign key
                               CONSTRAINT fk_user_profiles_user
                                   FOREIGN KEY (user_id)
                                       REFERENCES users(id)
                                       ON DELETE CASCADE
);

COMMENT ON TABLE user_profiles IS 'Stores user profile information separate from authentication data';
COMMENT ON COLUMN user_profiles.display_name IS 'Optional display name different from username';


CREATE TABLE categories (
                            id BIGSERIAL PRIMARY KEY,
                            name VARCHAR(100) UNIQUE NOT NULL,
                            description TEXT,
                            slug VARCHAR(100) UNIQUE NOT NULL,

    -- Hierarchy support
                            parent_id BIGINT,

    -- Metadata
                            is_active BOOLEAN DEFAULT TRUE NOT NULL,
                            display_order INTEGER DEFAULT 0 NOT NULL,

    -- Timestamps
                            created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
                            updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Self-referencing foreign key for hierarchy
                            CONSTRAINT fk_categories_parent
                                FOREIGN KEY (parent_id)
                                    REFERENCES categories(id)
                                    ON DELETE SET NULL,

                            CONSTRAINT chk_slug_format CHECK (slug ~ '^[a-z0-9-]+$')
);

COMMENT ON TABLE categories IS 'Categories for organizing posts in hierarchical structure';
COMMENT ON COLUMN categories.slug IS 'URL-friendly version of category name';


CREATE TABLE posts (
                       id BIGSERIAL PRIMARY KEY,

    -- Core content
                       author_id BIGINT NOT NULL,
                       title VARCHAR(500) NOT NULL,
                       content TEXT,
                       content_type content_type DEFAULT 'TEXT' NOT NULL,

    -- Categorization
                       category_id BIGINT,

    -- Privacy and visibility
                       privacy_level privacy_level DEFAULT 'PUBLIC' NOT NULL,
                       is_published BOOLEAN DEFAULT FALSE NOT NULL,
                       is_featured BOOLEAN DEFAULT FALSE NOT NULL,

    -- Engagement metrics (denormalized for performance)
                       like_count INTEGER DEFAULT 0 NOT NULL,
                       share_count INTEGER DEFAULT 0 NOT NULL,
                       comment_count INTEGER DEFAULT 0 NOT NULL,
                       view_count INTEGER DEFAULT 0 NOT NULL,

    -- Media information
                       media_urls JSONB, -- Stores array of media URLs: ["url1", "url2"]

    -- Timestamps
                       created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
                       updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
                       published_at TIMESTAMPTZ,

    -- Foreign keys
                       CONSTRAINT fk_posts_author
                           FOREIGN KEY (author_id)
                               REFERENCES users(id)
                               ON DELETE CASCADE,

                       CONSTRAINT fk_posts_category
                           FOREIGN KEY (category_id)
                               REFERENCES categories(id)
                               ON DELETE SET NULL,


                       CONSTRAINT chk_title_length CHECK (LENGTH(title) >= 1 AND LENGTH(title) <= 500),
                       CONSTRAINT chk_published_date
                           CHECK ((is_published = TRUE AND published_at IS NOT NULL) OR
                                  (is_published = FALSE AND published_at IS NULL))
);

COMMENT ON TABLE posts IS 'Main table for user posts and content sharing';
COMMENT ON COLUMN posts.media_urls IS 'JSON array of media file URLs for the post';
COMMENT ON COLUMN posts.published_at IS 'When the post was published, NULL if draft';



CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- User profiles indexes
CREATE INDEX idx_user_profiles_display_name ON user_profiles(display_name);
CREATE INDEX idx_user_profiles_location ON user_profiles(location);

-- Categories indexes
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_active ON categories(is_active) WHERE is_active = TRUE;

-- Posts table indexes
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_category_id ON posts(category_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_published_at ON posts(published_at DESC) WHERE is_published = TRUE;
CREATE INDEX idx_posts_privacy_level ON posts(privacy_level);
CREATE INDEX idx_posts_engagement ON posts(like_count DESC, comment_count DESC) WHERE is_published = TRUE;


CREATE INDEX idx_posts_published ON posts(id) WHERE is_published = TRUE;


INSERT INTO categories (name, description, slug, display_order) VALUES
                                                                    ('General', 'General discussions and posts', 'general', 1),
                                                                    ('Technology', 'Tech news, programming, and innovations', 'technology', 2),
                                                                    ('Business', 'Business insights and entrepreneurship', 'business', 3),
                                                                    ('Entertainment', 'Movies, music, and entertainment', 'entertainment', 4),
                                                                    ('Sports', 'Sports news and discussions', 'sports', 5),
                                                                    ('Science', 'Scientific discoveries and research', 'science', 6);

COMMENT ON TABLE categories IS 'Pre-populated with default categories for post organization';