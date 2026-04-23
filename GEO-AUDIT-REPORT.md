# GEO Audit Report: Ranná Správa

**Audit Date:** 2026-04-20
**URL:** https://rannasprava.sk
**Business Type:** Publisher (Slovak daily email newsletter + web archive)
**Pages Analyzed:** Homepage ([index.html](index.html)), latest issue ([vydania/82/index.html](vydania/82/index.html)), robots.txt, README.md, archive structure (36 issues under `vydania/`, 31 date pages under `archiv/`), socials prompts, email templates.

---

## Executive Summary

**Overall GEO Score: 34/100 (Critical)**

Ranná Správa has good fundamentals for an AI-friendly publisher: AI crawlers are explicitly allowed in robots.txt, issue pages are server-rendered static HTML (no JS-only content), content is in Slovak with clear daily cadence, and editorial voice is distinctive. However, the site is effectively invisible to AI systems today because of three structural gaps: (1) **zero structured data** on any page (no `Article`, `NewsArticle`, `Organization`, `Person`, `BreadcrumbList`), (2) **no discovery infrastructure** (no `sitemap.xml`, no `llms.txt`, no RSS), and (3) **no meta layer** on any page (no description, no OpenGraph, no Twitter cards, no canonical, no author). The homepage also renders its archive list and stats via client-side JavaScript, hiding the strongest internal-link signal from crawlers that don't execute JS.

The good news: all three gaps are fixable with template edits. Issue pages already contain the substance AI needs — named sections, clear headings, quotable passages, dates. They just lack the machine-readable wrapping.

### Score Breakdown

| Category | Score | Weight | Weighted |
|---|---|---|---|
| AI Citability | 55/100 | 25% | 13.75 |
| Brand Authority | 20/100 | 20% | 4.0 |
| Content E-E-A-T | 30/100 | 20% | 6.0 |
| Technical GEO | 45/100 | 15% | 6.75 |
| Schema & Structured Data | 0/100 | 10% | 0.0 |
| Platform Optimization | 35/100 | 10% | 3.5 |
| **Overall GEO Score** | | | **34.0/100** |

---

## Critical Issues (Fix Immediately)

1. **No structured data anywhere.** Neither [index.html](index.html) nor [vydania/82/index.html](vydania/82/index.html) has any `application/ld+json` block. AI systems use schema as a primary signal for entity recognition, article type, author, and publish date. Fix: add `NewsArticle` / `Article` schema to every issue page and `Organization` + `WebSite` schema to the homepage.

2. **No sitemap.xml.** AI crawlers (ClaudeBot, GPTBot, PerplexityBot) and Google have no index of the 36 published issues. The 82 existing URLs under `/vydania/NN/` are discoverable only by following client-side-rendered links. Fix: generate `sitemap.xml` listing every `/vydania/NN/` page with `<lastmod>`.

3. **No `llms.txt`.** GEO best practice (Anthropic, Perplexity guidance) — missing. Fix: publish `/llms.txt` with site description, editorial policy, and an indexed list of recent issues.

4. **Homepage archive list is JavaScript-rendered.** [index.html:434-442](index.html) builds the hero archive from a `const ISSUES = [...]` array at runtime. Non-JS crawlers (many AI training crawlers, some indexers) see an empty archive. Fix: server-render (or pre-render at build time) the list of the latest 20 issues into static HTML in addition to the JS version.

---

## High Priority Issues

5. **Homepage title is "Ranná Správa" — no keyword context.** [index.html:6](index.html). Fix: `"Ranná Správa — Slovenský denný newsletter | Slovensko a svet za 5 minút"`.

6. **No meta description on any page.** Grep confirms zero `<meta name="description">` across [index.html](index.html) and [vydania/82/index.html](vydania/82/index.html). Fix: add unique description per page; for issues derive from the cold-open paragraph.

7. **No OpenGraph / Twitter cards.** Social previews (LinkedIn, Facebook, X) render blank. Socials workflow exists in [socials/](socials/) but previews will be bare. Fix: add `og:title`, `og:description`, `og:image`, `og:type=article`, `article:published_time`, `twitter:card=summary_large_image`.

