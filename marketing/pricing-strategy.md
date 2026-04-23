# Ranná Správa — Pricing Strategy

**Status:** Draft · **Owner:** ADAM · **Created:** 2026-04-23
**Current state:** 100% free, ~4,200 subs, no revenue.
**Goal:** Phase in monetization without damaging organic growth. Target €2,000 MRR by month 18.

---

## 1. Strategic frame

Ranná Správa is a **free-at-core newsletter** competing for attention, not dollars. Paid-first would kill growth at this size. Adopt Morning Brew / The Hustle playbook, SK-scaled:

1. **Free stays free** — core morning newsletter never paywalled.
2. **Monetize attention first** (sponsorships) — unlocks revenue at current list size.
3. **Monetize depth second** (paid tier for heavy readers) — only when content surplus exists.
4. **Never tax the casual reader.**

---

## 2. Revenue streams — ranked by fit

| # | Stream | When | Effort | Ceiling at 4.2k subs |
|---|---|---|---|---|
| 1 | **Sponsorships** (in-newsletter ads) | Now | Low | ~€400–800 / mo |
| 2 | **Premium tier** (paid) | Month 6+ | Medium | ~€300–600 / mo |
| 3 | **Classifieds / job board** | Month 9+ | Low | ~€100–300 / mo |
| 4 | **Affiliate partner deals** | Month 3+ | Very low | ~€50–200 / mo |
| 5 | **Founding supporter** (voluntary) | Month 6+ | Very low | ~€100–300 / mo |
| 6 | **Merch** | Ongoing via referral program | Covered | Negligible direct |
| 7 | **B2B bundle** (corporate subs) | Month 18+ | High | ~€500+ / mo |

**Primary pillar:** Sponsorships. Everything else is additive.

---

## 3. Pricing fundamentals applied

### Value metric
- **For sponsors:** opens × engagement — charge per placement (per-send), priced against open count.
- **For readers:** time saved + morning briefing quality — charge flat monthly fee.

### Price anchors (SK market)
| Product | Price | Note |
|---|---|---|
| Denník N digital | ~€9.99 / mo | Full newsroom |
| SME Premium | ~€6.99 / mo | Full newsroom |
| Standard.sk PLUS | ~€4.99 / mo | Mid-tier |
| Netflix SK Basic | ~€5.49 / mo | Mental benchmark for "cheap digital" |
| Spotify SK | ~€6.99 / mo | Habit benchmark |
| **Ranná Správa Premium (target)** | **€4.99 / mo** | Below all news, above nothing |

Rationale: stay under the "real newspaper" price anchor. €4.99 reads as "under 5", Spotify-adjacent. Annual €39 = 35% discount, nice round number.

---

## 4. Phased rollout

### Phase 1 — Sponsorships only (month 0–6)

**Goal:** Prove monetization without disturbing product.

**Product:** Free newsletter, 1 sponsor slot per issue.

**Rate card (v1):**
| Placement | Description | Price / send | Bundle (5 sends) |
|---|---|---|---|
| **Top sponsor** | 1 block under intro, ~50 words + link | €120 | €500 |
| **Mid sponsor** | Between sections, ~40 words | €80 | €340 |
| **Classified** | 1-line text link at bottom | €30 | €120 |

CPM math: 4,200 subs × ~45% open ≈ 1,900 opens. €120 / 1.9 = **~€63 CPM** on top slot. High but justified by SK-native, niche audience. Discount 15% for first 10 sponsors.

**Sales:**
- Simple rate card page: `rannasprava.sk/sponzor`
- Self-serve email: `sponzor@rannasprava.sk`
- Pitch list: SK SaaS, fintech, HR-tech, recruitment, events, book publishers.
- Target: **2 sponsored sends / week by month 3**, **4 / week by month 6**.

**Month 6 projection:** 16 sends / mo × €100 avg = **€1,600 / mo**.

---

### Phase 2 — Premium tier (month 6–12)

**Prerequisite:** Sponsorships stable + list at 6,000+.

**Packaging — Good / Better / Best:**

| Tier | Price | What's included |
|---|---|---|
| **Zdarma** (Free) | €0 | Daily morning newsletter. Forever. |
| **Premium** ⭐ | **€4.99 / mo** or **€39 / rok** | Free + Weekly Deep Dive (Sun), full searchable archive, ad-free version, early access at 06:00 (vs. 07:00) |
| **Mecenáš** (Founding Supporter) | **€99 / rok** | Premium + name listed in site + annual dinner/Q&A + direct reply guarantee from Adam |

**Why these tiers:**
- **Free** stays untouched — defends growth flywheel.
- **Premium** = soft paywall on *extras only*, not core product. €4.99 = impulse-buy tier.
- **Mecenáš** = status + access, captures high-WTP superfans (same psychology as referral Tier 7).

**Conversion target:** 3–5% of active list → Premium.
- At 6,000 subs: 180–300 × €4.99 = **€900–1,500 MRR** from Premium alone.

**Payment stack:**
- Stripe checkout (SK-supported, handles VAT OSS for EU).
- Brevo attribute `PLAN = free | premium | mecenas` syncs via Stripe webhook → VPS.
- Access gate via email magic-link — no login system. Keeps static-site constraint.

