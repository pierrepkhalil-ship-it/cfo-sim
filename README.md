# CFO-Simulatorn — Deploy till Vercel + Supabase

Detta är en komplett guide för att få spelet live med fungerande leaderboard.
Beräknad tid: **15–20 minuter**.

## Översikt

- **Vercel** hostar HTML-spelet (statisk fil, gratis tier räcker)
- **Supabase** lagrar scoreboarden i en Postgres-databas (gratis tier räcker)
- Spelet skickar resultat direkt från webbläsaren till Supabase via REST
- Vercel injicerar Supabase-nycklarna i `env.js` vid varje build

## Så funkar leaderboarden

Spelet är 4 kvartal × 40 dagar = 160 dagar totalt. Efter varje kvartal (dag 40, 80, 120)
visas en kvartalsrapport och resultatet skickas till leaderboarden. Det sista
kvartalets (eller spelet-över-resultatet) skickas också när spelet slutar.

Det betyder att samma spelare kan ha upp till **4 rader på leaderboarden** per
spel — en per kvartal. Leaderboarden sorterar på enskilt högsta kvartalsresultat.
Så ett strålande Q2 räknas även om Q4 imploderade.

---

## STEG 1 — Sätt upp Supabase (5 minuter)

1. Gå till **https://supabase.com** och logga in (gratis konto)
2. Klicka **"New project"**
   - Name: `cfo-sim`
   - Database password: spara på säker plats (du behöver det inte direkt)
   - Region: välj närmaste (för Sverige: Frankfurt eller Stockholm)
   - Klicka **"Create new project"** och vänta ~2 min på provisionering
3. När projektet är klart, gå till **SQL Editor** i vänstermenyn
4. Klicka **"New query"**, klistra in hela innehållet från `supabase-schema.sql`
5. Klicka **"Run"** — du ska se "Success. No rows returned."
6. Gå till **Project Settings** (kugghjul) → **API**
   - Kopiera **Project URL** (typ `https://abcdefgh.supabase.co`)
   - Kopiera **anon public** key (lång sträng som börjar med `eyJ...`)
   - Spara dessa två — du behöver dem i Steg 3

> Anon-nyckeln är okej att ha publikt — den är begränsad av RLS-policies i schemat.

---

## STEG 2 — Lägg upp koden på GitHub (5 minuter)

1. Skapa nytt repo på **https://github.com/new**
   - Namn: `cfo-sim` (eller vad du vill)
   - Privat eller publikt — båda funkar
   - **Initiera inte** med README (du har redan filer)
2. Öppna terminal i mappen `cfo-sim-deploy`:
   ```bash
   cd cfo-sim-deploy
   git init
   git add .
   git commit -m "Initial CFO simulator"
   git branch -M main
   git remote add origin https://github.com/DITT-NAMN/cfo-sim.git
   git push -u origin main
   ```

> Om du inte använt git förut: installera GitHub Desktop istället
> (https://desktop.github.com) — dra in mappen och tryck Publish.

---

## STEG 3 — Deploya till Vercel (5 minuter)

1. Gå till **https://vercel.com** och logga in med ditt GitHub-konto
2. Klicka **"Add New..."** → **"Project"**
3. Välj ditt `cfo-sim`-repo och klicka **"Import"**
4. På konfigurationsskärmen:
   - **Framework Preset:** Other (eller lämna som auto-detected)
   - **Build Command:** lämna som det är (`sh build.sh` läses från vercel.json)
   - **Output Directory:** `.` (samma)
5. Klicka **"Environment Variables"** och lägg till två stycken:
   - `SUPABASE_URL` = din Project URL från Steg 1
   - `SUPABASE_ANON_KEY` = din anon-nyckel från Steg 1
6. Klicka **"Deploy"**
7. Efter ~30 sekunder är spelet live på en URL typ `cfo-sim-xyz.vercel.app`

---

## STEG 4 — Testa

1. Öppna din Vercel-URL
2. Skriv ett namn, välj avatar, spela
3. När du dör eller når dag 40, ska du se "✓ Resultat skickat till leaderboard"
4. Klicka **Leaderboard** — du ska se din rad

> Om det säger "Kunde inte skicka resultat":
> - Kontrollera att env-vars är satta i Vercel (Settings → Environment Variables)
> - Trigga om en deploy (Deployments → ... → Redeploy)
> - Öppna webbläsarens DevTools (F12) → Console för felmeddelanden

---

## Eget domännamn (valfritt)

Om du vill ha `cfo.dittnamn.se` istället för `*.vercel.app`:

1. Köp domän hos t.ex. Loopia, One.com eller Cloudflare
2. I Vercel: Project → Settings → Domains → Add
3. Lägg in din domän
4. Följ instruktionerna för att peka DNS (CNAME-post till `cname.vercel-dns.com`)
5. Vercel utfärdar SSL-certifikat automatiskt

---

## Underhåll

**Lägga till fler memos / ändra spelet:**
1. Redigera `index.html` lokalt
2. `git add . && git commit -m "Update" && git push`
3. Vercel deployar om automatiskt på 30 sekunder

**Rensa leaderboarden:**
- Supabase Dashboard → Table Editor → scores → markera rader → Delete
- Eller via SQL Editor: `delete from scores;`

**Modera resultat:**
- Supabase Dashboard → Table Editor → scores
- Du kan ändra namn (om någon spammar) eller ta bort enskilda rader

---

## Säkerhet & kostnad

- **Kostnad:** Båda tjänsterna har gratis tier som räcker långt
  - Vercel: 100 GB bandwidth/mån (du landar nog under 1 GB)
  - Supabase: 500 MB DB, 50 000 månadsanvändare (du landar nog under 100)
- **Säkerhet:** Anon-nyckeln är okej att exponera — RLS-policies i schemat
  förhindrar att någon raderar eller ändrar andras resultat. Värsta möjliga
  scenario: någon spammar in falska resultat. Modera via Supabase-dashboarden.
- **GDPR:** Du sparar bara förnamn (eller vad användaren skriver in) — ingen
  e-post, ingen IP. Lågt riskprofil men bra att nämna i din egen disclaimer
  om du delar URL:en bredare.
