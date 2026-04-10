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
- Do not use topic tags or category labels like `Slovensko`, `Biznis`, `Tech`, or `Šport` in archive metadata or as visible issue kickers. Archive cards should show only issue number, date, title, and preview.

## Quality checks before push

1. Confirm issue number, date, title, and preview.
2. Confirm issue appears in Home, Archive, and Reader views.
3. Confirm no duplicate or accidental content overwrite.
4. Update the relevant `.md` files so every new workflow, UI rule, and structural change is documented before commit/push.
5. Push and verify the public page source includes the new issue number.

- Publish note (2026-03-27): issue `#58` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-03-28): issue `#59` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-03-29): issue `#60` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-03-30): issue `#61` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-03-31): issue `#62` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-04-01): issue `#63` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-04-06): issue `#68` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-04-07): issue `#69` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-04-08): issue `#70` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Publish note (2026-04-09): issue `#71` was built with the standard pipeline only — HTML + `sources.md`, market snapshot, weather snapshot, overlap check, Brevo export, and podcast TXT. No template change.
- Maintenance note (2026-04-08): issue `#70` got its Spotify episode embed only after the user provided the exact episode URL, and the Brevo export was regenerated. No workflow change.
- Maintenance note (2026-04-07): issue `#69` got a live Spotify episode embed after the episode URL arrived, and the Brevo export was regenerated. No workflow change.
- Maintenance note (2026-03-29): backfilled Spotify episode embeds into issue pages `#55`, `#58`, and `#59`, then regenerated the Brevo exports. No workflow change.
- Maintenance note (2026-03-31): backfilled the compact Spotify episode embed into issue page `#57` and regenerated `emails/57-brevo.html`. No workflow change.

## AI issue workflow

- When an AI is creating or updating an issue, the AI must run the build scripts itself as part of the issue-writing process.
- The AI must never ask the user to run `update-market-snapshot.ps1` or `update-weather-snapshot.ps1`.
- The AI must also run `prepare-brevo-email.ps1` itself when the issue is being prepared for email sending. The user should not be asked to run it.
- The AI must also run `check-issue-overlap.ps1` itself before the issue is considered finished.
- The AI should first finish the issue HTML, then run the relevant snapshot scripts, then run the overlap check, then run the Brevo export script, then verify the inserted values and links in the HTML before presenting the issue as done.
- Markets command the AI must run:
  `powershell -ExecutionPolicy Bypass -File .\update-market-snapshot.ps1 vydania\[cislo]\index.html`
- Weather command the AI must run:
  `powershell -ExecutionPolicy Bypass -File .\update-weather-snapshot.ps1 vydania\[cislo]\index.html`
- Overlap check command the AI must run:
  `powershell -ExecutionPolicy Bypass -File .\check-issue-overlap.ps1 vydania\[cislo]\index.html`
- Email export command the AI must run:
  `powershell -ExecutionPolicy Bypass -File .\prepare-brevo-email.ps1 -Path 'vydania\[cislo]\index.html'`
- If the Brevo export fails on missing Python modules for CSS inlining, install:
  `python -m pip install cssutils premailer beautifulsoup4`
- If the weather script prints `[CONSULT]`, the AI should ask the user before the final output, but only for an extreme Slovakia split, not for normal regional variation.
- If the AI fixes a problem or successfully builds a new feature, it must update the relevant Markdown documentation automatically before commit/push.
- **Every single commit and push must include a documentation update in `how-we-do-ranna-sprava.md`.** This is non-negotiable. If nothing changed that affects the workflow, write a one-liner note. If something did change (design fix, new rule, new script behaviour), document it fully. The user should never have to ask "did you write this in the .md?".

## NotebookLM podcast script — mandatory per issue

Every new issue must have a NotebookLM-optimized podcast source file generated alongside the issue HTML. This file is used with the `notebooklm-prompt.txt` instructions to generate a podcast episode via NotebookLM Audio Overview.

- Script: `generate-podcast-txt.py`
- Command:
  `python .\generate-podcast-txt.py .\vydania\[cislo]\index.html`
