# How We Do Ranná Správa

## Operating model

- Site is a single-page app in `index.html` in `rondoniec/ranna-sprava`.
- New issues are added as objects in `const ISSUES = [...]`.
- Newest issue goes at the top of the array.
- Publishing flow: edit `index.html` → commit → push to `main` → GitHub Pages updates.

## Content & formatting rules

- Keep the existing site design system unless explicitly requested otherwise.
- Issue body supports Markdown and selected HTML blocks already wired in reader styles.
- If custom visual elements are needed, add compatible reader styles first, then content.

## Quality checks before push

1. Confirm issue number/date/title/preview/tags
2. Confirm issue appears in Home, Archive, and Reader views
3. Confirm no duplicate/accidental content overwrite
4. Push and verify public page source includes the new issue number

## Markets ticker — Alpha Vantage build snapshot

Market data is written into the issue HTML at build time by `update-market-snapshot.ps1`. Published issue pages do not fetch market data in the browser.

**5 tickers shown in every vydanie (pracovne dni):**

| Ticker | Source | HTML output |
|---|---|---|
| Bitcoin | `DIGITAL_CURRENCY_DAILY BTC/USD` | USD main line + EUR secondary line |
| S&P 500 | `TIME_SERIES_DAILY SPY` | USD main line + EUR secondary line |
| EUR/USD | `FX_DAILY EUR/USD` | USD main line + EUR secondary line |
| MSCI World | `TIME_SERIES_DAILY URTH` | USD main line + EUR secondary line |
| Zlato | `TIME_SERIES_DAILY GLD` proxy | USD main line + EUR secondary line |

**Ako to funguje:**

- Script cita datum vydania z issue HTML.
- Pre kazdy ticker vezme posledny dostupny close ku dnu pred vydanim.
- Ak je vikend alebo sviatok, pouzije posledny dostupny market close.
- `market-val` obsahuje USD hodnotu.
- `market-chg` obsahuje EUR prepocet tej istej hodnoty.
- `markets.js` je zamerne prazdny, aby otvorenie issue uz nikdy nevolalo API.

**Pri tvorbe noveho vydania:**

- V HTML markets sekcii pouzi vzdy rovnake IDs: `mval-btc`, `mchg-btc`, `mval-spy`, `mchg-spy`, `mval-eurusd`, `mchg-eurusd`, `mval-msci`, `mchg-msci`, `mval-gold`, `mchg-gold`
- Spusti `powershell -ExecutionPolicy Bypass -File .\update-market-snapshot.ps1 vydania\[cislo]\index.html`
- Pracovne dni: blok viditelny, script ho vyplni statickymi hodnotami
- Vikend / sviatok: cely `.markets` blok zakomentovat `<!-- -->`

**API key:** ulozeny priamo v `update-market-snapshot.ps1`.

## Publishing flow (updated)

1. Vytvor `vydania/[číslo]/index.html` podľa design-and-structure-spec.md
2. Pridaj issue objekt do `issues.js` (číslo, title, date, dateLabel, preview, tags)
3. Markets HTML: 5 div.market-item s IDs, potom spusti `update-market-snapshot.ps1` pre konkretne vydanie
4. Commit → push to `main` → GitHub Pages sa aktualizuje

## Notes

- GitHub Pages can be cached; use hard refresh or query param (`?v=...`) when verifying.
- Keep commit messages explicit (`Add Vydanie #X`, `Restore exact text`, etc.).
- Git default branch: `main` (master removed March 2026).

## To-do

- Add the same build-time static snapshot step for weather, not just markets.
