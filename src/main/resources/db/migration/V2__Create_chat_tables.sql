
CREATE TABLE media_files (
                             id BIGSERIAL PRIMARY KEY,
                             user_id BIGINT REFERENCES users(id),
                             file_name VARCHAR(255),
                             file_url TEXT,
                             file_size BIGINT,
                             mime_type VARCHAR(100),
                             storage_type VARCHAR(50) DEFAULT 'local',
                             created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Now create chats table
CREATE TABLE chats (
                       id BIGSERIAL PRIMARY KEY,
                       name VARCHAR(255),
                       description TEXT,
                       is_group BOOLEAN DEFAULT FALSE,
                       created_by BIGINT REFERENCES users(id),
                       created_at TIMESTAMPTZ DEFAULT NOW(),
                       updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat participants
CREATE TABLE chat_participants (
                                   id BIGSERIAL PRIMARY KEY,
                                   chat_id BIGINT REFERENCES chats(id) ON DELETE CASCADE,
                                   user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
                                   role user_role DEFAULT 'USER',
                                   joined_at TIMESTAMPTZ DEFAULT NOW(),
                                   UNIQUE(chat_id, user_id)
);

CREATE TABLE messages (
                          id BIGSERIAL PRIMARY KEY,
                          chat_id BIGINT REFERENCES chats(id) ON DELETE CASCADE,
                          sender_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
                          content TEXT NOT NULL,
                          message_type VARCHAR(50) DEFAULT 'TEXT',
                          media_id BIGINT REFERENCES media_files(id), -- ✅ NOW WORKS!
                          parent_message_id BIGINT REFERENCES messages(id),
                          is_edited BOOLEAN DEFAULT FALSE,
                          is_deleted BOOLEAN DEFAULT FALSE,
                          created_at TIMESTAMPTZ DEFAULT NOW(),
                          updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE message_reads (
                               id BIGSERIAL PRIMARY KEY,
                               message_id BIGINT REFERENCES messages(id) ON DELETE CASCADE,
                               user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
                               read_at TIMESTAMPTZ DEFAULT NOW(),
                               UNIQUE(message_id, user_id)
);

CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_chat_participants_user_id ON chat_participants(user_id);
CREATE INDEX idx_message_reads_user_id ON message_reads(user_id);
CREATE INDEX idx_media_files_user_id ON media_files(user_id); -- For media queries