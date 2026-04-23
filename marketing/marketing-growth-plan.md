# Ranná Správa — Marketing & Growth Plan

**Status:** Draft · **Owner:** ADAM · **Created:** 2026-04-23
**North star:** 4,200 → **15,000 subscribers in 18 months** (3.6×).
**Constraint:** Solo operator. Every channel must justify time spent.

Companion docs:
- [referral-plan.md](referral-plan.md) — viral loop (Tier 1–7 milestone rewards)
- [pricing-strategy.md](pricing-strategy.md) — sponsorships → Premium → B2B

---

## 1. Growth math

| Month | Target subs | Net adds / mo | Required gross signups (assume 5% monthly churn) |
|---|---|---|---|
| 0 | 4,200 | — | — |
| 6 | 7,000 | 467 | ~770 |
| 12 | 11,000 | 667 | ~1,200 |
| 18 | 15,000 | 667 | ~1,500 |

**Channel mix targets (month 18):**
| Channel | % new signups | Notes |
|---|---|---|
| Referral (existing readers) | 35% | See referral-plan.md |
| Organic search (SEO/GEO) | 25% | Topic pages + per-issue indexing |
| Social (LinkedIn primary) | 20% | Adam's personal brand |
| Partnerships (newsletter swaps, podcast) | 12% | Cheap + high-trust |
| Paid (Meta SK) | 5% | Spike during launches only |
| PR / earned | 3% | Bonus, not planned |

---

## 2. Positioning (foundation for everything below)

**Tagline:** *Slovensko a svet za 5 minút. Bez clickbaitu.*

**Wedge:** Slovak readers waste 30+ min/morning across SME, Denník N, Standard, Aktuality. Ranná Správa is **the daily summary that respects your time**.

**Differentiators to repeat in every channel:**
1. 5-minute morning read.
2. Slovak-first, world-second.
3. No clickbait, no opinion drift.
4. Free, no paywall on daily.

---

## 3. Channel playbook

### 3.1 Organic — SEO/GEO (largest leverage)

**Status:** Foundation laid (sitemap, llms.txt, JSON-LD homepage, GA, topic pages, favicon set 2026-04-23). Per-issue NewsArticle schema and meta/OG still pending — see GEO-AUDIT-REPORT.md.

**Plays:**
| # | Tactic | Action | Effort | Win window |
|---|---|---|---|---|
| 1 | **Per-issue NewsArticle schema** | Add to all `vydania/[N]/index.html` template + backfill | 4h + run | 4–8 weeks |
| 2 | **Meta description + OG on every issue** | Auto-generate from `preview` field | 2h | 4 weeks |
| 3 | **Topic landing pages** (`/temy/*`) | Already exist — populate with longer evergreen intros + 10 latest issue cards per topic | 6h | 8–12 weeks |
| 4 | **Programmatic pages: "Ranná Správa — DD. mesiac YYYY"** | One indexable page per archive day with that day's summary | Already done via `/archiv/DD/MM/YYYY/` — improve content (currently redirect-only) | 12 weeks |
| 5 | **Llms.txt + AI-citation hygiene** | Already in flight — keep updating per issue | Ongoing | Continuous |
| 6 | **"Newsletter Slovensko" / "denný newsletter" keyword targeting** | Dedicated `/co-je-ranna-sprava` SEO page + interlink from homepage | 4h | 12 weeks |
| 7 | **AI Overviews + ChatGPT citations** | Use `geo-platform-optimizer` skill quarterly to audit | 2h / quarter | Ongoing |

**KPI:** 25% of new signups attributed to organic by month 12 (UTM `utm_source=organic`).

---

### 3.2 Social — LinkedIn first, X + FB secondary

**LinkedIn SK is the unlock.** Small, professional, news-hungry. Adam's personal account is the asset, not the brand page.

