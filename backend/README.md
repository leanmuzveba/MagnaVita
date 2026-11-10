# Backend

MagnaVita has no server of its own. Optional accounts use **Supabase**:

- `supabase/schema.sql` creates the `profiles` table (one row per user: profile and goals), Row Level Security so each user reads and writes only their own row, a trigger that creates the row at sign-up, and `delete_my_account()` for in-app account deletion. Run it once in the project's SQL Editor; it is safe to run again.
- Diary, kitchen, workouts, weigh-in history and fasting sessions stay on the phone and are never sent here.
