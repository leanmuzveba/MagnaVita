# Backend

MagnaVita has no server of its own. Optional accounts use **Supabase** (email and password, confirmed with a code sent to the inbox), with emails delivered by **Brevo**.

## One-time setup in the Supabase dashboard

1. **Database:** SQL Editor → run `supabase/schema.sql` (safe to run again). It creates the `profiles` table (one row per user: profile and goals), Row Level Security so each user reads and writes only their own row, a trigger that creates the row at sign-up, and `delete_my_account()` for in-app account deletion.
2. **Email sign-up:** Authentication → Sign In / Providers → Email: keep **Confirm email** on. Email OTP length 6 (the app accepts 6–10 digits), expiry 3600 s.
3. **Emails through Brevo:** Authentication → Emails → SMTP Settings → enable custom SMTP:
   - Host `smtp-relay.brevo.com`, port `587`
   - Username: the **SMTP login** from Brevo → SMTP & API → SMTP (looks like `xxxx@smtp-brevo.com`)
   - Password: a Brevo **SMTP key** (starts `xsmtpsib-`), not the API key
   - Sender email: a sender verified in Brevo → Senders; sender name `MagnaVita`
4. **Templates:** Authentication → Emails → Templates: paste `supabase/email-templates/confirm-signup.html` into "Confirm sign up" and `reset-password.html` into "Reset password" (subjects are in each file's first comment). They show the code (`{{ .Token }}`) the app asks for.
5. **Rate limits:** Authentication → Rate Limits → raise "emails sent per hour" now that custom SMTP is on.

Diary, kitchen, workouts, weigh-in history and fasting sessions stay on the phone and are never sent here. Never put the service-role key, the SMTP key or a Brevo API key in the app.
