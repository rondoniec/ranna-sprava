param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Path = @('vydania/*/index.html')
)

$ErrorActionPreference = 'Stop'

# ── API KEYS ───────────────────────────────────────────────────────────────────
$FinnhubKey  = 'd58jgm1r01qvj8ih0ttgd58jgm1r01qvj8ih0tu0'
$AlphaKey    = '5FYB9ODD1KU6SWDQ'
$FinnhubBase = 'https://finnhub.io/api/v1'
$AlphaBase   = 'https://www.alphavantage.co/query?apikey=' + $AlphaKey
$EuroSymbol  = [char]0x20AC

# ── CACHE ──────────────────────────────────────────────────────────────────────
$CacheFile      = Join-Path $env:TEMP 'ranna-sprava-market-cache.json'
$RunCache       = @{}
$TodayCacheDate = (Get-Date).ToString('yyyy-MM-dd')

if (Test-Path $CacheFile) {
  try {
    $cached = Get-Content -Raw $CacheFile | ConvertFrom-Json
    if ($cached.cacheDate -eq $TodayCacheDate -and $cached.series) {
      foreach ($prop in $cached.series.PSObject.Properties) {
        $RunCache[$prop.Name] = $prop.Value
      }
    }
  } catch { $RunCache = @{} }
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Save-RunCache {
  $json = @{ cacheDate = $TodayCacheDate; series = $RunCache } | ConvertTo-Json -Depth 100
  [System.IO.File]::WriteAllText($CacheFile, $json, $Utf8NoBom)
}

# ── HELPERS ────────────────────────────────────────────────────────────────────
function Normalize-Token {
  param([string]$Value)
  if (-not $Value) { return '' }
  $normalized = $Value.Normalize([Text.NormalizationForm]::FormD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($c in $normalized.ToCharArray()) {
    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne
        [Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$sb.Append($c)
    }
  }
  return $sb.ToString().ToLowerInvariant()
}

function Parse-IssueDate {
  param([string]$Html)
  $patterns = @(
    '<title>[^<]*?(\d{1,2})\.\s*([^\s<]+)\s+(\d{4})</title>',
    '<div class="mast-date-bar">\s*<span>[^<]*?(\d{1,2})\.\s*([^\s<]+)\s+(\d{4})</span>'
  )
  $months = @{
    januara=1; februara=2; marca=3; aprila=4; maja=5; juna=6
    jula=7; augusta=8; septembra=9; oktobra=10; novembra=11; decembra=12
  }
  foreach ($pattern in $patterns) {
    $m = [regex]::Match($Html, $pattern, 'IgnoreCase,Singleline')
    if (-not $m.Success) { continue }
    $day = [int]$m.Groups[1].Value
    $tok = Normalize-Token $m.Groups[2].Value.Trim('.')
    $yr  = [int]$m.Groups[3].Value
    if (-not $months.ContainsKey($tok)) { throw "Unknown month token '$($m.Groups[2].Value)'." }
    return [datetime]::new($yr, $months[$tok], $day)
  }
  throw 'Could not parse issue date from HTML.'
}

function DateToUnix {
  param([datetime]$d)
  return [int64]($d.ToUniversalTime() - [datetime]::new(1970,1,1,0,0,0,'Utc')).TotalSeconds
}

# ── FINNHUB ────────────────────────────────────────────────────────────────────
function Invoke-Finnhub {
  param([string]$Endpoint, [string]$CacheKey)
  if ($RunCache.ContainsKey($CacheKey)) { return $RunCache[$CacheKey] }
  $url = "$FinnhubBase/$Endpoint&token=$FinnhubKey"
  $r   = Invoke-RestMethod -Uri $url
  $RunCache[$CacheKey] = $r
  Save-RunCache
  return $r
}

# Single quote endpoint — returns c (close) + pc (prev close) + dp (% change).
# Validates the quote timestamp is within 4 calendar days of targetDate so stale
# quotes never sneak into old issues.
function Get-FinnhubStockQuote {
  param([string]$Symbol, [datetime]$TargetDate)
  $q = Invoke-Finnhub -Endpoint "quote?symbol=$Symbol" -CacheKey "fh-quote-$Symbol"
  if (-not $q -or $q.c -eq 0) { throw "Finnhub quote empty for $Symbol." }
  $quoteDate = [DateTimeOffset]::FromUnixTimeSeconds([long]$q.t).UtcDateTime.Date
  $diff      = [math]::Abs(($quoteDate - $TargetDate.Date).TotalDays)
  if ($diff -gt 4) { throw "Finnhub quote for $Symbol is $diff days from target $($TargetDate.ToString('yyyy-MM-dd'))." }
  return [pscustomobject]@{ Price = [double]$q.c; Prev = [double]$q.pc }
}

# Daily crypto candle — fetches last 7 days and picks the two closest to targetDate.
function Get-FinnhubCryptoCandle {
  param([datetime]$TargetDate)
  $from = DateToUnix $TargetDate.AddDays(-7)
  $to   = DateToUnix $TargetDate.AddDays(1)
  $r    = Invoke-Finnhub `
    -Endpoint "crypto/candle?symbol=BINANCE:BTCUSDT&resolution=D&from=$from&to=$to" `
    -CacheKey "fh-btc-$($TargetDate.ToString('yyyyMMdd'))"
  if ($r.s -ne 'ok' -or -not $r.c -or $r.c.Count -lt 2) {
    throw "Finnhub crypto candle: no data for BTC around $($TargetDate.ToString('yyyy-MM-dd'))."
  }
  $last = $r.c[$r.c.Count - 1]
  $prev = $r.c[$r.c.Count - 2]
  return [pscustomobject]@{ Price = [double]$last; Prev = [double]$prev }
}

# Daily forex candle — OANDA EUR/USD.
function Get-FinnhubForexCandle {
  param([datetime]$TargetDate)
  $from = DateToUnix $TargetDate.AddDays(-7)
  $to   = DateToUnix $TargetDate.AddDays(1)
  $r    = Invoke-Finnhub `
    -Endpoint "forex/candle?symbol=OANDA:EUR_USD&resolution=D&from=$from&to=$to" `
    -CacheKey "fh-eurusd-$($TargetDate.ToString('yyyyMMdd'))"
  if ($r.s -ne 'ok' -or -not $r.c -or $r.c.Count -lt 2) {
    throw "Finnhub forex candle: no data for EUR/USD around $($TargetDate.ToString('yyyy-MM-dd'))."
  }
  $last = $r.c[$r.c.Count - 1]
  $prev = $r.c[$r.c.Count - 2]
  return [pscustomobject]@{ Price = [double]$last; Prev = [double]$prev }
}

# ── ALPHA VANTAGE ──────────────────────────────────────────────────────────────
$AlphaGapSeconds = 1.2

function Invoke-AlphaVantage {
  param([string]$Url, [string]$CacheKey)
  if ($RunCache.ContainsKey($CacheKey)) { return $RunCache[$CacheKey] }
  Start-Sleep -Milliseconds ([int]($AlphaGapSeconds * 1000))
  $r = Invoke-RestMethod -Uri $Url
  if ($r.'Error Message' -or $r.Information -or $r.Note) {
    $msg = $r.'Error Message'
    if (-not $msg) { $msg = $r.Note }
    if (-not $msg) { $msg = $r.Information }
    throw "Alpha Vantage error: $msg"
  }
  $RunCache[$CacheKey] = $r
  Save-RunCache
  return $r
}

function Get-LatestKeyOnOrBefore {
  param([string[]]$Keys, [datetime]$TargetDate)
  $target   = $TargetDate.ToString('yyyy-MM-dd')
  $eligible = $Keys | Where-Object { $_ -le $target } | Sort-Object -Descending
  if (-not $eligible -or $eligible.Count -eq 0) { throw "No data on or before $target." }
  return $eligible[0]
}

function Get-PreviousKey {
  param([string[]]$Keys, [string]$CurrentKey)
  $ordered = $Keys | Sort-Object -Descending
  $idx     = [array]::IndexOf($ordered, $CurrentKey)
  if ($idx -lt 0 -or $idx -ge ($ordered.Count - 1)) { throw "No previous key before $CurrentKey." }
  return $ordered[$idx + 1]
}

function Get-AlphaStockSnapshot {
  param([string]$Symbol, [datetime]$TargetDate)
  $data   = Invoke-AlphaVantage -Url "$AlphaBase&function=TIME_SERIES_DAILY&symbol=$Symbol" -CacheKey "av-stock-$Symbol"
  $series = $data.'Time Series (Daily)'
  $keys   = @($series.PSObject.Properties.Name)
  $cur    = Get-LatestKeyOnOrBefore $keys $TargetDate
  $prv    = Get-PreviousKey $keys $cur
  return [pscustomobject]@{ Price = [double]$series.$cur.'4. close'; Prev = [double]$series.$prv.'4. close' }
}

function Get-AlphaFxSnapshot {
  param([datetime]$TargetDate)
  $data   = Invoke-AlphaVantage -Url "$AlphaBase&function=FX_DAILY&from_symbol=EUR&to_symbol=USD" -CacheKey 'av-fx-eurusd'
  $series = $data.'Time Series FX (Daily)'
  $keys   = @($series.PSObject.Properties.Name)
  $cur    = Get-LatestKeyOnOrBefore $keys $TargetDate
  $prv    = Get-PreviousKey $keys $cur
  return [pscustomobject]@{ Price = [double]$series.$cur.'4. close'; Prev = [double]$series.$prv.'4. close' }
}

# ── YAHOO FINANCE (ultimate fallback — no API key required) ────────────────────
function Get-YahooSnapshot {
  param([string]$Symbol, [datetime]$TargetDate)
  $cacheKey = "yahoo-$Symbol-$($TargetDate.ToString('yyyyMMdd'))"
  if ($RunCache.ContainsKey($cacheKey)) { return $RunCache[$cacheKey] }
  $url     = "https://query1.finance.yahoo.com/v8/finance/chart/$Symbol`?interval=1d&range=10d"
  $headers = @{ 'User-Agent' = 'Mozilla/5.0 (compatible; ranna-sprava/1.0)' }
  $r       = Invoke-RestMethod -Uri $url -Headers $headers
  $ts      = $r.chart.result[0].timestamp
  $closes  = $r.chart.result[0].indicators.quote[0].close
  $target  = $TargetDate.Date
  $bestIdx = -1
  $bestDt  = [datetime]::MinValue
  for ($i = 0; $i -lt $ts.Count; $i++) {
    $d = [DateTimeOffset]::FromUnixTimeSeconds([long]$ts[$i]).UtcDateTime.Date
    if ($d -le $target -and $d -gt $bestDt -and $null -ne $closes[$i]) {
      $bestDt  = $d
      $bestIdx = $i
    }
  }
  if ($bestIdx -lt 1) { throw "Yahoo: not enough data for $Symbol around $($TargetDate.ToString('yyyy-MM-dd'))." }
  $prevClose = $closes[$bestIdx - 1]
  if ($null -eq $prevClose) { throw "Yahoo: null previous close for $Symbol at index $($bestIdx - 1) - data gap." }
  $result = [pscustomobject]@{ Price = [double]$closes[$bestIdx]; Prev = [double]$prevClose }
  $RunCache[$cacheKey] = $result
  Save-RunCache
  return $result
}

# ── TICKER FETCHERS WITH FALLBACK CHAIN ────────────────────────────────────────
#
#  BTC    → Finnhub crypto candle  → Yahoo (BTC-USD)
#  SPY    → Finnhub quote          → Yahoo → Alpha Vantage
#  EURUSD → Finnhub forex candle   → Yahoo (EURUSD=X) → Alpha Vantage FX
#  GLD    → Finnhub quote          → Yahoo → Alpha Vantage
#  URTH   → Alpha Vantage*         → Yahoo
#           *Finnhub requires premium for URTH
#
function Get-BtcSnapshot {
  param([datetime]$TargetDate)
  try   { return Get-FinnhubCryptoCandle -TargetDate $TargetDate }
  catch { Write-Warning "  [BTC] Finnhub failed: $_" }
  try   { return Get-YahooSnapshot -Symbol 'BTC-USD' -TargetDate $TargetDate }
  catch { Write-Warning "  [BTC] Yahoo failed: $_" }
  throw "All sources failed for BTC."
}

# Rolling 24h change from CoinGecko — industry standard for crypto, used on weekdays.
# Synthesises a Prev value so Format-Pct produces the correct 24h percentage.
function Get-CoinGeckoBtcSnapshot {
  $cacheKey = "coingecko-btc-$TodayCacheDate"
  if ($RunCache.ContainsKey($cacheKey)) { return $RunCache[$cacheKey] }
  $url = 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true'
  $r      = Invoke-RestMethod -Uri $url
  $price  = [double]$r.bitcoin.usd
  $chg24h = [double]$r.bitcoin.usd_24h_change
  if ($price -eq 0) { throw 'CoinGecko returned zero price for BTC.' }
  $prev   = $price / (1 + $chg24h / 100)
  $result = [pscustomobject]@{ Price = $price; Prev = $prev }
  $RunCache[$cacheKey] = $result
  Save-RunCache
  return $result
}

function Get-SpySnapshot {
  param([datetime]$TargetDate)
  try   { return Get-FinnhubStockQuote -Symbol 'SPY' -TargetDate $TargetDate }
  catch { Write-Warning "  [SPY] Finnhub failed: $_" }
  try   { return Get-YahooSnapshot -Symbol 'SPY' -TargetDate $TargetDate }
  catch { Write-Warning "  [SPY] Yahoo failed: $_" }
  try   { return Get-AlphaStockSnapshot -Symbol 'SPY' -TargetDate $TargetDate }
  catch { Write-Warning "  [SPY] Alpha Vantage failed: $_" }
  throw "All sources failed for SPY."
}

function Get-EurUsdSnapshot {
  param([datetime]$TargetDate)
  try   { return Get-FinnhubForexCandle -TargetDate $TargetDate }
  catch { Write-Warning "  [EURUSD] Finnhub failed: $_" }
  try   { return Get-YahooSnapshot -Symbol 'EURUSD=X' -TargetDate $TargetDate }
  catch { Write-Warning "  [EURUSD] Yahoo failed: $_" }
  try   { return Get-AlphaFxSnapshot -TargetDate $TargetDate }
  catch { Write-Warning "  [EURUSD] Alpha Vantage failed: $_" }
  throw "All sources failed for EUR/USD."
}

function Get-GoldSnapshot {
  param([datetime]$TargetDate)
  try   { return Get-FinnhubStockQuote -Symbol 'GLD' -TargetDate $TargetDate }
  catch { Write-Warning "  [GLD] Finnhub failed: $_" }
  try   { return Get-YahooSnapshot -Symbol 'GLD' -TargetDate $TargetDate }
  catch { Write-Warning "  [GLD] Yahoo failed: $_" }
  try   { return Get-AlphaStockSnapshot -Symbol 'GLD' -TargetDate $TargetDate }
  catch { Write-Warning "  [GLD] Alpha Vantage failed: $_" }
  throw "All sources failed for GLD."
}

function Get-MsciSnapshot {
  param([datetime]$TargetDate)
  # Finnhub requires premium for URTH — Alpha Vantage is primary here
  try   { return Get-AlphaStockSnapshot -Symbol 'URTH' -TargetDate $TargetDate }
  catch { Write-Warning "  [URTH] Alpha Vantage failed: $_" }
  try   { return Get-YahooSnapshot -Symbol 'URTH' -TargetDate $TargetDate }
  catch { Write-Warning "  [URTH] Yahoo failed: $_" }
  throw "All sources failed for URTH (MSCI World)."
}

# ── FORMATTERS ─────────────────────────────────────────────────────────────────
function Format-Usd {
  param([double]$Value, [string]$Mode)
  switch ($Mode) {
    'whole'   { return ('{0:N0} $' -f [math]::Round($Value)).Replace(',', ' ') }
    'fx'      { return ('{0:N4} $' -f $Value).Replace(',', ' ') }
    default   { return ('{0:N2} $' -f $Value).Replace(',', ' ') }
  }
}

function Format-Eur {
  param([double]$UsdValue, [double]$EurUsdRate, [string]$Mode)
  $e    = $EuroSymbol
  $dash = [char]0x2014
  if ($EurUsdRate -eq 0) { return ($dash + ' ' + $e) }
  $eurValue = $UsdValue / $EurUsdRate
  switch ($Mode) {
    'whole'   { return ('{0:N0}' -f [math]::Round($eurValue)).Replace(',', ' ') + ' ' + $e }
    'fx'      { return ('{0:N4}' -f $eurValue).Replace(',', ' ') + ' ' + $e }
    default   { return ('{0:N2}' -f $eurValue).Replace(',', ' ') + ' ' + $e }
  }
}

function Format-Pct {
  param([double]$Current, [double]$Previous)
  if ($Previous -eq 0) {
    return [pscustomobject]@{ ArrowHtml = ''; PctOnly = ([char]0x2014); Direction = '' }
  }
  $pct      = (($Current - $Previous) / $Previous) * 100
  $isUp     = $pct -ge 0
  $arrow    = if ($isUp) { [char]0x25B2 } else { [char]0x25BC }   # ▲ / ▼
  $color    = if ($isUp) { '#2D7A3A' } else { '#BF3A0A' }
  $sign     = if ($isUp) { '+' } else { '' }
  $dir      = if ($isUp) { 'up' } else { 'dn' }
  $pctStr   = "$sign$([string]::Format('{0:N2}', $pct))%"
  return [pscustomobject]@{
    ArrowHtml = " <span style=`"color:$color;font-size:11px`">$arrow</span>"
    PctOnly   = $pctStr
    Direction = $dir
  }
}

# ── HTML WRITER ────────────────────────────────────────────────────────────────
function Replace-MarketValue {
  param([string]$Html, [string]$Id, [string]$Value)
  $p = "(<div class=`"market-val`" id=`"mval-$Id`">)(.*?)(</div>)"
  return ([regex]::new($p)).Replace($Html, { param($m) $m.Groups[1].Value + $Value + $m.Groups[3].Value }, 1)
}

function Replace-MarketSecondary {
  param([string]$Html, [string]$Id, [string]$Value, [string]$Direction = '')
  $newClass = if ($Direction) { "market-chg $Direction" } else { "market-chg" }
  $p        = "(<div class=`"market-chg(?: [^`"]+)?`" id=`"mchg-$Id`">)(.*?)(</div>)"
  return ([regex]::new($p)).Replace($Html, { param($m) "<div class=`"$newClass`" id=`"mchg-$Id`">$Value</div>" }, 1)
}

function Replace-MarketEur {
  param([string]$Html, [string]$Id, [string]$Value)
  $p = "(<div class=`"market-eur`" id=`"meur-$Id`">)(.*?)(</div>)"
  return ([regex]::new($p)).Replace($Html, { param($m) $m.Groups[1].Value + $Value + $m.Groups[3].Value }, 1)
}

function Set-MarketSnapshot {
  param([string]$Html, [hashtable]$Snapshot, [bool]$IsWeekend = $false)
  $asterisk = if ($IsWeekend) { '*' } else { '' }
  foreach ($key in $Snapshot.Keys) {
    # Asterisk goes between price text and arrow span (price* ▲)
    $Html = Replace-MarketValue     -Html $Html -Id $key -Value ($Snapshot[$key].ValText + $asterisk + $Snapshot[$key].ArrowHtml)
    $Html = Replace-MarketEur       -Html $Html -Id $key -Value $Snapshot[$key].EurText
    $Html = Replace-MarketSecondary -Html $Html -Id $key -Value $Snapshot[$key].PctOnly -Direction $Snapshot[$key].Direction
  }
  # Populate or clear the footnote (present in all issues from #56 onward)
  $footnote = if ($IsWeekend) { '* piatkový záver trhov' } else { '' }
  $fnPat = '(<div class="market-footnote" id="market-footnote">)(.*?)(</div>)'
  $Html = ([regex]::new($fnPat, [System.Text.RegularExpressions.RegexOptions]::Singleline)).Replace($Html, { param($m) $m.Groups[1].Value + $footnote + $m.Groups[3].Value }, 1)
  $Html = [regex]::Replace($Html, '<!--\s*.*?MARKETS.*?-->', '<!-- MARKETS - static last close snapshot (written at build time) -->')
  $Html = $Html -replace '<script src="\.\./\.\./markets\.js"></script>\s*', ''
  return $Html
}

# ── MAIN ───────────────────────────────────────────────────────────────────────
$resolvedPaths = @()
foreach ($entry in $Path) {
  $resolvedPaths += Get-ChildItem -Path $entry -File | Select-Object -ExpandProperty FullName
}
$resolvedPaths = $resolvedPaths | Sort-Object -Unique

if (-not $resolvedPaths -or $resolvedPaths.Count -eq 0) { throw 'No issue files matched the provided path.' }

foreach ($issuePath in $resolvedPaths) {
  $html = [System.IO.File]::ReadAllText($issuePath, [System.Text.Encoding]::UTF8)
  if ($html -notmatch 'mval-btc' -or $html -notmatch 'mchg-gold') { continue }

  $issueDate  = Parse-IssueDate $html
  $isWeekend  = $issueDate.DayOfWeek -in @([System.DayOfWeek]::Saturday, [System.DayOfWeek]::Sunday)
  $targetDate = $issueDate.AddDays(-1)  # Sat→Fri, Sun→Sat (falls back to Fri via Get-LatestKeyOnOrBefore), Mon→Sun (idem)

  Write-Host "Processing $issuePath  (close date: $($targetDate.ToString('yyyy-MM-dd')))$(if ($isWeekend) { '  [WEEKEND - Friday close, * markers]' })"

  # BTC: rolling 24h (CoinGecko) on weekdays; Friday candle on weekends
  if ($isWeekend) {
    $btc = Get-BtcSnapshot -TargetDate $targetDate
  } else {
    try   { $btc = Get-CoinGeckoBtcSnapshot }
    catch {
      Write-Warning "  [BTC] CoinGecko 24h failed: $_ - falling back to candle"
      $btc = Get-BtcSnapshot -TargetDate $targetDate
    }
  }
  $spy    = Get-SpySnapshot    -TargetDate $targetDate
  $eurusd = Get-EurUsdSnapshot -TargetDate $targetDate
  $gold   = Get-GoldSnapshot   -TargetDate $targetDate
  $msci   = Get-MsciSnapshot   -TargetDate $targetDate

  $btcPct    = Format-Pct $btc.Price    $btc.Prev
  $spyPct    = Format-Pct $spy.Price    $spy.Prev
  $eurusdPct = Format-Pct $eurusd.Price $eurusd.Prev
  $goldPct   = Format-Pct $gold.Price   $gold.Prev   # ×10 scaling cancels in ratio
  $msciPct   = Format-Pct $msci.Price   $msci.Prev

  $rate = $eurusd.Price   # EUR/USD rate used for all EUR conversions

  $snapshot = @{
    'btc'    = @{ ValText = Format-Usd $btc.Price         'whole';   EurText = Format-Eur $btc.Price         $rate 'whole';   ArrowHtml = $btcPct.ArrowHtml;    PctOnly = $btcPct.PctOnly;    Direction = $btcPct.Direction    }
    'spy'    = @{ ValText = Format-Usd $spy.Price         'default'; EurText = Format-Eur $spy.Price         $rate 'default'; ArrowHtml = $spyPct.ArrowHtml;    PctOnly = $spyPct.PctOnly;    Direction = $spyPct.Direction    }
    # EUR/USD: EUR row shows inverse rate (how many EUR per 1 USD)
    'eurusd' = @{ ValText = Format-Usd $eurusd.Price      'fx';      EurText = (('{0:N4}' -f (1 / $eurusd.Price)) + ' ' + $EuroSymbol); ArrowHtml = $eurusdPct.ArrowHtml; PctOnly = $eurusdPct.PctOnly; Direction = $eurusdPct.Direction }
    'msci'   = @{ ValText = Format-Usd $msci.Price        'default'; EurText = Format-Eur $msci.Price         $rate 'default'; ArrowHtml = $msciPct.ArrowHtml;   PctOnly = $msciPct.PctOnly;   Direction = $msciPct.Direction   }
    'gold'   = @{ ValText = Format-Usd ($gold.Price * 10) 'whole';   EurText = Format-Eur ($gold.Price * 10)  $rate 'whole';   ArrowHtml = $goldPct.ArrowHtml;   PctOnly = $goldPct.PctOnly;   Direction = $goldPct.Direction   }
  }

  $updated = Set-MarketSnapshot -Html $html -Snapshot $snapshot -IsWeekend $isWeekend
  [System.IO.File]::WriteAllText($issuePath, $updated, $Utf8NoBom)
  Write-Host "  OK: Done"

  # ── WARNINGS: print if any asset is missing change data ───────────────────
  $dashChar   = [char]0x2014
  $missingChg = $snapshot.Keys | Where-Object { $snapshot[$_].PctOnly -eq $dashChar }
  if ($missingChg) {
    Write-Host ""
    Write-Host "  !! TRHY - chybajuce data zmeny, skontroluj rucne:" -ForegroundColor Yellow
    foreach ($k in $missingChg) {
      Write-Host "     $($k.ToUpper()) - zmena sa nezobrazuje ($dashChar)" -ForegroundColor Yellow
    }
    Write-Host ""
  }
}
