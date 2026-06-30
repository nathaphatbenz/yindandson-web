-- YinD Monthly Work tables. Run this complete file in Supabase SQL Editor.

create table if not exists public.monthly_vehicle_work_logs (
  id uuid primary key default gen_random_uuid(),
  work_month integer not null check (work_month between 1 and 12),
  work_year integer not null,
  work_date date not null,
  vehicle_name text not null,
  work_detail text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (work_year, work_month, work_date, vehicle_name)
);

create table if not exists public.monthly_employee_withdrawals (
  id uuid primary key default gen_random_uuid(),
  work_month integer not null check (work_month between 1 and 12),
  work_year integer not null,
  withdrawal_date date not null,
  employee_name text not null,
  withdrawal_detail text not null,
  amount numeric(12, 2) not null check (amount >= 0),
  note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.monthly_shared_vehicle_withdrawals (
  id uuid primary key default gen_random_uuid(),
  work_month integer not null check (work_month between 1 and 12),
  work_year integer not null,
  withdrawal_date date not null,
  withdrawal_type text not null,
  withdrawal_detail text not null,
  amount numeric(12, 2) not null check (amount >= 0),
  note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_monthly_work_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists monthly_vehicle_work_logs_updated_at on public.monthly_vehicle_work_logs;
create trigger monthly_vehicle_work_logs_updated_at
before update on public.monthly_vehicle_work_logs
for each row execute function public.set_monthly_work_updated_at();

drop trigger if exists monthly_employee_withdrawals_updated_at on public.monthly_employee_withdrawals;
create trigger monthly_employee_withdrawals_updated_at
before update on public.monthly_employee_withdrawals
for each row execute function public.set_monthly_work_updated_at();

drop trigger if exists monthly_shared_vehicle_withdrawals_updated_at on public.monthly_shared_vehicle_withdrawals;
create trigger monthly_shared_vehicle_withdrawals_updated_at
before update on public.monthly_shared_vehicle_withdrawals
for each row execute function public.set_monthly_work_updated_at();

alter table public.monthly_vehicle_work_logs enable row level security;
alter table public.monthly_employee_withdrawals enable row level security;
alter table public.monthly_shared_vehicle_withdrawals enable row level security;

drop policy if exists "Authenticated users manage monthly vehicle work" on public.monthly_vehicle_work_logs;
create policy "Authenticated users manage monthly vehicle work"
on public.monthly_vehicle_work_logs
for all to authenticated
using (true)
with check (true);

drop policy if exists "Authenticated users manage employee withdrawals" on public.monthly_employee_withdrawals;
create policy "Authenticated users manage employee withdrawals"
on public.monthly_employee_withdrawals
for all to authenticated
using (true)
with check (true);

drop policy if exists "Authenticated users manage shared vehicle withdrawals" on public.monthly_shared_vehicle_withdrawals;
create policy "Authenticated users manage shared vehicle withdrawals"
on public.monthly_shared_vehicle_withdrawals
for all to authenticated
using (true)
with check (true);