- Output: `vydania/[cislo]/issue-[cislo]-podcast.txt`
- The AI must run this script as part of every issue build, after the HTML is final (markets + weather already inserted). The user should not be asked to run it manually.
- The file is a clean plain-text version of the issue, optimised for spoken Slovak:
  - HTML markup stripped; abbreviations preserved in their original grammatical form (EÚ, SR, USA etc. are NOT expanded — expansion would introduce declension errors)
  - Symbols converted to words: `%` → `percent`, `°` → `stupňov`, `$` → `dolárov`, `▲/▼` → `nahor/nadol`
  - Decimal separator converted to Slovak comma: `653.18` → `653,18`
  - Temperature ranges: `4° – 15°` → `4 až 15 stupňov`
  - Weather emojis and day abbreviations stripped from the condition field
  - Structured with clear section markers (`=== INTRO ===`, `=== HLAVNÁ TÉMA ===`, etc.)
  - Intro block contains date, weather summary, and market snapshot
  - Outro block contains a generic sign-off: `Dovidenia zajtra.`
- The generated TXT is committed alongside the issue HTML in the same `vydania/[cislo]/` directory.
- If the user asks for Spotify episode copy, store it next to the issue as `vydania/[cislo]/issue-[cislo]-spotify-description.txt` so the final platform text lives with the rest of the issue assets.

**How to use with NotebookLM:**
1. Create a new NotebookLM notebook.
2. Add `vydania/[cislo]/issue-[cislo]-podcast.txt` as a source.
3. Open Audio Overview → Customize → paste the contents of `notebooklm-prompt.txt`.
4. Generate.

## Optional issue audio

- A listenable Slovak MP3 draft can be generated from an issue HTML file with `generate-issue-audio.py`.
- Command:
  `python .\generate-issue-audio.py .\vydania\[cislo]\index.html --out .\vydania\[cislo]\issue-[cislo]-sk-google.mp3 --script-out .\vydania\[cislo]\issue-[cislo]-sk-google.txt`
- Current implementation uses Google's `gTTS` stack as a lightweight prototype, not Google Cloud credentials.
- The AI should run this itself when the user asks for issue audio; the user should not be asked to generate it manually.
- Generated MP3 and narration text are local build artifacts unless the user explicitly asks to publish them.

## Spotify podcast block at top of issue

- New issues must be published **without** a Spotify embed by default.
- Spotify is added only after the user explicitly sends the episode link or explicitly asks to add the embed.
- Do not auto-insert the show embed during issue creation.
- If the supplied Spotify episode number/title does not clearly match the issue number, do not embed it and ask the user instead.
- Current preferred placement is **below markets and above cold open**.
- The current shipped web treatment for issue `#56` uses **no visible text and no button**; it is just a compact embedded Spotify player inside a fading background band.
- Current permanent show URL:
  `https://open.spotify.com/show/6vuQwKMWnRHowT5EiTZdxo?si=41d2808facb84636`
- When the user provides the right episode, embed that specific episode directly.
- The background should start in the same cream tone as the markets strip and fade out into the normal issue paper by the end of the Spotify block.
- To swap the embed after the episode exists, run:
  `powershell -ExecutionPolicy Bypass -File .\update-podcast-embed.ps1 -Url 'https://open.spotify.com/episode/...`
- If `-Path` is omitted, the script updates the latest numeric issue in `vydania/`.
- The script only changes the embedded player target from show to episode (or back again).

## Editorial focus — Slovak market first

Ranná Správa is built for the Slovak reader. Every issue must reflect this.

### Slovak stories as main topic

