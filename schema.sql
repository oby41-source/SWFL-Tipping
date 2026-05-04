-- Run this in Supabase: SQL Editor → New Query → paste → Run

-- Tips table
CREATE TABLE IF NOT EXISTS tips (
  round        INTEGER NOT NULL,
  tipster      TEXT    NOT NULL,
  game_index   INTEGER NOT NULL,
  pick         TEXT    NOT NULL,
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (round, tipster, game_index)
);

-- Results table (admin enters these)
CREATE TABLE IF NOT EXISTS results (
  round      INTEGER NOT NULL,
  game_index INTEGER NOT NULL,
  winner     TEXT    NOT NULL,
  PRIMARY KEY (round, game_index)
);

-- Fixtures table (loaded from PlayHQ by admin, cached here for everyone)
CREATE TABLE IF NOT EXISTS fixtures (
  round      INTEGER NOT NULL,
  game_index INTEGER NOT NULL,
  home       TEXT    NOT NULL,
  away       TEXT    NOT NULL,
  venue      TEXT    DEFAULT '',
  home_logo  TEXT    DEFAULT '',
  away_logo  TEXT    DEFAULT '',
  game_date  TEXT    DEFAULT '',
  PRIMARY KEY (round, game_index)
);

-- Row Level Security
ALTER TABLE tips     ENABLE ROW LEVEL SECURITY;
ALTER TABLE results  ENABLE ROW LEVEL SECURITY;
ALTER TABLE fixtures ENABLE ROW LEVEL SECURITY;

-- Public read
CREATE POLICY "Public read tips"     ON tips     FOR SELECT USING (true);
CREATE POLICY "Public read results"  ON results  FOR SELECT USING (true);
CREATE POLICY "Public read fixtures" ON fixtures FOR SELECT USING (true);

-- Public write
CREATE POLICY "Anyone insert tips"     ON tips     FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone update tips"     ON tips     FOR UPDATE USING (true);
CREATE POLICY "Anyone insert results"  ON results  FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone update results"  ON results  FOR UPDATE USING (true);
CREATE POLICY "Anyone insert fixtures" ON fixtures FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone update fixtures" ON fixtures FOR UPDATE USING (true);
