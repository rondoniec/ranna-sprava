"""
inline-email-css.py
Converts Ranná Správa issue HTML into email-safe HTML by:
1. Inlining all CSS via premailer
2. Stripping remaining <style> tags (Brevo parses { } as broken placeholders)
3. Converting flex-based layouts to table-based layouts for email client compatibility
Usage: python inline-email-css.py <input.html> [output.html]
"""
import sys
import re
import logging
import cssutils
cssutils.log.setLevel(logging.CRITICAL)  # suppress cssutils property warnings
from premailer import transform
from bs4 import BeautifulSoup, NavigableString

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def parse_style(style_str):
    """Parse a style="" string into a dict."""
    props = {}
    if not style_str:
        return props
    for decl in style_str.split(';'):
        decl = decl.strip()
        if ':' in decl:
            k, _, v = decl.partition(':')
            props[k.strip()] = v.strip()
    return props

def render_style(props):
    """Render a dict back to a style="" string."""
    return '; '.join(f'{k}: {v}' for k, v in props.items() if v)

def set_style(tag, props):
    tag['style'] = render_style(props)

def add_style(tag, extra: dict):
    props = parse_style(tag.get('style', ''))
    props.update(extra)
    set_style(tag, props)

# ---------------------------------------------------------------------------
# Layout fixes for email clients (flexbox → tables)
# ---------------------------------------------------------------------------

def fix_mast_date_bar(soup):
    """
    .mast-date-bar uses display:flex justify-content:space-between
    → convert to <table width="100%"> with date on left, issue# on right
    """
    bar = soup.find(class_='mast-date-bar')
    if not bar:
        return
    children = [c for c in bar.children if not isinstance(c, NavigableString) or c.strip()]
    if len(children) < 2:
        return

    bar_style = parse_style(bar.get('style', ''))
    bar_style.pop('display', None)
    bar_style.pop('justify-content', None)
    bar_style.pop('align-items', None)
    bar_style['width'] = '100%'

    table = soup.new_tag('table', width='100%', cellpadding='0', cellspacing='0', border='0')
    table['style'] = render_style(bar_style)
    tr = soup.new_tag('tr')
    table.append(tr)

    # left cell: date
    td_left = soup.new_tag('td')
    td_left['style'] = 'text-align: left; vertical-align: middle;'
    td_left.append(children[0].extract())
    tr.append(td_left)

    # share button — removed from email layout (kept on web version only)
    for child in children[1:-1]:
        child.extract()

    # right cell: issue number
    td_right = soup.new_tag('td')
    td_right['style'] = 'text-align: right; vertical-align: middle;'
    td_right.append(children[-1].extract())
    tr.append(td_right)

    bar.replace_with(table)


def fix_weather(soup):
    """
    .weather uses display:flex (city panel left, days panel right)
    → <table width="100%"> with two td cells
    """
    weather = soup.find(class_='weather')
    if not weather:
        return
    city = weather.find(class_='weather-city')
    days = weather.find(class_='weather-days')
    if not city or not days:
        return

    weather_style = parse_style(weather.get('style', ''))
    weather_style.pop('display', None)
    weather_style['width'] = '100%'

    table = soup.new_tag('table', width='100%', cellpadding='0', cellspacing='0', border='0')
    table['style'] = render_style(weather_style)
    tr = soup.new_tag('tr')
    table.append(tr)

    td_city = soup.new_tag('td')
    city_style = parse_style(city.get('style', ''))
    city_style.pop('display', None)
    city_style.pop('flex-direction', None)
    city_style.pop('justify-content', None)
    city_style.pop('align-items', None)
    city_style['vertical-align'] = 'middle'
    city_style['width'] = '140px'
    td_city['style'] = render_style(city_style)
    for child in list(city.children):
        td_city.append(child.extract())
    tr.append(td_city)

    td_days = soup.new_tag('td')
    days_style = parse_style(days.get('style', ''))
    days_style.pop('display', None)
    days_style.pop('flex', None)
    days_style.pop('justify-content', None)
    days_style.pop('align-items', None)
    days_style['vertical-align'] = 'middle'
    days_style['padding-left'] = '12px'
    td_days['style'] = render_style(days_style)

    # weather-days itself is also flex (each day column)
    # convert each .weather-day to inline-table column
    inner_table = soup.new_tag('table', cellpadding='0', cellspacing='0', border='0')
    inner_table['style'] = 'width:100%'
    inner_tr = soup.new_tag('tr')
    inner_table.append(inner_tr)
    for day in days.find_all(class_='weather-day'):
        td_day = soup.new_tag('td')
        day_style = parse_style(day.get('style', ''))
        day_style['text-align'] = 'center'
        day_style['vertical-align'] = 'top'
        day_style['padding'] = '0 4px'
        td_day['style'] = render_style(day_style)
        for child in list(day.children):
            td_day.append(child.extract())
        inner_tr.append(td_day)

    td_days.append(inner_table)
    tr.append(td_days)

    weather.replace_with(table)


