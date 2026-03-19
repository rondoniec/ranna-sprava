# Changelog

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
