# Changelog

---

## 2026-03-31 - Spotify embed backfill for issue 57

### Older issue now points to the real episode player

**Subory:** `vydania/57/index.html`, `emails/57-brevo.html`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Backfilled the compact Spotify episode embed into issue `#57`.

- added the same top-of-issue podcast block already used on newer issue pages
- set the embed target to episode `2KXlx0g24MAXQRMIrCJ6VE`
- regenerated the Brevo export for `#57`
- no workflow change, only an older-issue content backfill

---

## 2026-03-31 - Issue 62 published

### March 31 issue build

**Subory:** `vydania/62/index.html`, `vydania/62/sources.md`, `vydania/62/issue-62-podcast.txt`, `emails/62-brevo.html`, `issues.js`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Published issue `#62` for Tuesday, 31 March 2026.

- **Hlavná téma:** Slovensku chýbajú sestry, ukrajinské zdravotníčky brzdí uznávanie kvalifikácie a byrokracia
- **Prehliadka správ:** podpisy Demokratov za referendum, tesný marcový model SANEP, zmätok okolo sviatkov bez voľna, spor o Donbas medzi Zelenským a Rubiom
- **Číslo dňa:** `15 miliárd eur` ako nárast slovenského verejného dlhu za dva roky
- **Tento týždeň:** daňové priznanie za rok 2025, nová linka Bratislava–Tirana, Svetový deň povedomia o autizme
- **Slovo dňa:** `Credentialing`

**Skripty spustené:**
- `update-market-snapshot.ps1` — OK; Finnhub EUR/USD fallback warning, výstup zapísaný
- `update-weather-snapshot.ps1` — OK
- `check-issue-overlap.ps1` — OK po preformulovaní niekoľkých spoločných slovných stemov
- `prepare-brevo-email.ps1` — OK, výstup `emails/62-brevo.html`
- `generate-podcast-txt.py` — OK, výstup `vydania/62/issue-62-podcast.txt`

---

## 2026-03-30 - Issue 61 published

### March 30 issue build

**Subory:** `vydania/61/index.html`, `vydania/61/sources.md`, `vydania/61/issue-61-podcast.txt`, `emails/61-brevo.html`, `issues.js`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Published issue `#61` for Monday, 30 March 2026.

- **Hlavná téma:** aprílové dôchodky sa pre Veľkú noc posúvajú, pracujúcich dôchodcov čaká zvýšenie penzie
- **Prehliadka správ:** vláda stále nežiada parlament o dôveru, Dubnica čaká na mzdy od októbra, Šimečka ostáva na čele PS, Srbsko znervóznilo región čínskymi raketami
- **Číslo dňa:** `4000 rokov` ako vek nálezov odhaľovaných v Demänovskej ľadovej jaskyni
- **Tento týždeň:** Bratislava–Pisa, daňové priznanie za rok 2025, Svetový deň povedomia o autizme
- **Slovo dňa:** `Arrears`

**Skripty spustené:**
- `update-market-snapshot.ps1` — OK; Finnhub EUR/USD fallback warning, výstup zapísaný
- `update-weather-snapshot.ps1` — OK
- `check-issue-overlap.ps1` — OK po preformulovaní pár dátumových kolízií
- `prepare-brevo-email.ps1` — OK, výstup `emails/61-brevo.html`
- `generate-podcast-txt.py` — OK, výstup `vydania/61/issue-61-podcast.txt`

---

## 2026-03-29 - Spotify episode embeds backfilled

### Issue pages 55, 58, and 59 now point to real episode embeds

**Subory:** `vydania/55/index.html`, `vydania/58/index.html`, `vydania/59/index.html`, `emails/55-brevo.html`, `emails/58-brevo.html`, `emails/59-brevo.html`, `vydania/55/issue-55-podcast.txt`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Backfilled the compact Spotify embed block into older issue pages that previously had no podcast player.

