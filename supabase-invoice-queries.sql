-- Supabase table for YinD invoice documents.
-- Run this in Supabase SQL Editor if the table does not exist yet.

create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  invoice_number text not null,
  document_date date not null,
  document_type text not null,
  document_group text not null default 'INV' check (document_group in ('INV', 'RE', 'QT')),
  document_year integer not null default (extract(year from now())::integer + 543),
  document_status text not null default 'issued' check (document_status in ('issued', 'reserved', 'cancelled')),
  customer_address text not null,
  tax_id text not null,
  items jsonb not null default '[]'::jsonb,
  subtotal numeric(12, 2) not null default 0,
  vat_amount numeric(12, 2) not null default 0,
  grand_total numeric(12, 2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists invoices_created_at_idx
  on public.invoices (created_at desc);

create index if not exists invoices_customer_name_idx
  on public.invoices (customer_name);

create index if not exists invoices_invoice_number_idx
  on public.invoices (invoice_number);

create unique index if not exists invoices_invoice_number_unique_idx
  on public.invoices (invoice_number);

create index if not exists invoices_document_group_year_status_idx
  on public.invoices (document_group, document_year, document_status);

-- Optional: auto-update updated_at when a row is edited.
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists invoices_set_updated_at on public.invoices;
create trigger invoices_set_updated_at
before update on public.invoices
for each row
execute function public.set_updated_at();

-- The CRUD examples below use real SQL syntax that can be copied later.
-- Do not use :keyword or :id placeholders directly in Supabase SQL Editor.
-- In the website, these values will be passed by supabase-invoice-client.js.

-- Read: Dashboard list, newest first.
-- select
--   id,
--   customer_name,
--   invoice_number,
--   document_date,
--   document_type,
--   created_at
-- from public.invoices
-- order by created_at desc
-- limit 20
-- offset 0;

-- Read: search by customer name or invoice number.
-- Replace 'ABC' with the user's search text when testing in SQL Editor.
-- select
--   id,
--   customer_name,
--   invoice_number,
--   document_date,
--   document_type,
--   created_at
-- from public.invoices
-- where customer_name ilike '%ABC%'
--    or invoice_number ilike '%ABC%'
-- order by created_at desc
-- limit 20
-- offset 0;

-- Read: load one document for CreateInvoicePage edit mode.
-- Replace the uuid below with a real id from the invoices table.
-- select
--   id,
--   customer_name,
--   invoice_number,
--   document_date,
--   document_type,
--   customer_address,
--   tax_id,
--   items,
--   subtotal,
--   vat_amount,
--   grand_total,
--   created_at,
--   updated_at
-- from public.invoices
-- where id = '00000000-0000-0000-0000-000000000000'
-- limit 1;

-- Create: save a new document.
-- insert into public.invoices (
--   customer_name,
--   invoice_number,
--   document_date,
--   document_type,
--   customer_address,
--   tax_id,
--   items,
--   subtotal,
--   vat_amount,
--   grand_total
-- ) values (
--   'ABC จำกัด',
--   'INV69-001-1',
--   '2026-06-15',
--   'ใบวางบิล / ใบแจ้งหนี้',
--   '99/12 ถนนสุขุมวิท แขวงคลองตัน เขตคลองเตย กรุงเทพมหานคร 10110',
--   '0105569000001',
--   '[{"description":"ค่าบริการออกแบบสื่อประชาสัมพันธ์","quantity":1,"unitPrice":15000,"amount":15000}]'::jsonb,
--   15000,
--   1050,
--   16050
-- )
-- returning *;

-- Update: save over an existing document.
-- Replace the uuid below with a real id from the invoices table.
-- update public.invoices
-- set
--   customer_name = 'ABC จำกัด',
--   invoice_number = 'INV69-001-1',
--   document_date = '2026-06-15',
--   document_type = 'ใบวางบิล / ใบแจ้งหนี้',
--   customer_address = '99/12 ถนนสุขุมวิท แขวงคลองตัน เขตคลองเตย กรุงเทพมหานคร 10110',
--   tax_id = '0105569000001',
--   items = '[{"description":"ค่าบริการออกแบบสื่อประชาสัมพันธ์","quantity":1,"unitPrice":15000,"amount":15000}]'::jsonb,
--   subtotal = 15000,
--   vat_amount = 1050,
--   grand_total = 16050
-- where id = '00000000-0000-0000-0000-000000000000'
-- returning *;

-- Delete: remove one document.
-- Replace the uuid below with a real id from the invoices table.
-- delete from public.invoices
-- where id = '00000000-0000-0000-0000-000000000000';

-- Optional RLS setup. Adjust policies to your login/auth model before production.
alter table public.invoices enable row level security;

drop policy if exists "Allow read invoices" on public.invoices;
create policy "Allow read invoices"
on public.invoices
for select
using (true);

drop policy if exists "Allow insert invoices" on public.invoices;
create policy "Allow insert invoices"
on public.invoices
for insert
with check (true);

drop policy if exists "Allow update invoices" on public.invoices;
create policy "Allow update invoices"
on public.invoices
for update
using (true)
with check (true);

drop policy if exists "Allow delete invoices" on public.invoices;
create policy "Allow delete invoices"
on public.invoices
for delete
using (true);
