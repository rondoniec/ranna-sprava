# Ranná Správa — HTML Formatting & Content Guide

_Odvodené priamo z vydania #48. Pošli tento súbor AI spolu s redakčnou príručkou pri každom novom vydaní._

Output: HTML File

---

## Farby a typografia

|Premenná|Hodnota|Použitie|
|---|---|---|
|Tmavá|`#1A1208`|Masthead BG, text, orámovanie, footer|
|Zlatá|`#C8962A`|Box-shadow, akcenty, sekcie, puntíky|
|Krémová BG|`#F0EAE0`|Pozadie stránky, markets strip|
|Paper (obsah)|`#FAFAF7`|Vnútro wrap kontajnera|
|Muted text|`#5A4E3F`|Body text v sekciách|
|Šedá linka|`#D4C9B8`|Dashed oddeľovače|
|Jemná linka|`#E8E0D4`|Solid oddeľovače vnútri sekcií|

**Fonty:**

- `Playfair Display` — nadpisy, čísla, slovo dňa, masthead názov
- `Lora` — body text, sekcie, footer, meniny
- `IBM Plex Mono` — market ticker values and changes (monospace for aligned numerals)

**Rule of consistency:**

- This file is the typography source of truth for every issue.
- Do not introduce issue-specific font changes unless the user explicitly asks for them.
- Font family, size, weight, spacing, and casing should stay identical between issues.

**Importuj z Google Fonts:**

```
Playfair Display: ital,wght@0,700;0,900;1,400;1,700
Lora: ital,wght@0,400;0,600;1,400
IBM Plex Mono: wght@400;500;600
```

---

## Obal stránky

```css
.wrap {
  max-width: 620px;
  margin: 32px auto;
  background: #FAFAF7;
  border: 1.5px solid #1A1208;
  box-shadow: 6px 6px 0 #C8962A;   /* zlatý tieň — charakteristický prvok */
  /* padding-bottom zámerne vynechaný — footer sedí flush na konci */
}

/* Date bar — Anton 17px: single-weight display face, chunky and punchy */
.mast-date-bar {
  background: #C8962A;
  color: #1A1208;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 20px;
  font-family: 'Anton', sans-serif;
  font-size: 17px;
  font-weight: 400;   /* Anton is single-weight — 400 = its only weight */
  text-transform: uppercase;
  letter-spacing: 2px;
}
```

Maximálna šírka je **620px**. Nikdy nerozširovať.

---

## Povinné `<head>` elementy každého vydania

Každý `vydania/[cislo]/index.html` musí mať tieto elementy v `<head>` (tesne pred `</head>`):

1. **`<title>`** — formát: `Ranná Správa – Vydanie #[číslo] – [D. mesiaca YYYY]`
2. **`NewsArticle` JSON-LD** — povinné pre SEO/GEO, bez toho AI crawlery nedokážu identifikovať stránku ako novinový článok. Šablóna (vyplň `[cislo]`, `[YYYY-MM-DD]`, `[hlavný nadpis]` = `story-hed` z Hlavnej témy):

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "NewsArticle",
      "@id": "https://rannasprava.sk/vydania/[cislo]/#article",
      "headline": "[hlavný nadpis príbehu]",
      "name": "Ranná Správa — Vydanie #[cislo]",
      "url": "https://rannasprava.sk/vydania/[cislo]/",
      "datePublished": "[YYYY-MM-DD]",
      "inLanguage": "sk",
      "isPartOf": { "@id": "https://rannasprava.sk/#website" },
      "publisher": { "@id": "https://rannasprava.sk/#organization" },
      "author": { "@id": "https://rannasprava.sk/#organization" }
    },
    {
      "@type": "Organization",
      "@id": "https://rannasprava.sk/#organization",
      "name": "Ranná Správa",
      "url": "https://rannasprava.sk"
    },
    {
      "@type": "WebSite",
      "@id": "https://rannasprava.sk/#website",
      "url": "https://rannasprava.sk",
      "name": "Ranná Správa"
    },
    {
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Domov", "item": "https://rannasprava.sk/" },
        { "@type": "ListItem", "position": 2, "name": "Archív", "item": "https://rannasprava.sk/#archiv" },
        { "@type": "ListItem", "position": 3, "name": "Vydanie #[cislo]", "item": "https://rannasprava.sk/vydania/[cislo]/" }
      ]
    }
  ]
}
</script>
```

---

## Poradie sekcií — presné, nemenné

```
1.  Masthead (čierne pozadie, zlatý date bar)
2.  Markets ticker
3.  Podcast block (voliteľne — compact Spotify embed band, iba po samostatnom pokyne)
4.  Cold open (kurzíva, sivý text)
5.  Počasie (dnešok v tmavom bloku, forecast vpravo)
6.  Hlavná téma (headline + subhedy + BY THE WAY)
7.  Prehliadka správ (3–4 položky)
8.  Číslo dňa (zlatý ľavý blok + tmavý pravý blok)
9.  Tento týždeň / Kalendár (puntíky)
10. Slovo dňa
11. Footer (čierne pozadie)
```

---

## 1. Masthead

**HTML štruktúra:**

```html
<div class="mast">
  <div class="mast-top">Ak sa email nezobrazuje správne, <a href="#">klikni tu</a></div>
  <div class="mast-main">
    <div class="mast-eyebrow">Každé pracovné ráno.</div>
    <span class="mast-title">Ranná<span>Správa</span></span>
    <p class="mast-tagline">Slovensko a svet za 5 minút</p>
  </div>
  <div class="mast-date-bar">
    <span>[Deň], [dátum]</span>
    <a class="mast-share js-share-link"
       href="https://rannasprava.sk/share/index.html?issue=[číslo]"
       data-share-url="https://rannasprava.sk/vydania/[číslo]/">Zdieľaj</a>
    <span>Vydanie #[číslo]</span>
  </div>
