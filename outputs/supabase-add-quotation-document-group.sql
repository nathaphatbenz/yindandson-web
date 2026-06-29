-- Allow quotation documents in the existing YinD invoices table.
-- Run this in Supabase SQL Editor if your current table has
-- invoices_document_group_check limited to only INV and RE.

alter table public.invoices
  add column if not exists document_group text;

update public.invoices
set document_group = 'QT'
where document_group is null
  and (
    upper(invoice_number) like 'QT-%'
    or document_type ilike '%ใบเสนอราคา%'
  );

alter table public.invoices
  drop constraint if exists invoices_document_group_check;

alter table public.invoices
  add constraint invoices_document_group_check
  check (document_group in ('INV', 'RE', 'QT'));

create index if not exists invoices_document_group_year_status_idx
  on public.invoices (document_group, document_year, document_status);
