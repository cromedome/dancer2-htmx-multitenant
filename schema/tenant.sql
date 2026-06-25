PRAGMA journal_mode=WAL;             -- Better concurrent read performance
PRAGMA foreign_keys=ON;              -- Enforce FK constraints

CREATE TABLE IF NOT EXISTS stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    current_floor INT NOT NULL DEFAULT 1,
    hp_current INT NOT NULL DEFAULT 1,
    hp_max INT NOT NULL DEFAULT 1,
    gold INT NOT NULL DEFAULT 0,
    monsters_killed INT NOT NULL DEFAULT 0,
    players_killed INT NOT NULL DEFAULT 0,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE encounters (
    encounter_id  INTEGER PRIMARY KEY,  -- alias for rowid
    monster_name  TEXT NOT NULL,
    floor         INTEGER NOT NULL,
    xp_gained     INTEGER DEFAULT 0,
    survived      INTEGER DEFAULT 1,    -- boolean, 1/0
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);
