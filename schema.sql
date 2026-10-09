-- Pundit Studio · database schema (ALREADY APPLIED to the project "Pundit Studio Training").
-- Keep as a record, or run on a new Supabase project. Then create the admin user in Authentication → Users.
do $$ declare t text; begin
 foreach t in array array['registrations','assignments','submissions','quizzes','results','settings'] loop
  execute format('create table if not exists public.%I (id text primary key, data jsonb not null, created_at timestamptz default now())',t);
  execute format('alter table public.%I enable row level security',t);
 end loop; end $$;

-- Public (anon): add registrations/submissions/results, read assignments/quizzes/results/settings
create policy "anon add registrations" on public.registrations for insert to anon
  with check (data ? 'name' and data ? 'email' and data ? 'phone' and not (data ? 'approved') and length(data::text) < 2000);
create policy "anon add submissions" on public.submissions for insert to anon
  with check (data ? 'aid' and data ? 'name' and length(data::text) < 4000);
create policy "anon add results" on public.results for insert to anon
  with check (data ? 'qid' and data ? 'name' and length(data::text) < 1000);
create policy "anon read assignments" on public.assignments for select to anon using (true);
create policy "anon read quizzes" on public.quizzes for select to anon using (true);
create policy "anon read results" on public.results for select to anon using (true);
create policy "anon read settings" on public.settings for select to anon using (true);

-- Admin: only the admin email has full access (so open sign-ups cannot gain admin rights)
do $$ declare t text; begin
 foreach t in array array['registrations','assignments','submissions','quizzes','results','settings'] loop
  execute format('create policy "admin all %s" on public.%I for all to authenticated using ((auth.jwt() ->> ''email'') = ''ajibadei75@gmail.com'') with check ((auth.jwt() ->> ''email'') = ''ajibadei75@gmail.com'')',t,t);
 end loop; end $$;

create or replace function public.seat_count() returns int language sql security definer set search_path = public as $$ select count(*)::int from public.registrations $$;
grant execute on function public.seat_count() to anon, authenticated;
create or replace function public.check_email(e text) returns table(name text, approved boolean) language sql security definer set search_path = public as $$
  select data->>'name', coalesce((data->>'approved')::boolean,false) from public.registrations where lower(data->>'email')=lower(e) limit 1 $$;
grant execute on function public.check_email(text) to anon, authenticated;
create or replace function public.cap_check() returns trigger language plpgsql security definer set search_path = public as $$
begin if (select count(*) from public.registrations) >= 50 then raise exception 'Registration closed'; end if; return new; end $$;
create trigger cap_registrations before insert on public.registrations for each row execute function public.cap_check();
