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

## Markets ticker — Finnhub API

Live market data is fetched client-side by `/markets.js` using the Finnhub API.

**5 tickers shown in every vydanie (pracovné dni):**

| Ticker | Finnhub symbol | Formát |
|---|---|---|
| Bitcoin | `BINANCE:BTCUSDT` | `84 200 $` |
| S&P 500 | `SPY` | `5 638.10` |
| EUR/USD | `OANDA:EUR_USD` | `1.0821` |
| MSCI World | `URTH` | `121.50` |
| Zlato | `OANDA:XAU_USD` | `2 850 $` |

**Ako to funguje:**
- `markets.js` sa načíta pri otvorení každého vydania
- Fetchne aktuálnu cenu a % zmenu z Finnhub quote API
- Aktualizuje elementy podľa `id` atribútov: `mval-btc`, `mchg-btc`, `mval-spy`, atď.
- Ak fetch zlyhá (trhy zatvorené, chyba siete), ostanú pôvodné hodnoty v HTML

**Pri tvorbe nového vydania:**
- V HTML markets sekcii použi vždy rovnaké IDs: `mval-btc`, `mchg-btc`, `mval-spy`, `mchg-spy`, `mval-eurusd`, `mchg-eurusd`, `mval-msci`, `mchg-msci`, `mval-gold`, `mchg-gold`
- Vlož `<script src="../../markets.js"></script>` pred `</body>`
- Pracovné dni: blok viditeľný, API ho vyplní automaticky
- Víkend / sviatok: celý `.markets` blok zakomentovať `<!-- -->`

**API kľúč:** uložený priamo v `markets.js` (Finnhub free tier — client-side kľúč).

## Publishing flow (updated)

1. Vytvor `vydania/[číslo]/index.html` podľa design-and-structure-spec.md
2. Pridaj issue objekt do `issues.js` (číslo, title, date, dateLabel, preview, tags)
3. Markets HTML: 5 div.market-item s IDs, `<script src="../../markets.js"></script>` pred `</body>`
4. Commit → push to `main` → GitHub Pages sa aktualizuje

## Notes

- GitHub Pages can be cached; use hard refresh or query param (`?v=...`) when verifying.
- Keep commit messages explicit (`Add Vydanie #X`, `Restore exact text`, etc.).
- Git default branch: `main` (master removed March 2026).
