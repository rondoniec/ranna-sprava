# Vydanie 55 — opravy po publikovaní

## Gramatické opravy

- **Ropovod Džba → Družba** — opravené na troch miestach: v tele príbehu o SaS/Ficovi, v nadpise tour-itemu a v tele tour-itemu.

## Číslo dňa

- **zásobníkoch → zásobách** v stat-label aj stat-body (správny termín: európske zásoby plynu).
- **zásobníky → zásoby** v stat-body.
- **tankovce → tankery** (tankovce = tanks, tankery = tankers).
- Odstránená posledná veta: *„Kúrenie nabudúcu zimu nie je istota. Je to otázka."* — AI slop, nepridávala faktuálnu hodnotu.

## Tento týždeň

- Odstránené oba meninoví záznamy:
  - Streda 25. 3. — Meniny Marián
  - Štvrtok 26. 3. — Emanuel
- Ponechané len udalosti s reálnou spravodajskou hodnotou (česko-slovenský summit, Medzinárodný deň klavíra).
- Pridaná tretia položka: **Streda 25. 3.** — 69. výročie podpisu Rímskych zmlúv (1957).
- Položky zoradené chronologicky (najbližšie → najďalej): Streda 25. 3. → Nedeľa 29. 3. → Utorok 31. 3.

## Slovo dňa

- Nahradené slovom **Appeasement** (anglické, bez priameho slovenského ekvivalentu).
- Predchádzajúce slovo (*Pretvárka*) bolo príliš generické; *Finlandizácia* bola medzikrokom.
- Appeasement: politika ústupkov voči agresorovi, vstúpila do povedomia Mníchovskou dohodou 1938 — relevantné k téme vydania (Fico, Rusko, energia).
- Doplnená poznámka, že ide o anglické slovo bez priameho slovenského ekvivalentu.

## Layout — opravy zobrazovania

### Počasie (`.weather-days`)
- Dni sa zobrazovali vertikálne namiesto horizontálne.
- Príčina: chýbal explicitný `flex-direction: row` a `flex-wrap: nowrap` na `.weather-days`; bez nich môže prehliadač/email klient zalomiť položky.
- Oprava: `.weather-days` dostalo `flex-direction: row; flex-wrap: nowrap;`, každý `.weather-day` dostal `flex: 1; min-width: 0` aby sa rovnomerne roztiahli a nekollapsli.

### Číslo dňa — orezaný znak % (`.stat-num`)
- Percento sa zobrazovalo na novom riadku alebo bolo orezané `overflow: hidden` na `.stat-left` (šírka 130px).
- Príčina: `clamp(20px, 52cqi, 68px)` dosahoval ~68px font v 130px kontajneri, „30 %" s medzerou bol príliš široký.
- Oprava: clamp znížený na `clamp(18px, 44cqi, 56px)`, medzera medzi číslom a `%` odstránená (`30%` namiesto `30 %`).
