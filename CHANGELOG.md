# Changelog

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
