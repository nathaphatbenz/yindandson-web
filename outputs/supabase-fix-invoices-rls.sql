-- Fix RLS permissions for YinD invoices table.
-- Run this in Supabase SQL Editor.
-- This allows the current public/publishable key to read, create, update, and delete invoices.
-- For production with login, replace these policies with user-based rules later.

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.invoices to anon, authenticated;

alter table public.invoices enable row level security;

drop policy if exists "Allow read invoices" on public.invoices;
drop policy if exists "Allow insert invoices" on public.invoices;
drop policy if exists "Allow update invoices" on public.invoices;
drop policy if exists "Allow delete invoices" on public.invoices;

create policy "Allow read invoices"
on public.invoices
for select
to anon, authenticated
using (true);

create policy "Allow insert invoices"
on public.invoices
for insert
to anon, authenticated
with check (true);

create policy "Allow update invoices"
on public.invoices
for update
to anon, authenticated
using (true)
with check (true);

create policy "Allow delete invoices"
on public.invoices
for delete
to anon, authenticated
using (true);
