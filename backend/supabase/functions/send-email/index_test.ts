// Run: npx deno test --allow-env --allow-net backend/supabase/functions/send-email/
import { assert, assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0";
import { compose, handle } from "./index.ts";

const secretB64 = btoa("a test secret that is long enough!");
Deno.env.set("SEND_EMAIL_HOOK_SECRET", `v1,whsec_${secretB64}`);
Deno.env.set("BREVO_API_KEY", "test-key");

function signed(payload: unknown, secret = secretB64): Request {
  const body = JSON.stringify(payload);
  const id = "msg_1";
  const ts = new Date();
  const signature = new Webhook(secret).sign(id, ts, body);
  return new Request("http://localhost/", {
    method: "POST",
    body,
    headers: {
      "webhook-id": id,
      "webhook-timestamp": `${Math.floor(ts.getTime() / 1000)}`,
      "webhook-signature": signature,
    },
  });
}

function captureFetch(status = 201) {
  const calls: { url: string; headers: Headers; body: Record<string, unknown> }[] = [];
  globalThis.fetch = (input: string | URL | Request, init?: RequestInit) => {
    calls.push({
      url: String(input),
      headers: new Headers(init?.headers),
      body: JSON.parse(String(init?.body)),
    });
    return Promise.resolve(new Response("{}", { status }));
  };
  return calls;
}

Deno.test("sign-up code goes to Brevo with the API key", async () => {
  const calls = captureFetch();
  const res = await handle(signed({
    user: { email: "rudo@example.com" },
    email_data: { token: "123456", email_action_type: "signup" },
  }));
  assertEquals(res.status, 200);
  assertEquals(calls.length, 1);
  assertEquals(calls[0].url, "https://api.brevo.com/v3/smtp/email");
  assertEquals(calls[0].headers.get("api-key"), "test-key");
  assertEquals(calls[0].body.to, [{ email: "rudo@example.com" }]);
  assertEquals(calls[0].body.subject, "Your MagnaVita code: 123456");
  assert(String(calls[0].body.htmlContent).includes("123456"));
});

Deno.test("password reset uses its own wording", () => {
  const { subject, html } = compose("recovery", "654321");
  assertEquals(subject, "Your MagnaVita password code: 654321");
  assert(html.includes("choose a new password"));
});

Deno.test("a call not signed by Supabase is refused and nothing is sent", async () => {
  const calls = captureFetch();
  const res = await handle(signed({
    user: { email: "x@example.com" },
    email_data: { token: "1", email_action_type: "signup" },
  }, btoa("someone else's secret value!!")));
  assertEquals(res.status, 401);
  assertEquals(calls.length, 0);
});

Deno.test("a Brevo failure is reported, so Supabase shows an error", async () => {
  captureFetch(400);
  const res = await handle(signed({
    user: { email: "rudo@example.com" },
    email_data: { token: "123456", email_action_type: "signup" },
  }));
  assertEquals(res.status, 502);
});