- issue `#55` now embeds episode `7cdf2IrWXv9BTFlY8mESDa`
- issue `#58` now embeds episode `2dglMOrY5WfSf26zlcyYde`
- issue `#59` now embeds episode `1XT29Pr6mZjUgTYzJ5jGpT`
- regenerated the Brevo email exports after editing the issue HTML
- generated `vydania/55/issue-55-podcast.txt` while bringing `#55` in line with the current issue-asset workflow

---

## 2026-03-29 - Weekend Bitcoin market rule

### Bitcoin no longer freezes to Friday close on weekend issues

**Subory:** `update-market-snapshot.ps1`, `vydania/59/index.html`, `vydania/59/issue-59-podcast.txt`, `emails/59-brevo.html`, `vydania/60/index.html`, `vydania/60/issue-60-podcast.txt`, `emails/60-brevo.html`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Changed the weekend market logic so `Bitcoin` no longer gets the Friday-close treatment.

- on weekend issues, `Bitcoin` now stays on the live CoinGecko 24-hour snapshot
- the Friday `*` marker now applies only to `S&P 500`, `EUR/USD`, `MSCI World`, and `Zlato`
- regenerated the current weekend issues `#59` and `#60`, including their Brevo emails and podcast TXT files
- documented the new rule in the workflow and design docs

---

## 2026-03-29 - Issue 60 published

### March 29 issue build

**Subory:** `vydania/60/index.html`, `vydania/60/sources.md`, `vydania/60/issue-60-podcast.txt`, `emails/60-brevo.html`, `issues.js`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Published issue `#60` for Sunday, 29 March 2026.

- **Hlavná téma:** štát chce po kontrolách PN dôslednejšie preverovať aj invalidné dôchodky
- **Prehliadka správ:** ďalší odklad D1 pri Ružomberku, rast Republiky zo sklamaných voličov koalície, G7 rieši Irán a Ukrajinu, EP odobril dohodu EÚ–USA s poistkami
- **Číslo dňa:** `400 eur` ako limit na jedno tankovanie nafty
- **Tento týždeň:** začiatok letného času, daňové priznanie za rok 2025, Svetový deň povedomia o autizme
- **Slovo dňa:** `Bottleneck`

**Skripty spustené:**
- `update-market-snapshot.ps1` — OK; Finnhub fallback warning pre BTC a EUR/USD, výstup zapísaný
- `update-weather-snapshot.ps1` — OK
- `check-issue-overlap.ps1` — OK po obsahovom preformulovaní sekcií
- `prepare-brevo-email.ps1` — OK, výstup `emails/60-brevo.html`
- `generate-podcast-txt.py` — OK, výstup `vydania/60/issue-60-podcast.txt`

---

## 2026-03-28 - Spotify description for issue 58

### Short episode copy stored with issue assets

**Subory:** `vydania/58/issue-58-spotify-description.txt`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Added a short Spotify-ready episode description for issue `#58`.

- the description now lives next to the issue assets in `vydania/58/`
- the workflow docs now say Spotify episode copy should be stored as `issue-[cislo]-spotify-description.txt` when requested

---

## 2026-03-28 - Issue 59 published

### March 28 issue build + weekend market footnote fix

**Subory:** `vydania/59/index.html`, `vydania/59/sources.md`, `vydania/59/issue-59-podcast.txt`, `emails/59-brevo.html`, `issues.js`, `update-market-snapshot.ps1`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Published issue `#59` for Saturday, 28 March 2026.

- **Hlavná téma:** slovenská ekonomika vlani rástla len o 0,8 %, domácnosti citeľne ubrali zo spotreby
- **Prehliadka správ:** tri slovenské bronzy na zimnej paralympiáde, G7 vo Francúzsku rieši Irán a Ukrajinu, EÚ s Austráliou spojili obchod s obranou, dohoda EÚ–Mercosur štartuje 1. mája
- **Číslo dňa:** `344` vážnych výstrah na ohrozenie slobody médií v ročnom prehľade platformy Rady Európy
- **Tento týždeň:** Deň učiteľov, 22 rokov od vstupu Slovenska do NATO, Piano Day
- **Slovo dňa:** `Headwind`

