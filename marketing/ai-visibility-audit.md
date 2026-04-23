# GEO Platform Optimization Report — rannasprava.sk
Date: 2026-04-23
Audited by: geo-platform-optimizer skill (Claude)

---

## Overall Platform Readiness

- **Combined GEO Score: 31/100** — Weak
- Site age: ~13 months (launched March 2025)
- Content: Slovak daily newsletter, 38+ published issues, static GitHub Pages
- Schema implemented: NewsArticle, Organization, WebSite, FAQPage, WebPage, BreadcrumbList
- Bot access: GPTBot, ClaudeBot, PerplexityBot explicitly allowed in robots.txt

---

## Platform Scores

| Platform | Score | Status |
|---|---|---|
| Google AI Overviews | 44/100 | Moderate |
| ChatGPT Web Search | 20/100 | Weak |
| Perplexity AI | 26/100 | Weak |
| Google Gemini | 24/100 | Weak |
| Bing Copilot | 41/100 | Moderate |

Status thresholds: Strong = 70+, Moderate = 40–69, Weak = 0–39

---

## Platform Details

### 1. Google AI Overviews — 44/100 (Moderate)

| Criterion | Score | Notes |
|---|---|---|
| Ranks top 10 for target queries | 5/20 | New site (~13 mo). Probably top 10 for brand name only; not yet for "denný newsletter Slovensko" etc. |
| Question-based headings | 4/10 | `/co-je-ranna-sprava/` has 6 FAQ H3 headings. Issue pages use topic headings, not Q&A format. |
| Direct answers after headings | 6/15 | FAQ page answers are direct and concise. Issue pages are narrative, not Q&A. |
| Tables for comparison data | 0/10 | No tables anywhere on the site. |
| Lists for processes/features | 5/10 | News bullet lists in issues; "Čo nájdeš" and "Pre koho" lists on `/co-je-ranna-sprava/`. |
| FAQ section (5+ questions) | 10/10 | 6 FAQs with FAQPage schema on `/co-je-ranna-sprava/`. |
| Statistics with citations | 2/10 | Occasional statistics in news stories but not formatted as "According to [source], [stat]." |
| Publication date visible | 5/5 | All issue pages display date prominently in mastheads + JSON-LD datePublished. |
| Author byline with credentials | 3/5 | Brand byline "Ranná Správa" present; no individual author page with credentials. |
| Clean URL + heading hierarchy | 4/5 | Clean URLs. H1 titles present on all pages; H2/H3 hierarchy in issue content is informal. |

**Key gaps:**
- Not yet ranking top 10 for Slovak newsletter-related queries — content authority needed
- No comparison tables (market data, issue format comparison would help)
- Issue pages don't use Q&A headings; AI can't easily extract answers from news content
- No inline sourced statistics (news story statistics not formatted for AIO extraction)

**Quick fix:** Add a "Prečo čítať Rannú Správu?" section to homepage with structured Q&A headings and direct 1-sentence answers.

---

### 2. ChatGPT Web Search — 20/100 (Weak)

| Criterion | Score | Notes |
|---|---|---|
| Wikipedia article | 0/20 | No Wikipedia article for Ranná Správa. |
| Wikidata entity | 0/10 | No Wikidata item exists. |
| Bing index coverage | 5/10 | Not verified; site is `Allow: *` so Bing can crawl. |
| Reddit mentions | 0/10 | No confirmed Reddit presence or mentions. |
| YouTube channel | 0/10 | No YouTube channel. |
| Authoritative backlinks | 3/15 | Unknown; likely some Slovak news aggregator links but no .edu/.gov/major press. |
| Entity consistency | 5/10 | Brand name, URL, description consistent within site; no external entity anchors yet. |
| Content comprehensiveness | 7/10 | Issue pages are 1500–2500 words of curated news. `/co-je-ranna-sprava/` is thorough. |
| Bing Webmaster Tools | 0/5 | Not confirmed registered. |

**Key gaps:**
- Wikipedia is the #1 gap — ChatGPT cites Wikipedia in 47.9% of answers. No article = near-zero direct citation probability.
- Wikidata entity missing — foundational for entity recognition across AI systems
- Bing is ChatGPT's search index; no confirmed WMT setup = potential crawl gaps
- No YouTube, Reddit, or forum presence

