#!/usr/bin/env python3
"""
generate-podcast-txt.py

Generates a NotebookLM-optimized plain-text podcast source from a
Ranná Správa issue HTML file.  The output is a clean, symbol-free,
abbreviation-expanded Slovak text that NotebookLM can use as a source
document for its Audio Overview feature.

Usage:
    python generate-podcast-txt.py vydania/56/index.html
    python generate-podcast-txt.py vydania/56/index.html --out vydania/56/issue-56-podcast.txt

Default output path: vydania/[cislo]/issue-[cislo]-podcast.txt
"""
from __future__ import annotations

import argparse
import html as html_module
import re
from pathlib import Path

from bs4 import BeautifulSoup, NavigableString, Tag


# ---------------------------------------------------------------------------
# Symbol-only expansions — safe regardless of grammatical case
# ---------------------------------------------------------------------------
# NOTE: Do NOT expand inflected abbreviations like EÚ, EP, SR here.
# The original HTML text already uses them in the correct grammatical form.
# Replacing them with nominative forms would introduce declension errors.
# NotebookLM reads "EÚ" as "é-ú", "SR" as "es-er", which is correct Slovak.

SYMBOL_ABBREVS: list[tuple[str, str]] = [
    # Market tickers that contain symbols
    (r"S&P 500", "S a P päťsto"),
    (r"\bS&P\b", "S a P"),
    # Ampersand
    (r" & ", " a "),
]


# ---------------------------------------------------------------------------
# Low-level text helpers
# ---------------------------------------------------------------------------

def unescape(text: str) -> str:
    return html_module.unescape(text or "")


def strip_html_comments(soup: BeautifulSoup) -> None:
    for comment in soup.find_all(string=lambda t: isinstance(t, NavigableString) and "<!--" in str(t)):
        comment.extract()


def node_text(el: Tag | None) -> str:
    """Plain text from a BS4 element (no HTML, no extra whitespace)."""
    if el is None:
        return ""
    return unescape(el.get_text(" ", strip=True))


def clean(raw: str) -> str:
    """Normalise whitespace and common Unicode punctuation."""
    t = unescape(raw)
    # Normalise dashes: en-dash, em-dash → space-dash-space
    t = re.sub(r"\s*[–—]\s*", " — ", t)
    # Smart quotes → plain
    t = t.replace("„", "").replace(""", "").replace(""", "").replace("»", "").replace("«", "")
    # Non-breaking space
    t = t.replace("\xa0", " ")
    # Collapse whitespace
    t = re.sub(r" {2,}", " ", t)
    return t.strip()


def expand_abbrevs(text: str) -> str:
    for pattern, replacement in SYMBOL_ABBREVS:
        text = re.sub(pattern, replacement, text)
    return text


# Comprehensive emoji / variation-selector character class
_EMOJI_RE = re.compile(
    "["
    "\U0001F300-\U0001F9FF"  # Misc symbols and pictographs
    "\U0001FA00-\U0001FA6F"  # Supplemental symbols
    "\u2600-\u27BF"          # Miscellaneous symbols (includes ☁ ☀ ❄ etc.)
    "\uFE00-\uFE0F"          # Variation selectors (U+FE0F follows many emoji)
    "\u200D"                 # Zero-width joiner
    "\u20E3"                 # Combining enclosing keycap
    "]+",
    flags=re.UNICODE,
)


def strip_emoji(text: str) -> str:
    return _EMOJI_RE.sub("", text)