</div>
```

**Pravidlá:**

- `mast-title` — celé uppercase, letter-spacing 3px, font-size 56px
- `<span>` vo vnútri názvu — zlatá `#C8962A` (slovo "Správa")
- `mast-date-bar` — zlaté pozadie, tmavý text, flex space-between, Anton 17px, uppercase
- Date and `Vydanie #[cislo]` in the mast-date-bar stay uppercase.
- Eyebrow a tagline — priesvitná biela, uppercase, malé

---

## 1a. Podcast Block (optional)

If used, this block sits **between the markets strip and the cold open**.

**Rules:**

- Current preferred version is the compact one:
  no text, no badge, no CTA button — just the embedded Spotify player
- The embed should fill the content width and stay visually shallow
- The block background should fade from the same cream used by the markets strip into the normal paper background
- New issues ship with **no podcast block by default**
- The Spotify block is added only after the user explicitly provides the episode link or asks for the embed
- If the provided Spotify episode does not clearly match the issue number, do not embed it
- When the episode is confirmed, insert the specific episode directly via `update-podcast-embed.ps1`

---

## 2. Markets Ticker

Zobrazuje sa **v kazdom vydani, aj cez vikend**. Pri sobote alebo nedeli script pouzije posledny piatkovy zaver pre `S&P 500`, `EUR/USD`, `MSCI World` a `Zlato`, prida im `*` a doplni footnote `* piatkový záver trhov`. `Bitcoin` zostava live a bez `*`.

**HTML struktura - staticky market snapshot:**

```html
<!-- MARKETS - static last close snapshot (written at build time) -->
<div class="markets">
  <div class="market-item">
    <div class="market-name">Bitcoin</div>
    <div class="market-val" id="mval-btc">71 245 $ <span style="color:#2D7A3A;font-size:11px">▲</span></div>
    <div class="market-chg up" id="mchg-btc">+1.23%</div>
  </div>
  <div class="market-item">
    <div class="market-name">S&amp;P 500</div>
    <div class="market-val" id="mval-spy">661.43 $ <span style="color:#BF3A0A;font-size:11px">▼</span></div>
    <div class="market-chg dn" id="mchg-spy">-0.45%</div>
  </div>
  <div class="market-item">
    <div class="market-name">EUR/USD</div>
    <div class="market-val" id="mval-eurusd">1.1450 $ <span style="color:#2D7A3A;font-size:11px">▲</span></div>
    <div class="market-chg up" id="mchg-eurusd">+0.31%</div>
  </div>
  <div class="market-item">
    <div class="market-name">MSCI World</div>
    <div class="market-val" id="mval-msci">181.77 $ <span style="color:#BF3A0A;font-size:11px">▼</span></div>
    <div class="market-chg dn" id="mchg-msci">-0.12%</div>
  </div>
  <div class="market-item">
    <div class="market-name">Zlato</div>
    <div class="market-val" id="mval-gold">4 447 $ <span style="color:#2D7A3A;font-size:11px">▲</span></div>
    <div class="market-chg up" id="mchg-gold">+0.88%</div>
  </div>
</div>
```