**Adam's personal LinkedIn play (4 posts/week, 30 min/day):**
| Post type | Frequency | Hook |
|---|---|---|
| Today's RS issue teaser (3 bullets + link) | Daily (mon–fri) | "Dnes v Rannej Správe →" |
| Behind-the-scenes (build, mistakes, choices) | 1× / week | "Ako vyberám hlavnú tému dňa…" |
| Slovak news commentary (no agenda) | 1× / week | "Toto sa udialo včera. Tu je kontext." |
| Reader spotlight / testimonial | 1× / 2 weeks | "Jeden z čitateľov mi napísal…" |

**X/Twitter (auto via `rannaspravaposts` skill):**
- Already automated. Optimize: thread-form for top story (3–5 tweets, last = subscribe link).
- Pin tweet = "what is RS + subscribe link", refresh monthly.

**Facebook (auto):**
- Continue daily auto-post. SK FB still active for 35+ demographic.
- Build FB page community → 2k followers in 12 months.

**TikTok / Instagram Reels:** SKIP for now. ROI unclear, 60-min/day cost. Revisit at 10k subs.

**KPI:** LinkedIn → 500 subs in 12 months. Adam personal account → 5k SK followers.

---

### 3.3 Partnerships — newsletter swaps + podcast tour

**Newsletter swaps (highest ROI, free):**
Pitch list — SK / CZ newsletters with overlapping audience:
| Partner | Audience size (est.) | Type | Pitch |
|---|---|---|---|
| **Štandard.sk Briefing** | ~10k | News | Cross-mention swap, 1 issue each |
| **Refresher Daily** | ~30k | Lifestyle/news | Swap with niche framing |
| **Index.sme.sk** | unknown | Tech | RS-tech section swap |
| **Startitup newsletter** | ~15k | Business/startup | Swap |
| **Robo Chovanculiak / Konzervatívny týždeň** | ~5k | Politics | If neutral framing fits |
| **Pod čiarou (CZ)** | ~20k CZ | News | CZ readers also read SK content |
| **Heuréka týždeň** | ~3k | Tech | Niche but engaged |

**Process:**
1. Personal email from Adam to editor. No template. Reference their last issue.
2. Offer: "Ja spomeniem vás v RS, vy spomeniete RS u seba. Bez peňazí, bez tracking pixelov."
3. Track via UTM (`utm_source=swap_partnername`).
4. Target: **2 swaps/month from month 3**.

**Expected:** 50–150 signups per swap with similar-sized partner.

**Podcast tour:**
SK podcasts to pitch as guest (Adam talks newsletter ops, news literacy):
- **Pravidelná dávka** (Janičina) — biggest SK podcast
- **Vlado Schmidt — Cez prah**
- **SHARE podcast**
- **Stratený v dátach**
- **Ráno nahlas** (RTVS)
- **Newsfilter** (Tomáš Bella)

Pitch: "Solo operator publishing daily for 18 months. Lessons on news literacy, attention, AI in journalism."

**Target:** 1 podcast/month from month 4. Each = 100–300 signups + authority.

---

### 3.4 Content marketing (repurpose, don't create more)

Adam already produces ~21 articles/week (1 per issue). Don't create more — **repurpose** what exists.

**Plays:**
1. **Weekly Deep Dive** (becomes Premium tier per pricing-strategy.md) — also a free SEO magnet (snippet → paywall).
2. **"Top 10 stories of the month"** retrospective — auto-generated, shareable, indexable.
3. **Year-end "Slovensko 2026 v 50 príbehoch"** — annual report, big PR moment, Dec 2026.
4. **Glossary pages** — `/slovnik/` programmatic SEO. SK news terms explained. Examples: *eurofondy, PPA, OECD, NATO, ZSSK*. 100 terms × ~150 words. Each is a long-tail SEO page.
5. **"Ako čítam noviny" guide** — Adam's framework for filtering news. Free PDF gated by email = signup magnet.

---

### 3.5 Paid acquisition (surgical, not steady)

**Only spend on launches + milestones**, never as steady drip. Solo operator can't optimize daily.

**Recommended use:**
| Trigger | Budget | Channel | Goal |
|---|---|---|---|
| Premium tier launch (month 6) | €200 | Meta (FB/IG) SK | Drive to /premium landing |
| 10k subs milestone | €150 | Meta + LinkedIn promote | Brand moment |
| Year-end report | €300 | Meta + Google Ads | Content magnet |
| Sponsor shoutout swap | €0 | Sponsor pays for ad in their channel | Free reach |

