"""
inline-email-css.py
Converts Ranná Správa issue HTML into email-safe HTML by inlining all CSS.
Usage: python inline-email-css.py <input.html> [output.html]
If no output path given, prints to stdout.
"""
import sys
import re
import logging
import cssutils
cssutils.log.setLevel(logging.CRITICAL)  # suppress cssutils property warnings
from premailer import transform

def inline(html: str) -> str:
    # premailer inlines <style> blocks and removes them from <head>
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
    return result

def main():
    if len(sys.argv) < 2:
        print("Usage: python inline-email-css.py <input.html> [output.html]", file=sys.stderr)
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    with open(input_path, "r", encoding="utf-8") as f:
        html = f.read()

    inlined = inline(html)

    if output_path:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(inlined)
        print(f"Written: {output_path}")
    else:
        print(inlined)

if __name__ == "__main__":
    main()
