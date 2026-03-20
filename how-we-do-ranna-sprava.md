# How We Do Ranna Sprava

## Operating model

- Site is a single-page app in `index.html` in `rondoniec/ranna-sprava`.
- New issues are added as objects in `const ISSUES = [...]`.
- Newest issue goes at the top of the array.
- Publishing flow: edit `index.html` -> commit -> push to `main` -> GitHub Pages updates.

## Content and formatting rules

- Keep the existing site design system unless explicitly requested otherwise.
- Keep typography identical between issues unless the user explicitly asks for a design change. Do not drift font family, font size, font weight, or spacing from the current spec.
- Issue body supports Markdown and selected HTML blocks already wired in reader styles.
- If custom visual elements are needed, add compatible reader styles first, then content.

## Quality checks before push

1. Confirm issue number, date, title, preview, and tags.
2. Confirm issue appears in Home, Archive, and Reader views.
3. Confirm no duplicate or accidental content overwrite.
4. Update the relevant `.md` files so every new workflow, UI rule, and structural change is documented before commit/push.
5. Push and verify the public page source includes the new issue number.

## AI issue workflow

- When an AI is creating or updating an issue, the AI must run the build scripts itself as part of the issue-writing process.
- The AI must never ask the user to run `update-market-snapshot.ps1` or `update-weather-snapshot.ps1`.
- The AI must also run `prepare-brevo-email.ps1` itself when the issue is being prepared for email sending. The user should not be asked to run it.
- The AI should first finish the issue HTML, then run the relevant snapshot scripts, then run the Brevo export script, then verify the inserted values and links in the HTML before presenting the issue as done.
- Markets command the AI must run:
  `powershell -ExecutionPolicy Bypass -File .\update-market-snapshot.ps1 vydania\[cislo]\index.html`
- Weather command the AI must run:
  `powershell -ExecutionPolicy Bypass -File .\update-weather-snapshot.ps1 vydania\[cislo]\index.html`
- Email export command the AI must run:
  `powershell -ExecutionPolicy Bypass -File .\prepare-brevo-email.ps1 -Path 'vydania\[cislo]\index.html'`
- If the weather script prints `[CONSULT]`, the AI should ask the user before the final output, but only for an extreme Slovakia split, not for normal regional variation.
- If the AI fixes a problem or successfully builds a new feature, it must update the relevant Markdown documentation automatically before commit/push.
- If the user asks for "commit and push", the AI must first update the relevant Markdown documentation and include it in the same push.

## Masthead date bar font

- `Anton`, 17px, `font-weight: 400`.
- Google Fonts import required in every issue: `family=Anton`.

## Markets ticker - build snapshot

Market data is written into the issue HTML at build time by `update-market-snapshot.ps1`. Published issue pages do not fetch market data in the browser. `markets.js` is intentionally empty.

**5 tickers shown in every vydanie (pracovne dni):**

| Ticker | Primary source | Fallback 1 | Fallback 2 |
|---|---|---|---|
| Bitcoin | Finnhub `/crypto/candle` (`BINANCE:BTCUSDT`) | Yahoo Finance (`BTC-USD`) | - |
| S&P 500 | Finnhub `/quote` (`SPY`) | Yahoo Finance (`SPY`) | Alpha Vantage |
| EUR/USD | Finnhub `/forex/candle` (`OANDA:EUR_USD`) | Yahoo Finance (`EURUSD=X`) | Alpha Vantage |
| MSCI World | Alpha Vantage `TIME_SERIES_DAILY` (`URTH`) | Yahoo Finance (`URTH`) | - |
| Zlato | Finnhub `/quote` (`GLD`) | Yahoo Finance (`GLD`) | Alpha Vantage |

**How it works:**

- The script reads the issue date from the issue HTML.
- For each ticker it writes the last available close for the day before the issue date.
- If markets are closed on that day, it uses the last available close.
- `market-val` contains the USD price.
- `market-chg` contains percent change versus the previous close.
- The fallback chain starts automatically if the primary source fails.

**Market HTML hooks:**

