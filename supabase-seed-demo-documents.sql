-- YinD demo seed: 10 INV folders with receipt/tax-invoice scenarios.
-- Run the whole file in Supabase SQL Editor.
-- This deletes only the demo document numbers below, then inserts fresh demo rows.

alter table public.invoices add column if not exists document_group text;
alter table public.invoices add column if not exists document_year integer;
alter table public.invoices add column if not exists document_status text default 'issued';
alter table public.invoices add column if not exists source_invoice_id uuid null references public.invoices(id) on delete set null;

delete from public.invoices
where invoice_number in (
  'INV-2569-0001',
  'INV-2569-0002',
  'INV-2569-0003',
  'INV-2569-0004',
  'INV-2569-0005',
  'INV-2569-0006',
  'INV-2569-0007',
  'INV-2569-0008',
  'INV-2569-0009',
  'INV-2570-0001',
  'RE-2569-0001',
  'RE-2569-0002',
  'RE-2569-0003',
  'RE-2569-0010',
  'RE-2570-0001'
);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000001', 'บริษัท อัลฟ่า เทรดดิ้ง จำกัด', 'INV-2569-0001', '2026-06-18', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '99/12 ถนนสุขุมวิท กรุงเทพมหานคร 10110', '0105569000001', '[{"description":"ค่าบริการออกแบบสื่อประชาสัมพันธ์","quantity":1,"unitPrice":18000,"amount":18000}]'::jsonb, 18000, 1260, 19260);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000002', 'บริษัท เบต้า โลจิสติกส์ จำกัด', 'INV-2569-0002', '2026-06-17', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '199/7 ถนนบางนา-ตราด กรุงเทพมหานคร 10260', '0105569000002', '[{"description":"ค่าขนส่งและประสานงาน","quantity":2,"unitPrice":7200,"amount":14400}]'::jsonb, 14400, 1008, 15408);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000003', 'บริษัท แกมมา ฟู้ดส์ จำกัด', 'INV-2569-0003', '2026-06-16', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '45/9 ถนนมิตรภาพ ขอนแก่น 40000', '0105569000003', '[{"description":"ค่าสินค้าและค่าขนส่ง","quantity":1,"unitPrice":9500,"amount":9500}]'::jsonb, 9500, 665, 10165);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000004', 'บริษัท เดลต้า มีเดีย จำกัด', 'INV-2569-0004', '2026-06-15', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '55/21 ถนนลาดพร้าว กรุงเทพมหานคร 10900', '0105569000004', '[{"description":"ค่าบริการถ่ายภาพสินค้า","quantity":3,"unitPrice":4500,"amount":13500}]'::jsonb, 13500, 945, 14445);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000005', 'บริษัท เอคโค่ รีเทล จำกัด', 'INV-2569-0005', '2026-06-14', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '101/4 ถนนพหลโยธิน กรุงเทพมหานคร 10400', '0105569000005', '[{"description":"ค่าที่ปรึกษาระบบหน้าร้าน","quantity":1,"unitPrice":22000,"amount":22000}]'::jsonb, 22000, 1540, 23540);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000006', 'บริษัท ฟลอร่า โปรดักส์ จำกัด', 'INV-2569-0006', '2026-06-13', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '22/8 ถนนราชพฤกษ์ นนทบุรี 11130', '0105569000006', '[{"description":"ค่าผลิตสื่อและบรรจุภัณฑ์","quantity":2,"unitPrice":11200,"amount":22400}]'::jsonb, 22400, 1568, 23968);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000007', 'บริษัท กรีนไลน์ ซัพพลาย จำกัด', 'INV-2569-0007', '2026-06-12', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '77/9 ถนนวิภาวดีรังสิต กรุงเทพมหานคร 10210', '0105569000007', '[{"description":"ค่าบริการจัดซื้อและจัดส่ง","quantity":4,"unitPrice":3800,"amount":15200}]'::jsonb, 15200, 1064, 16264);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000008', 'บริษัท ฮอไรซอน ดีไซน์ จำกัด', 'INV-2569-0008', '2026-06-11', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '9/88 ถนนรัตนาธิเบศร์ นนทบุรี 11000', '0105569000008', '[{"description":"ค่าออกแบบและวางระบบเอกสาร","quantity":1,"unitPrice":30500,"amount":30500}]'::jsonb, 30500, 2135, 32635);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000009', 'บริษัท ไอริส เฮลท์แคร์ จำกัด', 'INV-2569-0009', '2026-06-10', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2569, 'issued', '33/10 ถนนติวานนท์ นนทบุรี 11000', '0105569000009', '[{"description":"ค่าบริการดูแลระบบรายเดือน","quantity":1,"unitPrice":16000,"amount":16000}]'::jsonb, 16000, 1120, 17120);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000010', 'บริษัท เจนเนอเรชั่น ซัพพลาย จำกัด', 'INV-2570-0001', '2027-01-05', 'ใบวางบิล / ใบแจ้งหนี้', 'INV', 2570, 'issued', '44/2 ถนนศรีราชา-หนองค้อ ชลบุรี 20110', '0105570000001', '[{"description":"เอกสารตัวอย่างคนละปี","quantity":1,"unitPrice":12500,"amount":12500}]'::jsonb, 12500, 875, 13375);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, source_invoice_id, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000101', 'บริษัท อัลฟ่า เทรดดิ้ง จำกัด', 'RE-2569-0010', '2026-06-18', 'ใบกำกับภาษี / ใบเสร็จรับเงิน', 'RE', 2569, 'reserved', '10000000-0000-4000-8000-000000000001', '99/12 ถนนสุขุมวิท กรุงเทพมหานคร 10110', '0105569000001', '[{"description":"เลข RE จองล่วงหน้าเพื่อทดสอบการหาเลขว่างต่ำสุด","quantity":1,"unitPrice":18000,"amount":18000}]'::jsonb, 18000, 1260, 19260);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, source_invoice_id, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000102', 'บริษัท เบต้า โลจิสติกส์ จำกัด', 'RE-2569-0001', '2026-06-17', 'ใบกำกับภาษี / ใบเสร็จรับเงิน', 'RE', 2569, 'issued', '10000000-0000-4000-8000-000000000002', '199/7 ถนนบางนา-ตราด กรุงเทพมหานคร 10260', '0105569000002', '[{"description":"ใบเสร็จรับเงินแบบออกตามปกติ","quantity":2,"unitPrice":7200,"amount":14400}]'::jsonb, 14400, 1008, 15408);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, source_invoice_id, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000103', 'บริษัท แกมมา ฟู้ดส์ จำกัด', 'RE-2569-0002', '2026-06-16', 'ใบกำกับภาษี / ใบเสร็จรับเงิน', 'RE', 2569, 'cancelled', '10000000-0000-4000-8000-000000000003', '45/9 ถนนมิตรภาพ ขอนแก่น 40000', '0105569000003', '[{"description":"ใบเสร็จรับเงินที่ยกเลิกแล้ว เลขยังห้ามใช้ซ้ำ","quantity":1,"unitPrice":9500,"amount":9500}]'::jsonb, 9500, 665, 10165);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, source_invoice_id, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000104', 'บริษัท เดลต้า มีเดีย จำกัด', 'RE-2569-0003', '2026-06-15', 'ใบกำกับภาษี / ใบเสร็จรับเงิน', 'RE', 2569, 'issued', '10000000-0000-4000-8000-000000000004', '55/21 ถนนลาดพร้าว กรุงเทพมหานคร 10900', '0105569000004', '[{"description":"ชำระเงินเรียบร้อย","quantity":3,"unitPrice":4500,"amount":13500}]'::jsonb, 13500, 945, 14445);

insert into public.invoices (id, customer_name, invoice_number, document_date, document_type, document_group, document_year, document_status, source_invoice_id, customer_address, tax_id, items, subtotal, vat_amount, grand_total)
values ('10000000-0000-4000-8000-000000000105', 'บริษัท เจนเนอเรชั่น ซัพพลาย จำกัด', 'RE-2570-0001', '2027-01-05', 'ใบกำกับภาษี / ใบเสร็จรับเงิน', 'RE', 2570, 'issued', '10000000-0000-4000-8000-000000000010', '44/2 ถนนศรีราชา-หนองค้อ ชลบุรี 20110', '0105570000001', '[{"description":"ใบเสร็จรับเงินคนละปี","quantity":1,"unitPrice":12500,"amount":12500}]'::jsonb, 12500, 875, 13375);
