// Supabase "Send Email" auth hook: Supabase calls this function instead of
// sending auth emails itself, and it sends them through Brevo's API.
//
// Secrets (Supabase → Edge Functions → Secrets):
//   BREVO_API_KEY           Brevo → SMTP & API → API keys (xkeysib-…)
//   SEND_EMAIL_HOOK_SECRET  from Authentication → Hooks → Send Email (v1,whsec_…)
//   SENDER_EMAIL            optional; a sender verified in Brevo
// Deploy with JWT verification OFF: Supabase signs hook calls itself, and
// this function checks that signature.

import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0";

const brevoUrl = Deno.env.get("BREVO_URL") ?? "https://api.brevo.com/v3/smtp/email";
const senderEmail = Deno.env.get("SENDER_EMAIL") ?? "lee1muzveba@gmail.com";
const senderName = "MagnaVita";

interface HookPayload {
  user: { email: string; new_email?: string };
  email_data: { token: string; token_new?: string; email_action_type: string };
}

/** Subject and HTML for each kind of auth email; every one shows the code. */
export function compose(type: string, code: string): { subject: string; html: string } {
  const [subject, heading, line, footer] = {
    signup: [
      `Your MagnaVita code: ${code}`,
      "Welcome to MagnaVita",
      "Enter this code in the app to confirm your email:",
      "If you didn’t create a MagnaVita account, you can ignore this email.",
    ],
    recovery: [
      `Your MagnaVita password code: ${code}`,
      "Reset your MagnaVita password",
      "Enter this code in the app, then choose a new password:",
      "If you didn’t ask to reset your password, you can ignore this email; your password stays the same.",
    ],
    email_change: [
      `Confirm your new email: ${code}`,
      "Confirm your new email",
      "Enter this code in the app to confirm your new email address:",
      "If you didn’t ask for this, you can ignore this email.",
    ],
  }[type] ?? [
    `Your MagnaVita code: ${code}`,
    "Your MagnaVita code",
    "Enter this code in the app:",
    "If you didn’t ask for this, you can ignore this email.",
  ];
  const html = `<div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; color: #1A2A20;">
  <h2 style="color: #135D44;">${heading}</h2>
  <p>${line}</p>
  <p style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #135D44; background: #F6FCEF; padding: 16px; text-align: center; border-radius: 12px;">${code}</p>
  <p>The code expires in an hour. ${footer}</p>
</div>`;
  return { subject, html };
}

function failure(status: number, message: string): Response {
  return new Response(JSON.stringify({ error: { http_code: status, message } }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export async function handle(req: Request): Promise<Response> {
  const secret = (Deno.env.get("SEND_EMAIL_HOOK_SECRET") ?? "").replace("v1,whsec_", "");
  const apiKey = Deno.env.get("BREVO_API_KEY");
  if (!secret || !apiKey) return failure(500, "Email hook is not configured");

  const body = await req.text();
  let payload: HookPayload;
  try {
    payload = new Webhook(secret).verify(body, Object.fromEntries(req.headers)) as HookPayload;
  } catch {
    return failure(401, "Invalid signature");
  }

  const { user, email_data } = payload;
  // Changing email sends a code to the new address too.
  const messages = [{ to: user.email, code: email_data.token }];
  if (email_data.email_action_type === "email_change" && user.new_email && email_data.token_new) {
    messages.push({ to: user.new_email, code: email_data.token_new });
  }

  for (const m of messages) {
    if (!m.code) continue;
    const { subject, html } = compose(email_data.email_action_type, m.code);
    const res = await fetch(brevoUrl, {
      method: "POST",
      headers: { "api-key": apiKey, "content-type": "application/json", accept: "application/json" },
      body: JSON.stringify({
        sender: { name: senderName, email: senderEmail },
        to: [{ email: m.to }],
        subject,
        htmlContent: html,
      }),
    });
    if (!res.ok) {
      console.error("Brevo error", res.status, await res.text());
      return failure(502, "Couldn't send the email");
    }
  }
  return new Response(JSON.stringify({}), { status: 200, headers: { "Content-Type": "application/json" } });
}

if (import.meta.main) Deno.serve(handle);
