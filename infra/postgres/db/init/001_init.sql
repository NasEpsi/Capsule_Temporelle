-- init.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS app_user (
  id           SERIAL PRIMARY KEY,
  name         TEXT NOT NULL,
  email        TEXT UNIQUE NOT NULL,
  password     TEXT NOT NULL,
  status       TEXT,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS capsules (
  id              SERIAL PRIMARY KEY,
  creator_user_id INT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
  title           TEXT NOT NULL,
  description     TEXT,
  unlock_at       TIMESTAMP NOT NULL,
  required_sky    TEXT NOT NULL, -- "SUNNY" | "CLOUDY" | "RAINY" | "SNOWY"
  created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS capsule_members (
  capsule_id INT NOT NULL REFERENCES capsules(id) ON DELETE CASCADE,
  user_id    INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  role       TEXT NOT NULL, -- "OWNER" | "BENEFICIARY" | "CONTRIBUTOR"
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (capsule_id, user_id)
);

CREATE TABLE IF NOT EXISTS message (
  id         SERIAL PRIMARY KEY,
  capsule_id INT NOT NULL REFERENCES capsules(id) ON DELETE CASCADE,
  user_id    INT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
  content    TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS capsule_invites (
  id SERIAL PRIMARY KEY,
  capsule_id INT NOT NULL REFERENCES capsules(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  role VARCHAR(12) NOT NULL DEFAULT 'BENEFICIARY', -- BENEFICIARY / CONTRIBUTOR
  status VARCHAR(12) NOT NULL DEFAULT 'PENDING',  -- PENDING / ACCEPTED / CANCELED
  token VARCHAR(120) NOT NULL UNIQUE,
  invited_by_user_id INT NOT NULL REFERENCES app_user(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  accepted_at TIMESTAMP NULL,
  UNIQUE (capsule_id, email, role) -- ✅ correction
);

INSERT INTO app_user(name, email, status)
VALUES ('Admin', 'admin@test.local', 'ONLINE')
ON CONFLICT (email) DO NOTHING;