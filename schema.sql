PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS app_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL DEFAULT (unixepoch()*1000));
INSERT OR IGNORE INTO app_settings(key,value) VALUES('promotion_mode','false');
CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, teacher_name TEXT NOT NULL, school TEXT NOT NULL, nip TEXT, email TEXT NOT NULL UNIQUE, whatsapp TEXT NOT NULL, teacher_type TEXT NOT NULL CHECK(teacher_type IN ('NON_PAI','PAI')), level TEXT CHECK(level IN ('SD','LANJUTAN') OR level IS NULL), verified INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','BLOCKED')), vip INTEGER NOT NULL DEFAULT 0, class_quota INTEGER, subject_quota INTEGER, device_quota INTEGER, classes_used INTEGER NOT NULL DEFAULT 0, subjects_used INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS user_devices (id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE, fingerprint_hash TEXT NOT NULL, label TEXT, status TEXT NOT NULL DEFAULT 'ACTIVE', created_at INTEGER NOT NULL, last_seen INTEGER NOT NULL, UNIQUE(user_id,fingerprint_hash));
CREATE TABLE IF NOT EXISTS otp_codes (id TEXT PRIMARY KEY, email TEXT NOT NULL, code_hash TEXT NOT NULL, expires_at INTEGER NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS verification_tokens (token_hash TEXT PRIMARY KEY, email TEXT NOT NULL, expires_at INTEGER NOT NULL, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS user_sessions (token_hash TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE, expires_at INTEGER NOT NULL, created_at INTEGER NOT NULL);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE TABLE IF NOT EXISTS quota_events (id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE, kind TEXT NOT NULL CHECK(kind IN ('class','subject')), resource TEXT NOT NULL, created_at INTEGER NOT NULL, UNIQUE(user_id,kind,resource));
CREATE INDEX IF NOT EXISTS idx_quota_events_user ON quota_events(user_id,kind);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_devices_user ON user_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_otp_email ON otp_codes(email);
-- Existing legacy tables retained for backward compatibility with earlier Worker prototype.
CREATE TABLE IF NOT EXISTS teachers (id TEXT PRIMARY KEY, teacher_name TEXT NOT NULL, school TEXT NOT NULL, nip TEXT, contact TEXT NOT NULL UNIQUE, contact_channel TEXT NOT NULL, role TEXT NOT NULL, locked_subject TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'PENDING', created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS access_grants (id TEXT PRIMARY KEY, teacher_id TEXT NOT NULL REFERENCES teachers(id) ON DELETE CASCADE, subject TEXT NOT NULL, class_name TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'ACTIVE', created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS devices (id TEXT PRIMARY KEY, teacher_id TEXT NOT NULL REFERENCES teachers(id) ON DELETE CASCADE, device_hash TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'PENDING', created_at INTEGER NOT NULL, UNIQUE(teacher_id,device_hash));
CREATE TABLE IF NOT EXISTS otp_challenges (id TEXT PRIMARY KEY, target TEXT NOT NULL, channel TEXT NOT NULL, code_hash TEXT NOT NULL, expires_at INTEGER NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL);
CREATE INDEX IF NOT EXISTS idx_otp_target ON otp_challenges(target);
CREATE TABLE IF NOT EXISTS verified_contacts (token_hash TEXT PRIMARY KEY, target TEXT NOT NULL, channel TEXT NOT NULL, expires_at INTEGER NOT NULL, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS access_requests (id TEXT PRIMARY KEY, teacher_id TEXT NOT NULL REFERENCES teachers(id) ON DELETE CASCADE, request_type TEXT NOT NULL, request_data TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'PENDING', created_at INTEGER NOT NULL, reviewed_at INTEGER, admin_note TEXT);
CREATE TABLE IF NOT EXISTS admin_users (id TEXT PRIMARY KEY, email TEXT UNIQUE NOT NULL, password_hash TEXT NOT NULL, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);

-- New global controls and device-login tracking
CREATE TABLE IF NOT EXISTS device_login_events (id TEXT PRIMARY KEY, fingerprint_hash TEXT NOT NULL, email TEXT NOT NULL, created_at INTEGER NOT NULL);
CREATE INDEX IF NOT EXISTS idx_device_login_events_fp_time ON device_login_events(fingerprint_hash,created_at);
CREATE TABLE IF NOT EXISTS device_blocks (fingerprint_hash TEXT PRIMARY KEY, blocked_until INTEGER NOT NULL, reason TEXT NOT NULL, updated_at INTEGER NOT NULL);
INSERT OR IGNORE INTO app_settings(key,value) VALUES('promotion_mode','false');
INSERT OR IGNORE INTO app_settings(key,value) VALUES('price_class','0');
INSERT OR IGNORE INTO app_settings(key,value) VALUES('price_subject','0');
INSERT OR IGNORE INTO app_settings(key,value) VALUES('price_session','0');
INSERT OR IGNORE INTO app_settings(key,value) VALUES('admin_whatsapp','628xxxxxxxxxx');
INSERT OR IGNORE INTO app_settings(key,value) VALUES('admin_message_template','Permohonan akses KAU');
INSERT OR IGNORE INTO app_settings(key,value) VALUES('guest_preview_export_block','true');
