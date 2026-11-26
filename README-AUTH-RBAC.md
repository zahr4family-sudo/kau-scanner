# Auth, OTP, RBAC and Admin Panel

See `CLOUDFLARE-SETUP.md` for Cloudflare Pages deployment, D1 binding, Brevo configuration, API routes, default quotas, and security caveats.

Files added:
- `schema.sql`: D1 tables and legacy tables retained.
- `functions/api/`: Pages Functions API endpoints.
- `kau-access.js`: registration UI and access-check integration helpers.
- `admin.html`: admin dashboard.

Admin password and all API keys must be configured as Cloudflare Pages Secrets, never committed to GitHub.