**Target CPA:** < €1.50 per email signup on Meta SK. Higher = pause.

**Don't spend on:**
- Google Search ads for "newsletter" keywords (RTBs hate news content).
- LinkedIn paid ads (too expensive for B2C newsletter).
- TikTok ads (audience mismatch).

---

### 3.6 PR & earned media

**Goal:** Be the *quoted source* on news literacy and Slovak independent media.

**Plays:**
1. **Pitch Adam as expert** to: Trend, Forbes SK, Týždeň. Angle: "Solo journalist publishing daily without VC."
2. **Annual stunt:** "Najčastejšie slovenské slová v správach 2026" — viral data piece, easy to pitch.
3. **Award submissions:** Novinárska cena (Slovak journalism award), European Press Prize. Free, signals authority.
4. **Reciprocal:** mention SK independent media in RS occasionally — they notice.

**KPI:** 6 mentions in SK mainstream press over 18 months.

---

### 3.7 Community + events

**Light touch — solo operator can't run community at scale.**

**Plays:**
1. **Quarterly subscriber meetup** — Bratislava (Q3 2026 first one). Free, BYO drinks at a café. Builds super-fans → super-referrers.
2. **University talks** — UK FFi, EUBA, STU. Free guest lectures on "media + AI". Direct path to student segment.
3. **Founding Reader dinner** — annual, for Mecenáš tier (see pricing). Cap 20 people.

**Skip:** Discord/Slack community. Newsletter ≠ community product. Too much support cost.

---

### 3.8 Retention & engagement (defend the leaky bucket)

Acquisition is wasted if churn eats it. Today: unknown churn rate — **first action is to measure.**

**Setup:**
1. Track open rate per issue (already in Brevo).
2. Define "active" = opened ≥2 of last 7 issues.
3. Track 30/60/90-day retention cohorts.

**Plays:**
| Tactic | When | Goal |
|---|---|---|
| **Welcome sequence** (3 emails over 7 days) | Immediately | Hook habit, set expectation |
| **30-day check-in** | Day 30 | Survey: "Co by si zmenil?" — feedback + reduce churn |
| **Re-engagement campaign** | Inactive 14 days | "Chýbal si — tu sú top 3 príbehy z minulého týždňa" |
| **Sunset list** | Inactive 90 days | Confirm or unsub — protects deliverability |
| **Birthday email** (if collected) | Annual | Soft, builds affinity |
| **Reader survey** | Quarterly | NPS, content asks |

**Deliverability hygiene** (Brevo):
- DKIM/SPF/DMARC configured (verify with mxtoolbox).
- Warm-up new sender domains slowly.
- Ratio: < 1% bounce, < 0.1% complaint. Above = problem.

**Target metrics by month 18:**
- Open rate > 45% (industry benchmark for news = 35–40%, RS aims higher)
- Click rate > 8%
- Monthly churn < 4%

---

## 4. 18-month roadmap

### Phase 1 — Foundation (months 0–3)
**Theme:** Fix the leaks. Don't pour water in a broken bucket.

- [ ] Per-issue NewsArticle schema deployed
- [ ] Meta description + OG on every issue (auto from `preview`)
- [ ] Welcome sequence built in Brevo (3 emails)
- [ ] Adam LinkedIn personal posting cadence locked (5 posts/week)
- [ ] 5 newsletter-swap pitches sent
- [ ] Open/click/churn baselines established

**Target end of phase:** 4,500 subs.

---

### Phase 2 — Distribution (months 3–9)
**Theme:** Scale what works. Kill what doesn't after 30 days.

- [ ] Referral program live (see referral-plan.md, target launch 2026-06-01)
- [ ] 2 newsletter swaps/month
- [ ] 1 podcast guest spot/month
- [ ] Topic pages (`/temy/*`) populated with evergreen intros
- [ ] Glossary pages launched (50 terms)
- [ ] Sponsorships rate card live (per pricing-strategy.md Phase 1)
- [ ] Quarterly subscriber meetup #1 (Bratislava, Q3)
- [ ] Re-engagement + sunset campaigns running