**Pravidla:**

- Vzdy 5 poloziek: **Bitcoin · S&P 500 · EUR/USD · MSCI World · Zlato**
- IDs su povinne: `mval-btc`, `meur-btc`, `mchg-btc`, `mval-spy`, `meur-spy`, `mchg-spy`, `mval-eurusd`, `meur-eurusd`, `mchg-eurusd`, `mval-msci`, `meur-msci`, `mchg-msci`, `mval-gold`, `meur-gold`, `mchg-gold`
- `market-val` = posledny dostupny close v USD (line 1)
- `market-eur` = ekvivalent v EUR (line 2, muted color `#5A4E3F`)
- `market-chg` = percent zmena oproti predchadzajucemu uzatvoreniu (line 3, colored up/dn)
- Pre EUR/USD: `market-eur` zobrazuje inverzu sadzbu (kolko EUR za 1 USD)
- Hodnoty zapisuje `update-market-snapshot.ps1` pri pisani vydania, nie browser
- AI musi spustit `update-market-snapshot.ps1` pocas tvorby issue a nikdy nema pytat usera, aby script spustal rucne
- Script vyberie posledny dostupny close ku dnu pred vydanim; cez vikend alebo sviatok pouzije posledne dostupne uzatvorenie
- Cez vikend je `Bitcoin` vynimka: ma ostat live 24h snapshot bez hviezdicky, ak CoinGecko uspeje
- Pozadie `#F0EAE0`, border-bottom `1.5px solid #1A1208`

---

## 3. Cold Open

```html
<div class="cold-open">
  [2–3 vety. Kurzíva. Komentár k dátumu, meniny alebo absurdita dňa.]
</div>
```

**CSS:** font-style italic, color `#5A4E3F`, font-weight 300, dashed border-bottom.

**Pravidlá obsahu:**

- Nesúvisí s hlavnou správou
- Komentuje meniny, deň, počasie, alebo nejakú bežnú absurditu
- Znie ako správa od priateľa, nie redakcie
- Nikdy nezačína "Dobré ráno"
- Posledná veta = pointа alebo tichý vtip

---

## 4. Počasie

**HTML struktura - staticky weather snapshot (s IDs pre `update-weather-snapshot.ps1`):**

```html
<div class="weather">
  <div class="weather-city">
    <div class="weather-city-name">Slovensko</div>
    <div class="weather-temp" id="wval-today-temp">3° - 14°</div>
    <div class="weather-cond" id="wval-today-cond">☀️ Ned · Jasno</div>
  </div>
  <div class="weather-days">
    <div class="weather-day">
      <div class="weather-day-icon" id="wval-d1-icon">🌧️</div>
      <div class="weather-day-name" id="wval-d1-name">Po</div>
      <div class="weather-day-temp" id="wval-d1-temp">5° - 10°</div>
      <div class="weather-day-rain" id="wval-d1-rain">35%</div>
    </div>
    <!-- d2, d3, d4, d5 use the same ID pattern -->
  </div>
</div>
```

**IDs pre weather snapshot (povinne - script ich hlada):**

| ID | Obsah |
|---|---|
| `wval-today-temp` | min° - max° pre den vydania |
| `wval-today-cond` | emoji + skratka dna + · + popis |
| `wval-d1-icon` ... `wval-d5-icon` | emoji pre kazdy z 5 forecast dni |
| `wval-d1-name` ... `wval-d5-name` | skratka dna |
| `wval-d1-temp` ... `wval-d5-temp` | min° - max° |
| `wval-d1-rain` ... `wval-d5-rain` | % sanca dazda |

**Pravidla:**

- Weather je pre cele Slovensko, nie pre Bratislavu
- `weather-city-name` ma byt vzdy `Slovensko`
- Script agreguje viac reprezentativnych lokalit po Slovensku a z nich vytvori jednu narodnu predpoved
- Tmavy blok vlavo = den vydania
- Forecast = **nasledujucich 5 dni**, zacina zajtrajskom - dnesok sa neopakuje
- Skratky dni maju byt vzdy **max 2 znaky**: `Po`, `Ut`, `St`, `Št`, `Pi`, `So`, `Ne` — toto plati aj pre den v `wval-today-cond` (napr. `Št`, nie `Štv`)
- Teploty vzdy format `min° - max°`, ale ako narodny priemer, nie extremy z krajiny
- Sanca dazda je narodna agregovana hodnota pre newsletter
- AI musi spustit `update-weather-snapshot.ps1` pocas tvorby issue a nikdy nema pytat usera, aby script spustal rucne
- Ak script vypise `[CONSULT]`, AI sa ma vratit k userovi iba pri extremnom rozdiele v ramci Slovenska, nie pri beznej regionalnej odchylke

