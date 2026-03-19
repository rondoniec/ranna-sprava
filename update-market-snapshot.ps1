param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Path = @('vydania/*/index.html')
)

$ErrorActionPreference = 'Stop'

$ApiKey = '5FYB9ODD1KU6SWDQ'
$BaseUrl = 'https://www.alphavantage.co/query?apikey=' + $ApiKey
$RequestGapSeconds = 1.2
$EuroSymbol = [char]0x20AC
$CacheFile = Join-Path $env:TEMP 'ranna-sprava-market-series-cache.json'
$RunCache = @{}
$TodayCacheDate = (Get-Date).ToString('yyyy-MM-dd')

if (Test-Path $CacheFile) {
  try {
    $cached = Get-Content -Raw $CacheFile | ConvertFrom-Json
    if ($cached.cacheDate -eq $TodayCacheDate -and $cached.series) {
      foreach ($prop in $cached.series.PSObject.Properties) {
        $RunCache[$prop.Name] = $prop.Value
      }
    }
  } catch {
    $RunCache = @{}
  }
}

function Save-RunCache {
  $payload = @{
    cacheDate = $TodayCacheDate
    series = $RunCache
  }

  $payload | ConvertTo-Json -Depth 100 | Set-Content -Path $CacheFile -Encoding UTF8
}

function Normalize-Token {
  param([string]$Value)

  if (-not $Value) { return '' }

  $normalized = $Value.Normalize([Text.NormalizationForm]::FormD)
  $builder = New-Object System.Text.StringBuilder

  foreach ($char in $normalized.ToCharArray()) {
    $category = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($char)
    if ($category -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$builder.Append($char)
    }
  }

  return $builder.ToString().ToLowerInvariant()
}

function Parse-IssueDate {
  param([string]$Html)

  $patterns = @(
    '<title>[^<]*?(\d{1,2})\.\s*([^\s<]+)\s+(\d{4})</title>',
    '<div class="mast-date-bar">\s*<span>[^<]*?(\d{1,2})\.\s*([^\s<]+)\s+(\d{4})</span>'
  )

  $months = @{
    'januara' = 1
    'februara' = 2
    'marca' = 3
    'aprila' = 4
    'maja' = 5
    'juna' = 6
    'jula' = 7
    'augusta' = 8
    'septembra' = 9
    'oktobra' = 10
    'novembra' = 11
    'decembra' = 12
  }

  foreach ($pattern in $patterns) {
    $match = [regex]::Match($Html, $pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) { continue }

    $day = [int]$match.Groups[1].Value
    $monthToken = Normalize-Token $match.Groups[2].Value.Trim('.')
    $year = [int]$match.Groups[3].Value

    if (-not $months.ContainsKey($monthToken)) {
      throw "Unknown month token '$($match.Groups[2].Value)' in issue date."
    }

    return [datetime]::new($year, $months[$monthToken], $day)
  }

  throw 'Could not parse issue date from HTML.'
}

function Invoke-AlphaVantage {
  param(
    [string]$Url,
    [string]$CacheKey
  )

  if ($RunCache.ContainsKey($CacheKey)) {
    return $RunCache[$CacheKey]
  }

  Start-Sleep -Milliseconds ([int]($RequestGapSeconds * 1000))
  $response = Invoke-RestMethod -Uri $Url

  if ($response.'Error Message' -or $response.Information -or $response.Note) {
    $message = $response.'Error Message'
    if (-not $message) { $message = $response.Note }
    if (-not $message) { $message = $response.Information }
    throw "Alpha Vantage error for URL '$Url': $message"
  }

  $RunCache[$CacheKey] = $response
  Save-RunCache
  return $response
}

function Get-LatestKeyOnOrBefore {
  param(
    [string[]]$Keys,
    [datetime]$TargetDate
  )

  $target = $TargetDate.ToString('yyyy-MM-dd')
  $eligible = $Keys | Where-Object { $_ -le $target } | Sort-Object -Descending
  if (-not $eligible -or $eligible.Count -eq 0) {
    throw "No market data available on or before $target."
  }

  return $eligible[0]
}

function Get-PreviousKey {
  param(
    [string[]]$Keys,
    [string]$CurrentKey
  )

  $ordered = $Keys | Sort-Object -Descending
  $index = [array]::IndexOf($ordered, $CurrentKey)
  if ($index -lt 0 -or $index -ge ($ordered.Count - 1)) {
    throw "No previous data point available before $CurrentKey."
  }

  return $ordered[$index + 1]
}