def expand_symbols(text: str) -> str:
    """Replace %, °, currency signs, and arrows with Slovak words.
    Called AFTER clean(), so en-dashes have already been converted to ' — '.
    Temperature ranges must therefore match ' — ' as well as original '–'/'-'.
    """
    # Temperature ranges — must come BEFORE single-° rule
    # Handles both original "4° – 15°" and post-clean "4° — 15°"
    text = re.sub(
        r"(-?\d+)\s*°\s*[–—\-]\s*(-?\d+)\s*°",
        lambda m: f"{m.group(1)} až {m.group(2)} stupňov",
        text,
    )
    # Single temperature  e.g.  8°
    text = re.sub(r"(-?\d+)\s*°", r"\1 stupňov", text)

    # Percentages — order matters (decimal before integer)
    # Slovak decimal comma already in text: 2,7 %
    text = re.sub(r"(\d+),(\d+)\s*%", r"\1,\2 percent", text)
    # US decimal point: 3.68%  →  3,68 percent
    text = re.sub(r"(\d+)\.(\d+)\s*%", lambda m: f"{m.group(1)},{m.group(2)} percent", text)
    # Integer percentages: 15 %  →  15 percent
    text = re.sub(r"(\d+)\s*%", r"\1 percent", text)

    # Arrows
    text = text.replace("▲", "nahor").replace("▼", "nadol")
    text = text.replace("↑", "nahor").replace("↓", "nadol")

    # Currency symbols (appear after market span-stripping)
    text = re.sub(r"\s*\$\s*", " dolárov ", text)
    text = re.sub(r"\s*€\s*", " eur ", text)

    # Decimal point → Slovak comma for bare numbers (e.g. market prices: 653.18)
    # Only digit.digit — won't touch ordinals like "15. apríla" (space after dot)
    text = re.sub(r"(\d)\.(\d)", r"\1,\2", text)

    # Bullet/separator remnants
    text = text.replace("•", "")
    text = text.replace("·", " — ")

    return text


def process(raw: str) -> str:
    """Full normalisation pipeline."""
    t = clean(raw)
    t = expand_abbrevs(t)
    t = expand_symbols(t)
    # Final collapse
    t = re.sub(r" {2,}", " ", t)
    t = re.sub(r"\. \.", ".", t)
    return t.strip()


def el_text(el: Tag | None) -> str:
    """process() applied to an element's plain text."""
    return process(node_text(el))


# ---------------------------------------------------------------------------
# Day abbreviation lookup (for weather forecast headers)
# ---------------------------------------------------------------------------

DAY_SK = {
    "Po": "Pondelok", "Ut": "Utorok", "St": "Streda",
    "Št": "Štvrtok", "Pi": "Piatok", "So": "Sobota", "Ne": "Nedeľa",
}


def expand_day(abbr: str) -> str:
    return DAY_SK.get(abbr.strip(), abbr.strip())


# ---------------------------------------------------------------------------
# Market section
# ---------------------------------------------------------------------------

def market_line(soup: BeautifulSoup, label: str, val_id: str, chg_id: str) -> str:
    val_el = soup.find(id=val_id)
    chg_el = soup.find(id=chg_id)
    if not val_el:
        return ""

    # Strip arrow span from value cell
    for sp in val_el.find_all("span"):
        sp.decompose()
    val = process(val_el.get_text(" ", strip=True))

    chg_raw = process(chg_el.get_text(" ", strip=True)) if chg_el else ""
    # Derive direction from CSS class; strip leading +/- from the number
    direction = ""
    if chg_el:
        classes = chg_el.get("class") or []
        if "up" in classes:
            direction = "nahor"
        elif "dn" in classes:
            direction = "nadol"
    chg_num = chg_raw.lstrip("+").lstrip("-").strip()
    chg_part = f", {direction} o {chg_num}" if direction and chg_num else ""

    return f"{label}: {val}{chg_part}."


def build_markets(soup: BeautifulSoup) -> str:
    if not soup.select_one(".markets"):
        return ""
    lines = [
        market_line(soup, "Bitcoin", "mval-btc", "mchg-btc"),
        market_line(soup, "S a P päťsto", "mval-spy", "mchg-spy"),
        market_line(soup, "Euro — dolár", "mval-eurusd", "mchg-eurusd"),
        market_line(soup, "MSCI World", "mval-msci", "mchg-msci"),
        market_line(soup, "Zlato", "mval-gold", "mchg-gold"),
    ]
    body = "\n".join(l for l in lines if l)
    return f"Na trhoch:\n{body}" if body else ""


# ---------------------------------------------------------------------------
# Weather section
# ---------------------------------------------------------------------------

