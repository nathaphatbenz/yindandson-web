-- Link receipt/tax invoice documents back to the original INV document.
-- Run this in Supabase SQL Editor after the invoices table already exists.

alter table public.invoices
add column if not exists source_invoice_id uuid null references public.invoices(id) on delete set null;

create index if not exists invoices_source_invoice_id_idx
  on public.invoices (source_invoice_id);

-- Useful check query:
-- select
--   child.id,
--   child.invoice_number,
--   child.document_type,
--   child.source_invoice_id,
--   parent.invoice_number as source_invoice_number
-- from public.invoices child
-- left join public.invoices parent on parent.id = child.source_invoice_id
-- order by child.created_at desc;