---

## 5. Sekcia Label

```html
<div class="sec-label">Hlavná téma</div>
```

Zlatý text, uppercase, malé písmená, za textom zlatá linka (`::after`). Použitie: pred každou sekciou okrem masthead, cold open, počasia a footra.

---

## 6. Hlavná Téma

```html
<div class="story">
  <div class="story-hed">Slovensko ustúpilo. Alebo teda — skoro.</div>

  <p>Prvý odstavec...</p>

  <div class="story-subhed">Rúra, ktorej sa nikto nedotkne</div>
  <p>Ďalší text...</p>

  <ul>
    <li>Položka so zlatou pomlčkou</li>
  </ul>

  <div class="wim">
    <div class="wim-label">BY THE WAY</div>
    <p class="wim-body">Praktický dopad na čitateľa.</p>
  </div>
</div>
```

**Kicker sa už nepoužíva.** Hlavná téma začína priamo headlineom; nepíš tematické štítky ani kategórie typu `Slovensko · Politika`.

**Pravidlá headline:** Playfair 28px, začína straight, skončí s pointou alebo zvratom

**Pravidlá subhedy:** Playfair italic, zlaté, fungujú ako slovná hračka alebo prekvapivý uhol

**Pravidlá zoznamu:** border-top a border-bottom na každej položke, zlatá `—` pred každou položkou (CSS `::before`)

**Pravidlá BY THE WAY boxu:**

- Žlté pozadie `#FFF8E8`
- Zlatý ľavý border `3px solid #C8962A`
- Maximálne 3 vety
- Praktický dopad na čitateľa — nie analýza
- Label uppercase zlatý `BY THE WAY`
- **BY THE WAY nesmie opakovať ani jednu informáciu z tela hlavnej témy.** Je to nová informácia — dôsledok, súvislosť alebo praktický dopad, ktorý v texte ešte nezaznel. Ak je v hlavnej téme uvedené číslo tankerov, BY THE WAY sa o tankeroch nezmieňuje.

---

## 7. Prehliadka Správ

```html
<div class="tour">
  <div class="tour-item">
    <div class="tour-hed">Pellegrini chce armádu v mieri.</div>
    <p>2–4 vety. Posledná = pointa alebo detail navyše.</p>
  </div>
  <!-- ďalšie 2–3 položky -->
</div>
```

**Pravidlá:**

- **Bez emoji** v nadpisoch — len tučný text
- 3–4 položky
- Každá položka má border-bottom okrem poslednej
- Nadpis je veta s bodkou na konci (nie otázka, nie výkrik)
- Každá položka pokrýva **inú tému** ako hlavná téma a číslo dňa
- Všetky správy sú z **posledných 24 hodín**

---

## 8. Číslo Dňa

```html
<div class="stat">
  <div class="stat-left">        ← zlaté pozadie #C8962A
    <div class="stat-num">14</div>
    <div class="stat-unit">rokov</div>
  </div>
  <div class="stat-right">       ← tmavé pozadie #1A1208
    <div class="stat-eyebrow">Číslo dňa</div>
    <div class="stat-label">Popis čísla kurzívou.</div>
    <div class="stat-body">2–3 vety kontextu. <strong>Najdôležitejšia pointa tučným.</strong></div>
  </div>
</div>
```

**Pravidlá:**

- `stat-num` — Playfair 68px, tmavý text na zlatom pozadí
- `stat-unit` — malé, uppercase, priehľadné
- `stat-label` — Playfair italic, biely text
- `stat-body` — sivý text `#B8B0A0`, strong = biely
- Box-shadow `3px 3px 0 #C8962A`
- Číslo musí byť z **inej témy** ako hlavná téma aj prehliadka — a zároveň nesmie zopakovať žiadnu informáciu, číslo ani aktéra, ktorý sa kdekoľvek vyskytol v tomto vydaní alebo v dvoch predchádzajúcich vydaniach. Číslo dňa je vždy úplne nová informácia.
- Číslo musí byť ukotvené v **aktuálnych správach** — buď z toho istého dňa, alebo z uplynulých týždňov. Môže to byť aj historické výročie ("pred X rokmi"), ale iba ak je preňho reálny dôvod zaujímavosti teraz. Štatistiky bez väzby na aktuálne dianie nepatria do Číslo dňa.

