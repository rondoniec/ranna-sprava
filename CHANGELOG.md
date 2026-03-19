# Changelog

---

## 2026-03-19

### Archív — oprava načítavania vydaní

**Súbor:** `archiv/index.html`

- Cesta k `issues.js` zmenená z `/issues.js` (absolútna) na `../issues.js` (relatívna).
- Dôvod: absolútna cesta nefungovala pri otvorení cez `file://` protokol ani pri GitHub Pages ak doména nemá root `/`.
- Archív teraz správne zobrazuje všetky vydania.

---

### `issues.js` — oprava syntaktickej chyby + vydanie #50

**Súbor:** `issues.js`

- Pridaný záznam pre vydanie #50 (*Orbán prišiel do Bruselu. A priniesol si „nie".*).
- Opravená syntaktická chyba v titulku vydania #50: vnútorná úvodzovka `"` v reťazci ohraničenom `"..."` nebola escapovaná — `"nie"` → `"nie\"`. Táto chyba spôsobila, že sa celé pole `ISSUES` nesparsovalo a archív zobrazoval nulu vydaní.

---

### Masthead date bar — typografický upgrade

**Súbory:** `vydania/48/index.html`, `vydania/49/index.html`, `vydania/50/index.html`, `vydania/492/index.html`, `design-and-structure-spec.md`

| Vlastnosť | Pred | Po |
|---|---|---|
| `font-family` | `'Lora', serif` | `'Playfair Display', serif` |
| `font-size` | `14px` | `16px` |
| `font-weight` | `800` | `900` |
| `letter-spacing` | `1.5px` | `2px` |
| `text-transform` | `uppercase` | `uppercase` (nezmenené) |

Zlatý date bar teraz používa Playfair Display 900 — výraznejší, ťažší rez, konzistentný s nadpismi v tele vydania.

---

### Markets ticker — percentuálna zmena namiesto EUR prepočtu

**Súbory:** `update-market-snapshot.ps1`, `how-we-do-ranna-sprava.md`, `design-and-structure-spec.md`

Druhý riadok každého market-item (`market-chg`) zobrazuje teraz **percentuálnu zmenu** oproti predchádzajúcemu uzatvoreniu namiesto EUR prepočtu.

- `▲ +1.23%` — zelená (`#2D7A3A`), CSS trieda `up`
- `▼ -0.45%` — červená (`#BF3A0A`), CSS trieda `dn`

CSS triedy `.market-chg.up` a `.market-chg.dn` existovali vo všetkých vydaniach — žiadna zmena HTML/CSS potrebná, len nový obsah zo scriptu.

---

### `update-market-snapshot.ps1` — kompletný prepis

**Súbor:** `update-market-snapshot.ps1`

Pôvodný script používal výlučne Alpha Vantage (limit 25 volaní/deň). Nový script zavádza vrstvený fallback:

#### Zdroje podľa tickera

| Ticker | Primárny | Fallback 1 | Fallback 2 |
|---|---|---|---|
| Bitcoin | Finnhub `/crypto/candle` (BINANCE:BTCUSDT) | Yahoo Finance (BTC-USD) | — |
| S&P 500 | Finnhub `/quote` (SPY) | Yahoo Finance (SPY) | Alpha Vantage |
| EUR/USD | Finnhub `/forex/candle` (OANDA:EUR_USD) | Yahoo Finance (EURUSD=X) | Alpha Vantage |
| MSCI World | Alpha Vantage `URTH`* | Yahoo Finance (URTH) | — |
| Zlato | Finnhub `/quote` (GLD) | Yahoo Finance (GLD) | Alpha Vantage |

*URTH nie je dostupný na Finnhub free tiere — Alpha Vantage zostáva primárnym zdrojom.

#### Kľúčové zmeny oproti pôvodnému scriptu

- **Finnhub** je teraz primárny zdroj pre 4 z 5 tickerov. Free tier: 60 volaní/min, bez denného limitu.
- **`/quote` endpoint** (SPY, GLD) vracia `c` (close) a `pc` (predchádzajúci close) v jednom volaní — žiadna historická séria, žiadne date-matching.
- **`/crypto/candle`** a **`/forex/candle`** (BTC, EUR/USD) fetchujú posledných 7 dní a berú posledné dve uzatvorenia.
- **Yahoo Finance** funguje ako tichý fallback bez API kľúča — endpoint `query1.finance.yahoo.com/v8/finance/chart/{symbol}`. Každý failed pokus vypíše `[WARNING]` do konzoly.
- **`Format-Pct`** teraz generuje `▲`/`▼` (plné trojuholníky) namiesto `↑`/`↓`.
- **Cache** funguje rovnako — jeden JSON súbor v `$env:TEMP`, platný jeden deň. Kľúče cache sú namespace-ované podľa zdroja (`fh-quote-SPY`, `av-stock-URTH`, `yahoo-GLD-20260318`).

#### Spustenie

```powershell
# Jedno konkrétne vydanie
powershell -ExecutionPolicy Bypass -File .\update-market-snapshot.ps1 vydania\50\index.html

# Všetky vydania naraz
powershell -ExecutionPolicy Bypass -File .\update-market-snapshot.ps1
```

---

*Verzia 2026-03-19*