function Get-StockSnapshot {
  param(
    [string]$Symbol,
    [datetime]$TargetDate
  )

  $data = Invoke-AlphaVantage -Url "$BaseUrl&function=TIME_SERIES_DAILY&symbol=$Symbol" -CacheKey "stock-$Symbol"
  $series = $data.'Time Series (Daily)'
  $keys = @($series.PSObject.Properties.Name)
  $currentKey = Get-LatestKeyOnOrBefore $keys $TargetDate
  $previousKey = Get-PreviousKey $keys $currentKey

  $current = [double]$series.$currentKey.'4. close'
  $previous = [double]$series.$previousKey.'4. close'

  return [pscustomobject]@{
    Date = $currentKey
    Usd = $current
    PreviousUsd = $previous
  }
}

function Get-FxSnapshot {
  param([datetime]$TargetDate)

  $data = Invoke-AlphaVantage -Url "$BaseUrl&function=FX_DAILY&from_symbol=EUR&to_symbol=USD" -CacheKey 'fx-eurusd'
  $series = $data.'Time Series FX (Daily)'
  $keys = @($series.PSObject.Properties.Name)
  $currentKey = Get-LatestKeyOnOrBefore $keys $TargetDate
  $previousKey = Get-PreviousKey $keys $currentKey

  return [pscustomobject]@{
    Date = $currentKey
    EurUsd = [double]$series.$currentKey.'4. close'
    PreviousEurUsd = [double]$series.$previousKey.'4. close'
  }
}

function Get-CryptoSnapshot {
  param([datetime]$TargetDate)

  $data = Invoke-AlphaVantage -Url "$BaseUrl&function=DIGITAL_CURRENCY_DAILY&symbol=BTC&market=USD" -CacheKey 'crypto-btcusd'
  $series = $data.'Time Series (Digital Currency Daily)'
  $keys = @($series.PSObject.Properties.Name)
  $currentKey = Get-LatestKeyOnOrBefore $keys $TargetDate
  $previousKey = Get-PreviousKey $keys $currentKey

  $current = [double]$series.$currentKey.'4. close'
  $previous = [double]$series.$previousKey.'4. close'

  return [pscustomobject]@{
    Date = $currentKey
    Usd = $current
    PreviousUsd = $previous
  }
}

function Format-Usd {
  param(
    [double]$Value,
    [string]$Mode
  )

  switch ($Mode) {
    'whole' { return ('{0:N0} $' -f [math]::Round($Value)).Replace(',', ' ') }
    'fx' { return ('{0:N4} $' -f $Value).Replace(',', ' ') }
    default { return ('{0:N2} $' -f $Value).Replace(',', ' ') }
  }
}

function Format-Eur {
  param(
    [double]$Value,
    [string]$Mode
  )

  switch ($Mode) {
    'whole' { return (('{0:N0} ' -f [math]::Round($Value)) + $EuroSymbol).Replace(',', ' ') }
    'fx' { return (('{0:N4} ' -f $Value) + $EuroSymbol).Replace(',', ' ') }
    default { return (('{0:N2} ' -f $Value) + $EuroSymbol).Replace(',', ' ') }
  }
}

function Format-Pct {
  param([double]$Current, [double]$Previous)

  if ($Previous -eq 0) { return [pscustomobject]@{ Text = '—'; Direction = '' } }

  $pct   = (($Current - $Previous) / $Previous) * 100
  $arrow = if ($pct -ge 0) { [char]0x2191 } else { [char]0x2193 }
  $sign  = if ($pct -ge 0) { '+' } else { '' }
  $dir   = if ($pct -ge 0) { 'up' } else { 'dn' }

  return [pscustomobject]@{
    Text      = "$arrow $sign$([string]::Format('{0:N2}', $pct))%"
    Direction = $dir
  }
}

function Replace-MarketValue {
  param(
    [string]$Html,
    [string]$Id,
    [string]$Value
  )

  $pattern = "(<div class=`"market-val`" id=`"mval-$Id`">)(.*?)(</div>)"
  $regex = [regex]::new($pattern)
  return $regex.Replace($Html, { param($m) $m.Groups[1].Value + $Value + $m.Groups[3].Value }, 1)
}

