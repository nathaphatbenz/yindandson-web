# YinD Document System

Web application for creating invoices, receipts, tax invoices, dashboard document management, and monthly receipt reports.

## Requirements

- Node.js 20 or later
- A Supabase project

## Run Locally

1. Configure Supabase Auth users as described in SUPABASE_AUTH_SETUP.md.
2. Open the static pages from the outputs directory through a local web server.
3. Start at outputs/index.html.

The project has no npm dependencies. To build the deployable static files, run:

    npm run build

The output is created in dist.

## Authentication

Login uses Supabase Auth. The login form maps these usernames to internal Auth emails:

- Yodsapong -> yodsapong@yind.local
- ntpbenz -> ntpbenz@yind.local

Create and confirm these users in Supabase before logging in. The Work List page is restricted to ntpbenz.

## Supabase Security

The browser uses a Supabase publishable key. Do not add a Supabase service role key, LINE token, or user passwords to frontend files or .env.example.

Before public deployment, enable Row Level Security on the invoices table and allow access only to authenticated users.

## Deploy to Vercel

Vercel uses:

- Build command: npm run build
- Output directory: dist

The repository includes vercel.json with these settings.

## GitHub

The .gitignore excludes node_modules, environment files, Vercel metadata, build output, local workspace folders, and old copied HTML files.