**Target end of phase:** 8,000 subs.

---

### Phase 3 — Monetize + accelerate (months 9–18)
**Theme:** Revenue funds growth. Growth funds revenue.

- [ ] Premium tier launches (per pricing-strategy.md Phase 2)
- [ ] First paid Meta campaign (Premium launch, €200)
- [ ] Annual report "Slovensko 2026 v 50 príbehoch" (Dec 2026)
- [ ] University talks (3 in academic year)
- [ ] Award submission: Novinárska cena
- [ ] Founding Reader dinner #1
- [ ] B2B Tím bundle outbound (5 SK companies)

**Target end of phase:** 15,000 subs + €6k MRR.

---

## 5. Solo operator capacity model

**Adam's weekly time budget on growth (excluding writing the issue):**

| Activity | Hours/week | Tradeoff if cut |
|---|---|---|
| LinkedIn posting + engagement | 3.5h | Lose biggest social channel |
| Newsletter swap outreach + execution | 1.5h | Lose 50–150 signups/swap |
| Sponsor outreach + ops | 2h | Lose Phase 1 revenue |
| Podcast pitch + appearances | 1h | Lose authority signal |
| SEO/content infra | 1h | Slow organic growth |
| Reader emails / community | 1h | Hurts retention + word-of-mouth |
| **Total** | **10h / week** | |

**Anything beyond 10h** = need a contractor (e.g. Slovak VA for swap outreach, freelance designer for sponsor decks). Plan for first hire at month 9 funded by sponsorship revenue.

---

## 6. Tracking — single dashboard

Maintain `marketing/marketing-metrics.md` (to be created), updated weekly:

```
Week of: 2026-MM-DD
─────────────────────────
List size:           X (Δ +Y)
Signups this week:   Z
  - Referral:        a (a%)
  - Organic:         b (b%)
  - Social:          c (c%)
  - Swaps:           d (d%)
  - Other:           e (e%)
Unsubs this week:    U
Open rate (avg):     %
Click rate (avg):    %
Active rate:         %  (opened ≥2 of last 7)
─────────────────────────
Top swap of week:    [partner]  → N signups
Top LinkedIn post:   [link]      → N signups
```

UTM convention:
- `utm_source` = channel (referral / organic / linkedin / swap_partnername / podcast_name / meta_ads)
- `utm_medium` = post / email / podcast / ad
- `utm_campaign` = month-YYYY-MM

---

## 7. What we will NOT do

- ❌ Daily TikTok / IG Reels — wrong demo for solo operator capacity.
- ❌ Cold email scraping SK companies — brand damage > short-term gain.
- ❌ Gated content beyond Premium tier — kills word-of-mouth.
- ❌ "10x your news habit" growth-hack messaging — clashes with positioning.
- ❌ Buying email lists (illegal in EU, plus death of deliverability).
- ❌ AI-generated SEO sludge — would torch the brand we're building.
- ❌ Discord community — wrong product format, support cost too high.

---

## 8. Open questions

1. **Domain authority budget** — willing to invest in 1–2 high-quality backlinks via guest posts? (e.g. write for Trend, Startitup blog).
2. **Adam's bandwidth for podcast tour** — recording quality? Mic + acoustic-treated room?
3. **Bratislava-only meetups** vs. Košice/Žilina rotation? Affects which super-fans we can activate.
4. **Year-end report** — solo build vs. partner with a SK design studio?
5. **Multi-language** — CZ readers already onboard organically (CZ/SK mutual intelligibility). Worth a dedicated CZ landing page at month 12?

---

## 9. Next actions (this week)

1. Adam approves channel priorities + Phase 1 checklist.
2. Set up tracking baseline: open / click / churn for last 4 weeks.
3. Lock LinkedIn posting cadence — first scheduled post Monday.
4. Draft 3 newsletter-swap pitch emails.
5. Create `marketing/marketing-metrics.md` with first weekly snapshot.
