# Ranná Správa — Tvoj kompletný sprievodca

## Čo si stiahol

```
ranna-sprava/
├── index.html        ← Celý web (landing page + archív + čitateľ)
├── issues/           ← Tu ukladáš svoje vydania (záloha)
│   └── 001.md
└── README.md         ← Tento súbor
```

Jeden súbor (index.html) robí všetko:
- Tvoja landing page so signup formulárom
- Archív všetkých vydaní
- Čitateľ každého vydania
- Mobilne responzívny dizajn

---

## Ako pridáš nové vydanie (každý deň)

Otvor `index.html` v akomkoľvek textovom editore (Notepad, VS Code, Sublime).

Nájdi sekciu ktorá začína takto (je asi na riadku 350):

```javascript
const ISSUES = [
```

**Pridaj nový objekt NA ZAČIATOK zoznamu** (najnovšie vydanie musí byť prvé):

```javascript
const ISSUES = [
  {
    number: 4,                          // ← číslo vydania
    title: "Titulok dnešného vydania",  // ← hlavný titulok
    date: "2025-03-06",                 // ← dátum vo formáte RRRR-MM-DD
    dateLabel: "Štvrtok, 6. marca",     // ← slovenský dátum pre zobrazenie
    preview: "Krátky perex — 1-2 vety čo je v čísle.", // ← preview text
    tags: ["slovensko", "biznis"],      // ← vyber: slovensko, biznis, tech, svet, sport, zdravie
    content: `
Sem príde celý text vydania v Markdown formáte.

## 🇸🇰 Slovensko

**KICKER · TÉMA**

### Titulok príbehu

Prvý odsek...

Druhý odsek...

> **Prečo ti to záleží:** Text WIM boxu.

---

## 💼 Biznis & Financie
...

## ⚡ Rýchle správy

- ⚽ **Bullet 1**
- 📈 **Bullet 2**

---

Záver.

*— Tím Ranná Správa*
    `
  },
  // ... zvyšok vydaní
```

Ulož súbor. Hotovo — vydanie je v archíve.

---

## Markdown cheat sheet (formátovanie)

| Čo chceš | Čo napíšeš |
|---|---|
| **Tučné** | `**tučný text**` |
| *Kurzíva* | `*kurzíva*` |
| Nadpis sekcie | `## 🇸🇰 Slovensko` |
| Titulok príbehu | `### Titulok príbehu` |
| WIM box | `> **Prečo ti to záleží:** Text...` |
| Oddeľovač | `---` |
| Bullet bod | `- ⚽ **Šport:** Text` |

---

## Ako dáš web na internet (zadarmo, 10 minút)

### Možnosť A: Netlify Drop (najrýchlejšie — 2 minúty)

1. Otvor **netlify.com/drop**
2. Pretiahni celú složku `ranna-sprava` na stránku
3. Netlify ti dá URL ako `https://amazing-name-123.netlify.app`
4. Hotovo — tvoj web je live

Pre vlastnú doménu (rannasprava.sk):
- V Netlify → Site settings → Domain management → Add custom domain

### Možnosť B: GitHub + Vercel (profesionálnejšie, 10 minút)

1. Vytvor účet na **github.com**
2. Nové repository → nazvi ho `ranna-sprava`
3. Nahraj `index.html` do repozitára
4. Otvor **vercel.com** → "New Project" → importuj z GitHub
5. Vercel automaticky nasadí web
6. Pri každej zmene `index.html` na GitHub sa web automaticky aktualizuje

---

## Ako zbieraš emaily (Brevo — zadarmo do 300/deň)

### Krok 1: Vytvor účet na brevo.com

Brevo (predtým Sendinblue) je zadarmo do 300 emailov denne a 100 000 kontaktov.

### Krok 2: Získaj API kľúč

V Brevo → SMTP & API → API Keys → Create new API key

### Krok 3: Pridaj do index.html

Nájdi funkciu `handleSignup` a nahraď komentár skutočným volaním:

```javascript
async function handleSignup(inputId) {
  const email = document.getElementById(inputId).value.trim();
  if (!email || !email.includes('@')) return;

  // Pridaj kontakt do Brevo
  await fetch('https://api.brevo.com/v3/contacts', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'api-key': 'TU_VLOZ_SVOJ_API_KLUC'  // ← sem
    },
    body: JSON.stringify({
      email: email,
      listIds: [2],  // ← ID tvojho zoznamu v Brevo
      updateEnabled: true
    })
  });

  // Ukáž potvrdenie
  document.getElementById(inputId).placeholder = '✓ Prihlásený!';
}
```

### Krok 4: Rozosielanie vydaní

Keď budeš chcieť poslať vydanie emailom:
1. Otvor Brevo → Campaigns → Create email campaign
2. Vyber zoznam odberateľov
3. Vlož HTML z emailovej šablóny (ranna-sprava-email-template.html)
4. Odošli

---

## Denná rutina (45-60 minút)

```
06:00 — Prečítaj: SME.sk, HNonline.sk, Startitup.sk, TechCrunch, Reuters
06:30 — Vyber 4 príbehy + 5 quick hits
07:00 — Napíš vydanie podľa šablóny
07:45 — Pridaj do index.html, ulož, nahraj na GitHub/Netlify
08:00 — Vydanie je live na webe
```

---

## Zdroje na čítanie každé ráno

**Slovensko:**
- sme.sk
- hnonline.sk
- startitup.sk
- dennikn.sk

**Biznis & Financie:**
- hnonline.sk/ekonomika
- finweb.hnonline.sk
- bloomberg.com (hlavné titulky)

**Tech:**
- techcrunch.com
- theverge.com
- zive.sk

**Svet:**
- reuters.com
- bbc.com/news

**Šport:**
- sport.sk
- futbalnet.sk

---

## Náklady

| Položka | Cena |
|---|---|
| Hosting (Netlify/Vercel) | **0€** |
| Email platforma (Brevo, do 300/deň) | **0€** |
| Doména rannasprava.sk | **~10€/rok** (voliteľné) |
| **Celkom** | **0€ / mesiac** |

---

*Ranná Správa — postavené bez kódu, bez peňazí, bez platformy.*