**Skripty spustené:**
- `update-market-snapshot.ps1` — OK; Finnhub fallback warning pre BTC a EUR/USD, výstup zapísaný
- `update-weather-snapshot.ps1` — OK
- `check-issue-overlap.ps1` — OK po obsahovom preformulovaní sekcií
- `prepare-brevo-email.ps1` — OK, výstup `emails/59-brevo.html`
- `generate-podcast-txt.py` — OK, výstup `vydania/59/issue-59-podcast.txt`

Also fixed a weekend build bug while publishing:

- `update-market-snapshot.ps1` now writes the weekend footnote `* piatkový záver trhov` via explicit Unicode code points
- this prevents mojibake in Saturday/Sunday issue pages
- the design and workflow docs now reflect that markets remain visible on weekend issues

---

## 2026-03-27 - Topic tags removed

### Archive and issue labels simplified

**Subory:** `index.html`, `archiv/index.html`, `issues.js`, `vydania/48/index.html`, `vydania/49/index.html`, `vydania/492/index.html`, `vydania/50/index.html`, `vydania/51/index.html`, `vydania/52/index.html`, `vydania/53/index.html`, `vydania/54/index.html`, `vydania/55/index.html`, `vydania/56/index.html`, `vydania/57/index.html`, `vydania/58/index.html`, `generate-podcast-txt.py`, `vydania/56/issue-56-podcast.txt`, `vydania/57/issue-57-podcast.txt`, `vydania/58/issue-58-podcast.txt`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Removed topical categorisation from the product surface.

- deleted archive filter buttons and issue tag pills from the home page and dedicated archive page
- removed `tags` arrays from `issues.js`
- removed visible `story-kicker` category lines from all tracked issue HTML files
- updated podcast generation so it no longer emits `Téma:` category labels
- documented the rule that issue cards and issue bodies should not show topic labels like `Slovensko`, `Biznis`, `Tech`, or `Šport`

---

## 2026-03-27 - Issue 58 published

### March 27 issue build

**Subory:** `vydania/58/index.html`, `vydania/58/sources.md`, `vydania/58/issue-58-podcast.txt`, `emails/58-brevo.html`, `issues.js`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Published issue `#58` for Friday, 27 March 2026.

- **Hlavná téma:** Slovensko prehralo s Kosovom 3:4 a končí v baráži o MS 2026
- **Prehliadka správ:** slovenský HDP vlani stúpol len o 0,8 %, EP odobril dohodu EÚ–USA, G7 vo Francúzsku rieši Irán a Ukrajinu, EÚ s Austráliou spojili obchod s obranou
- **Číslo dňa:** 700 miliónov ľudí na trhu EÚ–Mercosur od 1. mája
- **Tento týždeň:** Deň divadla, Hodina Zeme, začiatok letného času
- **Slovo dňa:** `Safeguard`

**Skripty spustené:**
- `update-market-snapshot.ps1` — OK, s warningom pri Finnhub fallbacku pre EUR/USD; výstup zapísaný
- `update-weather-snapshot.ps1` — OK
- `check-issue-overlap.ps1` — OK po obsahovom preformulovaní sekcií
- `prepare-brevo-email.ps1` — OK, výstup `emails/58-brevo.html`
- `generate-podcast-txt.py` — OK, výstup `vydania/58/issue-58-podcast.txt`

---

## 2026-03-25 - Tento týždeň ordering rule

### Closest date first is mandatory

**Subory:** `vydania/56/index.html`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Fixed the `Tento týždeň` order in issue `#56` and made the rule explicit in the docs.