---

## 9. Kalendár / Tento týždeň

```html
<div class="cal">
  <div class="cal-item">
    <div class="cal-dot"></div>    ← zlatý kruh 5px
    <span>Text položky, max 2 vety.</span>
  </div>
</div>
```

**Pravidlá:**

- 4–5 položiek
- Zlatý krúžok vľavo (`#C8962A`, 5px, border-radius 50%)
- Posledná položka bez border-bottom
- Aspoň jedna položka musí byť absurdná alebo lokálna
- **Žiadna téma z prehliadky ani hlavnej témy sa tu neopakuje**

---

## 10. Slovo Dňa

```html
<div class="wotd">
  <div class="wotd-word">Sonder</div>
  <div class="wotd-body">Definícia ako pocit, nie slovník.</div>
</div>
```

**CSS:** border `1.5px solid #1A1208`, border-left `4px solid #C8962A`, `margin-bottom: 0` — žiadna medzera pod boxom, footer nasleduje priamo

**Pravidlá:**

- `wotd-word` — Playfair italic 24px
- Slovo vyberá AI náhodne každý deň
- Nesmie sa opakovať — AI sleduje archív v redakčnej príručke
- Kritérium: pomenúva pocit, ktorý každý zná ale nevedel nazvať
- Definícia znie ako pocit, nie výkladový slovník
- Po každom vydaní pridaj slovo do archívnej tabuľky v `ranna-sprava-editorial-guide.md`
- **Zrozumiteľnosť je povinná:** definícia musí byť zrozumiteľná bežnému dospelému čitateľovi bez odborného vzdelania. Ak na vysvetlenie slova treba najprv vysvetliť ďalšie odborné pojmy, definíciu treba prepísať, alebo zvoliť iné slovo. Analógie, príklady z každodenného života a porovnania sú vítané. Slovníkové paráty nie.

---

## 11. Footer

```html
<div class="foot">
  <div class="foot-brand">Ranná<span>Správa</span></div>
  <div class="foot-links">
    <a href="https://rannasprava.sk/archiv/">Archív</a>
    <a href="https://rannasprava.sk/">Web</a>
    <a href="https://rannasprava.sk/share/index.html?issue=[cislo]" class="js-share-link" data-share-url="https://rannasprava.sk/vydania/[cislo]/">Zdieľaj</a>
  </div>
  <p class="foot-copy">
    RannáSpráva · Bratislava · Slovensko · [Deň, dátum]<br>
    <a href="#">Odhlásiť sa z newslettera</a>
  </p>
</div>
```

**Pravidlá:** čierne pozadie, biely názov, zlaté "Správa", priesvitné linky

- `margin-top: 1.5rem` — oddeľuje footer od wotd boxu bez bielej medzery pod ním
- Footer je posledný element — žiadny padding ani medzera po ňom
- `Archív` vzdy linkuje na `https://rannasprava.sk/archiv/`
- Jednotlive issue v archive sa odteraz verejne otvaraju cez datumovy path format `https://rannasprava.sk/archiv/DD/MM/YYYY/`
- Tento datumovy archive path je public URL pre issue; podkladovy issue subor moze stale fyzicky zit v `vydania/[cislo]/index.html`
- `Web` vzdy linkuje na `https://rannasprava.sk/`
- `Kontakt` sa nepouziva
- `Spravovat preferencie` sa nepouziva
- Na webe `Zdieľaj` otvara overlay nad issue obsahom cez `share.js`
- Overlay je in-page modal, nie samostatna stranka nacitana vo vnutri popupu
- Webova verzia nema preskakovat do browser native share sheetu namiesto modalu
- Modal sa musi dat zavriet klikom mimo panelu, klavesom `Escape`, aj tlacidlom `Zavrieť`
- Share page URL je `https://rannasprava.sk/share/index.html?issue=[cislo]`
- V emailovej verzii je `Zdieľaj` obycajny link na ten isty share page URL, bez JS

---

## 12. Email export

Newsletter email sa generuje z issue HTML scriptom `prepare-brevo-email.ps1`.