**Quick fix:** Create a Wikidata item (30 min). Submit to Bing Webmaster Tools (15 min). Both are free and high-leverage for ChatGPT.

---

### 3. Perplexity AI — 26/100 (Weak)

| Criterion | Score | Notes |
|---|---|---|
| Active Reddit presence | 0/20 | No confirmed Reddit presence. |
| Forum/community mentions | 0/10 | No HN, Quora, or Slovak forum mentions confirmed. |
| Content freshness | 10/10 | Daily publishing with clear dates. llms.txt lists last 10 issues with dates. |
| Original research/data | 5/15 | Curated analysis and editorial framing; no original surveys or datasets. |
| YouTube content | 0/10 | No channel. |
| Quotable paragraphs | 6/10 | Issue intros (cold opens) and news briefs are well-structured standalone paragraphs. |
| Multi-source claim validation | 3/10 | Sources tracked in `sources.md` per issue but not inline-linked in HTML content. |
| Discussion-generating content | 2/10 | Buffer social posts scheduled; engagement level unknown. |
| Wikipedia/Wikidata | 0/5 | None. |

**Key gaps:**
- Reddit is Perplexity's #1 citation source (46.7%). Zero presence = major ceiling.
- Sources inline in HTML would let Perplexity cross-reference claims automatically
- Content is fresh (daily) — this is the biggest existing advantage

**Quick fix:** Inline-link at least 1 source URL per story in issue HTML (already tracked in sources.md, just need to surface it).

---

### 4. Google Gemini — 24/100 (Weak)

| Criterion | Score | Notes |
|---|---|---|
| Google Knowledge Panel | 0/15 | None; site too new and no GBP. |
| Google Business Profile | 0/10 | Not applicable (online newsletter, no physical location). N/A in practice. |
| YouTube channel | 0/20 | None. YouTube is Gemini's strongest signal. |
| Schema.org structured data | 13/15 | Comprehensive: NewsArticle + Organization + WebSite + FAQPage + WebPage + BreadcrumbList. |
| Google ecosystem presence | 2/10 | Google Analytics only (G-WQDSFGYPJ0). Not in Google News, Scholar, or News Showcase. |
| Image optimization | 3/10 | `og:image` uses SVG (suboptimal — not previewable in all social/AI contexts). No images in issue content. |
| E-E-A-T signals | 5/10 | `/co-je-ranna-sprava/` about page, footer brand info. No individual author page. |
| Multi-modal content | 0/5 | Text-only. No images, infographics, or video. |

**Key gaps:**
- YouTube absence is the single biggest Gemini gap (20 pts)
- No Google News registration despite NewsArticle schema being in place — this is a quick win
- SVG og:image won't render as preview cards; needs JPG/PNG fallback
- Knowledge Panel will come with time + entity building

**Quick fix:** Submit to Google News Publisher Center (free, ~1 week approval). The NewsArticle schema is already correct. This alone could get individual issues into Gemini's news feed citations.

---

### 5. Bing Copilot — 41/100 (Moderate)

| Criterion | Score | Notes |
|---|---|---|
| Bing WMT + sitemap | 5/15 | `sitemap.xml` directive in robots.txt. WMT registration not confirmed. |
| IndexNow | 0/15 | Not implemented. |
| Bing index coverage | 5/10 | Not verified. |
| LinkedIn company page | 0/10 | None confirmed. |
| GitHub presence | 3/5 | Site hosted on GitHub Pages; repository exists. |
| Meta descriptions | 10/10 | All key pages have optimized Slovak meta descriptions. |
| Social media engagement | 3/10 | Automated Buffer posts on Twitter/LinkedIn/Facebook; engagement data unknown. |
| Exact-match keywords | 7/10 | "slovenský denný newsletter" in title tags and headings across multiple pages. |
| Page load speed | 8/10 | Static site + GitHub Pages CDN. Expected < 2s. |

**Key gaps:**
- IndexNow is a 1-hour implementation that gives Copilot near-instant indexing of new issues — huge win for a daily publisher
- Bing WMT registration needed to verify actual coverage and catch crawl errors
- LinkedIn company page directly improves Copilot citation probability (Microsoft ecosystem)