- issue `#56` now lists the calendar items in chronological order: 25. 3. -> 29. 3. -> 31. 3.
- the workflow docs now treat nearest-to-furthest ordering as a required final check before publishing
- the design spec now says calendar items must never be reordered by perceived importance

---

## 2026-03-25 - Podcast top block

### Spotify top embed + swappable episode target

**Subory:** `vydania/56/index.html`, `update-podcast-embed.ps1`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Added the first web-only Spotify podcast block to issue `#56`.

- final shipped order is: masthead -> markets -> Spotify block -> cold open
- final shipped version is compact: no text, no badge, no CTA button
- background fades from the markets cream into the normal issue paper
- embedded player starts on the Spotify show and can later switch to a specific episode

New helper script:

- `update-podcast-embed.ps1`
- accepts a Spotify show or episode URL
- updates the latest issue by default, or a specific issue via `-Path`
- changes only the embedded player target

---

## 2026-03-25 — Vydanie #56

### Issue #56 — Slovensko žaluje Úniu (Streda, 25. marca 2026)

**Súbory:** `vydania/56/index.html`, `vydania/56/sources.md`, `emails/56-brevo.html`, `issues.js`, `index.html`, `archiv/index.html`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Vydaných päť sekcií, všetky skripty spustené, no overlap, commit a push:

- **Hlavná téma:** Fico podal žalobu na EÚ Court pre nariadenie RePowerEU (zákaz ruského plynu) — tvrdí, že rozhodnutie bolo prijaté obchádzaním jednomyseľnosti; podobná žaloba v príprave aj v Maďarsku.
- **Prehliadka správ (4 položky):** Slovenská inflácia február 2026 (3,7 %), hlasovanie EP o dohode Turnberry EÚ–USA, prímerí pre ukrajinskú energetiku, maďarské voľby 12. apríla.
- **Číslo dňa:** 38 rokov od Sviečkovej manifestácie (25. 3. 1988) — príbeh s pašovaním správy cez svokrú.
- **Tento týždeň (3 položky):** 69. výročie Rímskych dohôd (25. 3. 1957), Medzinárodný deň klavíra 29. 3., termín daňového priznania SR 31. 3.
- **Slovo dňa:** *locus standi* — latinský právnický termín (miesto na státie) bez priameho slovenského ekvivalentu; relevantné k žalobe Slovenska na EÚ Court.

**Skripty spustené:**
- `update-market-snapshot.ps1` — OK (EUR/USD Finnhub fallback zlyhalo na PS5, Yahoo Finance použité)
- `update-weather-snapshot.ps1` — OK; CONSULT flag pre 27. 3. (Košice 15°, Poprad 6°), posúdené ako normálna regionálna variácia
- `check-issue-overlap.ps1` — prešiel (po 3 iteráciách opráv)
- `prepare-brevo-email.ps1` — OK, výstup `emails/56-brevo.html`

**Žiadne zmeny vo workflow oproti predchádzajúcemu vydaniu.**

---

## 2026-03-21 - Session 2

### Issue #48 publish and historical weather backfill

**Subory:** `vydania/48/index.html`, `vydania/48/sources.md`, `emails/48-brevo.html`, `issues.js`, `index.html`, `archiv/index.html`, `update-weather-snapshot.ps1`, `how-we-do-ranna-sprava.md`, `CHANGELOG.md`

Published the missing March 16, 2026 issue as `#48` and wired it into the website archive.

- added the standalone issue page for `Pondelok, 16. marca 2026`
- added the issue metadata to `issues.js`
- regenerated the Brevo export for issue `#48`
- versioned the `issues.js` script include on the home page and archive page to avoid stale cached issue lists

Also fixed the weather build flow for archive backfills:

- `update-weather-snapshot.ps1` now uses historical Open-Meteo data for past issue dates instead of forecast-only output
- the workflow docs now record that backdated issues must still get a full Slovakia weather snapshot

---