8. **No canonical URLs.** Brevo email versions (e.g. `82-brevo.html`) and web versions (`/vydania/82/`) have overlapping content. Without `<link rel="canonical">`, duplicate-content risk exists if Brevo HTML is ever publicly linked.

9. **No author attribution / E-E-A-T signals.** Issues have no byline, no author page, no "About" content about the editorial team. [README.md:217](README.md) says "Tím Ranná Správa" but this is not exposed on the site. AI models cite sources with identifiable authors far more often. Fix: add an `/o-nas/` (About) page + `Person` schema with a named editor.

10. **No RSS / Atom feed.** Publishers without feeds lose the easiest machine-readable subscription surface. Fix: generate `/feed.xml`.

## Medium Priority Issues

11. **Homepage H1 is decorative, not descriptive.** Hero uses a headline-style H1 but no semantic summary of *what the site is*. AI extractors struggle to answer "what is Ranná Správa?" from the homepage alone.

12. **No `BreadcrumbList` schema.** Archive → issue navigation not exposed to crawlers.

13. **Internal linking from issue pages is thin.** [vydania/82/index.html](vydania/82/index.html) links to the share page and home but not to related issues or topic clusters.

14. ~~**No topic clusters / tag pages.**~~ ✅ **FIXED 2026-04-22** — `generate-topic-pages.ps1` generates 6 static pages: `/temy/slovensko/` (31), `/temy/biznis/` (22), `/temy/tech/` (2), `/temy/svet/` (17), `/temy/sport/` (3), `/temy/zdravie/` (4). Each has CollectionPage + BreadcrumbList JSON-LD, canonical, hreflang, OG. Script runs on every new issue publish.

15. **`archiv/` date pages are nearly empty.** [archiv/01/04/](archiv/01/04/) exists but most day folders are empty. Either fill or remove from any future sitemap — empty URLs hurt perceived site quality.

16. **Robots.txt does not reference the (still-missing) sitemap.** Standard `Sitemap:` directive missing from [robots.txt](robots.txt).

17. **No brand presence on Wikipedia, Reddit, or LinkedIn.** AI models weight third-party mentions heavily. Founding an LinkedIn company page + securing a few Reddit/HN mentions would move the needle.

18. ~~**No `hreflang`.**~~ ✅ **FIXED 2026-04-22** — Added `<link rel="alternate" hreflang="sk">` to `index.html`, `vydania/82/index.html`, and all topic pages (via `generate-topic-pages.ps1` template). Added to mandatory head template in `design-and-structure-spec.md`.

## Low Priority Issues