```powershell
powershell -ExecutionPolicy Bypass -File .\prepare-brevo-email.ps1 -Path 'vydania\[cislo]\index.html'
```

**Output:**

- `emails/[cislo]-brevo.html`

**Pravidla:**

- Email HTML sa generuje z issue HTML; nerobi sa rucne separatny dizajn.
- `mast-top` link v emaile musi otvorit `https://rannasprava.sk/vydania/[cislo]/`
- Email `Zdieľaj` linkuje na `https://rannasprava.sk/share/index.html?issue=[cislo]`
- Email unsubscribe pouziva Brevo placeholder `{{ unsubscribe }}`
- Email HTML nesmie obsahovat `<script>` tagy

---

## 13. Archive URL format

Kazde issue musi mat verejny archive alias v tomto presnom formate:

```text
/archiv/DD/MM/YYYY/
```

Priklady:

- `2026-04-09` -> `/archiv/09/04/2026/`
- `2026-04-13` -> `/archiv/13/04/2026/`

Pravidla:

- Alias pages sa generuju scriptom `generate-archive-date-pages.ps1`
- Home page a archive listing maju otvarat tento datumovy URL format
- Root archive landing page zostava `https://rannasprava.sk/archiv/`
- Datumovy archive alias moze presmerovat na podkladovy issue HTML subor v `vydania/[cislo]/`
- Ak viac issue zdiela rovnaky datum, date page sa zmeni na malu archive landing page pre ten den a moze cielit konkretne issue cez hash, napr. `/archiv/17/03/2026/#issue-50`

---

## Oddeľovače medzi sekciami

|Typ|CSS|Kde|
|---|---|---|
|Dashed|`border-bottom: 1px dashed #D4C9B8`|Cold open, story, tour, cal|
|Solid|`border-bottom: 1.5px solid #1A1208`|Markets ticker|
|Solid svetlá|`border-bottom: 1px solid #E8E0D4`|Vnútri tour-item, ul li, cal-item|

---

## Pravidlo jednej témy — najdôležitejšie pravidlo

**Každá informácia, téma alebo udalosť sa v celom vydaní vyskytuje práve raz.** Nezáleží na kontexte, skloňovaní ani uhle pohľadu — ak bola téma použitá, je uzavretá.

### Postup pri tvorbe vydania

Pred písaním si vytvor zoznam použitých tém. Aktualizuj ho po každej sekcii:

```
Použité témy:
- [ ] [téma A]  → Hlavná téma
- [ ] [téma B]  → Prehliadka správ, položka 1
- [ ] [téma C]  → Prehliadka správ, položka 2
- [ ] [téma D]  → Číslo dňa
- [ ] [téma E]  → Kalendár
```

Pred každou novou sekciou alebo položkou: **pozri sa na zoznam a vyber tému, ktorá v ňom ešte nie je.**

### Čo je opakovanie

- Rovnaká udalosť v inej sekcii (napr. Fico v hlavnej téme aj v kalendári)
- Rovnaká téma v inej forme (napr. Družba v hlavnej téme, potom číslo dňa o dňoch blokády Družby)
- Rovnaký aktér v inom kontexte (napr. Danko v prehliadke aj v čísle dňa)
- BY THE WAY opakuje detail z tela hlavnej témy (napr. hlavná téma spomína tanker, BY THE WAY tiež spomína tanker)
- Hlavná téma a prehliadková položka opisujú tú istú vec inak

### Archív a listingy

- Na home page ani na archive sa nezobrazujú žiadne tematické filtre ani tag pills.
- Každá issue karta obsahuje len číslo vydania, dátum, title a preview.

### Čo nie je opakovanie

- Cold open môže odkazovať na meniny, aj keď meniny sú v kalendári — **meniny sú rámec dňa, nie správa**
- Vtip v cold opene môže narážať na tému z hlavnej témy — **humor má povolenie recyklovať kontext**

---

## Obsahové pravidlá (rýchly prehľad)