## 2026-03-21 - Session 1

### Share modal Slovak diacritics

**Subory:** `share.js`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

The website share modal copy now uses proper Slovak diacritics instead of ASCII fallbacks.

- `Zdieľaj vydanie`
- `Vyber si, ako chceš odkaz poslať ďalej.`
- `Skopírovať odkaz`
- `Otvoriť vydanie`
- `Poslať emailom`
- `Ranná Správa`
- `Ak kopírovanie zlyhá, odkaz hore si môžeš označiť a skopírovať ručne.`

The docs now also explicitly require correct Slovak diacritics in all visible share-modal text.

---

### Inline source links and Slovakia relevance

**Subory:** `vydania/52/index.html`, `vydania/52/sources.md`, `ranna-sprava-gold.html`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Issue `#52` now demonstrates the new sourcing pattern inside the article text itself:

- only a few inline source links across the whole issue
- direct links to the underlying report, not vague attributions
- links used where the user may want to read further

The editorial rule is now documented for future issues:

- keep `sources.md` as the full fact-check file
- use only `2` to `4` inline source links per issue
- prefer stories with clear Slovak or regional relevance
- keep `Číslo dňa` relevant to Slovak readers

Issue `#52` also replaces the Oscars-based `Číslo dňa` with the Slovakia-relevant repatriation count of `811` people.

---

### Duplicate-story guardrail and overlap checker

**Subory:** `check-issue-overlap.ps1`, `vydania/52/index.html`, `vydania/52/sources.md`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Added a real anti-duplication workflow for issue writing.

- New script: `check-issue-overlap.ps1`
- It scans `Hlavná téma`, every `Prehliadka správ` item, `Číslo dňa`, and `Tento týždeň`
- It fails if the same story or topic signature appears across sections that should stay unique
- The AI now has to run this check before an issue is considered done

Issue `#52` was also cleaned up to match the new rule:

- removed the duplicated repatriation item from `Prehliadka správ`
- kept repatriation in `Číslo dňa`
- removed the repeated Hungary-election note from `Tento týždeň`

---

### Slovak wording cleanup

**Subory:** `issues.js`, `vydania/51/index.html`, `vydania/52/index.html`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Cleaned up a few Slovak wording inconsistencies and documented the rule for future issues.

- `diplomatia` -> `diplomacia`
- `Druzhba` -> `Družba`
- `ropovod Druzhba` -> `ropovod Družba`

The docs now explicitly require Slovak wording for these forms.

---

### Slovak dictionary and grammar check

**Subory:** `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

The workflow docs now explicitly require a final Slovak-language sanity check before an issue is treated as finished.

- wording must match standard Slovak dictionary usage
- grammar must be checked against standard Slovak forms
- doubtful forms should be verified in a dictionary or language reference before publishing

---

### Issue audio generator prototype

**Subory:** `generate-issue-audio.py`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Added a reusable issue-audio generator that turns issue HTML into a Slovak MP3 draft.

- command: `python .\generate-issue-audio.py .\vydania\[cislo]\index.html`
- current implementation uses Google `gTTS`
- outputs an MP3 plus the narration text file next to the issue
- meant as a local build artifact unless the user explicitly wants it published

---

## 2026-03-20 - Session 1

### Documentation backfill for recent pushes

**Subory:** `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`, `CHANGELOG.md`

Added the missing documentation for the recent newsletter and issue-template changes. This now explicitly records that every future "commit and push" must also include Markdown doc updates in the same push.

**Documented rules added:**

- `prepare-brevo-email.ps1` is part of the issue build flow and must be run by the AI, not the user
- Brevo export output lives in `emails/[issue-number]-brevo.html`
- Footer links are `Archiv`, `Web`, `Zdielaj`; `Kontakt` and `Spravovat preferencie` stay removed
- Website `Zdielaj` opens the share page in an overlay above the issue content
- Email `Zdielaj` links to `https://rannasprava.sk/share/index.html?issue=[cislo]`
- Weather day labels use 2-letter Slovak abbreviations
- Typography must stay identical between issues unless the user explicitly asks for a design change

