# YinD Invoice System - Quick Context

## Goal

เว็บสร้างและจัดการเอกสารของ YinD โดยมี 3 หน้าหลัก:

- `login-page.html` - หน้าล็อกอินแบบ local session
- `dashboard-page.html` - รายการเอกสาร, โฟลเดอร์ INV, ค้นหา, แก้ไข, ลบ และเปิด PDF
- `create-invoice-page.html` - สร้าง/แก้ไขใบวางบิลหรือใบกำกับภาษี/ใบเสร็จ และสร้าง PDF A4

ไฟล์ใช้งานทั้งหมดอยู่ใน `outputs/` และเป็น HTML/CSS/JavaScript แบบไม่ใช้ build step หรือ framework

## Start Here

1. อ่าน `outputs/supabase-invoice-client.js` เพื่อดู data contract กับ Supabase
2. อ่าน `outputs/create-invoice-page.html` สำหรับ form, validation, numbering และ PDF template
3. อ่าน `outputs/dashboard-page.html` สำหรับการแสดงผล, grouping และ navigation

## Main Files

| File | Responsibility |
| --- | --- |
| `outputs/login-page.html` | Login gate ผ่าน `sessionStorage` (`admin` / `1234` เป็น demo credentials) |
| `outputs/dashboard-page.html` | Dashboard, folder/grid/table views, search, edit/delete, PDF download |
| `outputs/create-invoice-page.html` | Form เอกสาร, line items, totals, save/update และ PDF layout |
| `outputs/supabase-invoice-client.js` | Supabase client และ CRUD/shared mapping functions |
| `outputs/supabase-invoice-queries.sql` | Schema เริ่มต้นของตาราง `public.invoices` |
| `outputs/supabase-fix-invoices-rls.sql` | SQL สำหรับแก้ RLS เมื่อ insert ถูกปฏิเสธ |
| `outputs/supabase-add-invoice-source-link.sql` | เพิ่มความสัมพันธ์ RE ไปยัง INV ต้นทาง |
| `outputs/supabase-document-number-migration.sql` | Migration สำหรับ group/year/status และ index หมายเลขเอกสาร |
| `outputs/supabase-seed-demo-documents.sql` | Seed ข้อมูล demo: INV 10 รายการและ RE ที่มีทั้ง issued/reserved/cancelled |
| `outputs/yind-logo-pdf.png` | โลโก้ที่ใช้ใน PDF |

## Data Model: `public.invoices`

Fields สำคัญที่หน้าเว็บใช้:

```text
id uuid
customer_name text
customer_address text
tax_id text
invoice_number text
document_date date
document_type text
items jsonb
subtotal numeric
vat_amount numeric
grand_total numeric
created_at timestamptz
document_group text       -- INV หรือ RE
document_year integer     -- ปี พ.ศ. เช่น 2569
document_status text      -- issued | reserved | cancelled
source_invoice_id uuid    -- RE อ้างอิง INV ต้นทาง
```

RE (ใบกำกับภาษี / ใบเสร็จรับเงิน) ต้องอ้างอิง `source_invoice_id` ของ INV ต้นทาง เพื่อให้ Dashboard รวมไว้ในโฟลเดอร์เดียวกันได้

## Document Flow

1. Login สำเร็จ จะตั้ง `sessionStorage.yind_dashboard_logged_in = "true"` แล้วเปิด Dashboard
2. Dashboard โหลด `fetchInvoices()` จาก Supabase และเรียงล่าสุดก่อน
3. Dashboard แสดง INV เป็นโฟลเดอร์หลัก และแสดง RE ที่มี `source_invoice_id` เดียวกันภายในโฟลเดอร์นั้น
4. สร้าง INV ใหม่จาก Dashboard จะเปิด Create Invoice แบบ `ใบวางบิล / ใบแจ้งหนี้`
5. สร้าง RE จากแถว INV จะเปิด Create Invoice พร้อมข้อมูล INV และตั้งชนิดเป็น `ใบกำกับภาษี / ใบเสร็จรับเงิน`
6. บันทึกเอกสารเรียก `createInvoice()` หรือ `updateInvoice()` จาก client และดาวน์โหลด PDF จากหน้า Create Invoice

## Document Number Rules

Current numbering format:

```text
INV-2569-0001
RE-2569-0001
```