- Always keep these IDs in the issue HTML:
  `mval-btc`, `mchg-btc`, `mval-spy`, `mchg-spy`, `mval-eurusd`, `mchg-eurusd`, `mval-msci`, `mchg-msci`, `mval-gold`, `mchg-gold`
- Workdays: the block is visible and the AI runs the script while building the issue.
- Weekend or holiday: the entire `.markets` block stays commented out.

## Weather snapshot - build snapshot

Weather data is written into the issue HTML at build time by `update-weather-snapshot.ps1`. Published issue pages do not fetch weather in the browser.

**Important rule:**

- Weather is for the entire Slovakia, not for Bratislava alone.
- The visible label in the issue stays `Slovensko`.

**Sources:**

| Source | Endpoint | Role |
|---|---|---|
| Open-Meteo | `api.open-meteo.com/v1/forecast` | Primary |
| wttr.in | `wttr.in/<location>?format=j1` | Fallback |

**Slovakia coverage:**

- The script aggregates representative locations across Slovakia:
  `Bratislava`, `Zilina`, `Banska Bystrica`, `Poprad`, `Kosice`
- It combines those locations into one Slovakia-wide forecast.
- The national temperature line uses the country average min and average max.
- The displayed condition uses the dominant countrywide weather pattern.
- The displayed rain percentage is the aggregated nationwide probability used for the newsletter tile.

**Regional split rule:**

- If the script detects an emergency-level split across Slovakia, it prints `[CONSULT]`.
- This is only for very direct contrasts, for example freezing or snow in one part of Slovakia and sunny much warmer weather elsewhere.
- Normal regional variation should not trigger a question; the AI should just use the national average output.

**Weather HTML hooks:**

- Always keep these IDs in the issue HTML:
  `wval-today-temp`, `wval-today-cond`, `wval-d1-icon`, `wval-d1-name`, `wval-d1-temp`, `wval-d1-rain`, through `wval-d5-*`
- Forecast day labels must use 2-letter Slovak abbreviations only:
  `Po`, `Ut`, `St`, `Št`, `Pi`, `So`, `Ne`
- The AI runs the weather script while building the issue; the user should not be asked to run it.

## Newsletter email export

Newsletter sending uses a separate Brevo-ready HTML export generated from the issue page.

**Script:**

- `prepare-brevo-email.ps1`

**Output:**

- `emails/[issue-number]-brevo.html`

**Rules:**

- The website issue remains the canonical public page.
- The email HTML is generated from the website issue, not written by hand from scratch.
- The mast-top `klikni tu` link in the email must open the real issue page on `rannasprava.sk`.
- `Archív` in the footer must open `https://rannasprava.sk/archiv/`.
- `Web` in the footer must open `https://rannasprava.sk/`.
- Unsubscribe in email uses Brevo's built-in `{{ unsubscribe }}` placeholder.
- Email HTML must stay script-free.

## Footer and share rules

- Footer links shown in issues are:
  `Archív`, `Web`, `Zdieľaj`
- `Kontakt` is removed.
- `Spravovať preferencie` is removed.
- `Odhlásiť sa z newslettera` stays in the footer copy line.
- On website issue pages, `Zdieľaj` should open an overlay above the issue content.
- That overlay should be an in-page modal, not a separate site loaded inside the popup.
- The share-page URL format is:
  `https://rannasprava.sk/share/index.html?issue=[cislo]`
- In email HTML, `Zdieľaj` must be a normal link to that same share page URL.
- Share-page UI lives in `share/index.html`; the website overlay behavior lives in `share.js`.

## Publishing flow

1. Create `vydania/[cislo]/index.html` according to `design-and-structure-spec.md`.
2. Add the issue object to `issues.js`.
3. Keep the markets and weather HTML IDs in place.
4. The AI runs `update-market-snapshot.ps1` and `update-weather-snapshot.ps1` for the target issue.
5. The AI runs `prepare-brevo-email.ps1` for the target issue.
6. Verify the generated values and footer/share links in the HTML and email export.
7. Generate the **source verification document** (see below).
8. Update the relevant `.md` files for any new rules or workflow changes.
9. Commit and push to `main`.

## Source verification document — mandatory

Every time the AI creates a new issue, it **must** also generate a source verification document saved as `vydania/[cislo]/sources.md`. This is non-negotiable.