---

### Newsletter email exports

**Commit backfilled:** `954bcd7` - `Prepare newsletter email exports`

**Subory:** `prepare-brevo-email.ps1`, `emails/*.html`

The project now generates Brevo-ready email HTML from each issue page instead of hand-maintaining a second version. The export keeps the real issue URL in the masthead helper link, points footer links to the live site, and uses Brevo unsubscribe placeholders.

---

### Weather day labels shortened

**Commit backfilled:** `53c0ea7` - `Shorten weather day labels`

Weather forecast day labels were standardized to the 2-letter Slovak format used across the project:

- `Po`, `Ut`, `St`, `Št`, `Pi`, `So`, `Ne`

This applies both to the issue HTML and the Brevo export copies.

---

### Issue 50 typography alignment

**Commit backfilled:** `321f153` - `Align issue 50 typography`

Issue `#50` had drifted from issue `#49` in font sizing, weights, and spacing. The issue HTML and matching Brevo export were normalized so typography stays identical between issues.

---

### Share page and overlay behavior

**Commit backfilled:** `230c7a0` - `Add share page and copy links`

**Subory:** `share.js`, `share/index.html`, issue footers, Brevo export

Implemented the first share flow:

- On website issue pages, `Zdielaj` opens the share page
- In the current version, website issues open that share page inside an overlay iframe
- In email HTML, `Zdielaj` is a normal link to the same share page
- Share destinations are handled by `share/index.html`

---

### Share modal close behavior and inline modal update

**Subory:** `share.js`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`

The website share popup was changed from an iframe-style overlay into a real in-page modal. This makes close behavior reliable and keeps the user inside the issue page.

- Clicking outside the panel closes the modal
- Pressing `Escape` closes the modal
- The popup content is rendered directly in-page instead of loading a mini website inside an iframe
- Email `Zdielaj` still links to `share/index.html`

---

### Share modal no longer falls into native share sheet

**Subory:** `share.js`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`

The website share button now always opens the in-page modal. It no longer switches to the browser or device native share sheet, which could make the share popup appear to vanish instead of staying open on the page.

---

### Share modal close behavior hardened

**Subory:** `share.js`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`

The website share modal now uses explicit show/hide state instead of relying on the `hidden` attribute, and the close button label is `Zavrieť`.

- Outside click closes the modal
- `Escape` closes the modal
- The `Zavrieť` button closes the modal

---

## 2026-03-19 — Session 3

### Weather snapshot — `update-weather-snapshot.ps1` (nový script)

**Súbory:** `update-weather-snapshot.ps1`, `vydania/50/index.html`, `design-and-structure-spec.md`, `how-we-do-ranna-sprava.md`

Nový build-time script pre počasie — rovnaká architektúra ako `update-market-snapshot.ps1`.

**Zdroje (fallback chain):**

| Zdroj | Endpoint | API kľúč | Počet dní |
|---|---|---|---|
| Open-Meteo | `api.open-meteo.com/v1/forecast` | žiadny | 8 dní |
| wttr.in | `wttr.in/Bratislava?format=j1` | žiadny | 3 dni |

**Čo script robí:**
- Číta dátum vydania z `mast-date-bar` v HTML
- Fetchuje 8-dňovú predpoveď z Open-Meteo pre Bratislavu (lat 48.1486, lon 17.1077)
- Nájde index zodpovedajúci dátumu vydania v poli predpovede
- `wval-today-temp` + `wval-today-cond` = podmienky pre deň doručenia
- `wval-d1-*` … `wval-d5-*` = nasledujúcich 5 dní (začína zajtrajškom)
- WMO weather codes → emoji (ConvertFromUtf32, surrogate-pair safe) + slovenský popis

**PS5 compatibility fixes aplikované:**
- Emoji cez `[System.Char]::ConvertFromUtf32()` — žiadne literal surrogate pairs
- Slovenské diakritiká cez `[char]0xXXXX` premenné — žiadne literal non-ASCII v script source
- `ReadAllText` / `WriteAllText` s UTF-8 no-BOM encodingom

**Weather IDs (povinné v každom vydaní):**
`wval-today-temp`, `wval-today-cond`, `wval-d1-icon/name/temp/rain` … `wval-d5-icon/name/temp/rain`

**Spustenie:**
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\update-weather-snapshot.ps1 vydania\[cislo]\index.html
```

