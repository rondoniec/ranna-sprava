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

    # middle cells if share button present
    for child in children[1:-1]:
        td_mid = soup.new_tag('td')
        td_mid['style'] = 'text-align: center; vertical-align: middle;'
        td_mid.append(child.extract())
        tr.append(td_mid)

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
    → <table><tr><td>dot</td><td>text</td></tr></table>
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

        # dot cell
        td_dot = soup.new_tag('td')
        dot_style = parse_style(dot.get('style', ''))
        dot_style['vertical-align'] = 'top'
        dot_style['padding-top'] = '7px'
        dot_style['padding-right'] = '10px'
        dot_style['width'] = '5px'
        td_dot['style'] = render_style(dot_style)
        td_dot.append(dot.extract())
        tr.append(td_dot)

        # text cell
        td_text = soup.new_tag('td')
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
    .market-row / ticker uses display:flex
    → inline-block per item with explicit width
    """
    market_row = soup.find(class_='market-row')
    if not market_row:
        return
    mr_style = parse_style(market_row.get('style', ''))
    mr_style.pop('display', None)
    mr_style.pop('gap', None)
    mr_style.pop('overflow-x', None)
    mr_style['text-align'] = 'center'
    market_row['style'] = render_style(mr_style)

    for item in market_row.find_all(class_='market-item'):
        item_style = parse_style(item.get('style', ''))
        item_style['display'] = 'inline-block'
        item_style['vertical-align'] = 'top'
        item_style['margin'] = '0 6px'
        item['style'] = render_style(item_style)


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

    table = soup.new_tag('table', width='100%', cellpadding='0', cellspacing='0', border='0')
    table['style'] = render_style(stat_style)
    tr = soup.new_tag('tr')
    table.append(tr)

    td_left = soup.new_tag('td')
    left_style = parse_style(left.get('style', ''))
    left_style['vertical-align'] = 'middle'
    left_style['width'] = '120px'
    td_left['style'] = render_style(left_style)
    for child in list(left.children):
        td_left.append(child.extract())
    tr.append(td_left)

    td_right = soup.new_tag('td')
    right_style = parse_style(right.get('style', ''))
    right_style['vertical-align'] = 'middle'
    td_right['style'] = render_style(right_style)
    for child in list(right.children):
        td_right.append(child.extract())
    tr.append(td_right)

    stat.replace_with(table)


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