def fix_cal_items(soup):
    """
    .cal-item uses display:flex gap:12px (dot + text side by side)
    → <table><tr><td>●</td><td>text</td></tr></table>
    CSS border-radius circles don't render in email clients — replace with Unicode ● character.
    """
    for item in soup.find_all(class_='cal-item'):
        dot = item.find(class_='cal-dot')
        text = item.find('span')
        if not dot or not text:
            continue

        item_style = parse_style(item.get('style', ''))
        item_style.pop('display', None)
        item_style.pop('align-items', None)
        item_style.pop('gap', None)

        table = soup.new_tag('table', width='100%', cellpadding='0', cellspacing='0', border='0')
        table['style'] = render_style(item_style)
        tr = soup.new_tag('tr')
        table.append(tr)

        # dot cell — use ● Unicode character instead of CSS circle (border-radius ignored in email)
        td_dot = soup.new_tag('td')
        td_dot['width'] = '14'
        td_dot['valign'] = 'top'
        td_dot['style'] = 'color: #C8962A; font-size: 8px; padding-top: 5px; padding-right: 8px; width: 14px; vertical-align: top;'
        td_dot.string = '●'
        tr.append(td_dot)

        # text cell
        td_text = soup.new_tag('td')
        td_text['valign'] = 'top'
        td_text['style'] = 'vertical-align: top;'
        td_text.append(text.extract())
        tr.append(td_text)

        item.replace_with(table)


def fix_foot_links(soup):
    """
    .foot-links uses display:flex gap:20px
    → inline-block links with margin spacing
    """
    foot_links = soup.find(class_='foot-links')
    if not foot_links:
        return
    fl_style = parse_style(foot_links.get('style', ''))
    fl_style.pop('display', None)
    fl_style.pop('gap', None)
    fl_style.pop('justify-content', None)
    fl_style['text-align'] = 'center'
    foot_links['style'] = render_style(fl_style)

    for a in foot_links.find_all('a'):
        a_style = parse_style(a.get('style', ''))
        a_style['display'] = 'inline-block'
        a_style['margin'] = '0 10px'
        a['style'] = render_style(a_style)


def fix_market_items(soup):
    """
    .markets flex div → proper <table> with one <td> per market-item.
    display:flex is unreliable in email clients (Gmail strips it).
    Table layout is universally supported.
    """
    markets_div = soup.find(class_='markets')
    if not markets_div:
        return

    items = markets_div.find_all(class_='market-item')
    if not items:
        return

    # Pull background/border styles from the container to apply to the table
    container_style = parse_style(markets_div.get('style', ''))
    bg = container_style.get('background', '#F0EAE0')
    border_bottom = container_style.get('border-bottom', '1.5px solid #1A1208')

    table = soup.new_tag('table', border='0', cellpadding='0', cellspacing='0', width='100%')
    table['style'] = f'background:{bg}; border-bottom:{border_bottom};'
    tr = soup.new_tag('tr')
    table.append(tr)

    width_pct = 100 // len(items)
    for item in items:
        td = soup.new_tag('td', align='center', valign='top')
        td['style'] = (
            f'padding:10px 4px 6px; text-align:center; vertical-align:top; width:{width_pct}%;'
        )
        # Move item's children into the td directly
        for child in list(item.children):
            child.extract()
            # Strip flex properties from children
            if hasattr(child, 'get'):
                cs = parse_style(child.get('style', ''))
                for prop in ('flex', 'flex-shrink', 'flex-grow', 'flex-basis'):
                    cs.pop(prop, None)
                child['style'] = render_style(cs)
            td.append(child)
        tr.append(td)

    # Remove the market-footnote div (empty in non-weekend issues, would become stray td)
    footnote = markets_div.find(class_='market-footnote')
    if footnote:
        footnote.decompose()

    markets_div.replace_with(table)