- **Hlavná téma must feature a Slovak or Slovakia-affecting story whenever one exists.** A Slovak political development, domestic scandal, economic decision, or event that directly impacts Slovak citizens takes priority over foreign stories of equivalent size.
- If a foreign story is genuinely bigger (e.g. a major war development, a European-level crisis that dwarfs anything happening domestically), it may lead — but this should be the exception, not the default.
- The last two issues (#54, #55) led with Slovenian elections and a Hungarian scandal. Going forward, actively look for Slovak angles first before defaulting to international stories.

### Second main topic

- If a Slovak story and a major international story are both large enough to stand on their own, the issue **may carry a second Hlavná téma block**. Label the first `Hlavná téma` and the second `Druhá téma` (or a contextual subhead). Do not force two topics into one story — give each its own space.
- Only add a second topic if both stories genuinely warrant it. Do not pad.

### Slovak sources — mandatory

Every issue must draw on Slovak-language or Slovakia-focused sources. Required outlets to check for every issue:

| Source | URL | Type |
|---|---|---|
| SME | sme.sk | Broadsheet daily |
| Denník N | dennikn.sk | Independent investigative |
| Pravda | pravda.sk | Broadsheet daily |
| TASR | tasr.sk | Official Slovak news agency |
| SITA | sita.sk | Private Slovak news agency |
| Aktuality | aktuality.sk | Online news portal |
| HN (Hospodárske noviny) | hnonline.sk | Business/economy |
| Refresher | refresher.sk | Youth/lifestyle angle |
| TA3 | ta3.com | TV news |
| Trend | trend.sk | Business/economics weekly |

- At least one Slovak source must appear in `sources.md` for every issue.
- For any story touching Slovak politics, economy, or society, a Slovak source is **required** — not optional.
- Foreign outlets (Reuters, BBC, Euronews, FT) remain valid for international stories but must be paired with a Slovak source whenever one covers the same event.

### What counts as a Slovak story

- Slovak government decisions, legislation, or political scandals
- Slovak economic data (GDP, inflation, unemployment, energy prices domestically)
- Slovak companies, infrastructure, or public institutions
- Events happening in Slovakia or directly initiated by Slovak actors
- EU or international decisions that specifically and significantly affect Slovakia (e.g. energy policy, trade deals with direct Slovak exposure)
- Slovak sports, culture, or society if genuinely newsworthy

### Prehliadka správ balance

- At least **1 of the 4 Prehliadka items must be a Slovak domestic story** in every weekday issue.
- The other 3 items may be international, but must be relevant to what a Slovak reader cares about — not generic world news.

### Prehliadka správ — heading style (`.tour-hed`)

- Telegraphic shorthand (omitted verbs, participles standing alone) is appropriate for **subject lines and preview text**, where space is tight and scanning speed matters.
- Inside the email, once the reader is already reading, headings must use **full, human sentences** with proper verb forms.
- Do not drop "je", "sú", "bude", "budú", "bol", "bola" etc. just to sound punchy — it reads as machine-generated.
- Example — wrong: *„Fond SAFE plne upísaný. Firmy vylúčené."* / correct: *„Fond SAFE je plne upísaný. Firmy budú vylúčené."*
- Rule of thumb: if you would not say the headline out loud to a colleague, rewrite it.

## Section uniqueness rule

- Each issue section must own a different story or angle.
- `Hlavná téma`, every `Prehliadka správ` item, `Číslo dňa`, and `Tento týždeň` must not repeat the same underlying news event.
- If a story is used in `Číslo dňa`, it must not also appear in `Prehliadka správ` or `Hlavná téma`.
- `Tento týždeň` can mention upcoming events, but it must not restate the same political or news development already covered elsewhere in the same issue.
- If the overlap checker flags a duplicate, the AI must rewrite or replace one of the sections until the issue passes.

## Číslo dňa — topic freshness rule

- `Číslo dňa` must be tied to **recent news** — either from the same day as the issue, or from recent weeks. It can also be a meaningful historical anniversary (e.g. "X years ago today…"), but only if it is genuinely interesting and connects to something the reader can care about now.
- **Do not recycle a topic that was already covered in the same issue** (Hlavná téma, Prehliadka správ). If the best number of the day comes from the same event as Hlavná téma, find a different number from a different story. The check-issue-overlap script catches keyword overlaps, but the AI must also apply editorial judgment — even if the wording differs, covering the same event twice is forbidden.
- **Do not reuse topics from the previous 2 issues.** Before choosing a stat, mentally check the last two issues' Číslo dňa and all their sections. If the underlying event was already featured, pick something else.

## Slovo dňa — accessibility rule

- `Slovo dňa` must be understandable to an ordinary, curious adult with no specialist background. The goal is to teach the reader something genuinely new — not to show off vocabulary.
- **The definition must not contain other words the reader would also need to look up.** If explaining the word requires first explaining two other technical terms, choose a simpler word or rewrite the definition using plain language.
- Test: could a secondary school student read this definition and understand it without pausing? If no, simplify.
- Analogies, real-world examples, and comparisons to everyday things are strongly preferred over academic definitions.
- The word itself may be a technical, economic, legal, or foreign term — that is fine. The definition must still be written in plain, direct Slovak.

## Tento týždeň — writing style

- Each entry is factual first: date, event, one or two sentences of genuine context.
- **No snarky or forced punchline endings.** Do not end a cal-item with a cheap observation like "Ešte menej ľudí vie, kde je v susedstve klavír." — this kind of wit feels hollow and does not add value.
- If a lighter touch is appropriate (cultural day, anniversary), end with something **actionable or genuinely interesting** — a song to listen to, a book to read, a fact worth knowing. Example: for Medzinárodný deň klavíra, point readers to Billy Joel's *Piano Man* (1973) rather than making a throwaway joke.
- **No namedays (meniny).** Namedays are not included in `Tento týždeň`. They were removed from issue #55 onward. If a build script or template generates nameday entries, delete them before publishing.
- Entries should feel like a smart friend flagging something worth your attention — not a listicle bot padding word count.
- **Always include at least 3 entries.** If the week is light, look for anniversaries, international days, or political/economic deadlines with Slovak or European relevance.
- **Sort entries chronologically** — closest date first, furthest last. This is a mandatory pre-publish check, not an editorial preference.
- **Do not reorder by importance, theme, or punchiness.** If the issue goes out on Wednesday, Wednesday comes before Sunday, and Sunday comes before the following Tuesday.

## Slovak wording and names

- Use correct Slovak words, not Czech or English-looking variants.
- Before an issue is finished, check that wording and grammar match standard Slovak dictionary usage.
- If a form looks doubtful, verify it against a Slovak dictionary or standard language reference before publishing.
- Example: use `diplomacia`, never `diplomatia`.
- Use Slovak naming for the oil pipeline: `Družba`.
- If it appears with the noun, write `ropovod Družba`, never `ropovod Druzhba`.
- Ceasefire is `prímerie` (nominative). Never use `prímerí` — that is an incorrect form.

## Masthead date bar font

- `Anton`, 17px, `font-weight: 400`.
- Google Fonts import required in every issue: `family=Anton`.

## Číslo dňa — stat-num dynamic font sizing

The number in the golden left column (`.stat-num`) auto-shrinks if it is too wide to fit. Two-layer approach:

1. **CSS container query** — `.stat-left` has `container-type: inline-size`; `.stat-num` uses `font-size: clamp(20px, 52cqi, 68px)`. This covers modern browsers.
2. **JS shrink fallback** — An inline `<script>` at the bottom of each issue reduces the font size 2px at a time until `scrollWidth ≤ available width`. Covers browsers without container-query support and email clients that run JS.

This CSS and script must be present in every new issue. Copy from the latest issue template. Do **not** replace it with a fixed `font-size: 68px` — that will overflow the column for multi-digit numbers like `9 523`.

## Markets ticker - build snapshot

Market data is written into the issue HTML at build time by `update-market-snapshot.ps1`. Published issue pages do not fetch market data in the browser. `markets.js` is intentionally empty.

**5 tickers shown in every vydanie:**

| Ticker | Primary source | Fallback 1 | Fallback 2 |
|---|---|---|---|
| Bitcoin | CoinGecko free API (rolling 24h change, weekdays aj víkendy) | Finnhub `/crypto/candle` (`BINANCE:BTCUSDT`) | Yahoo Finance (`BTC-USD`) |
| S&P 500 | Finnhub `/quote` (`SPY`) | Yahoo Finance (`SPY`) | Alpha Vantage |
| EUR/USD | Finnhub `/forex/candle` (`OANDA:EUR_USD`) | Yahoo Finance (`EURUSD=X`) | Alpha Vantage |
| MSCI World | Alpha Vantage `TIME_SERIES_DAILY` (`URTH`) | Yahoo Finance (`URTH`) | - |
| Zlato | Finnhub `/quote` (`GLD`) | Yahoo Finance (`GLD`) | Alpha Vantage |

**How it works:**

- The script reads the issue date from the issue HTML.
- **Bitcoin (weekdays):** uses CoinGecko free API for live price + rolling 24-hour change (industry standard for crypto). No API key required. Fallback to Finnhub candle if CoinGecko fails.
- **Bitcoin (weekends):** stays on the live rolling 24-hour CoinGecko snapshot just like on weekdays. It does **not** get the Friday `*` marker. Only if CoinGecko fails does the script fall back to a Friday candle.
- **All other tickers:** last available close for the day before the issue date. If markets are closed, uses the last available close.
- `market-val` contains the USD price.
- `market-chg` contains percent change: 24h rolling for BTC, close-to-close for all others.
- The fallback chain starts automatically if the primary source fails.
- **Run the script on the morning of publication.** US markets close at ~10pm Slovak time. If you run `update-market-snapshot.ps1` for Tuesday's issue before Monday's US markets close, the script will correctly use Friday's data for Monday's issue but will also use Friday's data for Tuesday's issue (Monday close not yet available). Re-run on Tuesday morning to get Monday's actual close in Tuesday's issue. The script's cache is per-day so a re-run on a new day always fetches fresh data.
- **Cache key is per-symbol + per-target-date.** Two issues processed in the same script session each make their own Finnhub API call. Prior to March 2026 the key was per-symbol only, causing the second issue to reuse the first issue's cached quote.
- **Known data gap (fixed March 2026):** Yahoo Finance occasionally returns `null` for a day's close. Previously this silently became `0`, causing `market-chg` to display `—` (no change). Fix: `Get-YahooSnapshot` now throws on null prev close so the fallback chain continues. If all sources fail and `—` still appears, fix the value manually in the HTML.
- **Weekend footnote encoding (fixed March 2026):** the weekend footnote string (`* piatkový záver trhov`) is now assembled from explicit Unicode code points inside `update-market-snapshot.ps1`. This avoids PowerShell source-encoding mojibake on Saturday/Sunday issues.
- **Warnings:** if any asset's change shows `—` after the script writes the file, a yellow warning prints in the console naming the exact ticker. Always check the console output after running the script.

**Market HTML hooks:**

- Always keep these IDs in the issue HTML (three rows per ticker):
  `mval-btc`, `meur-btc`, `mchg-btc`,
  `mval-spy`, `meur-spy`, `mchg-spy`,
  `mval-eurusd`, `meur-eurusd`, `mchg-eurusd`,
  `mval-msci`, `meur-msci`, `mchg-msci`,
  `mval-gold`, `meur-gold`, `mchg-gold`
- Each ticker shows: USD value (line 1) → EUR equivalent (line 2, muted) → % change (line 3, colored)
- For EUR/USD the EUR row shows the inverse rate (how many EUR per 1 USD)
- Workdays: the block is visible, no asterisks, no footnote.
- Weekends: the block is **always visible**. The script detects Saturday/Sunday from the issue date, uses the last Friday close for `S&P 500`, `EUR/USD`, `MSCI World`, and `Zlato`, appends `*` only to those four `market-val` prices (between the number and the arrow span), and sets `<div class="market-footnote" id="market-footnote">* piatkový záver trhov</div>` at the bottom of the strip. `Bitcoin` stays live and shows no `*`.
- If you rerun a weekend issue later, `Bitcoin` will refresh to the then-current CoinGecko 24-hour snapshot while the other four assets remain frozen to Friday close.
- The `.markets` div must include `flex-wrap: wrap` and a `<div class="market-footnote" id="market-footnote"></div>` as its last child in every issue from #56 onward.
- Do NOT comment out the markets block on weekends — always include the full HTML with placeholder values; the script fills them in and adds asterisks automatically.

### Markets strip — email layout (critical)

- The `index.html` (web) uses `display:flex` for the markets strip — this is fine for browsers.
- **The brevo email file must use a `<table>` layout**, not flexbox. Gmail and other clients strip `display:flex` and collapse items into a vertical stack.
- `inline-email-css.py` handles this automatically via `fix_market_items()`: it converts the `.markets` flex div into a 5-column `<table>` during the inlining step. Each `.market-item` becomes a `<td width="20%">`.
- The `market-footnote` div (used on weekends) is dropped from the table conversion since it would become a stray element. Weekend footnote handling needs to be revisited if weekend issues are ever sent via Brevo.
- **Bug fixed in issue #55:** `fix_market_items()` was previously looking for `class_='market-row'` (wrong class name — should be `markets`), so the conversion silently did nothing and flex layout reached email clients unchanged. Fixed from issue #55 onward.

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

**Backdated issues:**

- When the issue date is in the past, the weather build should use historical-capable Open-Meteo data instead of forecast-only output so archive backfills still render a full 6-day Slovakia snapshot.

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
- Unsubscribe in email uses Brevo's `{unsubscribe}` placeholder — **single curly braces, no spaces**. Double-brace `{{ unsubscribe }}` is wrong and triggers Brevo's "incorrect placeholder" suspension warning. Single-brace is for Brevo system variables; double-brace is only for contact attributes like `{{ contact.FIRSTNAME }}`.
- Email HTML must stay script-free.
- **Web fonts do not load in email clients.** `inline-email-css.py` automatically replaces the `Anton` font stack with `"Anton", Impact, "Arial Narrow", Arial, sans-serif` so the date bar degrades to `Impact` (a condensed bold system font) instead of plain Arial. Do not remove or bypass this step — without it the masthead date bar renders in a completely different style. The fix lives in `fix_web_font_fallbacks()` in `inline-email-css.py`.
- **All CSS must be inlined.** `prepare-brevo-email.ps1` calls `inline-email-css.py` automatically — this converts all `<style>` block rules into `style=""` attributes on each element. This is required because email clients (Gmail, Outlook, Apple Mail) strip `<style>` tags and render raw unstyled text without inlining. Do not skip this step or bypass the Python inliner.
- **All `<style>` tags must be stripped after inlining.** Premailer keeps a residual `<style>` block for `!important` rules after inlining. Brevo parses any `{ }` found anywhere in the HTML as template placeholders — CSS rules like `{color:#1A1208 !important}` trigger the "incorrect placeholder" error. `inline-email-css.py` strips all remaining `<style>` tags after inlining so the only `{ }` left in the file is `{unsubscribe}`.
- **How to import in Brevo:** Use the **"Import HTML"** or **"Code your own"** option in the campaign Design step — not the drag-and-drop editor and not dev mode (which uses YAML). The drag-and-drop editor cannot accept raw HTML.

**Automatic regeneration — mandatory:**

- Any time the AI creates, edits, or deletes a `vydania/[cislo]/index.html` file — for any reason, including content edits, design fixes, stat corrections, or structural changes — it must immediately re-run `prepare-brevo-email.ps1` for that issue before committing.
- This applies even to small one-line fixes. There are no exceptions.
- The regenerated `emails/[cislo]-brevo.html` must be included in the same commit as the HTML change.
- Command: `powershell -ExecutionPolicy Bypass -File .\prepare-brevo-email.ps1 -Path 'vydania\[cislo]\index.html'`

## Footer and share rules

- Footer links shown in issues are:
  `Archív`, `Web`, `Zdieľaj`
- `Kontakt` is removed.
- `Spravovať preferencie` is removed.
- `Odhlásiť sa z newslettera` stays in the footer copy line.
- On website issue pages, `Zdieľaj` should open an overlay above the issue content.
- That overlay should be an in-page modal, not a separate site loaded inside the popup.
- The website should not switch to the browser's native share sheet instead of the modal.
- The modal must close reliably when the user clicks outside it, presses `Escape`, or clicks the `Zavrieť` button.
- The share-page URL format is:
  `https://rannasprava.sk/share/index.html?issue=[cislo]`
- In email HTML, `Zdieľaj` must be a normal link to that same share page URL.
- Share-page UI lives in `share/index.html`; the website overlay behavior lives in `share.js`.

## Share system — current behaviour (share.js)

### 1. Share button in masthead
Every issue has a `Zdieľaj` button inside the `.mast-date-bar` (the gold date bar), centred between the date and the issue number.

**Email:** The share button is stripped from the email date bar by `fix_mast_date_bar()` in `inline-email-css.py` — the middle child element is extracted and discarded. The web version is unaffected. The footer `Zdieľaj` link remains in both web and email. When a share CTA is added back to emails in future, it will go in as a dedicated segment, not inside the date bar. It uses class `mast-share js-share-link` and carries `data-share-url`. Hidden on mobile (≤640px) via CSS — footer link remains the mobile entry point.

HTML pattern in every new issue:
```html
<div class="mast-date-bar">
  <span>[Deň, dátum]</span>
  <a class="mast-share js-share-link"
     href="https://rannasprava.sk/share/index.html?issue=[cislo]"
     data-share-url="https://rannasprava.sk/vydania/[cislo]/">Zdieľaj</a>
  <span>Vydanie #[cislo]</span>
</div>
```

CSS to include in every new issue (identical to existing issues):
```css
.mast-share { font-family: 'Lora', serif; font-size: 11px; font-weight: 600;
  text-transform: uppercase; letter-spacing: 1.5px;
  color: #1A1208; background: transparent; border: 1.5px solid #1A1208;
  padding: 4px 12px; cursor: pointer; text-decoration: none;
  transition: background .15s, color .15s; }
.mast-share:hover { background: #1A1208; color: #C8962A; }
@media (max-width: 640px) { .mast-share { display: none; } }
```

### 2. Native Share API (mobile)
On devices that support `navigator.share()` (all modern iOS/Android), clicking any `.js-share-link` triggers the OS share sheet directly. The user sees their native iMessage / WhatsApp / Telegram options in one tap. The in-page overlay is only shown when `navigator.share` is not available (desktop) or when a non-cancel error occurs.

### 3. Pre-written share message
The clipboard copy, WhatsApp link, email body, and X tweet all use a pre-written message:
`"Pozri si dnešnú Rannú Správu 👉 [url]"`
The raw URL is still displayed in the overlay's URL box so the user can copy it manually if needed.

## Brevo campaign subject and preview

After generating an issue, the AI must output the Brevo campaign Subject and Preview text directly in the chat. Format:

```
Subject:
Ranná Správa · [Deň], [dátum]

Preview:
[Hlavný príbeh v skratke]. [Druhý príbeh]. [Tretí príbeh].
```

Rules:
- Subject is always `Ranná Správa · [Deň], [dátum]` — e.g. `Ranná Správa · Utorok, 24. marca`
- Preview is 2–4 short punchy phrases separated by periods, matching the top stories of the issue
- Preview should be under 130 characters so it fully displays in Gmail/Outlook inbox preview
- Output this in the chat only — it is not written into any file

## Publishing flow

1. Create `vydania/[cislo]/index.html` according to `design-and-structure-spec.md`.
2. Add the issue object to `issues.js` — new issue goes at the **top** of the `const ISSUES = [...]` array.
3. Keep the markets and weather HTML IDs in place.
4. The AI runs `update-market-snapshot.ps1` and `update-weather-snapshot.ps1` for the target issue.
5. The AI runs `check-issue-overlap.ps1` for the target issue and resolves every flagged duplicate before continuing.
6. The AI runs `prepare-brevo-email.ps1` for the target issue. This step is also mandatory after any later edit to the issue HTML — even minor fixes.
7. The AI runs `generate-podcast-txt.py` for the target issue. This generates `vydania/[cislo]/issue-[cislo]-podcast.txt`.
8. Verify the generated values, section uniqueness, and footer/share links in the HTML and email export.
9. Generate the **source verification document** (see below).
10. Update the relevant `.md` files for any new rules or workflow changes.
11. Commit and push to `main`.

**These steps are all mandatory when creating an issue. The AI must complete all of them without being asked — including adding to `issues.js` and committing/pushing.**

## Archive cache-buster — mandatory on every new issue

After adding a new issue to `issues.js`, the AI must update the `?v=` cache-busting query string on the `issues.js` script tag in **both** of these files:

- `archiv/index.html` — `<script src="../issues.js?v=YYYYMMDD-NN">`
- `index.html` — `<script src="/issues.js?v=YYYYMMDD-NN">`

Format: `YYYYMMDD-NN` where `YYYYMMDD` is the issue date and `NN` is the issue number.

Example for issue #53 on 22 March 2026: `?v=20260322-53`

Without this update, browsers that have cached the old `issues.js` will not show the new issue in the archive or on the landing page.

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

## Share modal note

- Website `Zdieľaj` must always open the in-page modal, not the browser or device native share sheet.
- All visible share-modal copy must use correct Slovak diacritics:
  `Zdieľaj`, `Zavrieť`, `Skopírovať`, `Otvoriť`, `Poslať`, `Ranná Správa`, `dnešnú`, `môžeš`.

## Inline source links and relevance

- `sources.md` remains the full fact-check log for every issue.
- The issue HTML should also contain a small number of inline source links inside the written text.
- Target volume is `2` to `4` inline links per entire issue, not per section.
- In a short paragraph, use at most `1` inline source link. In a long paragraph, use at most `2`, and only if both materially help the reader go deeper.
- Use inline links only where the reader may reasonably want the original report because we are not covering the story in full depth.
- Link directly to the underlying report or official source already logged in `sources.md`.
- Prioritize inline links for stories relevant to Slovak readers: Slovakia, Czechia, Central Europe, the EU, energy, security, migration, and the Middle East.
- `Číslo dňa` must be understandable and relevant for the Slovak audience. Avoid niche celebrity or awards statistics unless there is a clear Slovak, regional, or geopolitical angle.

## Session note — 2026-03-25 (Issue #56)

No workflow or structural changes in this session. Issue #56 built and published following the existing process. The `market-footnote` div (required from issue #56 onward per earlier doc update) is present in the HTML. CONSULT flag from weather script for 27. 3. assessed as normal regional variation — not escalated to user.

## Session note — 2026-03-25 (podcast script)

Added `generate-podcast-txt.py` — generates `issue-[N]-podcast.txt` in each vydanie directory. This file is the NotebookLM source for podcast episodes. Generating it is now a mandatory step in the publishing flow (step 7). The script: strips HTML, converts symbols to Slovak words, preserves abbreviations in their original grammatical form (no declension-breaking expansions), formats temperature ranges and decimal numbers correctly for Slovak. The `notebooklm-prompt.txt` instructions file was also rewritten to match the new podcast format (intro with date/weather/markets, turn-taking format, Slovak grammar rules, outro).

## Session note — 2026-03-25 (brevo weather fix)

Fixed `inline-email-css.py` — `fix_weather()` was copying `.weather-day` flex CSS (`display:flex; flex-direction:column; align-items:center; gap:3px; flex:1; min-width:0`) directly onto `<td>` cells, causing email clients to collapse all 5 weather columns into a single row. Fix: strip ALL flex properties from each day `<td>` using `_FLEX_PROPS` tuple; add explicit `width`/`align`/`valign` HTML attributes. Also strip `flex-direction:row; flex-wrap:nowrap` from the outer days `<td>`. Issue #56 brevo file regenerated with the fix applied.

## Session note – 2026-03-26 (Issue #57)

Issue #57 built and published. Hlavná téma: Ferenčák garage video (45 000 € in cash, coalition fragility). Prehliadka: dual diesel pricing + EU threat, EP Turnberry vote, SK–Kosovo WC qualifier, Iran peace plan rejection. Číslo dňa: 800 evakuovaných (largest-ever Slovak repatriation). Slovo dňa: Backwardation. check-issue-overlap.ps1 flagged three pairs — all confirmed false positives (common political vocabulary, different stories). Weather script: OK. Market script: Finnhub EURUSD fallback (non-critical).

## Session note – 2026-04-10 (Issue #73)

Issue #73 was prepared with the standard HTML + `sources.md` + Brevo + podcast pipeline. `update-market-snapshot.ps1` and `update-weather-snapshot.ps1` were both invoked but could not reach their external APIs in this sandboxed environment, so the issue stayed on the inherited market snapshot and a manually aligned weather block. No workflow change was introduced.
