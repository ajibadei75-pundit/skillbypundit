-- Pundit Studio · Supabase schema. Run in the Supabase SQL editor.
-- 1) Create admin user: Authentication → Users → Add user (email + password). That email is the admin "username".
do $$ declare t text; begin
 foreach t in array array['registrations','assignments','submissions','quizzes','results'] loop
  execute format('create table if not exists %I (id text primary key, data jsonb not null, created_at timestamptz default now())',t);
  execute format('alter table %I enable row level security',t);
 end loop; end $$;
-- Public (anon) may submit and read only what participants need
create policy "anon add registrations" on registrations for insert to anon with check (true);
create policy "anon add submissions" on submissions for insert to anon with check (true);
create policy "anon add results" on results for insert to anon with check (true);
create policy "anon read assignments" on assignments for select to anon using (true);
create policy "anon read quizzes" on quizzes for select to anon using (true);
-- Signed-in admin: full access
create policy "admin all registrations" on registrations for all to authenticated using (true) with check (true);
create policy "admin all assignments" on assignments for all to authenticated using (true) with check (true);
create policy "admin all submissions" on submissions for all to authenticated using (true) with check (true);
create policy "admin all quizzes" on quizzes for all to authenticated using (true) with check (true);
create policy "admin all results" on results for all to authenticated using (true) with check (true);
-- Public seat counter without exposing personal data
create or replace function seat_count() returns int language sql security definer as $$ select count(*)::int from registrations $$;
grant execute on function seat_count() to anon, authenticated;
-- Enforce the 50-seat cap on the server
create or replace function cap_check() returns trigger language plpgsql security definer as $$
begin if (select count(*) from registrations) >= 50 then raise exception 'Registration closed'; end if; return new; end $$;
create trigger cap_registrations before insert on registrations for each row execute function cap_check();

-- ===== v3 additions: settings (certificate/flier/announcement), student lookup, public leaderboard =====
create table if not exists settings (id text primary key, data jsonb not null, created_at timestamptz default now());
alter table settings enable row level security;
create policy "anon read settings" on settings for select to anon using (true);
create policy "admin all settings" on settings for all to authenticated using (true) with check (true);
create policy "anon read results" on results for select to anon using (true);
create or replace function check_email(e text) returns table(name text, approved boolean) language sql security definer as $$
  select data->>'name', coalesce((data->>'approved')::boolean,false) from registrations where lower(data->>'email')=lower(e) limit 1 $$;
grant execute on function check_email(text) to anon, authenticated;
