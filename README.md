# Pundit Studio — Deployment Guide

Files
- index.html  → the whole website (public site, student portal, quizzes, admin)
- netlify.toml → makes /admin, /portal, /quizzes work as real paths
- schema.sql  → database tables, security rules, 50-seat limit

## 1. Create the database (Supabase, free)
1. Create a project at supabase.com.
2. SQL Editor → paste all of schema.sql → Run.
3. Authentication → Users → Add user. Use your admin email + a strong password.
   This email/password is the admin login at /admin (username = that email).
4. Project Settings → API → copy the Project URL and the anon public key.

## 2. Connect the site
Open index.html and find this line near the top:
  window.PUNDIT_CONFIG={supabaseUrl:"",supabaseKey:""};
Paste your URL and anon key between the quotes. Save.

## 3. Deploy (Netlify)
- Drag the folder with index.html and netlify.toml onto app.netlify.com/drop, or
- Connect a Git repo containing these files.

## 4. Use it
- Public site:  yoursite.netlify.app
- Student portal: /portal   Quizzes: /quizzes   Admin: /admin
- Admin: approve students, upload certificate and flier, create quizzes and assignments.

## Notes
- Do not put the Supabase service_role key in index.html. Only the anon key.
- If PUNDIT_CONFIG is left empty the site runs in demo mode (data stays in each browser).
- Changing the Supabase admin password: Authentication → Users.