**Quick fix:** Register Bing WMT + implement IndexNow. For a daily newsletter, IndexNow is unusually high-leverage — new issues get indexed within minutes.

---

## Prioritized Action Plan

### Quick Wins (this week — < 2h each)

| # | Action | Platform Impact | Effort |
|---|---|---|---|
| 1 | Register Bing Webmaster Tools + verify sitemap | ChatGPT, Copilot | 15 min |
| 2 | Implement IndexNow protocol (ping on each issue publish) | Copilot, Bing | 1h |
| 3 | Create Wikidata item for Ranná Správa (entity + sameAs links) | ChatGPT, Perplexity, Gemini | 30 min |
| 4 | Replace `og:image: /og-image.svg` with a JPG/PNG (1200×630) | All platforms | 30 min |
| 5 | Submit to Google News Publisher Center | Gemini, Google AIO | 30 min + review |
| 6 | Inline-link ≥1 source URL per story in issue HTML | Perplexity, AIO | Add to publish workflow |

### Medium-Term (this month — content or technical work)

| # | Action | Platform Impact | Effort |
|---|---|---|---|
| 7 | Add "Prečo Ranná Správa?" Q&A section to homepage | Google AIO | 2h |
| 8 | Create LinkedIn company page (full profile + link to site) | Copilot, ChatGPT | 1h |
| 9 | Create individual author/editor page (`/adam/`) with credentials, sameAs links | AIO, Gemini, ChatGPT | 2h |
| 10 | Add market data tables to select issue pages (weekly recap format) | Google AIO | Per-issue ~20 min |
| 11 | Add "Podľa [zdroja]..." citation formatting in stories (named-source stats) | AIO, Perplexity | Style guide change |

### Strategic (this quarter)

| # | Action | Platform Impact | Effort |
|---|---|---|---|
| 12 | Wikipedia article for Ranná Správa (once notability criteria are met — ~10k subs or media coverage) | ChatGPT, Perplexity, Gemini | Research + draft |
| 13 | Authentic Reddit presence in r/Slovakia and Slovak news subreddits | Perplexity, ChatGPT | Ongoing |
| 14 | YouTube channel — repurpose audio summaries or short video clips | Gemini, ChatGPT, Perplexity | Setup + 1 video/week |
| 15 | Get 2–3 Slovak media mentions (press coverage) | ChatGPT, Perplexity | PR outreach |
| 16 | Quarterly re-audit with this tool to track score progression | All | 1h/quarter |

---

## Score Trajectory Projection

Implementing all Quick Wins + Medium-Term items:

| Platform | Current | After Quick Wins | After Medium-Term |
|---|---|---|---|
| Google AI Overviews | 44 | 50 | 65 |
| ChatGPT Web Search | 20 | 30 | 42 |
| Perplexity AI | 26 | 34 | 48 |
| Google Gemini | 24 | 34 | 46 |
| Bing Copilot | 41 | 66 | 72 |
| **Combined** | **31** | **43** | **55** |

Biggest single-session leverage: Bing WMT + IndexNow + Wikidata + Google News submission. Four items, ~2h total, move combined score from 31 → 43.

---

## Cross-Platform Notes

**What's already working well:**
- Daily publishing cadence (freshness signal)
- Comprehensive structured data (NewsArticle, FAQPage, Organization — rare for Slovak sites)
- llms.txt + llms-full.txt (direct AI crawler index)
- robots.txt explicitly allows all major AI bots
- Clean static HTML (no JS rendering barrier on issue pages)
- Slovak-language title/heading/meta throughout (no language mismatch)

**Structural ceiling:**
- No YouTube, no Reddit, no Wikipedia = locked out of top citation sources for ChatGPT and Perplexity. These platforms reward entity presence and community validation over technical SEO. The structured data advantage doesn't help if the entity doesn't exist outside the site.
- Solution: Entity building (Wikidata → Wikipedia → press) is the 6-month priority alongside IndexNow for Copilot.

---

*Cross-reference: [referral-plan.md](referral-plan.md) | [pricing-strategy.md](pricing-strategy.md) | [marketing-growth-plan.md](marketing-growth-plan.md)*
*Next audit: 2026-07-23 (quarterly)*