|Pravidlo|Detail|
|---|---|
|Čerstvosť|Všetky správy sú z **posledných 24 hodín**|
|Neopakovanie medzi vydaniami|Správa z #48 sa neobjaví v #49 (výnimka: zásadný nový vývoj)|
|Neopakovanie v rámci vydania|Každá téma/udalosť/aktér sa objaví práve raz — bez ohľadu na kontext alebo skloňovanie|
|Číslo dňa|Iná téma ako hlavná téma aj prehliadka|
|Kalendár|Žiadna téma z hlavnej témy ani prehliadky|
|Prehliadka|Bez emoji, iné témy ako hlavná téma|
|Markets|Len pracovne dni, cez vikend zakomentovane, build-time snapshot v USD + percent change|
|Pocasie|Tmavy blok = dnes, forecast zacina zajtrajskom, cele Slovensko|
|Slovo dňa|Archivované, neopakuje sa|

---

## Pravidlá presnosti dát — bez výnimiek

Toto nie sú odporúčania. Každý údaj v newsletteri musí byť overený z reálneho zdroja pred publikáciou.

**Povinný zdrojový dokument:** Pri každom novom vydaní AI musí vytvoriť `vydania/[cislo]/sources.md` — dokument, ktorý ku každej správe, štatistike a faktickému tvrdeniu priradí konkrétny zdroj (URL alebo publikácia + dátum). Detailný formát a pravidlá sú v `how-we-do-ranna-sprava.md`. Ak AI nevie nájsť overiteľný zdroj pre tvrdenie, tvrdenie sa do vydania nedostane.

### Kedy sa vydanie tvorí a pre koho je určené

Vydanie sa tvorí **večer predchádzajúceho dňa** a čitateľ ho dostane **ráno nasledujúceho pracovného dňa**. Vydanie vždy opisuje udalosti **dňa tvorby** — nie dňa doručenia.

Príklad: vydanie sa tvorí v pondelok večer, doručí sa v utorok ráno. Správy sú z pondelka. Tickery sú z pondelkového uzatvorenia trhov. Počasie platí pre utorok. Meniny sú utorkové.

---

### Počasie

- Stiahni predpoveď z reálneho zdroja pred zostavením vydania — napr. **shmu.sk**, **yr.no**, **meteo.sk**
- Zobrazuje sa **celoštátna predpoveď** — bez názvu konkrétného mesta
- Tmavý blok = podmienky pre **deň doručenia** (zajtrajšok z pohľadu tvorby)
- Forecast = nasledujúcich 5 dní od dňa doručenia
- Nikdy nedávaj odhadované alebo vymyslené hodnoty

---

### Pocasie - build workflow override

- Pocasie zapisuj pri tvorbe vydania scriptom `update-weather-snapshot.ps1`
- AI ma tento script spustit samo pocas tvorby issue; user nema byt poziadany, aby ho spustal rucne
- Zobrazuje sa **celostatna predpoved** pre Slovensko, nie iba pre Bratislavu
- `weather-city-name` ma byt vzdy `Slovensko`
- Standardne pouzi narodny priemer pre Slovensko
- Ak script vypise `[CONSULT]`, AI sa ma vratit k userovi iba pri extremnom rozdiele, napr. mraz alebo sneh na jednej strane krajiny a zaroven slnecno a teplo na druhej

---

### Markets ticker

- Hodnoty zapisuj pri tvorbe vydania scriptom `update-market-snapshot.ps1`
- AI ma tento script spustit samo pocas tvorby issue; user nema byt poziadany, aby ho spustal rucne
- Pouzivaj hodnoty z **poslednej dostupnej uzatvaracej ceny** ku dnu pred vydanim
- Ak su trhy v den tvorby zatvorene (vikend, sviatok), pouzi posledne dostupne obchodne uzatvorenie
- Kazda polozka zobrazuje USD hodnotu ako hlavny riadok a percent change ako druhy riadok
- Ticker sa zobrazuje len v pracovne dni - ak su trhy zatvorene, cely blok zakomentuj
- Nikdy nedavaj odhadovane, zaokruhlene alebo vymyslene hodnoty

---

### Meniny

- Vždy over pred zostavením vydania — napr. **meniny.sk**, **kalendar.zoznam.sk**
- Meniny musia byť pre **deň doručenia** — nie deň tvorby
- Chybné meniny sú rovnako zlé ako chybné číslo — overiť, nie hádať

---

### Sekcia „Tento týždeň"

