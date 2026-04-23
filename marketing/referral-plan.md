# Ranná Správa — Referral Program Plan

**Status:** Draft · **Owner:** ADAM · **Created:** 2026-04-23
**Goal:** Turn ~4,200 subscribers into growth engine. Target +30% MoM subs via referrals within 90 days of launch.

---

## 1. Program type

**Customer referral (milestone-based), not affiliate.**

Why:
- Free product, no revenue → no commission model.
- B2C Slovak audience, low-ticket, high-trust word-of-mouth.
- Proven model for newsletters: Morning Brew, The Hustle, The Pour Over.
- Reader is the referrer. No influencer tier (yet).

---

## 2. Economics

| Metric | Value |
|---|---|
| Product cost per sub | ~0 (static site, Brevo free tier) |
| CAC target via referral | < €1 per sub (reward cost amortized) |
| Current base | ~4,200 (hardcoded counter — real Brevo list is source of truth) |
| Avg referrals per referrer (target) | 1.5 |
| Share rate target | 10% of active subs refer ≥ 1 friend |

Budget: €300–500 for first 6 months (stickers, print, postage inside SK).

---

## 3. Reward ladder (milestone tiers)

Single-sided (referrer earns). Referred friend gets the newsletter itself — no reward needed, free product.

| Tier | Referrals | Reward | Cost per unit |
|---|---|---|---|
| 1 | **1** | Digital thank-you + name in "Ďakujeme" section of next issue | €0 |
| 2 | **3** | Exclusive PDF: "Ranná Správa Weekly Deep Dive" (1 per month, subs-only) | €0 |
| 3 | **5** | Ranná Správa sticker pack (SK post) | ~€2 |
| 4 | **10** | Enamel mug with logo | ~€8 |
| 5 | **25** | Branded tee + handwritten postcard from Adam | ~€18 |
| 6 | **50** | 30-min 1:1 call with Adam — custom briefing on any topic | €0 (time) |
| 7 | **100** | Permanent "Founding Reader" credit on site + lifetime ad-free guarantee + dinner in Bratislava | ~€50 |

**Rationale:**
- Low tiers (1, 3) = psychological wins, cost nothing, hook the habit.
- Mid tiers (5, 10) = tangible merch, creates IRL brand visibility in SK.
- High tiers (25, 50, 100) = status + access. Scarcity drives super-fans.

---

## 4. Mechanics — how it works

### 4.1 Unique referral link per subscriber

Each Brevo contact gets a unique code stored as custom attribute `REF_CODE` (e.g. `RS-4F9K2`).

Link format:
```
https://rannasprava.sk/?ref=RS-4F9K2
```

Landing behavior:
- `index.html` reads `?ref=` param via JS, stores in `localStorage`.
- Subscribe form POST to `api.rannasprava.sk/subscribe` includes `ref` field.
- Backend writes `REFERRED_BY` attribute on new Brevo contact.

### 4.2 Attribution + counter

Daily/weekly cron (PowerShell or Node on VPS):
1. Query Brevo API for contacts with `REFERRED_BY = X`.
2. Count per referrer, update `REF_COUNT` attribute.
3. Trigger Brevo automation when `REF_COUNT` crosses tier thresholds.

### 4.3 Dashboard per subscriber

New page: `rannasprava.sk/odporucania/?ref=RS-4F9K2`
- Shows: current count, next tier, progress bar, copy-link button, pre-filled share buttons (WhatsApp, Messenger, email, X, LinkedIn).
- Static HTML + JS fetch to lightweight endpoint on `api.rannasprava.sk/ref-status`.

---

## 5. Share mechanism — ranked

1. **In-newsletter footer** — every issue ends with "Odporuč Rannú Správu — získaj [next tier reward]. Tvoj link: [URL]".
2. **Dashboard page** with one-click share buttons.
3. **Post-signup welcome email** — "Tu je tvoj link, pozvi kamaráta."
4. **Milestone trigger emails** — "Gratulujeme! 3 odporúčania = Weekly Deep Dive."

---

## 6. Trigger moments (when to ask)

| Moment | Channel | Copy (SK) |
|---|---|---|
| Right after confirm double opt-in | Welcome email | "Vitaj. Ak ti Ranná Správa pomôže, pošli ju kamarátovi — tu je tvoj link." |
| After 7 issues read | Automation email | "7 rán spolu. Kto by z tvojho okolia ocenil 5-minútový brífing?" |
| After each milestone | Triggered email | "Odomkol si Tier 2. Tu je Weekly Deep Dive." |
| In every issue footer | Every newsletter | "📤 Odporuč RS — tvoj link + progress: [dashboard URL]" |