def fix_stat_block(soup):
    """
    .stat uses display:grid with two columns
    → <table> with two cells
    """
    stat = soup.find(class_='stat')
    if not stat:
        return
    left = stat.find(class_='stat-left')
    right = stat.find(class_='stat-right')
    if not left or not right:
        return

    stat_style = parse_style(stat.get('style', ''))
    stat_style.pop('display', None)
    stat_style.pop('grid-template-columns', None)
    stat_style.pop('gap', None)
    # Remove margin — applying margin + width=100% causes overflow in email clients.
    # Instead, we'll use a wrapper <td> with equivalent padding.
    margin = stat_style.pop('margin', None)

    table = soup.new_tag('table', width='100%', cellpadding='0', cellspacing='0', border='0')
    table['style'] = render_style(stat_style)
    tr = soup.new_tag('tr')
    table.append(tr)

    td_left = soup.new_tag('td')
    left_style = parse_style(left.get('style', ''))
    # Strip flex properties — <td> handles alignment natively
    for prop in ('display', 'flex-direction', 'justify-content', 'align-items', 'flex-shrink', 'flex'):
        left_style.pop(prop, None)
    left_style['vertical-align'] = 'middle'
    left_style['text-align'] = 'center'
    td_left['style'] = render_style(left_style)
    td_left['width'] = '130'   # HTML width attr — more reliable than CSS width in email clients
    td_left['valign'] = 'middle'
    td_left['align'] = 'center'
    for child in list(left.children):
        td_left.append(child.extract())
    tr.append(td_left)

    td_right = soup.new_tag('td')
    right_style = parse_style(right.get('style', ''))
    for prop in ('display', 'flex-direction', 'justify-content', 'align-items', 'flex-shrink', 'flex'):
        right_style.pop(prop, None)
    right_style['vertical-align'] = 'middle'
    td_right['style'] = render_style(right_style)
    td_right['valign'] = 'middle'
    for child in list(right.children):
        td_right.append(child.extract())
    tr.append(td_right)

    if margin:
        # Wrap stat table in outer table so padding (not margin) constrains the width
        wrapper = soup.new_tag('table', width='100%', cellpadding='0', cellspacing='0', border='0')
        wrapper_tr = soup.new_tag('tr')
        wrapper_td = soup.new_tag('td')
        wrapper_td['style'] = f'padding: {margin}'
        wrapper_td.append(table)
        wrapper_tr.append(wrapper_td)
        wrapper.append(wrapper_tr)
        stat.replace_with(wrapper)
    else:
        stat.replace_with(table)


def fix_web_font_fallbacks(html: str) -> str:
    """
    Replace Google Fonts stacks with email-safe fallbacks.
    Most email clients do not load external web fonts — add system fonts
    that closely match each typeface so layout degrades gracefully.
      Anton  → Impact (condensed bold sans, available on all major email clients)
    """
    replacements = [
        ('"Anton", sans-serif',   '"Anton", Impact, "Arial Narrow", Arial, sans-serif'),
        ("'Anton', sans-serif",   '"Anton", Impact, "Arial Narrow", Arial, sans-serif'),
    ]
    for old, new in replacements:
        html = html.replace(old, new)
    return html


def apply_email_layout_fixes(html: str) -> str:
    soup = BeautifulSoup(html, 'lxml')
    fix_mast_date_bar(soup)
    fix_weather(soup)
    fix_cal_items(soup)
    fix_foot_links(soup)
    fix_market_items(soup)
    fix_stat_block(soup)
    return str(soup)

# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------

def inline(html: str) -> str:
    # 1. Inline all CSS from <style> blocks onto elements
    result = transform(
        html,
        base_url=None,
        include_star_selectors=True,
        remove_classes=False,
        strip_important=False,
        allow_network=False,
        allow_insecure_ssl=False,
        disable_leftover_css=False,
    )
    # 2. Strip remaining <style> tags — Brevo parses CSS { } as broken placeholders
    result = re.sub(r'<style\b[^>]*>[\s\S]*?</style>', '', result)
    # 3. Fix flex/grid layouts → table-based layouts for email clients
    result = apply_email_layout_fixes(result)
    # 4. Replace web font stacks with email-safe fallbacks
    result = fix_web_font_fallbacks(result)
    return result


def main():
    if len(sys.argv) < 2:
        print("Usage: python inline-email-css.py <input.html> [output.html]", file=sys.stderr)
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    with open(input_path, 'r', encoding='utf-8') as f:
        html = f.read()

    inlined = inline(html)

    if output_path:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(inlined)
        print(f'Written: {output_path}')
    else:
        print(inlined)


if __name__ == '__main__':
    main()
