-- Run this once in Supabase SQL Editor.
create table if not exists public.site_content (
  id text primary key default 'default' check (id = 'default'),
  content jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.feedback (
  id bigint primary key,
  message text not null,
  created_at timestamptz not null default now(),
  read boolean not null default false
);

create table if not exists public.product_ratings (
  product_id bigint primary key,
  counts jsonb not null default '{}'::jsonb
);

alter table public.site_content enable row level security;
alter table public.feedback enable row level security;
alter table public.product_ratings enable row level security;

drop policy if exists "Public can read site content" on public.site_content;
drop policy if exists "Public can write site content" on public.site_content;
drop policy if exists "Public can update site content" on public.site_content;
drop policy if exists "Anyone can submit feedback" on public.feedback;
drop policy if exists "Admins can read feedback" on public.feedback;
drop policy if exists "Admins can manage feedback" on public.feedback;
drop policy if exists "Anyone can read ratings" on public.product_ratings;
drop policy if exists "Anyone can insert ratings" on public.product_ratings;
drop policy if exists "Anyone can update ratings" on public.product_ratings;
drop policy if exists "Public can view Mirate images" on storage.objects;
drop policy if exists "Public can upload Mirate images" on storage.objects;

create policy "Public can read site content" on public.site_content for select to anon, authenticated using (true);
create policy "Public can write site content" on public.site_content for insert to anon, authenticated with check (id = 'default');
create policy "Public can update site content" on public.site_content for update to anon, authenticated using (id = 'default') with check (id = 'default');
create policy "Anyone can submit feedback" on public.feedback for insert to anon, authenticated with check (true);
create policy "Admins can read feedback" on public.feedback for select to authenticated using (true);
create policy "Admins can manage feedback" on public.feedback for all to authenticated using (true) with check (true);
create policy "Anyone can read ratings" on public.product_ratings for select to anon, authenticated using (true);
create policy "Anyone can insert ratings" on public.product_ratings for insert to anon, authenticated with check (true);
create policy "Anyone can update ratings" on public.product_ratings for update to anon, authenticated using (true) with check (true);

insert into storage.buckets (id, name, public)
values ('MIRATE-IMAGES', 'MIRATE-IMAGES', true)
on conflict (id) do update set public = true;

create policy "Public can view Mirate images" on storage.objects for select to anon, authenticated using (bucket_id = 'MIRATE-IMAGES');
create policy "Public can upload Mirate images" on storage.objects for insert to anon, authenticated with check (bucket_id = 'MIRATE-IMAGES');
