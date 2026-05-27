#!/bin/sh
# Vercel build script - injects Supabase env vars into env.js
# Vercel sets SUPABASE_URL and SUPABASE_ANON_KEY from its dashboard settings.

set -e

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "Warning: SUPABASE_URL or SUPABASE_ANON_KEY not set. Leaderboard will be disabled."
fi

# Replace placeholders in env.js with actual values (or empty strings)
sed -i.bak "s|__SUPABASE_URL__|${SUPABASE_URL:-}|g" env.js
sed -i.bak "s|__SUPABASE_ANON_KEY__|${SUPABASE_ANON_KEY:-}|g" env.js
rm -f env.js.bak

echo "Build complete. env.js configured."
