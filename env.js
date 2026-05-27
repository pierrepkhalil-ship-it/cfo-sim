// This file is loaded by index.html and exposes Supabase config to the game.
// In Vercel, these placeholders are replaced at build time (see vercel.json + build.sh)
// For local testing, edit the values directly.
window.ENV = {
  SUPABASE_URL: '__SUPABASE_URL__',
  SUPABASE_ANON_KEY: '__SUPABASE_ANON_KEY__'
};
