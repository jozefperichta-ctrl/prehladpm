-- 1. Tabuľka pre push subscriptions
create table public.push_subscriptions (
  id       uuid default gen_random_uuid() primary key,
  endpoint text not null unique,
  subscription jsonb not null,
  created_at timestamptz default now()
);
alter table public.push_subscriptions enable row level security;
create policy "allow_all" on public.push_subscriptions for all using (true) with check (true);

-- 2. Index na rýchle vyhľadávanie
create index on public.push_subscriptions (endpoint);
