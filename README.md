# Pundit Studio — Go-live guide

The backend is ALREADY set up and connected:
- Supabase project "Pundit Studio Training" (database, security rules, 50-seat limit, admin account)
- index.html already contains the project URL and public (anon) key.

## Deploy on Vercel (recommended)
Option A — dashboard (no tools needed)
1. Put index.html and vercel.json in a new GitHub repository (netlify.toml can stay; Vercel ignores it).
2. On https://vercel.com/new, import that repository.
3. Framework Preset: "Other". Build command: leave empty. Output directory: leave empty (root).
4. Click Deploy. You get a public https://your-project.vercel.app link.

Option B — Vercel CLI (fastest)
1. Install Node.js, then run: npm i -g vercel
2. Unzip this package, open a terminal in the folder, run: vercel
3. Answer the prompts (framework: Other, no build). Run "vercel --prod" for the production link.

## Deploy on Netlify (alternative)
Drag the folder (index.html + netlify.toml) onto https://app.netlify.com/drop

## Pages
/ public site and registration · /portal student portal · /quizzes quizzes and leaderboards · /admin admin sign-in
(quiz and assignment links look like /#/quiz/ID and work on any host)

## First-time admin steps
1. Sign in at /admin (username = admin email).
2. Registrations → approve students after payment.
3. Certificate tab → upload template + signature, place name, tick "Release certificates", Save.
4. Flier tab → upload flier, place the photo area, Save.
5. Quizzes / Assignments → create and share the links.

## Security notes
- Change the admin password after first login (Supabase → Authentication → Users).
- Only the anon key is in index.html. Never add the service_role key.
- Only the admin email has full data access; the public can only register, submit, and read quizzes/leaderboards.
- Custom domain: add it in Vercel → Project → Settings → Domains.
