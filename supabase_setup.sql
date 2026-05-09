-- ═══════════════════════════════════════════════════════════
--  SLEEVEACE HQ — Supabase SQL Setup
--  Esegui questo script nell'SQL Editor di Supabase
--  (una tantum, se le tabelle non esistono già)
-- ═══════════════════════════════════════════════════════════

-- ─── TASKS ───────────────────────────────────────────────
create table if not exists tasks (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  who text not null default 'simone',
  proj text not null default 'generale',
  prio text not null default 'media',
  due date,
  status text not null default 'todo',
  created_at timestamptz default now()
);
alter table tasks enable row level security;
drop policy if exists "open" on tasks;
create policy "open" on tasks for all using (true) with check (true);

-- ─── FINANCES ────────────────────────────────────────────
create table if not exists finances (
  id uuid default gen_random_uuid() primary key,
  type text not null default 'entrata',
  date date not null,
  proj text not null default 'altro',
  description text default '—',
  amount numeric(10,2) not null,
  created_at timestamptz default now()
);
alter table finances enable row level security;
drop policy if exists "open" on finances;
create policy "open" on finances for all using (true) with check (true);

-- ─── CONFIG (chiavi generiche + people_helped) ───────────
create table if not exists config (
  key text primary key,
  value text not null,
  updated_at timestamptz default now()
);
alter table config enable row level security;
drop policy if exists "open" on config;
create policy "open" on config for all using (true) with check (true);

-- Inserisce il counter persone aiutate con valore iniziale 0
-- (se già esiste non fa nulla)
insert into config (key, value)
values ('people_helped', '0')
on conflict (key) do nothing;

-- Inserisce altri valori di config se non esistono
insert into config (key, value) values ('lf_users', '0')  on conflict (key) do nothing;
insert into config (key, value) values ('lab_users', '0') on conflict (key) do nothing;

-- ═══════════════════════════════════════════════════════════
--  Per aggiornare manualmente il counter dal DB:
--  update config set value = '1234' where key = 'people_helped';
-- ═══════════════════════════════════════════════════════════