def build_weather(soup: BeautifulSoup) -> str:
    if not soup.select_one(".weather"):
        return ""

    # Today
    temp_raw = node_text(soup.find(id="wval-today-temp"))
    cond_raw = node_text(soup.find(id="wval-today-cond"))

    # Temperature: "4° – 15°" → "4 až 15 stupňov"
    temp = expand_symbols(clean(temp_raw))

    # Condition: "☁️ St · Zamračene" → strip emoji+variation selectors, strip
    # the 1-2 char day abbreviation and its separator, lowercase the rest
    cond = strip_emoji(cond_raw).strip()
    # Strip leading day abbreviation + separator: "St · " or "St — "
    cond = re.sub(r"^[A-ZÁČĎÉÍĹĽŇÓÔŔŠŤÚÝŽa-záčďéíĺľňóôŕšťúýž]{1,2}\s*[·\-—]\s*", "", cond)
    cond = cond.strip().lower()

    today_line = f"Na Slovensku dnes {temp}, {cond}."

    forecast: list[str] = []
    for i in range(1, 6):
        name_el = soup.find(id=f"wval-d{i}-name")
        temp_el = soup.find(id=f"wval-d{i}-temp")
        rain_el = soup.find(id=f"wval-d{i}-rain")
        if not name_el:
            continue
        day = expand_day(node_text(name_el))
        t = expand_symbols(clean(node_text(temp_el))) if temp_el else ""
        r = expand_symbols(clean(node_text(rain_el))) if rain_el else ""
        rain_part = f", zrážky {r}." if r and r not in ("0 percent", "") else "."
        if day and t:
            forecast.append(f"  {day}: {t}{rain_part}")

    result = today_line
    if forecast:
        result += "\nPredpoveď na ďalšie dni:\n" + "\n".join(forecast)
    return result


# ---------------------------------------------------------------------------
# Content sections
# ---------------------------------------------------------------------------

def build_cold_open(soup: BeautifulSoup) -> str:
    el = soup.select_one(".cold-open")
    if not el:
        return ""
    return f"=== ÚVOD ===\n\n{process(node_text(el))}"


def build_hlavna_tema(soup: BeautifulSoup) -> str:
    story = soup.select_one(".story")
    if not story:
        return ""

    lines: list[str] = ["=== HLAVNÁ TÉMA ===\n"]

    hed = el_text(story.select_one(".story-hed"))
    if hed:
        lines.append(f"{hed}\n")

    for child in story.children:
        if not isinstance(child, Tag):
            continue
        classes = child.get("class") or []
        tag = child.name

        if tag == "p" and not set(classes) & {"story-kicker", "story-hed"}:
            t = process(node_text(child))
            if t:
                lines.append(t)

        elif tag == "div" and "story-subhed" in classes:
            t = el_text(child)
            if t:
                lines.append(f"\n{t}\n")

        elif tag == "ul":
            for li in child.find_all("li", recursive=False):
                t = process(node_text(li))
                if t:
                    lines.append(f"— {t}")

        elif tag == "div" and "wim" in classes:
            body_el = child.select_one(".wim-body") or child
            t = process(node_text(body_el))
            if t:
                lines.append(f"\nMimochodom: {t}\n")

    return "\n".join(lines)


def build_prehliadka(soup: BeautifulSoup) -> str:
    items = soup.select(".tour-item")
    if not items:
        return ""

    ordinals = ["Prvá správa", "Druhá správa", "Tretia správa", "Štvrtá správa", "Piata správa"]
    parts: list[str] = ["=== PREHLIADKA SPRÁV ===\n"]

    for i, item in enumerate(items):
        label = ordinals[i] if i < len(ordinals) else f"Správa {i + 1}"
        hed = el_text(item.select_one(".tour-hed"))
        body_el = item.select_one("p")
        body = process(node_text(body_el)) if body_el else ""
        block = f"{label}: {hed}"
        if body:
            block += f"\n{body}"
        parts.append(block)

    return "\n\n".join(parts)


