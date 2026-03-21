from __future__ import annotations

import argparse
import html
import re
from pathlib import Path

from bs4 import BeautifulSoup
from gtts import gTTS


def clean_text(value: str) -> str:
    text = html.unescape(value or "")
    text = text.replace("\xa0", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def section_text(elements: list[str]) -> str:
    parts = [clean_text(item) for item in elements if clean_text(item)]
    return " ".join(parts).strip()


def build_script(soup: BeautifulSoup) -> str:
    script_parts: list[str] = []

    mast_bar = soup.select_one(".mast-date-bar")
    mast_title = soup.select_one(".mast-title")
    if mast_title:
      title = clean_text(mast_title.get_text(" ", strip=True))
      issue_info = clean_text(mast_bar.get_text(" ", strip=True)) if mast_bar else ""
      script_parts.append(f"{title}. {issue_info}.")

    cold_open = soup.select_one(".cold-open")
    if cold_open:
        script_parts.append("Cold open. " + clean_text(cold_open.get_text(" ", strip=True)))

    weather = soup.select_one(".weather")
    if weather:
        city = clean_text(weather.select_one(".weather-city-name").get_text(" ", strip=True)) if weather.select_one(".weather-city-name") else ""
        temp = clean_text(weather.select_one(".weather-temp").get_text(" ", strip=True)) if weather.select_one(".weather-temp") else ""
        cond = clean_text(weather.select_one(".weather-cond").get_text(" ", strip=True)) if weather.select_one(".weather-cond") else ""
        forecast_items = []
        for day in weather.select(".weather-day"):
            day_name = clean_text(day.select_one(".weather-day-name").get_text(" ", strip=True)) if day.select_one(".weather-day-name") else ""
            day_temp = clean_text(day.select_one(".weather-day-temp").get_text(" ", strip=True)) if day.select_one(".weather-day-temp") else ""
            day_rain = clean_text(day.select_one(".weather-day-rain").get_text(" ", strip=True)) if day.select_one(".weather-day-rain") else ""
            forecast_items.append(f"{day_name}: {day_temp}, dážď {day_rain}")
        weather_line = f"Počasie pre {city}. Dnes {temp}. {cond}."
        if forecast_items:
            weather_line += " Predpoveď: " + "; ".join(forecast_items) + "."
        script_parts.append(weather_line)

    story = soup.select_one(".story")
    if story:
        kicker = clean_text(story.select_one(".story-kicker").get_text(" ", strip=True)) if story.select_one(".story-kicker") else ""
        hed = clean_text(story.select_one(".story-hed").get_text(" ", strip=True)) if story.select_one(".story-hed") else ""
        paragraphs = [clean_text(p.get_text(" ", strip=True)) for p in story.select("p")]
        bullets = [clean_text(li.get_text(" ", strip=True)) for li in story.select("li")]
        story_parts = ["Hlavná téma."]
        if kicker:
            story_parts.append(kicker + ".")
        if hed:
            story_parts.append(hed + ".")
        story_parts.extend([p for p in paragraphs if p])
        if bullets:
            story_parts.append("V skratke. " + " ".join(bullets))
        script_parts.append(" ".join(story_parts))

    tour_items = soup.select(".tour-item")
    if tour_items:
        tour_parts = ["Prehliadka správ."]
        for index, item in enumerate(tour_items, start=1):
            hed = clean_text(item.select_one(".tour-hed").get_text(" ", strip=True)) if item.select_one(".tour-hed") else ""
            body = clean_text(item.select_one("p").get_text(" ", strip=True)) if item.select_one("p") else ""
            chunk = f"Správa {index}. {hed}. {body}".strip()
            tour_parts.append(chunk)
        script_parts.append(" ".join(tour_parts))

    stat = soup.select_one(".stat")
    if stat:
        num = clean_text(stat.select_one(".stat-num").get_text(" ", strip=True)) if stat.select_one(".stat-num") else ""
        unit = clean_text(stat.select_one(".stat-unit").get_text(" ", strip=True)) if stat.select_one(".stat-unit") else ""
        label = clean_text(stat.select_one(".stat-label").get_text(" ", strip=True)) if stat.select_one(".stat-label") else ""
        body = clean_text(stat.select_one(".stat-body").get_text(" ", strip=True)) if stat.select_one(".stat-body") else ""
        script_parts.append(f"Číslo dňa. {num} {unit}. {label} {body}".strip())

    calendar_items = soup.select(".cal-item")
    if calendar_items:
        cal_parts = ["Tento týždeň."]
        for item in calendar_items:
            cal_parts.append(clean_text(item.get_text(" ", strip=True)))
        script_parts.append(" ".join(cal_parts))

    wotd = soup.select_one(".wotd")
    if wotd:
        word = clean_text(wotd.select_one(".wotd-word").get_text(" ", strip=True)) if wotd.select_one(".wotd-word") else ""
        body = clean_text(wotd.select_one(".wotd-body").get_text(" ", strip=True)) if wotd.select_one(".wotd-body") else ""
        script_parts.append(f"Slovo dňa. {word}. {body}".strip())

    final_script = "\n\n".join(part for part in script_parts if part.strip())
    final_script = final_script.replace("EÚ", "Európska únia")
    final_script = final_script.replace("OSN", "Organizácia Spojených národov")
    final_script = final_script.replace("WMO", "Svetová meteorologická organizácia")
    return final_script


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("issue_path", help="Path to issue HTML file")
    parser.add_argument("--out", help="Optional output mp3 path")
    parser.add_argument("--script-out", help="Optional output narration text path")
    args = parser.parse_args()

    issue_path = Path(args.issue_path)
    soup = BeautifulSoup(issue_path.read_text(encoding="utf-8"), "html.parser")
    script = build_script(soup)

    output_path = Path(args.out) if args.out else issue_path.with_name("issue-audio-sk.mp3")
    gTTS(text=script, lang="sk", slow=False).save(str(output_path))

    if args.script_out:
        Path(args.script_out).write_text(script, encoding="utf-8")

    print(output_path)


if __name__ == "__main__":
    main()
