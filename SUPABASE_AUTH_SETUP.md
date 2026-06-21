# Supabase Auth Setup

YinD now signs in with Supabase Auth instead of passwords embedded in the frontend.

1. In Supabase Dashboard, enable the Email provider under Authentication.
2. Create these two confirmed email/password users:
   - yodsapong@yind.local
   - ntpbenz@yind.local
3. Set the intended passwords in Supabase Dashboard. Do not place them in source files or Vercel environment variables exposed to the browser.
4. Keep the existing usernames in the login form:
   - Yodsapong
   - ntpbenz
5. Configure Row Level Security so invoice data is available only to authenticated users before public deployment.

The Work List page is additionally restricted to the ntpbenz@yind.local Auth user.
