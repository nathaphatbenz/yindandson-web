-- YinD: remove known demo rows and load the current production documents.
-- Run this complete file in Supabase SQL Editor.
-- It removes only rows created by the supplied demo seed UUIDs.

begin;

delete from public.invoices
where id in (
  '10000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000002',
  '10000000-0000-4000-8000-000000000003',
  '10000000-0000-4000-8000-000000000004',
  '10000000-0000-4000-8000-000000000005',
  '10000000-0000-4000-8000-000000000006',
  '10000000-0000-4000-8000-000000000007',
  '10000000-0000-4000-8000-000000000008',
  '10000000-0000-4000-8000-000000000009',
  '10000000-0000-4000-8000-000000000010',
  '10000000-0000-4000-8000-000000000101',
  '10000000-0000-4000-8000-000000000102',
  '10000000-0000-4000-8000-000000000103',
  '10000000-0000-4000-8000-000000000104',
  '10000000-0000-4000-8000-000000000105'
);

-- Allow this script to be rerun without creating duplicate current documents.
delete from public.invoices
where invoice_number in (
  'RE-2569-065',
  'RE-2569-075',
  'INV01-053',
  'INV01-050'
);

insert into public.invoices (
  id,
  customer_name,
  invoice_number,
  document_date,
  document_type,
  document_group,
  document_year,
  document_status,
  customer_address,
  tax_id,
  items,
  subtotal,
  vat_amount,
  grand_total
) values
(
  '20000000-0000-4000-8000-000000000053',
  'เปรมโยธา',
  'INV01-053',
  '2026-06-20',
  'ใบวางบิล / ใบแจ้งหนี้',
  'INV',
  2569,
  'issued',
  '',
  '',
  '[]'::jsonb,
  0,
  0,
  0
),
(
  '20000000-0000-4000-8000-000000000050',
  'ศรีราชา ฮิลลไซด์',
  'INV01-050',
  '2026-06-25',
  'ใบวางบิล / ใบแจ้งหนี้',
  'INV',
  2569,
  'issued',
  '',
  '',
  '[]'::jsonb,
  0,
  0,
  0
);

insert into public.invoices (
  id,
  customer_name,
  invoice_number,
  document_date,
  document_type,
  document_group,
  document_year,
  document_status,
  source_invoice_id,
  customer_address,
  tax_id,
  items,
  subtotal,
  vat_amount,
  grand_total
) values
(
  '20000000-0000-4000-8000-000000000065',
  'เปรมโยธา',
  'RE-2569-065',
  '2026-06-20',
  'ใบกำกับภาษี / ใบเสร็จรับเงิน',
  'RE',
  2569,
  'issued',
  '20000000-0000-4000-8000-000000000053',
  '',
  '',
  '[]'::jsonb,
  0,
  0,
  0
),
(
  '20000000-0000-4000-8000-000000000075',
  'ศรีราชา ฮิลลไซด์',
  'RE-2569-075',
  '2026-06-25',
  'ใบกำกับภาษี / ใบเสร็จรับเงิน',
  'RE',
  2569,
  'reserved',
  '20000000-0000-4000-8000-000000000050',
  '',
  '',
  '[]'::jsonb,
  0,
  0,
  0
);

commit;

select
  receipt.document_date,
  receipt.invoice_number as receipt_number,
  source.invoice_number as reference_invoice_number,
  receipt.customer_name,
  receipt.document_status
from public.invoices as receipt
left join public.invoices as source on source.id = receipt.source_invoice_id
where receipt.invoice_number in ('RE-2569-065', 'RE-2569-075')
order by receipt.document_date asc, receipt.invoice_number asc;