function Replace-MarketSecondary {
  param(
    [string]$Html,
    [string]$Id,
    [string]$Value,
    [string]$Direction = ''
  )

  $newClass = if ($Direction) { "market-chg $Direction" } else { "market-chg" }
  $pattern = "(<div class=`"market-chg(?: [^`"]+)?`" id=`"mchg-$Id`">)(.*?)(</div>)"
  $regex = [regex]::new($pattern)
  return $regex.Replace($Html, { param($m) "<div class=`"$newClass`" id=`"mchg-$Id`">$Value</div>" }, 1)
}

function Set-MarketSnapshot {
  param(
    [string]$Html,
    [hashtable]$Snapshot
  )

  foreach ($key in $Snapshot.Keys) {
    $Html = Replace-MarketValue -Html $Html -Id $key -Value $Snapshot[$key].UsdText
    $Html = Replace-MarketSecondary -Html $Html -Id $key -Value $Snapshot[$key].PctText -Direction $Snapshot[$key].Direction
  }

  $Html = [regex]::Replace($Html, '<!--\s*.*?MARKETS.*?markets\.js.*?-->', '<!-- MARKETS - static last close snapshot (written at build time) -->')
  $Html = $Html -replace '<script src="\.\./\.\./markets\.js"></script>\s*', ''

  return $Html
}

$resolvedPaths = @()
foreach ($entry in $Path) {
  $resolvedPaths += Get-ChildItem -Path $entry -File | Select-Object -ExpandProperty FullName
}

$resolvedPaths = $resolvedPaths | Sort-Object -Unique
if (-not $resolvedPaths -or $resolvedPaths.Count -eq 0) {
  throw 'No issue files matched the provided path.'
}

foreach ($issuePath in $resolvedPaths) {
  $html = Get-Content -Raw $issuePath
  if ($html -notmatch 'mval-btc' -or $html -notmatch 'mchg-gold') { continue }

  $issueDate = Parse-IssueDate $html
  $targetDate = $issueDate.AddDays(-1)

  $eurUsd = Get-FxSnapshot -TargetDate $targetDate
  $btc = Get-CryptoSnapshot -TargetDate $targetDate
  $spy = Get-StockSnapshot -Symbol 'SPY' -TargetDate $targetDate
  $msci = Get-StockSnapshot -Symbol 'URTH' -TargetDate $targetDate
  $gold = Get-StockSnapshot -Symbol 'GLD' -TargetDate $targetDate

  $btcPct    = Format-Pct -Current $btc.Usd       -Previous $btc.PreviousUsd
  $spyPct    = Format-Pct -Current $spy.Usd       -Previous $spy.PreviousUsd
  $msciPct   = Format-Pct -Current $msci.Usd      -Previous $msci.PreviousUsd
  $goldPct   = Format-Pct -Current $gold.Usd      -Previous $gold.PreviousUsd
  $eurusdPct = Format-Pct -Current $eurUsd.EurUsd -Previous $eurUsd.PreviousEurUsd

  $snapshot = @{
    'btc' = @{
      UsdText   = Format-Usd -Value $btc.Usd -Mode 'whole'
      PctText   = $btcPct.Text
      Direction = $btcPct.Direction
    }
    'spy' = @{
      UsdText   = Format-Usd -Value $spy.Usd -Mode 'default'
      PctText   = $spyPct.Text
      Direction = $spyPct.Direction
    }
    'eurusd' = @{
      UsdText   = Format-Usd -Value $eurUsd.EurUsd -Mode 'fx'
      PctText   = $eurusdPct.Text
      Direction = $eurusdPct.Direction
    }
    'msci' = @{
      UsdText   = Format-Usd -Value $msci.Usd -Mode 'default'
      PctText   = $msciPct.Text
      Direction = $msciPct.Direction
    }
    'gold' = @{
      UsdText   = Format-Usd -Value ($gold.Usd * 10) -Mode 'whole'
      PctText   = $goldPct.Text
      Direction = $goldPct.Direction
    }
  }

  $updated = Set-MarketSnapshot -Html $html -Snapshot $snapshot
  Set-Content -Path $issuePath -Value $updated -Encoding UTF8

  Write-Host "Updated $issuePath using close data up to $($targetDate.ToString('yyyy-MM-dd'))."
}