Testované na vydaní #50 — Open-Meteo zdroj použitý úspešne, všetky hodnoty zapísané.

---

## 2026-03-19 — Session 2

### Masthead date bar — switched to Anton 17px

**Súbory:** `vydania/48`, `49`, `50`, `492` index.html, `design-and-structure-spec.md`

After live font comparison (Playfair Display → Barlow Condensed → Anton), Anton was selected.
Anton is a single-weight display face — chunky, punchy, high contrast. Used at 17px with `font-weight: 400` (Anton has only one weight).

| Property | Barlow Condensed (prev) | Anton (final) |
|---|---|---|
| `font-family` | `'Barlow Condensed', sans-serif` | `'Anton', sans-serif` |
| `font-size` | `18px` | `17px` |
| `font-weight` | `900` | `400` (single-weight font) |
| `letter-spacing` | `2px` | `2px` |

Google Fonts import updated in all 4 issues — Barlow Condensed removed, Anton added.

---

### Markets ticker — colored arrows inline with USD price

**Súbory:** `update-market-snapshot.ps1`, `design-and-structure-spec.md`, `vydania/50/index.html`

The `market-chg` second line previously showed EUR conversion values. Now:

- **`market-val` (first line):** USD price with a colored arrow inline after the `$`
  - `71 246 $ ▼` — arrow rendered as `<span style="color:#BF3A0A;font-size:11px">▼</span>`
- **`market-chg` (second line):** percentage change only, no duplicate arrow
  - `-3.62%` — still colored green/red via `.up`/`.dn` CSS class

One arrow per ticker. USD line only. The arrow color matches the direction:
- ▲ green `#2D7A3A` = up
- ▼ red `#BF3A0A` = down

Data source: live API call via `update-market-snapshot.ps1` at issue build time.

---

### `update-market-snapshot.ps1` — PowerShell 5.x compatibility fixes

**Súbor:** `update-market-snapshot.ps1`

Several bugs introduced by PS7-only syntax, fixed for Windows PowerShell 5.1:

| Bug | Fix |
|---|---|
| `$($var:yyyy-MM-dd)` format operator (PS7 only) | Replaced with `$($var.ToString('yyyy-MM-dd'))` |
| `Set-Content -Encoding UTF8` adds BOM, corrupts Slovak chars | Replaced with `[System.IO.File]::WriteAllText($path, $content, $Utf8NoBom)` |
| `Get-Content -Raw` reads UTF-8 files as ANSI (Windows-1252) | Replaced with `[System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)` |
| Literal `▲▼` in script body corrupted when script read as ANSI | Replaced with `[char]0x25B2` / `[char]0x25BC` |
| `✓` emoji in `Write-Host` caused parse error after CRLF conversion | Replaced with plain text `OK: Done` |