---

## 7. Launch copy (Slovak)

**Email subject:**
> Odteraz môžeš zarobiť za zdieľanie Rannej Správy

**Body:**
> Spustili sme program odporúčaní.
>
> Pošli Rannú Správu kamarátovi, a za každého nového čitateľa získaš odmenu — od exkluzívnych PDF analýz až po tričko či večeru so mnou v Bratislave.
>
> Tvoj osobný link:
> **rannasprava.sk/?ref=RS-XXXXX**
>
> Stav a odmeny:
> **rannasprava.sk/odporucania**
>
> Ďakujem,
> Adam

---

## 8. Fraud prevention

- Double opt-in required (already enforced via Brevo) → blocks fake emails.
- 1 referral = 1 confirmed subscribe that stays active 7+ days (not instant).
- Cap: max 3 referrals from same IP per 24h.
- Manual review at Tier 5+ before shipping physical reward.

---

## 9. Tech build — scope

Static site, no SSR. Minimal build:

| Task | Where | Effort |
|---|---|---|
| `?ref=` param capture in `index.html` | edit existing file | 1h |
| `ref` field in subscribe POST | `index.html` form + VPS Node handler | 2h |
| Brevo attribute schema: `REF_CODE`, `REFERRED_BY`, `REF_COUNT`, `REF_TIER` | Brevo dashboard | 30m |
| Referral code generator (on confirm) | VPS Node | 1h |
| Cron: recompute `REF_COUNT` daily | VPS | 1h |
| Brevo automations: 7 tier triggers | Brevo dashboard | 2h |
| Dashboard page `odporucania/index.html` | new static file + fetch | 3h |
| `/ref-status` endpoint | VPS Node | 1h |

**Total: ~12h dev.** No new infra. Reuses Caddy + Node + Brevo.

---

## 10. Tools considered

| Tool | Verdict |
|---|---|
| **SparkLoop** | Gold standard for newsletters, but $99+/mo. Overkill for 4200 subs. |
| **Rewardful / Tolt** | Stripe-native, wrong fit (no payments). |
| **Custom Brevo + VPS** | ✅ Chosen. Free, owns data, matches current stack. |
| **KickoffLabs** | Worth re-evaluating at 20k+ subs. |

---

## 11. Metrics — dashboard targets (90 days post-launch)

| Metric | Target |
|---|---|
| Subscribers with ≥1 referral | 10% of active list |
| Total referred signups | 500+ |
| Avg referrals per active referrer | 1.5 |
| Tier 3+ reachers | 25 subs |
| Tier 5+ reachers | 5 subs |
| % new signups from referrals | 30% |

Track weekly in `marketing/referral-metrics.md` (to be created).

---

## 12. Launch checklist

### Pre-launch
- [ ] Brevo custom attributes created (`REF_CODE`, `REFERRED_BY`, `REF_COUNT`, `REF_TIER`)
- [ ] Backfill `REF_CODE` for existing ~4200 subs
- [ ] Backend `/subscribe` accepts `ref` param
- [ ] `/ref-status` endpoint live
- [ ] `odporucania/index.html` built + tested
- [ ] Welcome email rewritten to include referral link
- [ ] 7 milestone Brevo automations configured
- [ ] Newsletter template footer updated with referral CTA
- [ ] Stickers, mugs, tees sourced (SK supplier — ask: printservis.sk, redbubble, local)
- [ ] Fraud caps tested
- [ ] Terms page drafted: `rannasprava.sk/odporucania/podmienky`

### Launch day
- [ ] Broadcast email to full list (section 7 copy)
- [ ] Social posts (LinkedIn, X, FB) via `rannaspravaposts` skill
- [ ] Pin tweet + LinkedIn post about program
- [ ] Update `index.html` hero with small "Pozvi kamaráta" link

### Post-launch (30 days)
- [ ] Review funnel weekly
- [ ] Identify top 10 referrers, send personal thanks
- [ ] Reminder email to non-sharers day 14
- [ ] A/B test reward amount at Tier 1 (shoutout vs. digital badge)

---

## 13. Open questions

1. Shoutout in issue — opt-in checkbox required (GDPR — names in email).
2. Tier 7 dinner — cap at X people total, else unsustainable.
3. Confirm SK postal address capture — needs new Brevo field + privacy note.
4. Does Adam want a "gift a subscription" option on top of referral? (Different flow — skip v1.)

---

## 14. Next actions

1. Adam approves reward ladder + budget.
2. Source Slovak merch supplier — 3 quotes.
3. Scope backend changes with VPS in mind (keep `api.rannasprava.sk` lean).
4. Build v1. Target launch: **2026-06-01**.
