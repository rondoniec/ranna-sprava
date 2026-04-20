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

14. **No topic clusters / tag pages.** README mentions tags (`slovensko, biznis, tech, svet, sport, zdravie`) but no tag-index pages exist. Missing `/temy/slovensko/` etc. loses long-tail GEO surface.

15. **`archiv/` date pages are nearly empty.** [archiv/01/04/](archiv/01/04/) exists but most day folders are empty. Either fill or remove from any future sitemap — empty URLs hurt perceived site quality.

16. **Robots.txt does not reference the (still-missing) sitemap.** Standard `Sitemap:` directive missing from [robots.txt](robots.txt).

17. **No brand presence on Wikipedia, Reddit, or LinkedIn.** AI models weight third-party mentions heavily. Founding an LinkedIn company page + securing a few Reddit/HN mentions would move the needle.

18. **No `hreflang`.** Only Slovak audience now, but `<link rel="alternate" hreflang="sk" href="...">` helps regional AI ranking.

## Low Priority Issues

19. **Google Fonts loaded without `font-display: swap` preloading.** Minor Core Web Vitals impact.
20. **No `favicon.ico` or `apple-touch-icon` checks surfaced.** Verify presence.
21. **Images likely missing `alt` attributes** (if any are used in issue bodies).
22. **No `Article.dateModified`** — only publish date will matter once schema is added.
23. **No explicit `copyright` / license footer** beyond plain-text "© Ranná Správa".

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

### Week 1: Meta + discovery foundation
- [ ] Add `<title>`, `<meta name="description">`, `<link rel="canonical">` to homepage and issue template
- [ ] Add OpenGraph + Twitter card tags (with per-issue `og:image`)
- [ ] Generate `sitemap.xml` (PowerShell script in repo style — reuse [generate-archive-date-pages.ps1](generate-archive-date-pages.ps1) as template)
- [ ] Add `Sitemap: https://rannasprava.sk/sitemap.xml` to [robots.txt](robots.txt)
- [ ] Create `/llms.txt` and `/llms-full.txt`

### Week 2: Structured data + RSS
- [ ] `NewsArticle` JSON-LD on every `/vydania/NN/` page (auto-generated from issue metadata)
- [ ] `Organization` + `WebSite` + `SearchAction` JSON-LD on homepage
- [ ] `BreadcrumbList` JSON-LD on issue pages (Home → Archív → Vydanie #N)
- [ ] Generate `/feed.xml` (RSS 2.0) listing latest 30 issues
- [ ] Pre-render homepage hero archive list into static HTML (run at publish time, not only client-side)

### Week 3: E-E-A-T + entity building
- [ ] Create `/o-nas/` (About) page — editorial mission, team, contact
- [ ] Add `Person` schema for the named editor; link from every issue as `author`
- [ ] Add explicit byline to issue template
- [ ] Create `/redakcna-politika/` (editorial standards) page
- [ ] Create LinkedIn company page + Wikipedia draft (entity anchors for `sameAs`)
- [ ] Populate `Organization.sameAs` with LinkedIn, X, Facebook, podcast platforms

### Week 4: Content surface expansion
- [ ] Build tag-index pages: `/temy/slovensko/`, `/temy/biznis/`, `/temy/tech/`, `/temy/svet/`, `/temy/sport/`, `/temy/zdravie/` — each with its own schema + intro copy
- [ ] Add "Súvisiace vydania" (related issues) block to issue template (3 links based on shared tags)
- [ ] Add Q&A-style subheads ("Čo sa dnes deje?", "Prečo ti to záleží?") consistently across sections
- [ ] Publish podcast RSS feed referencing [podcastrecs/](podcastrecs/) audio
- [ ] Re-run audit; target GEO score ≥ 70.

---

## Appendix: Pages Analyzed

| URL | Title | Critical Issues |
|---|---|---|
| [index.html](index.html) | "Ranná Správa" | No description, no OG, no schema, JS-rendered archive |
| [vydania/82/index.html](vydania/82/index.html) | "Ranná Správa – Vydanie #82 – 20. apríla 2026" | No description, no OG, no schema, no canonical, no author |
| [robots.txt](robots.txt) | — | AI crawlers allowed (good), no sitemap reference |
| [README.md](README.md) | — | Internal doc, good operational context |

Live-fetched crawl deferred — local source sufficient for structural audit; re-verify against production after deploying Week 1 fixes.