def build_cislo_dna(soup: BeautifulSoup) -> str:
    stat = soup.select_one(".stat")
    if not stat:
        return ""

    num = el_text(stat.select_one(".stat-num"))
    unit = el_text(stat.select_one(".stat-unit"))
    label = el_text(stat.select_one(".stat-label"))
    body = process(node_text(stat.select_one(".stat-body")))

    lines = ["=== ČÍSLO DŇA ===\n"]
    if num or unit:
        lines.append(f"Číslo dňa: {num} {unit}.\n".strip())
    if label:
        lines.append(label)
    if body:
        lines.append(body)
    return "\n".join(lines)


def build_tyzden(soup: BeautifulSoup) -> str:
    items = soup.select(".cal-item")
    if not items:
        return ""

    lines = ["=== TENTO TÝŽDEŇ ===\n"]
    for item in items:
        # Text lives in the <span>; cal-dot has no text but we strip it anyway
        span = item.select_one("span")
        t = process(node_text(span)) if span else process(node_text(item))
        if t:
            lines.append(f"— {t}")
    return "\n".join(lines)


def build_slovo_dna(soup: BeautifulSoup) -> str:
    wotd = soup.select_one(".wotd")
    if not wotd:
        return ""

    word = el_text(wotd.select_one(".wotd-word"))
    body = process(node_text(wotd.select_one(".wotd-body")))

    lines = ["=== SLOVO DŇA ===\n"]
    if word:
        lines.append(f"Slovo dňa: {word}.\n")
    if body:
        lines.append(body)
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------

def build_header(soup: BeautifulSoup) -> tuple[str, str]:
    """Returns (date_string, issue_string)."""
    bar = soup.select_one(".mast-date-bar")
    if not bar:
        return "", ""
    spans = [s for s in bar.find_all("span") if not s.find("a")]
    date_str = clean(spans[0].get_text(strip=True)) if spans else ""
    issue_str = clean(spans[1].get_text(strip=True)) if len(spans) > 1 else ""
    return date_str, issue_str


# ---------------------------------------------------------------------------
# Main assembler
# ---------------------------------------------------------------------------

def build_podcast_txt(soup: BeautifulSoup) -> str:
    date_str, issue_str = build_header(soup)

    title_line = f"RANNÁ SPRÁVA — {issue_str}" if issue_str else "RANNÁ SPRÁVA"
    divider = "=" * len(title_line)

    sections: list[str] = [
        f"{title_line}\n{date_str}\n{divider}",
    ]

    # --- INTRO ---
    intro: list[str] = ["=== INTRO ===\n"]
    if date_str:
        intro.append(f"Dnes je {date_str[0].lower() + date_str[1:]}.\n")

    weather = build_weather(soup)
    if weather:
        intro.append(weather + "\n")

    markets = build_markets(soup)
    if markets:
        intro.append(markets)

    sections.append("\n".join(intro))

    # --- Cold open ---
    cold = build_cold_open(soup)
    if cold:
        sections.append(cold)

    # --- Main content ---
    for fn in (build_hlavna_tema, build_prehliadka, build_cislo_dna, build_tyzden, build_slovo_dna):
        block = fn(soup)
        if block:
            sections.append(block)

    # --- OUTRO ---
    sections.append("=== OUTRO ===\n\nTo je na dnes všetko z Rannéj Správy. Dovidenia zajtra.")

    return "\n\n\n".join(sections)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate a NotebookLM podcast source TXT from a Ranná Správa issue HTML.",
    )
    parser.add_argument("issue_path", help="Path to vydania/[cislo]/index.html")
    parser.add_argument("--out", help="Output path (default: same dir as issue, issue-[N]-podcast.txt)")
    args = parser.parse_args()

    issue_path = Path(args.issue_path)
    if not issue_path.exists():
        raise SystemExit(f"File not found: {issue_path}")

    soup = BeautifulSoup(issue_path.read_text(encoding="utf-8"), "html.parser")
    txt = build_podcast_txt(soup)

    if args.out:
        out_path = Path(args.out)
    else:
        issue_num = issue_path.parent.name
        out_path = issue_path.parent / f"issue-{issue_num}-podcast.txt"

    out_path.write_text(txt, encoding="utf-8")
    print(f"Podcast script -> {out_path}")


if __name__ == "__main__":
    main()
