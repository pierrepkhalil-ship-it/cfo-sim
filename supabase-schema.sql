-- ============================================================
-- CFO Simulator — Supabase Schema (v2 — kvartal-baserad leaderboard)
-- Run this in Supabase SQL Editor (left sidebar in Supabase dashboard)
-- ============================================================

-- Drop old table if you ran v1 first (uncomment if needed)
-- drop table if exists scores;

-- 1. Create the scores table — one row per submitted quarter
create table if not exists scores (
  id          bigserial primary key,
  name        text not null check (char_length(name) between 1 and 40),
  avatar      smallint not null default 1 check (avatar between 1 and 5),
  quarter     smallint not null default 1 check (quarter between 1 and 4),
  xp          integer not null check (xp >= 0 and xp <= 10000),
  level       smallint not null check (level between 1 and 20),
  longest_streak smallint not null default 0 check (longest_streak >= 0 and longest_streak <= 200),
  decisions   smallint not null default 0 check (decisions >= 0 and decisions <= 500),
  cash        smallint not null default 0,
  cred        smallint not null default 0,
  team        smallint not null default 0,
  created_at  timestamptz not null default now()
);

-- Om du redan kört v1 utan quarter-kolumnen, lägg till den:
alter table scores add column if not exists quarter smallint not null default 1 check (quarter between 1 and 4);

-- 2. Index for fast leaderboard queries (top N by XP)
create index if not exists scores_xp_desc_idx on scores (xp desc, created_at desc);

-- 3. Enable Row Level Security
alter table scores enable row level security;

-- 4. Allow anyone to read scores (public leaderboard)
drop policy if exists "scores_select_public" on scores;
create policy "scores_select_public"
  on scores for select
  using (true);

-- 5. Allow anyone to insert their score
drop policy if exists "scores_insert_public" on scores;
create policy "scores_insert_public"
  on scores for insert
  with check (
    char_length(name) between 1 and 40
    and xp between 0 and 10000
    and avatar between 1 and 5
    and quarter between 1 and 4
  );

-- ============================================================
-- Nu skickar spelet ett resultat per kvartal — sa samma spelare
-- far upp till 4 rader per spel (Q1, Q2, Q3, Q4). Leaderboarden
-- sorterar pa hogsta enskilda kvartal-XP, vilket gor att aven
-- ett bra Q3 raknas aven om hela spelet kraschade i Q4.
-- ============================================================