- Obsahuje iba udalosti, ktoré sa dejú **v aktuálnom kalendárnom týždni** (Po–Ne)
- Ak je vydanie doručené vo štvrtok, zahrni len udalosti do nedele toho týždňa
- Žiadne udalosti z budúceho týždňa
- Žiadne udalosti ktoré prebehli pred dňom doručenia — tie patria do správ, nie kalendára
- Položky sú zoradené striktne podľa dátumu: najbližší dátum je prvý, najvzdialenejší posledný.
- Poradie nikdy nemeň podľa dôležitosti alebo „zaujímavosti" položky. Toto je povinná finálna kontrola pred publikovaním.
- **Žiadna položka sa nesmie opakovať z predchádzajúceho vydania.** Ak bol „Prvý deň jari" v kalendári vydania #51, vydanie #52 ho neuvedie znova — aj keby bol stále technicky aktuálny. Výnimka: ak nastala zásadná nová udalosť spojená s tým dňom, môže sa uviesť s novým faktom, nie ako opakovaný avíz.
- Pred písaním sekcie AI skontroluje „Tento týždeň" v **posledných dvoch vydaniach** a vylúči všetky tam použité položky.

---

## Mobilná verzia

```css
@media only screen and (max-width: 640px) {
  .wrap { margin: 0; box-shadow: none; border: none; }
  .mast-title { font-size: 38px; letter-spacing: 1px; }
  .mast-date-bar { flex-direction: column; gap: 4px; }
  .story, .tour, .cal { padding-left: 1.5rem; padding-right: 1.5rem; }
  .stat { grid-template-columns: 1fr; }
  .stat-left { min-width: auto; padding: 1.2rem; }
}
```

Na mobile: box-shadow zmizne, masthead sa zúži, stat box sa stohuje vertikálne.

---

_Verzia 1.5 — odvodená z vydania #48, aktualizovaná 20. marca 2026_

## Share modal note

- Na webe `Zdieľaj` vždy otvára in-page modal, nie browser native share sheet.
- Všetok viditeľný text v share modale musí mať správnu slovenskú diakritiku:
  `Zdieľaj`, `Zavrieť`, `Skopírovať`, `Otvoriť`, `Poslať`, `Ranná Správa`, `dnešnú`, `môžeš`.

## Inline source links note

- `sources.md` zostáva plný kontrolný zoznam zdrojov pre celé vydanie.
- V issue HTML sa majú objaviť len riedke inline linky na zdroje: typicky `2` až `4` za celé vydanie.
- Krátky odsek má mať najviac `1` inline link; dlhý odsek najviac `2`, iba ak to čitateľovi reálne pomôže.
- Inline link sa používa tam, kde sa téma ďalej nerozpisuje, ale čitateľ si ju môže chcieť otvoriť v pôvodnom reporte.
- Linkuj priamo na report alebo oficiálny zdroj, ktorý je už zapísaný v `sources.md`.
- `Číslo dňa` musí byť zrozumiteľné a relevantné pre slovenského čitateľa; vyhýbaj sa čisto hollywoodskym alebo celebritným číslam bez jasného lokálneho uhla.

## Sekcie sa nesmu prekrývať

- `Hlavná téma`, jednotlivé bloky `Prehliadka správ`, `Číslo dňa` a `Tento týždeň` musia byť obsahovo odlišné.
- Rovnaká správa alebo rovnaký news peg sa nesmie objaviť v dvoch sekciách toho istého vydania.
- Ak sa jeden príbeh použije v `Číslo dňa`, nesmie sa znovu objaviť v `Prehliadka správ` ani v `Hlavnej téme`.
- `Tento týždeň` nesmie opakovať to isté, čo už issue rozobralo vyššie.
- AI musí pred dokončením vydania spustiť `check-issue-overlap.ps1` a všetky nájdené duplicity prepísať alebo nahradiť.

## Slovenske pomenovania

- Používaj správne slovenské slová a názvy, nie nespisovné varianty.
- Pred dokončením vydania skontroluj, že slovná zásoba aj gramatika sedia so spisovnou slovenčinou a slovníkovým tvarom.
- Ak je nejaký tvar podozrivý, over ho v slovníku alebo v štandardnej jazykovej príručke ešte pred publikovaním.
- Píš `diplomacia`, nie `diplomatia`.
- Píš `Družba`; ak je pri tom všeobecné pomenovanie, tak `ropovod Družba`.

## Volitelne issue audio

- Ak user chce posluchovu verziu, AI moze z issue HTML vygenerovat slovenske MP3 cez `generate-issue-audio.py`.
- Aktualny prototyp pouziva Google `gTTS` a uklada MP3 aj text narracie vedla issue suboru.
- Toto je volitelny build krok; nepublikuj audio automaticky bez toho, aby o to user poziadal.