**Confirmed working on Windows PowerShell 5.1** — run with:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\update-market-snapshot.ps1 vydania\50\index.html
```

---

### Market data API — Finnhub fallback bug (Finnhub crypto/forex candles)

**Súbor:** `update-market-snapshot.ps1`

Finnhub crypto and forex candle endpoints are failing with a `[datetime]::new()` constructor error on PS5.x (`"Utc"` passed as millisecond argument). Root cause: `DateToUnix` uses `[datetime]::new(1970,1,1,0,0,0,'Utc')` which PS5 doesn't resolve the `DateTimeKind` enum string correctly in that overload.

**Workaround:** BTC and EUR/USD automatically fall through to Yahoo Finance (no API key needed), which works correctly. URTH falls through to Yahoo when Alpha Vantage daily limit is hit.

**Status:** Script runs cleanly with warnings — all 5 tickers populate via fallback sources.

---

## 2026-03-19 — Session 1

### Archív — oprava načítavania vydaní

**Súbor:** `archiv/index.html`

- Cesta k `issues.js` zmenená z `/issues.js` (absolútna) na `../issues.js` (relatívna).
- Dôvod: absolútna cesta nefungovala pri GitHub Pages ak doména nemá root `/`.
- Archív teraz správne zobrazuje všetky vydania.

---

### `issues.js` — oprava syntaktickej chyby + vydanie #50

**Súbor:** `issues.js`

- Pridaný záznam pre vydanie #50 (*Orbán prišiel do Bruselu. A priniesol si „nie".*).
- Opravená syntaktická chyba: vnútorná úvodzovka `"` v titulku vydania #50 nebola escapovaná — `"nie"` → `"nie\"`. Spôsobila, že sa celé pole `ISSUES` nesparsovalo a archív zobrazoval nulu vydaní.

---

### Masthead date bar — typografický upgrade (iterácia)

**Finálny stav:** Anton 17px (pozri Session 2 vyššie)

Postup:
1. `Lora 800 14px` → `Playfair Display 900 16px` (prvý upgrade)
2. Živé porovnanie 14 fontov v kontexte date baru
3. `Playfair Display 900 16px` → `Barlow Condensed 900 18px`
4. `Barlow Condensed 900 18px` → **`Anton 400 17px`** (finál)

---

### `update-market-snapshot.ps1` — kompletný prepis (Finnhub-first)

Pôvodný script používal výlučne Alpha Vantage (limit 25 volaní/deň). Nový script:

| Ticker | Primárny | Fallback 1 | Fallback 2 |
|---|---|---|---|
| Bitcoin | Finnhub `/crypto/candle` (BINANCE:BTCUSDT) | Yahoo Finance (BTC-USD) | — |
| S&P 500 | Finnhub `/quote` (SPY) | Yahoo Finance | Alpha Vantage |
| EUR/USD | Finnhub `/forex/candle` (OANDA:EUR_USD) | Yahoo Finance (EURUSD=X) | Alpha Vantage |
| MSCI World | Alpha Vantage URTH* | Yahoo Finance | — |
| Zlato | Finnhub `/quote` (GLD) | Yahoo Finance | Alpha Vantage |

*URTH vyžaduje Finnhub premium — Alpha Vantage zostáva primárnym zdrojom.

**API kľúče:**

| Kľúč | Hodnota | Použitie |
|---|---|---|
| `$FinnhubKey` | `d58jgm1r01qvj8ih0ttgd58jgm1r01qvj8ih0tu0` | Primárny (BTC, SPY, EUR/USD, GLD) |
| `$AlphaKey` | `5FYB9ODD1KU6SWDQ` | URTH + fallback |
| Yahoo Finance | bez kľúča | Ultimátny fallback |

---

### Súbory dokumentácie

| Súbor | Zmena |
|---|---|
| `CHANGELOG.md` | Vytvorený — záznam všetkých zmien |
| `design-and-structure-spec.md` | Aktualizovaný: mast-date-bar CSS, markets HTML block (▲/▼ % namiesto EUR) |
| `how-we-do-ranna-sprava.md` | Aktualizovaná markets sekcia — nová tabuľka zdrojov, API kľúče |
| `font-preview.html` | Dočasný súbor na porovnanie fontov (možno zmazať) |

---

*Verzia 2026-03-19 Session 2*