Logic อยู่ใน `outputs/create-invoice-page.html`:

- `getDocumentGroup()` แยก INV / RE จากประเภทเอกสาร
- `getDocumentYear()` ใช้ปี พ.ศ. จากวันที่เอกสาร
- `findNextAvailableDocumentNumber(group, year)` ดึงเลขที่ใช้อยู่แล้วจาก Supabase แล้วหาเลขว่างที่น้อยที่สุด
- `validateDocumentNumberBeforeSave()` ป้องกันเลขซ้ำก่อนบันทึก

เลขที่ถือว่าใช้แล้วและห้ามนำกลับมาใช้: `issued`, `reserved`, `cancelled`

ห้ามเปลี่ยนกลับไปใช้ `last_number` เพื่อหาเลขถัดไป เพราะระบบรองรับการจองเลขล่วงหน้า เช่น `RE-2569-0010` ถูกจอง แต่ `RE-2569-0001` ยังต้องถูกเลือกก่อน

## PDF Notes

PDF ถูกสร้างใน `create-invoice-page.html` (ค้นหา `generatePdf` หรือ CSS ส่วน PDF):

- A4 หน้าเดียว, ใช้ Noto Sans Thai ทั้งหน้า
- มี logo จาก `yind-logo-pdf.png`
- INV ใช้พื้นที่ลงนาม: ผู้รับสินค้า / ผู้ส่งสินค้า / ในนาม บริษัท ยินดีแอนด์ซันส์ จำกัด
- RE ใช้พื้นที่ลงนาม: ผู้รับเงิน / วันที่
- รายการสินค้าไม่ตีเส้นคั่นด้านล่างระหว่างแต่ละแถวตาม requirement ล่าสุด

เมื่อแก้ layout PDF ให้แก้ CSS และ HTML template ในไฟล์นี้เท่านั้น และตรวจสอบทั้ง INV กับ RE เสมอ

## Supabase Setup / Troubleshooting

1. รัน `outputs/supabase-invoice-queries.sql` หากยังไม่มีตาราง
2. รัน `outputs/supabase-document-number-migration.sql` เพื่อรองรับระบบเลขเอกสารใหม่
3. รัน `outputs/supabase-add-invoice-source-link.sql` หากยังไม่มี `source_invoice_id`
4. หากบันทึกขึ้น `new row violates row-level security policy` ให้รัน `outputs/supabase-fix-invoices-rls.sql`
5. ต้องการข้อมูลทดลอง ให้เปิด `outputs/supabase-seed-demo-documents.sql`, เลือกทั้งหมด แล้วรันทั้งไฟล์ ห้ามรันเพียง fragment ที่ลงท้าย `, (` เพราะ PostgreSQL จะขึ้น syntax error at end of input

`SUPABASE_URL` และ publishable anon key ถูกตั้งค่าใน `outputs/supabase-invoice-client.js` แล้ว อย่าใส่ service role key ใน frontend

## Important Implementation Details

- `supabase-invoice-client.js` รองรับ schema เก่า: ถ้าคอลัมน์ metadata ยังไม่ถูก migration จะ fallback ไปบันทึกโดยตัด `document_group`, `document_year`, `document_status` ออก
- Dashboard มี `seedSampleRecords()` แบบเก่าหลงเหลือเป็น function แต่ไม่ได้ถูกเรียกใช้ ข้อมูลจริงควรมาจาก Supabase เท่านั้น
- Dashboard เตรียม `paginationState` ไว้แล้ว แต่ยังไม่มี UI pagination เต็มรูปแบบ
- การแก้ไขเอกสารต้องรักษา `invoice_number` เดิม ไม่ generate หมายเลขใหม่
- การสร้าง RE ต้องส่งและเก็บ `source_invoice_id` จาก INV ต้นทาง

## Safe Change Checklist

- Form/data field ใหม่: แก้ทั้ง `collectInvoiceData`, client mapping และ SQL schema
- เปลี่ยน format เลขเอกสาร: แก้ helper ทั้ง generate, parse, validation, migration และ seed ให้สอดคล้องกัน
- เปลี่ยน Dashboard grouping: ทดสอบ INV เดี่ยว, INV+RE, RE reserved และ RE cancelled
- เปลี่ยน PDF: ทดสอบ desktop/mobile form data, หลาย line items และทั้ง document type