19. ~~**Google Fonts loaded without `font-display: swap` preloading.**~~ ✅ **N/A — already handled.** All Google Fonts URLs include `&display=swap` parameter which instructs Google's CSS to emit `font-display: swap` for each @font-face. `<link rel="preconnect">` to both `fonts.googleapis.com` and `fonts.gstatic.com` already present on all pages.
20. ~~**No `favicon.ico` or `apple-touch-icon`.**~~ ✅ **FIXED 2026-04-22 / EXTENDED 2026-04-23** — Full favicon set now in place. Root files: `favicon.svg`, `favicon.ico` (32×32, multi-size), `favicon-192.png`, `favicon-512.png`, `apple-touch-icon.png` (180×180). PNG/ICO generated via System.Drawing PowerShell script (background #1A1208, gold "R" #C8962A, Georgia Bold). Link block updated across all 9 HTML files (`index.html`, `o-nas/index.html`, `vydania/82/index.html`, 6× `temy/*/index.html`) and in `design-and-structure-spec.md` head template. Rationale: Google SERP was falling back to globe icon because it prefers raster favicons sized as multiples of 48px and uses `apple-touch-icon` as fallback. Post-fix: request re-index via Search Console. Per-issue pages beyond #82 still need update on next publish.
21. ~~**Images missing `alt` attributes.**~~ ✅ **N/A** — Issue pages (`vydania/[N]/index.html`) contain no `<img>` tags. Newsletter content is text-only. No action needed.
22. ~~**No `Article.dateModified`.**~~ ✅ **FIXED 2026-04-22** — `"dateModified"` added to `vydania/82/index.html` NewsArticle JSON-LD (set equal to `datePublished`). Added to mandatory head template in `design-and-structure-spec.md`. Set to publish date on creation; update manually on edits.
23. ~~**No explicit `copyright` / license footer.**~~ ✅ **FIXED 2026-04-22** — Copyright updated from `© 2025` to `© 2024–2026` in `index.html` and `o-nas/index.html`. Year range reflects launch date (March 2024) through current year.

---

## Category Deep Dives

### AI Citability (55/100)
Issue content is well-structured: short, quotable paragraphs, labeled sections ("Slovensko", "Biznis & Financie"), WIM ("Why it matters") boxes at [vydania/82/index.html:59-61](vydania/82/index.html). This is exactly the shape AI loves. Ceiling is held down by missing schema + lack of Q&A-style subheads. Adding `<h2>` questions ("Čo sa deje na Slovensku dnes?") with concise answers would push citability past 80.

### Brand Authority (20/100)
Domain is `rannasprava.sk`, CNAME confirmed. No sameAs pointers, no LinkedIn/Wikipedia/Reddit signals. AI models will not recognize "Ranná Správa" as a distinct entity without external mentions + an `Organization.sameAs` schema block.

### Content E-E-A-T (30/100)
Content is original, published daily (strong freshness signal — CHANGELOG shows issues 79–82 published within 4 days), editorial voice is consistent. Weakness: zero author signal, no About page, no editorial standards page, no contact page surfaced. For a news publisher, this is the single biggest credibility gap.

### Technical GEO (45/100)
Wins: `lang="sk"`, mobile-viewport meta, static HTML for issues, explicit AI-crawler allowlist in [robots.txt](robots.txt). Losses: no sitemap, no llms.txt, no canonical, JS-rendered homepage archive, no RSS.

### Schema & Structured Data (0/100)
Nothing. Baseline.

### Platform Optimization (35/100)
`socials/` has prompts for Facebook, LinkedIn, Twitter ([socials/linkedin-post-prompt.md](socials/linkedin-post-prompt.md)), and a podcast pipeline exists ([podcastrecs/](podcastrecs/), [generate-issue-audio.py](generate-issue-audio.py)). Distribution infrastructure is in place but has no GEO hooks (no podcast RSS, no OG images, no YouTube presence).

---

## Quick Wins (This Week)

1. Add `<meta name="description">` + OpenGraph tags to [index.html](index.html) and to the issue template used for [vydania/82/index.html](vydania/82/index.html).
2. Generate `sitemap.xml` listing homepage + every `/vydania/NN/` URL; reference it from [robots.txt](robots.txt).
3. Publish `/llms.txt` describing site purpose, Slovak language, daily cadence, and linking to latest 10 issues.
4. Add `NewsArticle` JSON-LD to the issue template (headline, datePublished, inLanguage=sk, publisher, author).
5. Add `Organization` + `WebSite` JSON-LD to homepage (including `sameAs` once social profiles exist, plus `SearchAction`).

---

## 30-Day Action Plan

### Week 1: Meta + discovery foundation ✅ COMPLETE
- [x] Add `<title>`, `<meta name="description">`, `<link rel="canonical">` to homepage and issue template — **DONE 2026-04-20**
- [x] Add OpenGraph + Twitter card tags (with per-issue `og:image`) — **DONE 2026-04-20**
- [x] Generate `sitemap.xml` via `generate-sitemap.ps1` — **DONE 2026-04-20**
- [x] Add `Sitemap: https://rannasprava.sk/sitemap.xml` to `robots.txt` — **DONE 2026-04-20**
- [x] Create `/llms.txt` and `/llms-full.txt` via `generate-llms.ps1` — **DONE 2026-04-20**

### Week 2: Structured data + RSS ✅ COMPLETE
- [x] `NewsArticle` JSON-LD on every `/vydania/NN/` page — **DONE 2026-04-20** (mandatory template in `design-and-structure-spec.md`); **FULLY BACKFILLED 2026-04-23** via `generate-issue-schema.ps1` — all 34 issues (#48–#81) received full schema block (NewsArticle + Organization + Person + WebSite + BreadcrumbList @graph) plus canonical, hreflang, meta description, OG meta, og:image (Cloudflare Worker URL), Twitter cards.
- [x] `Organization` + `WebSite` + `SearchAction` JSON-LD on homepage — **DONE 2026-04-20**
- [x] `BreadcrumbList` JSON-LD on issue pages and topic pages — **DONE 2026-04-20/22**
- [x] Generate `/feed.xml` (RSS 2.0) via `generate-feed.ps1` — **DONE 2026-04-20**
- [x] Pre-render homepage hero archive list into static HTML via `generate-static-archive.ps1` — **DONE 2026-04-20**

### Week 3: E-E-A-T + entity building ✅ MOSTLY COMPLETE
- [x] Create `/o-nas/` (About) page — **DONE 2026-04-20** (Adam Hodoši bio, editorial mission, 5 principles)
- [x] Add `Person` schema for Adam Hodoši; linked from issue #82 as `author` — **DONE 2026-04-20**
- [x] Add explicit byline to issue template — **DONE 2026-04-20** (in `design-and-structure-spec.md`)
- [ ] Create `/redakcna-politika/` (editorial standards) page — **pending**
- [ ] Create LinkedIn company page + Wikipedia draft (entity anchors for `sameAs`) — **off-site, manual**
- [ ] Populate `Organization.sameAs` with LinkedIn, X, Facebook, podcast platforms — **pending LinkedIn/Wikipedia above**

### Week 4: Content surface expansion ✅ MOSTLY COMPLETE
- [x] Build tag-index pages: `/temy/slovensko/`, `/temy/biznis/`, `/temy/tech/`, `/temy/svet/`, `/temy/sport/`, `/temy/zdravie/` — **DONE 2026-04-22** via `generate-topic-pages.ps1`
- [x] Add "Súvisiace vydania" (related issues) block — **DONE 2026-04-20** (backfilled to #82; template documented)
- [ ] Add Q&A-style subheads ("Čo sa dnes deje?", "Prečo ti to záleží?") consistently across sections — **pending content work**
- [ ] Publish podcast RSS feed referencing [podcastrecs/](podcastrecs/) audio — **pending**
- [ ] Re-run audit; target GEO score ≥ 70.

### Platform Visibility Audit — DONE 2026-04-23
- [x] Full per-platform AI visibility audit completed — **DONE 2026-04-23** — output: `marketing/ai-visibility-audit.md`
  - Combined GEO score: 31/100 (Weak)
  - Google AI Overviews: 44/100 (Moderate) — FAQ page + schema strong; tables and Q&A headings missing
  - ChatGPT Web Search: 20/100 (Weak) — no Wikipedia, no Wikidata, no Bing WMT
  - Perplexity AI: 26/100 (Weak) — no Reddit, no inline source links; freshness is the one win
  - Google Gemini: 24/100 (Weak) — no YouTube, no GBP; schema is the one win
  - Bing Copilot: 41/100 (Moderate) — meta descriptions good; IndexNow not implemented
- **Next quarter actions (highest leverage):**
  - Register Bing Webmaster Tools + implement IndexNow (1.5h, +15 pts Copilot)
  - Create Wikidata entity (30 min, lifts ChatGPT/Perplexity/Gemini)
  - Submit to Google News Publisher Center (30 min + review, lifts Gemini/AIO)
  - Replace `og:image` SVG with JPG/PNG 1200×630
- Scheduled re-audit: 2026-07-23

---

## Appendix: Pages Analyzed

| URL | Title | Critical Issues |
|---|---|---|
| [index.html](index.html) | "Ranná Správa" | No description, no OG, no schema, JS-rendered archive |
| [vydania/82/index.html](vydania/82/index.html) | "Ranná Správa – Vydanie #82 – 20. apríla 2026" | No description, no OG, no schema, no canonical, no author |
| [robots.txt](robots.txt) | — | AI crawlers allowed (good), no sitemap reference |
| [README.md](README.md) | — | Internal doc, good operational context |

Live-fetched crawl deferred — local source sufficient for structural audit; re-verify against production after deploying Week 1 fixes.
