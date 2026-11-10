# Backend

MagnaVita has no server of its own. Optional accounts use **Supabase** (email and password, confirmed with a code sent to the inbox). Supabase hands each account email to a small function, `send-email`, which sends it through **Brevo's API**.

## One-time setup in the Supabase dashboard

1. **Database:** SQL Editor → run `supabase/schema.sql` (safe to run again). It creates the `profiles` table (one row per user: profile and goals), Row Level Security so each user reads and writes only their own row, a trigger that creates the row at sign-up, and `delete_my_account()` for in-app account deletion.
2. **Email sign-up:** Authentication → Sign In / Providers → Email: keep **Confirm email** on. Email OTP length 6 (the app accepts 6–10 digits), expiry 3600 s.
3. **The email function:** Edge Functions → Deploy a new function → **Via Editor**. Name it `send-email`, paste `supabase/functions/send-email/index.ts`, deploy. Then open the function's **Details** and turn **Verify JWT** (JWT verification) **off**: Supabase signs hook calls itself, and the function checks that signature.
4. **Turn the hook on:** Authentication → Hooks → **Add hook → Send Email hook** → type **HTTPS** → URL `https://islckdvxqfrqmsvqbido.supabase.co/functions/v1/send-email` → **Generate secret** → copy the secret (`v1,whsec_…`) → create the hook.
5. **Secrets:** Edge Functions → Secrets → add
   - `BREVO_API_KEY`: a Brevo API key (Brevo → SMTP & API → API keys, `xkeysib-…`)
   - `SEND_EMAIL_HOOK_SECRET`: the secret from step 4
   - `SENDER_EMAIL` (optional): a sender verified in Brevo → Senders; defaults to `lee1muzveba@gmail.com`
6. **Check:** create an account in the app; the code should arrive within a minute (check spam). If not, Edge Functions → `send-email` → Logs shows Brevo's answer.

Diary, kitchen, workouts, weigh-in history and fasting sessions stay on the phone and are never sent here. The Brevo key lives only in Supabase's secrets: never put it, or the service-role key, in the app or this repo.

## Testing the function locally

```bash
npx deno test --allow-env --allow-net backend/supabase/functions/send-email/
```

The tests sign fake hook calls like Supabase does and capture what would be sent to Brevo; nothing is really sent.
