-- YinD document number metadata.
-- Run this in Supabase SQL Editor to support issued/reserved/cancelled numbers.

alter table public.invoices
add column if not exists document_group text,
add column if not exists document_year integer,
add column if not exists document_status text not null default 'issued';

update public.invoices
set
  document_group = coalesce(
    document_group,
    case
      when upper(invoice_number) like 'RE-%' then 'RE'
      when upper(invoice_number) like 'RE.%' then 'RE'
      when document_type ilike '%ใบเสร็จรับเงิน%' then 'RE'
      else 'INV'
    end
  ),
  document_year = coalesce(
    document_year,
    case
      when invoice_number ~ '^[A-Za-z.]+-[0-9]{4}-[0-9]{3,4}$'
        then substring(invoice_number from '^[A-Za-z.]+-([0-9]{4})-[0-9]{3,4}$')::integer
      else extract(year from document_date)::integer + 543
    end
  ),
  document_status = coalesce(document_status, 'issued');

alter table public.invoices
alter column document_group set not null,
alter column document_year set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'invoices_document_group_check'
      and conrelid = 'public.invoices'::regclass
  ) then
    alter table public.invoices
    add constraint invoices_document_group_check
    check (document_group in ('INV', 'RE'));
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'invoices_document_status_check'
      and conrelid = 'public.invoices'::regclass
  ) then
    alter table public.invoices
    add constraint invoices_document_status_check
    check (document_status in ('issued', 'reserved', 'cancelled'));
  end if;
end $$;

create index if not exists invoices_document_group_year_status_idx
  on public.invoices (document_group, document_year, document_status);

create unique index if not exists invoices_invoice_number_unique_idx
  on public.invoices (invoice_number);

-- Example query to see numbers counted as unavailable.
-- select invoice_number, document_group, document_year, document_status
-- from public.invoices
-- where document_group = 'RE'
--   and document_year = 2569
--   and document_status in ('issued', 'reserved', 'cancelled')
-- order by invoice_number;
