alter table public.invoices
  add column if not exists company_code text not null default 'YDS';

update public.invoices
set company_code = 'YDS'
where company_code is null or company_code = '';

alter table public.invoices
  drop constraint if exists invoices_company_code_check;

alter table public.invoices
  add constraint invoices_company_code_check
  check (company_code in ('YDS', 'YDH'));

create index if not exists invoices_company_code_idx
  on public.invoices(company_code);

create index if not exists invoices_company_number_idx
  on public.invoices(company_code, invoice_number);

create index if not exists invoices_company_group_year_idx
  on public.invoices(company_code, document_group, document_year);

do $$
begin
  if to_regclass('public.documents') is not null then
    execute 'alter table public.documents add column if not exists company_code text not null default ''YDS''';
    execute 'update public.documents set company_code = ''YDS'' where company_code is null or company_code = ''''';
    execute 'alter table public.documents drop constraint if exists documents_company_code_check';
    execute 'alter table public.documents add constraint documents_company_code_check check (company_code in (''YDS'', ''YDH''))';
    execute 'create index if not exists documents_company_code_idx on public.documents(company_code)';
  end if;
end $$;
