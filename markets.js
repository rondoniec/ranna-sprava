/**
 * markets.js — Ranná Správa
 * Fetches live market data from Finnhub and updates the markets strip in every issue.
 *
 * Tickers shown in every vydanie:
 *   Bitcoin (BINANCE:BTCUSDT)
 *   S&P 500 / SPY ETF (SPY)
 *   EUR/USD (OANDA:EUR_USD)
 *   MSCI World / URTH ETF (URTH)
 *   Gold / Zlato (OANDA:XAU_USD)
 *
 * Element IDs expected in the HTML:
 *   mval-btc   / mchg-btc
 *   mval-spy   / mchg-spy
 *   mval-eurusd/ mchg-eurusd
 *   mval-msci  / mchg-msci
 *   mval-gold  / mchg-gold
 */

(function () {
  var KEY = 'd58jgm1r01qvj8ih0ttgd58jgm1r01qvj8ih0tu0';

  var MARKETS = [
    { id: 'btc',    symbol: 'BINANCE:BTCUSDT', fmt: 'crypto' },
    { id: 'spy',    symbol: 'SPY',             fmt: 'stock'  },
    { id: 'eurusd', symbol: 'OANDA:EUR_USD',   fmt: 'forex'  },
    { id: 'msci',   symbol: 'URTH',            fmt: 'stock'  },
    { id: 'gold',   symbol: 'OANDA:XAU_USD',   fmt: 'gold'   },
  ];

  function fmtVal(c, fmt) {
    if (fmt === 'crypto') return Math.round(c).toLocaleString('sk-SK') + '\u00a0$';
    if (fmt === 'gold')   return Math.round(c).toLocaleString('sk-SK') + '\u00a0$';
    if (fmt === 'forex')  return c.toFixed(4);
    // stock/ETF
    return c.toFixed(2);
  }

  function fmtChg(dp) {
    if (dp === null || dp === undefined || isNaN(dp)) return '\u2014';
    var sign = dp >= 0 ? '+' : '';
    return sign + dp.toFixed(2).replace('.', ',') + '%';
  }

  function fetchQuote(sym) {
    return fetch(
      'https://finnhub.io/api/v1/quote?symbol=' +
        encodeURIComponent(sym) +
        '&token=' + KEY
    ).then(function (r) { return r.json(); });
  }

  function applyData(m, data) {
    if (!data || !data.c || data.c === 0) return;
    var valEl = document.getElementById('mval-' + m.id);
    var chgEl = document.getElementById('mchg-' + m.id);
    if (valEl) valEl.textContent = fmtVal(data.c, m.fmt);
    if (chgEl) {
      chgEl.textContent = fmtChg(data.dp);
      chgEl.className = 'market-chg ' + (data.dp >= 0 ? 'up' : 'dn');
    }
  }

  function loadMarkets() {
    MARKETS.forEach(function (m) {
      fetchQuote(m.symbol)
        .then(function (data) { applyData(m, data); })
        .catch(function () { /* keep fallback HTML values on error */ });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadMarkets);
  } else {
    loadMarkets();
  }
})();
