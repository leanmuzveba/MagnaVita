-- MagnaVita accounts: run once in Supabase → SQL Editor (safe to run again).
--
-- Only your profile and goals are stored here. Diary, kitchen, workouts,
-- weigh-in history and everything else stay on the phone.
-- Row Level Security means each signed-in user can only see and change
-- their own row; the publishable key alone can read nothing.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  sex text check (sex in ('female', 'male')),
  birth_year int check (birth_year between 1900 and 2100),
  height_cm real check (height_cm > 0 and height_cm < 300),
  weight_kg real check (weight_kg > 0 and weight_kg < 700),
  main_goal text,                      -- loseWeight / maintain / buildMuscle / getFitter / fasting
  goal_weight_kg real check (goal_weight_kg > 0 and goal_weight_kg < 700),
  pace_kg real check (pace_kg > 0 and pace_kg <= 1),
  activity_level text,                 -- sedentary / light / moderate / active / veryActive
  meals_per_day int check (meals_per_day between 1 and 8),
  training_days int check (training_days between 0 and 7),
  experience text,                     -- beginner / intermediate / expert
  equipment text,                      -- gym / dumbbells / bodyweight
  diet text,
  allergies text[] not null default '{}',
  units text,                          -- metric / imperial
  setup_done boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Read own profile" on public.profiles;
create policy "Read own profile" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);

drop policy if exists "Create own profile" on public.profiles;
create policy "Create own profile" on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);

drop policy if exists "Update own profile" on public.profiles;
create policy "Update own profile" on public.profiles
  for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

-- Keep updated_at current.
create or replace function public.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists profiles_touch on public.profiles;
create trigger profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

-- A profile row for every new account, with the name given at sign-up
-- (email sign-up passes it as "name"; Google provides "full_name").
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'full_name', '')
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- "Delete my account" in the app: removes the signed-in user (and, through the
-- cascade, their profile). Callable only by that user for themselves.
create or replace function public.delete_my_account() returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in';
  end if;
  delete from auth.users where id = auth.uid();
end $$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
revoke all on function public.handle_new_user() from public, anon, authenticated;