---

### Phase 3 — Expansion (month 12–24)

**Add:**
- **Classified / job board** — €50 per listing, 2 slots per week. SK tech job market underserved.
- **B2B bundle** — `Tím` plan: 5+ Premium seats for teams/companies. €3 / seat / mo (bulk discount). Target SK companies wanting employees briefed.
- **Affiliate deals** — hand-picked partner picks in issue footer (books, tools). Revenue share.

**Price review at month 18:**
- If conversion to Premium > 5% and churn < 3% → test **€5.99 / mo** for new signups, grandfather existing.
- If sponsor demand exceeds inventory → raise rate card 20%.

---

## 5. What NOT to do

- ❌ **No paywall on daily issue.** Ever. It's the growth engine.
- ❌ **No freemium feature gates beyond Deep Dive / archive / ad-free.** Adding artificial limits (e.g. "3 articles / mo") destroys trust.
- ❌ **No ads from categories that damage brand:** crypto pump, gambling, predatory loans, political parties.
- ❌ **No dynamic pricing / discount spam.** Annual discount = only standing offer.
- ❌ **No lifetime plan.** Kills recurring revenue math.

---

## 6. Willingness-to-pay research plan

Before Phase 2 launch, run Van Westendorp on active readers:

**Survey (Brevo broadcast, ~500 respondents target):**
1. Pri akej cene by bola Ranná Správa Premium **príliš drahá**?
2. Pri akej cene **lacná natoľko, že by si pochyboval o kvalite**?
3. Pri akej cene by si to **ešte zvážil**, hoci je to drahé?
4. Pri akej cene je to **výhodná kúpa**?

Plot intersections → optimal price corridor. Expected: €3–6. Confirms or adjusts €4.99 anchor.

**Also ask:**
- MaxDiff on 5 premium perks — which matter most? (Weekly Deep Dive / archive / ad-free / early access / Adam reply)

---

## 7. Sponsorship ops checklist

### Pre-launch
- [ ] `rannasprava.sk/sponzor` page live — rate card, audience stats, past sponsors (logos)
- [ ] Media kit PDF: open rate, CTR, demographics (% BA, % 25–45, % exec, etc.)
- [ ] `sponzor@rannasprava.sk` inbox + reply template
- [ ] Sponsor contract template (SK) — 1-page
- [ ] Invoice template (IČO, DPH if applicable)
- [ ] Fair-disclosure policy published (sponsor ≠ editorial)

### First 10 sponsors
- [ ] 15% launch discount
- [ ] Case-study write-up after each send (CTR, clicks)
- [ ] Ask for referral to 2 other potential sponsors

---

## 8. Premium launch checklist

### Pre-launch (month 5)
- [ ] Run Van Westendorp survey
- [ ] Write 4 Weekly Deep Dives in advance (buffer)
- [ ] Build `/premium` landing page
- [ ] Stripe product + prices configured (€4.99 mo, €39 yr, €99 yr Mecenáš)
- [ ] Webhook: Stripe → VPS → Brevo attribute `PLAN`
- [ ] Magic-link gate for archive + Deep Dive
- [ ] Cancel flow (partner with `churn-prevention` skill later)

### Launch
- [ ] Announce via broadcast email — lead with gratitude, soft CTA
- [ ] Pin on homepage
- [ ] Reserve: first 50 annual subscribers get handwritten thank-you postcard

### Post-launch (30 days)
- [ ] Track conversion by traffic source
- [ ] Survey non-converters: "Čo by ťa presvedčilo?"
- [ ] Review churn reasons weekly

---

## 9. Metrics & targets

| Metric | Month 6 | Month 12 | Month 18 |
|---|---|---|---|
| List size | 6,000 | 10,000 | 15,000 |
| Sponsor MRR | €1,600 | €2,500 | €3,500 |
| Premium subs | — | 300 | 600 |
| Premium MRR | — | €1,300 | €2,700 |
| Mecenáš count | — | 20 | 50 |
| Total MRR | €1,600 | €3,800 | €6,200 |
| Free → Premium conversion | — | 3% | 4% |
| Premium monthly churn | — | <5% | <3% |

---

## 10. Interactions with referral program

See [referral-plan.md](referral-plan.md). Alignment points:

- **Tier 7 referral reward** (100 refs) = free lifetime Premium. Zero marginal cost, huge psychological value.
- **Premium subscribers get 2x credit** in referral counts (loyalty compounding).
- **Referred subs** see "čítaj ad-free za €4.99" CTA after day 30 — warm conversion path.

---

## 11. Open questions

1. VAT / DPH — Adam's IČO status, registered for DPH? Affects price displayed (€4.99 incl. vs. excl.).
2. Stripe vs. local SK processor — Stripe easier for subs, some readers prefer SK cards/bank transfer.
3. Annual-only for Mecenáš, or monthly option? Recommend annual-only (signals commitment).
4. Sponsor category exclusivity — offer 30-day exclusivity in a vertical for +20% price?

---

## 12. Next actions

1. Adam approves phased plan + Phase 1 rate card.
2. Build `/sponzor` page + media kit (this week).
3. Outreach list of 30 SK sponsor prospects.
4. Schedule Phase 2 kickoff for **2026-10-01**.
