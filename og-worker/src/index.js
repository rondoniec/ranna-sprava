/**
 * rannasprava-og — Cloudflare Worker
 * Generates 1200x630 PNG OG images for rannasprava.sk issues.
 *
 * Usage:
 *   https://og.rannasprava.sk/?n=82&t=Headline+text&d=20.+apr%C3%ADla+2026
 *
 * Params:
 *   n  — issue number (e.g. 82)
 *   t  — headline text (URL-encoded)
 *   d  — date string  (URL-encoded, e.g. "20. apríla 2026")
 *
 * Stack: satori (SVG layout) + @resvg/resvg-wasm (SVG→PNG)
 * Fonts: Playfair Display 900, latin + latin-ext subsets (Google Fonts)
 *        fetched once per isolate, then cached in module scope.
 * PNG:   cached 24h in Cloudflare Cache API.
 */

import satori from 'satori';
import { Resvg, initWasm } from '@resvg/resvg-wasm';

// ─── Module-level cache (persists across requests within same Worker isolate) ─

const RESVG_WASM_URL =
  'https://cdn.jsdelivr.net/npm/@resvg/resvg-wasm@2.6.2/index_bg.wasm';

const FONT_CSS_URL =
  'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@900';

// Fake a real browser UA so Google Fonts returns woff2 (not woff/ttf)
const BROWSER_UA =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

let wasmReady = false;
let fonts = null; // array of { name, data, weight, style }

async function ensureReady() {
  if (!wasmReady) {
    const wasmResp = await fetch(RESVG_WASM_URL);
    await initWasm(wasmResp);
    wasmReady = true;
  }

  if (!fonts) {
    // Fetch Google Fonts CSS — returns multiple @font-face blocks
    // (cyrillic, cyrillic-ext, vietnamese, latin-ext, latin — in that order)
    // We need latin-ext (á é í ľ š č ž ť ň…) AND latin (standard a-z + accented Latin-1)
    const css = await fetch(FONT_CSS_URL, {
      headers: { 'User-Agent': BROWSER_UA },
    }).then((r) => r.text());

    const fontUrls = [
      ...css.matchAll(/url\((https:\/\/fonts\.gstatic\.com[^)]+\.woff2)\)/g),
    ].map((m) => m[1]);

    if (!fontUrls.length) throw new Error('Could not parse font URLs from Google Fonts CSS');

    // Load all subsets in parallel — satori falls back between them per-glyph
    const buffers = await Promise.all(
      fontUrls.map((url) => fetch(url).then((r) => r.arrayBuffer()))
    );

    fonts = buffers.map((data) => ({
      name: 'Playfair Display',
      data,
      weight: 900,
      style: 'normal',
    }));
  }
}

// ─── Layout builder (satori vnode format — no JSX required) ─────────────────

function buildLayout(num, title, date) {
  const n = String(num);

  return {
    type: 'div',
    props: {
      style: {
        display: 'flex',
        flexDirection: 'column',
        width: '100%',
        height: '100%',
        backgroundColor: '#1A1208',
        padding: '64px',
        fontFamily: '"Playfair Display"',
        justifyContent: 'space-between',
      },
      children: [

        // ── Header ──────────────────────────────────────────────────────────
        {
          type: 'div',
          props: {
            style: { display: 'flex', flexDirection: 'column', gap: '10px' },
            children: [
              // Gold accent bars
              {
                type: 'div',
                props: {
                  style: { display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '6px' },
                  children: [
                    {
                      type: 'div',
                      props: { style: { width: 48, height: 4, backgroundColor: '#C8962A' } },
                    },
                    {
                      type: 'div',
                      props: { style: { width: 28, height: 4, backgroundColor: '#C8962A' } },
                    },
                  ],
                },
              },
              // Brand name — use unicode escapes so no raw diacritics in JS source
              {
                type: 'div',
                props: {
                  style: {
                    fontSize: 13,
                    fontWeight: 900,
                    color: 'rgba(245,240,232,0.35)',
                    letterSpacing: 5,
                  },
                  // RANN\u00C1 SPR\u00C1VA = "RANNÁ SPRÁVA"
                  children: 'RANN\u00C1 SPR\u00C1VA',
                },
              },
              // Issue label
              {
                type: 'div',
                props: {
                  style: {
                    fontSize: 12,
                    fontWeight: 900,
                    color: '#C8962A',
                    letterSpacing: 3,
                  },
                  children: 'VYDANIE #' + n,
                },
              },
            ],
          },
        },

        // ── Headline ─────────────────────────────────────────────────────────
        {
          type: 'div',
          props: {
            style: {
              display: 'flex',
              flex: 1,
              alignItems: 'center',
              paddingTop: '20px',
              paddingBottom: '20px',
            },
            children: {
              type: 'div',
              props: {
                style: {
                  fontSize: 50,
                  fontWeight: 900,
                  color: '#F5F0E8',
                  lineHeight: '1.28',
                  // satori wraps text to container width automatically
                },
                children: title,
              },
            },
          },
        },

        // ── Footer ───────────────────────────────────────────────────────────
        {
          type: 'div',
          props: {
            style: {
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              borderTop: '1px solid rgba(245,240,232,0.1)',
              paddingTop: '16px',
            },
            children: [
              {
                type: 'div',
                props: {
                  style: { fontSize: 14, fontWeight: 900, color: 'rgba(245,240,232,0.35)' },
                  children: date,
                },
              },
              {
                type: 'div',
                props: {
                  style: { fontSize: 14, fontWeight: 900, color: '#C8962A' },
                  children: 'rannasprava.sk',
                },
              },
            ],
          },
        },
      ],
    },
  };
}

// ─── Main handler ────────────────────────────────────────────────────────────

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // Only handle GET
    if (request.method !== 'GET') {
      return new Response('Method not allowed', { status: 405 });
    }

    const n = url.searchParams.get('n') || '?';
    const t = url.searchParams.get('t') || 'Rann\u00E1 Spr\u00E1va';
    const d = url.searchParams.get('d') || '';

    // ── CF Cache lookup ──────────────────────────────────────────────────────
    const cache = caches.default;
    const cacheKey = new Request(url.toString());
    const cached = await cache.match(cacheKey);
    if (cached) return cached;

    // ── Generate PNG ─────────────────────────────────────────────────────────
    try {
      await ensureReady();

      const svg = await satori(buildLayout(n, t, d), {
        width: 1200,
        height: 630,
        fonts,
      });

      const resvg = new Resvg(svg, {
        fitTo: { mode: 'width', value: 1200 },
      });
      const rendered = resvg.render();
      const png = rendered.asPng();

      const response = new Response(png, {
        status: 200,
        headers: {
          'Content-Type': 'image/png',
          'Cache-Control': 'public, max-age=86400, s-maxage=86400, immutable',
          'X-Generated-At': new Date().toISOString(),
        },
      });

      // Store in CF Cache asynchronously (don't block the response)
      ctx.waitUntil(cache.put(cacheKey, response.clone()));

      return response;
    } catch (err) {
      // Fallback: redirect to the generic OG image
      console.error('OG generation error:', err);
      return Response.redirect('https://rannasprava.sk/og-image.svg', 302);
    }
  },
};
