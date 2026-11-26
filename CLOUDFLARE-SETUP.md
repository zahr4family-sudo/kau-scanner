# KAU Scanner — Cloudflare Pages + Pages Functions + D1 + Brevo

## Deploy
1. Push this repository to GitHub. In Cloudflare Dashboard → Workers & Pages → Create → Pages → Connect to Git, choose repository.
2. Build settings: Framework preset **None**; Build command empty; Build output directory `/` (root). Functions folder `/functions` is auto-detected by Pages.
3. Create D1 database (example `kau-access`). D1 → Console, execute the complete `schema.sql`.
4. Pages project → Settings → Functions → D1 database bindings: binding name `DB`, select database `kau-access`.
5. Pages project → Settings → Variables and Secrets, add secrets:
   - `BREVO_API_KEY` — Brevo API key (secret)
   - `OTP_FROM_EMAIL` — verified sender address in Brevo
   - `OTP_FROM_NAME` — optional, e.g. `KAU Scanner`
   - `OTP_PEPPER` — random secret string, minimum 32 random characters
   - `ADMIN_PASSWORD` — strong admin password
   - `ADMIN_SESSION_SECRET` — random secret at least 32 characters for signing admin session
6. Redeploy Pages after configuring bindings/secrets. Confirm OTP endpoints use `/api/otp/request` and `/api/otp/verify`, registration `/api/register`.

## Brevo
- Create/login at https://www.brevo.com/ and generate an API key under SMTP & API → API Keys.
- Verify your sender email/domain. Copy the API key to `BREVO_API_KEY`; set sender in `OTP_FROM_EMAIL` to the verified sender.
- API sends transactional email through `https://api.brevo.com/v3/smtp/email`.

## Admin panel
Open `/admin.html`, enter `ADMIN_PASSWORD`. Admin session token is signed with `ADMIN_SESSION_SECRET` and expires in 8 hours. Admin actions include promotion mode, user search/list, VIP/unlimited toggle, reset devices, manual quotas, block/unblock.

## API routes
- `POST /api/otp/request` `{email}` (Gmail only; OTP 6 digits, 5-minute expiry)
- `POST /api/otp/verify` `{email,code}` → verification token (15 minutes)
- `POST /api/login` `{email,verificationToken,deviceFingerprint,deviceLabel}` (existing account login and device limit)
- `POST /api/register` `{verificationToken,email,teacherName,school,nip,whatsapp,teacherType:'PAI'|'NON_PAI',level:'SD'|'LANJUTAN',deviceFingerprint,deviceLabel}`
- `POST /api/access/check` `{userId,kind:'class'|'subject'|'device'}`
- `POST /api/access/consume` `{userId,kind:'class'|'subject',resource}` (server-side quota consumption)
- `POST /api/device/register` `{userId,deviceFingerprint,deviceLabel}`
- `POST /api/admin?action=login` `{password}`; then bearer token for `users`, `promotion`, and `user` actions.

## Important integration note
`index.html` includes the account-registration UI and client access check for the “Tambah Kelas/Mapel” prompt. The server-side `/api/access/consume` endpoint must be called when the actual class/subject resource is created, and not merely when a UI prompt is opened, to avoid quota bypass. For production, wire resource creation to this API and use the signed-in session token from localStorage only as a client cache, and validate it server-side; the API endpoints already validate the bearer session against `user_sessions`. Quota consumption uses a unique quota event for each kind/resource pair to prevent duplicate-counting. During Promotion/VIP events are not counted so returning to Normal applies the regular quota. Browser fingerprint is a practical installation identifier, not hardware-level identity and can be reset/forged. The current client integration stores the user ID and bearer session token in localStorage for compatibility with this existing offline-first scanner. Workspace persistence is blocked until an OTP-verified session exists. Review XSS risk and move tokens to HttpOnly Secure cookies before handling sensitive exports.

## Default quotas
- Non-PAI: 1 class, 2 subjects, 1 active device.
- PAI SD: 6 classes, 0 subjects, 2 devices.
- PAI Lanjutan: 3 classes, 0 subjects, 2 devices.
- Promotion mode or VIP: unlimited.
- Admin WhatsApp target is configured in `kau-access.js` (`window.KAU_ADMIN_WA` fallback). Replace placeholder `628xxxxxxxxxx` with your number.