**Purpose:** The user must be able to verify that every claim, story, statistic, and fact in the issue comes from a real, identifiable source. The AI is held accountable for accuracy.

**What must be sourced (every single one):**

| Section | What to document |
|---|---|
| Hlavná téma | Every factual claim, quote, statistic, and the overall story. Multiple sources if the story has multiple angles. |
| Prehliadka správ | Each of the 3–4 news items — separate source for each. |
| Číslo dňa | The statistic itself and the context around it. |
| Kalendár / Tento týždeň | Each calendar event — where did the AI learn about it. |
| Cold open | If it references a real event, meniny, or factual claim — source it. Pure humor/opinion needs no source. |
| Meniny | Which site was used to verify (e.g. meniny.sk, kalendar.zoznam.sk). |
| Slovo dňa | Origin or dictionary reference for the word. |
| Markets | Handled by script — note which API returned the data. |
| Počasie | Handled by script — note which API returned the data. |

**Document format (`vydania/[cislo]/sources.md`):**

```markdown
# Vydanie #[číslo] — Zdroje a overenie
Dátum vydania: [dátum]
Vytvorené: [dátum a čas tvorby]

## Hlavná téma
**Headline:** [headline text]
- [Factual claim 1] — [source URL or publication name + date]
- [Factual claim 2] — [source URL or publication name + date]
- [Statistic or quote] — [source URL]

## Prehliadka správ
**1. [Headline]**
- [source URL or publication name + date]

**2. [Headline]**
- [source URL or publication name + date]

**3. [Headline]**
- [source URL or publication name + date]

## Číslo dňa
**Číslo:** [number] [unit]
- [source for the statistic] — [URL]
- [source for the context] — [URL]

## Kalendár / Tento týždeň
- [Event 1] — [source URL]
- [Event 2] — [source URL]
- [Event 3] — [source URL]

## Cold open
- [If factual reference] — [source URL]
- [If pure opinion/humor] — No source needed

## Meniny
- Overené na: [meniny.sk / kalendar.zoznam.sk / iný zdroj]

## Slovo dňa
**Slovo:** [word]
- [dictionary or origin reference]

## Markets
- Dáta z: [API name, e.g. Finnhub, Yahoo Finance]
- Script: `update-market-snapshot.ps1`

## Počasie
- Dáta z: [API name, e.g. Open-Meteo, wttr.in]
- Script: `update-weather-snapshot.ps1`
```

**Rules:**

- Every source must be a **real, accessible URL** or a clearly identifiable publication (name + date).
- The AI must not use vague attributions like "podľa médií" or "podľa zdrojov" — name the specific outlet.
- If the AI cannot find a verifiable source for a claim, it must **not include that claim in the issue**.
- The source document is committed alongside the issue HTML in the same `vydania/[cislo]/` directory.
- The user reviews this document to verify the AI's work before the issue goes live.

## Landing page structure

The landing page (`index.html`) has these sections top-to-bottom:

1. **Nav** — Logo left, "Archív · Prihlásiť sa zadarmo" right.
2. **Hero** — Two-column grid (single column on mobile ≤860px):
   - Left: eyebrow ("Každý deň. Každé ráno."), headline, description, email signup, social proof.
   - Right: archive panel showing the 8 most recent issues with issue number, date, and title. Same cream background as the left column (no border between them).
3. **Stats bar** — Four stats in a row: `4.2k čitateľov`, `5min priemerný čas čítania`, `8:00 každé pracovné ráno`, `0€ zadarmo navždy`.
4. **Mobile archive** — Shown only on mobile (≤860px), between stats and footer. Shows 6 most recent issues.
5. **Footer** — Dark background, two-column layout:
   - Left: logo + short tagline.
   - Right: email signup form with "Prihlásiť sa zadarmo" label.
   - Bottom: Archív link + copyright.

All hero and stats elements use scroll-reveal animations (fade up on scroll).

The side-scrolling ticker is kept in the code but hidden (`display: none`).

## Notes

- GitHub Pages can be cached; use hard refresh or a query param when verifying.
- Keep commit messages explicit.
- Git default branch: `main`.
