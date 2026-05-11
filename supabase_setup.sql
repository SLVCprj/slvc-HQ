-- ═══════════════════════════════════════════════════════════
--  SLEEVEACE HQ — Supabase SQL Setup
--  Esegui nell'SQL Editor di Supabase (una tantum)
-- ═══════════════════════════════════════════════════════════

-- ─── STEP 1 · ESTENSIONE ────────────────────────────────
create extension if not exists pgcrypto;


-- ─── STEP 2 · CREA UTENTI AUTH ──────────────────────────

do $slv$
begin
  if not exists (select 1 from auth.users where email = 'simonetabozzi@sleeveace.hq') then
    insert into auth.users (
      instance_id, id, aud, role, email,
      encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data,
      created_at, updated_at,
      confirmation_token, recovery_token,
      email_change_token_new, email_change
    ) values (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated', 'authenticated',
      'simonetabozzi@sleeveace.hq',
      crypt('SLVCFirstPSW1!', gen_salt('bf', 12)),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{"must_reset":true}',
      now(), now(), '', '', '', ''
    );
  end if;
end $slv$;

do $slv$
begin
  if not exists (select 1 from auth.users where email = 'andreafinucci@sleeveace.hq') then
    insert into auth.users (
      instance_id, id, aud, role, email,
      encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data,
      created_at, updated_at,
      confirmation_token, recovery_token,
      email_change_token_new, email_change
    ) values (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated', 'authenticated',
      'andreafinucci@sleeveace.hq',
      crypt('SLVCFirstPSW1!', gen_salt('bf', 12)),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{"must_reset":true}',
      now(), now(), '', '', '', ''
    );
  end if;
end $slv$;

-- Identities — provider_id è obbligatorio nelle versioni recenti di Supabase
-- Per il provider "email", provider_id = indirizzo email dell'utente
insert into auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
select
  gen_random_uuid(),
  u.email,
  u.id,
  json_build_object('sub', u.id::text, 'email', u.email),
  'email',
  now(), now(), now()
from auth.users u
where u.email in ('simonetabozzi@sleeveace.hq', 'andreafinucci@sleeveace.hq')
  and not exists (
    select 1 from auth.identities i where i.user_id = u.id
  );


-- ─── STEP 3 · TABELLE CON RLS AUTH-ONLY ────────────────

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
drop policy if exists "auth_only" on tasks;
create policy "auth_only" on tasks
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

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
drop policy if exists "auth_only" on finances;
create policy "auth_only" on finances
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create table if not exists config (
  key text primary key,
  value text not null,
  updated_at timestamptz default now()
);
alter table config enable row level security;
drop policy if exists "open" on config;
drop policy if exists "auth_only" on config;
create policy "auth_only" on config
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

insert into config (key, value) values ('lf_users', '0')  on conflict (key) do nothing;
insert into config (key, value) values ('lab_users', '0') on conflict (key) do nothing;

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
drop policy if exists "auth_only" on people;
create policy "auth_only" on people
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

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
drop policy if exists "auth_only" on affiliations;
create policy "auth_only" on affiliations
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');


-- ─── STEP 4 · SEED AFFILIAZIONI ─────────────────────────

insert into affiliations (brand, status, offer, contact, notes, affiliate_link)
select v.brand, v.status, v.offer, v.contact, v.notes, v.affiliate_link
from (values
  ('Funding Pips',    'Attiva',       'Codice: 67f23d18',               'Dashboard',            '',                                'https://app.fundingpips.com/register?ref=67f23d18'),
  ('FTMO',            'In Corso',     'Richiesta fatta',                '—',                    'In attesa di risposta.',          ''),
  ('AVA',             'In Corso',     'Proposta iniziale + Bonus',      'Giancarlo Barosso',    'Attendere risposta finale.',      ''),
  ('XM',              'In Corso',     'FTD $400 - CPA $400 @ 2 Lotti', 'Elisa Prieto Fajardo', 'Proposta ricevuta.',              ''),
  ('AXI',             'In Attesa',    'Richiesta inviata',              'Giuseppe Di Stefano',  'In attesa di risposta.',          ''),
  ('MyFundedFutures', 'In Programma', 'Requisito: 500 followers',       '—',                    'Stand-by fino al target social.', ''),
  ('IC Markets',      'Chiusa',       'Nessun CPA disponibile',         'Partners',             'Non si procede.',                 '')
) as v(brand, status, offer, contact, notes, affiliate_link)
where not exists (select 1 from affiliations limit 1);


-- ─── STEP 5 · VERIFICA ──────────────────────────────────
-- select email, raw_user_meta_data from auth.users where email like '%sleeveace%';
-- select tablename, policyname from pg_policies where schemaname = 'public';
