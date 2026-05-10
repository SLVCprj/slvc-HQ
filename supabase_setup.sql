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

-- ─── PEOPLE ──────────────────────────────────────────────
create table if not exists people (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  proj text not null default 'lifeflow',
  contact text not null default '',
  notes text not null default '',
  created_at timestamptz default now()
);
alter table people enable row level security;
drop policy if exists "open" on people;
create policy "open" on people for all using (true) with check (true);

-- ─── AFFILIATIONS ────────────────────────────────────────
create table if not exists affiliations (
  id uuid default gen_random_uuid() primary key,
  brand text not null,
  status text not null default 'In Corso',
  offer text not null default '—',
  contact text not null default '—',
  notes text not null default '',
  affiliate_link text not null default '',
  created_at timestamptz default now()
);
alter table affiliations enable row level security;
drop policy if exists "open" on affiliations;
create policy "open" on affiliations for all using (true) with check (true);

-- Seed dati iniziali (esegui una volta)
insert into affiliations (brand, status, offer, contact, notes, affiliate_link) values
  ('Funding Pips', 'Attiva', 'Codice: 67f23d18', 'Dashboard', '', 'https://app.fundingpips.com/register?ref=67f23d18'),
  ('FTMO', 'In Corso', 'Richiesta fatta', '—', 'In attesa di risposta.', ''),
  ('AVA', 'In Corso', 'Proposta iniziale + Bonus', 'Giancarlo Barosso', 'Attendere risposta finale.', ''),
  ('XM', 'In Corso', 'FTD $400 — CPA $400 @ 2 Lotti', 'Elisa Prieto Fajardo', 'Proposta ricevuta.', ''),
  ('AXI', 'In Attesa', 'Richiesta inviata', 'Giuseppe Di Stefano', 'In attesa di risposta.', ''),
  ('MyFundedFutures', 'In Programma', 'Requisito: 500 followers', '—', 'Stand-by fino al target social.', ''),
  ('IC Markets', 'Chiusa', 'Nessun CPA disponibile', 'Partners', 'Non si procede.', '')
on conflict do nothing;

-- ═══════════════════════════════════════════════════════════
--  Per aggiornare manualmente il counter dal DB:
--  update config set value = '1234' where key = 'people_helped';
-- ═══════════════════════════════════════════════════════════
