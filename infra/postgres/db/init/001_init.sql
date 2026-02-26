-- Extensions utiles
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS app_user (
  id           SERIAL PRIMARY KEY,
  name         TEXT NOT NULL,
  email        TEXT UNIQUE NOT NULL,
  password     TEXT NOT NULL,
  status       TEXT,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- CAPSULES
CREATE TABLE IF NOT EXISTS capsule (
  id            SERIAL PRIMARY KEY,
  creator_user_id INT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
  title         TEXT NOT NULL,
  description   TEXT,
  unlock_at     TIMESTAMP NOT NULL,
  required_sky  TEXT NOT NULL, -- "SUNNY" | "CLOUDY" | "RAINY"
  created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- MEMBERS
CREATE TABLE IF NOT EXISTS capsule_member (
  capsule_id INT NOT NULL REFERENCES capsule(id) ON DELETE CASCADE,
  user_id    INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  role       TEXT NOT NULL, -- "OWNER" | "BENEFICIARY" | "CONTRIBUTOR"
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (capsule_id, user_id)
);

-- MESSAGES
CREATE TABLE IF NOT EXISTS message (
  id         SERIAL PRIMARY KEY,
  capsule_id INT NOT NULL REFERENCES capsule(id) ON DELETE CASCADE,
  user_id    INT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
  content    TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Données de test (optionnel)
INSERT INTO app_user(name, email, status)
VALUES ('Admin', 'admin@test.local', 'ONLINE')
ON CONFLICT (email) DO NOTHING;