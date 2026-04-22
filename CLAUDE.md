# CLAUDE.md — rannasprava.sk

Context + standing rules for Claude Code sessions in this repo. Read alongside `how-we-do-ranna-sprava.md` (workflow SOT) and `design-and-structure-spec.md` (design SOT).

## Project snapshot

- **Product:** Ranná Správa — Slovak daily newsletter (lang=`sk`), morning format.
- **Site:** https://rannasprava.sk — static, GitHub Pages, custom domain (CNAME), `.nojekyll`, no build step.
- **Owner:** ADAM (git user).
- **Backend:** `api.rannasprava.sk` — Node.js + Caddy on VPS. Only endpoint: `POST /subscribe` → Brevo API. No SSR.
- **Subscriber counter** in `index.html` is hardcoded base 4200 + localStorage, **not** real count.

## Repo layout

- `index.html` — SPA landing (~484 lines). Renders issue list client-side from `issues.js` → `ISSUES` array. Newest issue goes top of array.
- `landing.html` — separate landing variant.
- `vydania/[N]/index.html` — static per-issue HTML, fully crawlable. Issues 48–82 published; anomalies below.
- `vydania/[N]/sources.md`, `[N]-podcast.txt`, `social-posts.md`, `edits.md` — per-issue sidecars.
- `emails/[N]-brevo.html` — Brevo newsletter export per issue.
- `archiv/DD/MM/YYYY/` — static date-aliased issue pages (canonical public archive URLs).
- `issues/`, `share/`, `podcastrecs/`, `socials/` — content + distribution assets.
- `robots.txt` — allows GPTBot, ClaudeBot, PerplexityBot (added 2026-04-14).
- `sitemap.xml`, `llms.txt`, `llms-full.txt` — SEO/GEO infra (added 2026-04-20).

## Automation scripts (PowerShell + Python)

- `update-market-snapshot.ps1` — markets block.
- `update-weather-snapshot.ps1` — weather block.
- `update-podcast-embed.ps1` — podcast embed.
- `prepare-brevo-email.ps1` — Brevo HTML export.
- `check-issue-overlap.ps1` — dupe content guard.
- `generate-archive-date-pages.ps1` — builds `/archiv/DD/MM/YYYY/` aliases.
- `generate-sitemap.ps1` — scans `vydania/`, writes `sitemap.xml` with 36 URLs. Excludes folder `492`. Output has UTF-8 BOM (strict validator gotcha). Only issue #82 has `<lastmod>` because date extraction via JSON-LD only works where structured data exists.
- `generate-llms.ps1` — `llms.txt` generator.
- `generate-static-archive.ps1` — static archive pages.
- `generate-issue-audio.py`, `generate-podcast-txt.py`, `inline-email-css.py` — Python pipeline.

## Publishing workflow

Edit `index.html` (push issue object on top of `ISSUES`) → create `vydania/[N]/` → run market/weather/overlap/Brevo/podcast scripts → commit → push `main` → GitHub Pages deploys.

**Quality checks before push** (from `how-we-do-ranna-sprava.md`):
1. Issue number, date, title, preview correct.
2. Appears in Home, Archive, Reader views.
3. No duplicates or overwrites.
4. Update relevant `.md` files.
5. Push and verify public page source.

## Standing rules (non-negotiable)

- **Every commit updates docs.** `how-we-do-ranna-sprava.md` mandates a doc update on every push. AI must update relevant `.md` before commit/push.
- **SEO/GEO fixes marked in all `.md` files.** Decision 2026-04-20: every SEO/GEO fix annotated in `GEO-AUDIT-REPORT.md` and `how-we-do-ranna-sprava.md`. Why: cross-session tracking so fixes aren't re-audited.
- **Typography frozen** unless user asks. No drift in font family, size, weight, spacing. `design-and-structure-spec.md` is SOT.
- **No topic/category labels** (`Slovensko`, `Biznis`, `Tech`, `Šport`) in archive metadata or as visible kickers. Archive cards show only: issue number, date, title, preview.
- **Archive URLs** use `/archiv/DD/MM/YYYY/`. `/vydania/[N]/` pages exist as underlying files but home + archive listings link the date URL.
- **`robots.txt`** lives at repo root — must never 404.

## SEO/GEO state (as of 2026-04-20)

**Completed:**
- Homepage title tag expanded with keywords (`index.html:6`): "Ranná Správa — Slovenský denný newsletter | Slovensko a svet za 5 minút".
- Homepage JSON-LD: Organization + WebSite `@graph` block injected before `</head>`. Includes SearchAction `urlTemplate`.
- `sitemap.xml` generated (36 URLs).
- `llms.txt`, `llms-full.txt` at root.
- Google Analytics (G-WQDSFGYPJ0) on all pages (commit `e8dd8ef`).
- Static archive pages for AI crawlers.

**Pending / known gaps:**
- NewsArticle/Article JSON-LD on every `vydania/[N]/index.html` — still missing.
- Meta description, OG tags, Twitter Cards, canonical, hreflang — absent on homepage and all issue pages.
- `<lastmod>` missing from 34 of 35 sitemap entries (only #82 has JSON-LD `datePublished`).
- `sitemap.xml` UTF-8 BOM may trip strict validators.
- SPA landing renders via JS — Googlebot needs JS execution to see issue list; issue pages are static so still crawlable directly.
- `robots.txt` has no `Sitemap:` directive.

**Content anomalies:**
- `vydania/492/` = duplicate of issue #49 (title says `#49`).
- `vydania/50/` also contains issue #49 content (folder/issue-number mismatch).
- `vydania/49/` has no date in title tag (all others do).
- `generate-sitemap.ps1` excludes folder `492` via `-ne '492'` filter.

## Scheduled tasks

- **`rannaspravaposts`** — `C:\Users\user\.claude\scheduled-tasks\rannaspravaposts\SKILL.md`. Auto-generates Twitter / LinkedIn / Facebook Slovak posts from latest issue, saves to `vydania/[N]/social-posts.md`, schedules via Buffer MCP (GraphQL API) at Bratislava time +3h. Uses Node.js `fs` read (not shell pipe) to preserve Slovak Unicode. Channel IDs + API key stored in SKILL.md.

## Key `.md` files

- `how-we-do-ranna-sprava.md` — workflow SOT + per-issue publish notes log.
- `design-and-structure-spec.md` — typography + design SOT.
- `GEO-AUDIT-REPORT.md` — SEO/GEO audit tracking, fix annotations go here.
- `server-infrastructure.md` — VPS + Caddy + Brevo backend.
- `README.md`, `CHANGELOG.md`.

## Persistent memory

Auto-memory lives at `C:\Users\user\.claude\projects\C--Users-user-Desktop-rannasprava\memory\` (`MEMORY.md` index + per-topic files). Persists across sessions and across CLI frontends (CMD, terminal) since path is keyed on project dir.
