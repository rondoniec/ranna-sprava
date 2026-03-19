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

## Masthead date bar font

`Anton`, 17px, `font-weight: 400` (single-weight display face). Google Fonts import required in every issue: `family=Anton`.

---

## Markets ticker — build snapshot (Finnhub + Alpha Vantage + Yahoo fallback)

Market data is written into the issue HTML at build time by `update-market-snapshot.ps1`. Published issue pages do not fetch market data in the browser. `markets.js` is intentionally empty.

**5 tickers shown in every vydanie (pracovne dni):**

| Ticker | Primary source | Fallback 1 | Fallback 2 |
|---|---|---|---|
| Bitcoin | Finnhub `/crypto/candle` (BINANCE:BTCUSDT) | Yahoo Finance (BTC-USD) | — |
| S&P 500 | Finnhub `/quote` (SPY) | Yahoo Finance (SPY) | Alpha Vantage |
| EUR/USD | Finnhub `/forex/candle` (OANDA:EUR_USD) | Yahoo Finance (EURUSD=X) | Alpha Vantage |
| MSCI World | Alpha Vantage `TIME_SERIES_DAILY URTH`* | Yahoo Finance (URTH) | — |
| Zlato | Finnhub `/quote` (GLD) | Yahoo Finance (GLD) | Alpha Vantage |

*URTH requires Finnhub premium — Alpha Vantage is primary for this ticker.

**Ako to funguje:**

- Script číta dátum vydania z issue HTML.
- Pre každý ticker vezme posledný dostupný close ku dňu pred vydaním.
- Ak je víkend alebo sviatok, použije posledné dostupné obchodné uzatvorenie.
- `market-val` obsahuje USD hodnotu.
- `market-chg` obsahuje percentuálnu zmenu oproti predchádzajúcemu uzatvoreniu — zelená ▲ alebo červená ▼.
- Fallback chain sa spustí automaticky ak primárny zdroj zlyhá; každý krok vypíše `[WARNING]` do konzoly.

**Pri tvorbe nového vydania:**

- V HTML markets sekcii použi vždy rovnaké IDs: `mval-btc`, `mchg-btc`, `mval-spy`, `mchg-spy`, `mval-eurusd`, `mchg-eurusd`, `mval-msci`, `mchg-msci`, `mval-gold`, `mchg-gold`
- Spusti `powershell -ExecutionPolicy Bypass -File .\update-market-snapshot.ps1 vydania\[cislo]\index.html`
- Pracovné dni: blok viditeľný, script ho vyplní statickými hodnotami
- Víkend / sviatok: celý `.markets` blok zakomentovať `<!-- -->`

**API kľúče** (uložené priamo v `update-market-snapshot.ps1`):

| Kľúč | Hodnota | Použitie |
|---|---|---|
| `$FinnhubKey` | `d58jgm1r01qvj8ih0ttgd58jgm1r01qvj8ih0tu0` | Primárny zdroj (BTC, SPY, EUR/USD, GLD) |
| `$AlphaKey` | `5FYB9ODD1KU6SWDQ` | URTH (MSCI World) + fallback |
| Yahoo Finance | bez kľúča | Ultimátny fallback pre všetky tickery |

## Publishing flow (updated)

1. Vytvor `vydania/[číslo]/index.html` podľa design-and-structure-spec.md
2. Pridaj issue objekt do `issues.js` (číslo, title, date, dateLabel, preview, tags)
3. Markets HTML: 5 div.market-item s IDs, potom spusti `update-market-snapshot.ps1` pre konkretne vydanie
4. Commit → push to `main` → GitHub Pages sa aktualizuje

## Notes

- GitHub Pages can be cached; use hard refresh or query param (`?v=...`) when verifying.
- Keep commit messages explicit (`Add Vydanie #X`, `Restore exact text`, etc.).
- Git default branch: `main` (master removed March 2026).

## Weather snapshot — build snapshot (Open-Meteo + wttr.in fallback)

Weather data is written into the issue HTML at build time by `update-weather-snapshot.ps1`. Published issue pages do not fetch weather in the browser.

**Source:**

| Zdroj | Endpoint | Fallback |
|---|---|---|
| Open-Meteo | `api.open-meteo.com/v1/forecast` (bez kľúča) | wttr.in |
| wttr.in | `wttr.in/Bratislava?format=j1` (bez kľúča) | — |

**Súradnice:** Bratislava — lat `48.1486`, lon `17.1077` (reprezentatívne pre Slovensko)

**Ako to funguje:**

- Script číta dátum vydania z HTML (mast-date-bar)
- Fetches 8-day forecast z Open-Meteo pre Bratislavu
- Finds the array index matching issue date
- `wval-today-*` = conditions for the issue delivery date
- `wval-d1-*` through `wval-d5-*` = next 5 days (starting tomorrow from delivery date)
- WMO weather codes → emoji + Slovak description (built from char codes, no literal diacritics in script)
- Fallback: wttr.in (3 days only; days 4–5 show `...` placeholder if primary fails)

**Pri tvorbe nového vydania:**

- V HTML weather sekcii použi vždy rovnaké IDs: `wval-today-temp`, `wval-today-cond`, `wval-d1-icon`, `wval-d1-name`, `wval-d1-temp`, `wval-d1-rain` … `wval-d5-*`
- Spusti: `powershell -ExecutionPolicy Bypass -File .\update-weather-snapshot.ps1 vydania\[cislo]\index.html`
- Script automaticky nájde správny deň v predpovedi podľa dátumu vydania

**API kľúče:** žiadne — oba zdroje sú úplne zadarmo bez registrácie.
