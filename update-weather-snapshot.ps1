param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Path = @('vydania/*/index.html')
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Bratislava coordinates (default location for Slovensko forecast)
$Lat = 48.1486
$Lon = 17.1077

# ── UNICODE HELPERS ───────────────────────────────────────────────────────────
#    No literal non-ASCII chars in script source — PS5 reads the script as ANSI
#    and would corrupt them.  Build every Slovak character via [char] code point.

$deg   = [char]0x00B0   # °
$ndash = [char]0x2013   # –  (en dash)
$mid   = [char]0x00B7   # ·  (middle dot)

# Uppercase
$cSH = [char]0x0160     # Š

# Lowercase diacritics used in condition descriptions and day names
$cA  = [char]0x00E1     # á
$cC  = [char]0x010D     # č
$cD  = [char]0x010F     # ď
$cE  = [char]0x00E9     # é
$cI  = [char]0x00ED     # í
$cU  = [char]0x00FA     # ú
$cY  = [char]0x00FD     # ý
$cZ  = [char]0x017E     # ž

# ── DATE PARSING (mirrors update-market-snapshot.ps1) ─────────────────────────
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
    '<div class="mast-date-bar">\s*<span>[^<]*?(\d{1,2})\.\s*([^\s<]+)\s+(\d{4})</span>',
    '<title>[^<]*?(\d{1,2})\.\s*([^\s<]+)\s+(\d{4})</title>'
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
    if (-not $months.ContainsKey($tok)) { continue }
    return [datetime]::new($yr, $months[$tok], $day)
  }
  throw 'Could not parse issue date from HTML.'
}

# ── WMO WEATHER CODE → EMOJI / DESCRIPTION ────────────────────────────────────
#    WMO 4677 codes — the same system used by both Open-Meteo and wttr.in.
#    Emoji built via ConvertFromUtf32 so surrogate pairs work in PS5 without
#    embedding literal high-codepoint characters in the script source.

function Get-WeatherEmoji {
  param([int]$Code)
  $sunny   = [System.Char]::ConvertFromUtf32(0x2600)  + [char]0xFE0F   # ☀️
  $pcloudy = [System.Char]::ConvertFromUtf32(0x1F324) + [char]0xFE0F   # 🌤️
  $cloudy  = [System.Char]::ConvertFromUtf32(0x2601)  + [char]0xFE0F   # ☁️
  $fog     = [System.Char]::ConvertFromUtf32(0x1F32B) + [char]0xFE0F   # 🌫️
  $drizzle = [System.Char]::ConvertFromUtf32(0x1F326) + [char]0xFE0F   # 🌦️
  $rain    = [System.Char]::ConvertFromUtf32(0x1F327) + [char]0xFE0F   # 🌧️
  $snow    = [System.Char]::ConvertFromUtf32(0x2744)  + [char]0xFE0F   # ❄️
  $hsnow   = [System.Char]::ConvertFromUtf32(0x1F328) + [char]0xFE0F   # 🌨️
  $storm   = [System.Char]::ConvertFromUtf32(0x26C8)  + [char]0xFE0F   # ⛈️

  if ($Code -eq 0)                     { return $sunny   }
  if ($Code -in @(1, 2))               { return $pcloudy }
  if ($Code -eq 3)                     { return $cloudy  }
  if ($Code -in @(45, 48))             { return $fog     }
  if ($Code -in @(51, 53, 55, 56, 57)) { return $drizzle }
  if ($Code -in @(61, 63, 65, 66, 67)) { return $rain    }
  if ($Code -in @(71, 73, 75, 77))     { return $snow    }
  if ($Code -in @(80, 81, 82))         { return $rain    }
  if ($Code -in @(85, 86))             { return $hsnow   }
  if ($Code -in @(95, 96, 99))         { return $storm   }
  return $pcloudy
}

function Get-WeatherDesc {
  param([int]$Code)
  # Every Slovak string assembled from [char] variables — no literal diacritics.
  if ($Code -eq 0)                     { return 'Jasno'                                                }
  if ($Code -eq 1)                     { return 'Preva' + $cZ + 'ne jasno'                             }
  if ($Code -eq 2)                     { return 'Polojasno'                                            }
  if ($Code -eq 3)                     { return 'Zamra' + $cC + 'en' + $cE                             }
  if ($Code -in @(45, 48))             { return 'Hmla'                                                 }
  if ($Code -in @(51, 53, 55))         { return 'Mrholenie'                                            }
  if ($Code -in @(56, 57))             { return 'Mrzn' + $cU + 'ce mrholenie'                          }
  if ($Code -in @(61, 63))             { return 'Da' + $cZ + $cD + 'ovo'                               }
  if ($Code -eq 65)                    { return 'Siln' + $cY + ' da' + $cZ + $cD                       }
  if ($Code -in @(66, 67))             { return 'Mrzn' + $cU + 'ci da' + $cZ + $cD                     }
  if ($Code -in @(71, 73))             { return 'Sne' + $cZ + 'enie'                                   }
  if ($Code -eq 75)                    { return 'Siln' + $cE + ' sne' + $cZ + 'enie'                   }
  if ($Code -eq 77)                    { return 'Snehov' + $cE + ' zrn' + $cA                          }
  if ($Code -in @(80, 81, 82))         { return 'Preh' + $cA + 'nky'                                   }
  if ($Code -in @(85, 86))             { return 'Snehov' + $cE + ' preh' + $cA + 'nky'                 }
  if ($Code -eq 95)                    { return 'B' + $cU + 'rka'                                      }
  if ($Code -in @(96, 99))             { return 'B' + $cU + 'rka s kr' + $cU + 'pobit' + $cI + 'm'     }
  return 'Polojasno'
}

function Get-DayAbbrev {
  param([int]$DotNetDayOfWeek)   # 0=Sunday, 1=Monday … 6=Saturday
  # Only Štv needs a diacritic (Š = [char]0x0160 = $cSH); the rest are ASCII.
  $days = @('Ned', 'Pon', 'Uto', 'Str', ($cSH + 'tv'), 'Pia', 'Sob')
  return $days[$DotNetDayOfWeek]
}

# ── BUILD STANDARDISED DAY RECORD ─────────────────────────────────────────────
function Build-DayRecord {
  param([datetime]$Date, [int]$TempMin, [int]$TempMax, [int]$WmoCode, [int]$PrecipPct)
  $emoji  = Get-WeatherEmoji -Code $WmoCode
  $desc   = Get-WeatherDesc  -Code $WmoCode
  $abbrev = Get-DayAbbrev    -DotNetDayOfWeek ([int]$Date.DayOfWeek)
  return [pscustomobject]@{
    Abbrev    = $abbrev
    TempStr   = "$TempMin$deg $ndash $TempMax$deg"
    Emoji     = $emoji
    CondStr   = "$emoji $abbrev $mid $desc"
    PrecipStr = "$PrecipPct%"
  }
}

# ── PRIMARY: Open-Meteo (free, no API key, 7-14 day forecast) ─────────────────
function Get-OpenMeteoData {
  param([datetime]$IssueDate)
  $url = ('https://api.open-meteo.com/v1/forecast' +
          '?latitude=' + $Lat + '&longitude=' + $Lon +
          '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode' +
          '&timezone=Europe%2FBratislava&forecast_days=8')
  $r     = Invoke-RestMethod -Uri $url
  $daily = $r.daily
  $tStr  = $IssueDate.ToString('yyyy-MM-dd')

  # Find array index matching the issue date
  $idx = -1
  for ($i = 0; $i -lt $daily.time.Count; $i++) {
    if ($daily.time[$i] -eq $tStr) { $idx = $i; break }
  }
  if ($idx -lt 0) {
    throw ("Open-Meteo: date $tStr not found in forecast " +
           "(available: $($daily.time[0]) to $($daily.time[-1])).")
  }

  $days = @()
  for ($d = 0; $d -le 5; $d++) {
    $i = $idx + $d
    if ($i -ge $daily.time.Count) { break }
    $date  = [datetime]::ParseExact($daily.time[$i], 'yyyy-MM-dd', $null)
    $tmax  = [int][math]::Round([double]$daily.temperature_2m_max[$i])
    $tmin  = [int][math]::Round([double]$daily.temperature_2m_min[$i])
    $wmo   = [int]$daily.weathercode[$i]
    $prec  = if ($null -ne $daily.precipitation_probability_max[$i]) {
               [int]$daily.precipitation_probability_max[$i]
             } else { 0 }
    $days += Build-DayRecord -Date $date -TempMin $tmin -TempMax $tmax -WmoCode $wmo -PrecipPct $prec
  }
  return $days
}

# ── FALLBACK: wttr.in (free, no API key, 3-day forecast) ──────────────────────
function Get-WttrData {
  param([datetime]$IssueDate)
  $url     = 'https://wttr.in/Bratislava?format=j1'
  $headers = @{ 'User-Agent' = 'Mozilla/5.0 (compatible; ranna-sprava/1.0)' }
  $r       = Invoke-RestMethod -Uri $url -Headers $headers
  $tStr    = $IssueDate.ToString('yyyy-MM-dd')

  # Find index matching issue date (wttr.in gives today + 2 days)
  $idx = -1
  for ($i = 0; $i -lt $r.weather.Count; $i++) {
    if ($r.weather[$i].date -eq $tStr) { $idx = $i; break }
  }
  if ($idx -lt 0) { $idx = 0 }   # fallback: use first available day

  $days = @()
  for ($d = 0; $d -le 5; $d++) {
    $i = $idx + $d
    if ($i -ge $r.weather.Count) {
      # wttr.in only has 3 days — pad missing days with placeholders
      $days += [pscustomobject]@{
        Abbrev    = '...'
        TempStr   = '...'
        Emoji     = ''
        CondStr   = '...'
        PrecipStr = '...'
      }
      continue
    }
    $w     = $r.weather[$i]
    $date  = [datetime]::ParseExact($w.date, 'yyyy-MM-dd', $null)
    $tmax  = [int]$w.maxtempC
    $tmin  = [int]$w.mintempC
    # Use noon (1200) slot for representative condition; fall back to first slot
    $noon  = $w.hourly | Where-Object { $_.time -eq '1200' } | Select-Object -First 1
    if (-not $noon) { $noon = $w.hourly[0] }
    $wmo   = if ($noon.weatherCode) { [int]$noon.weatherCode } else { 2 }
    $prec  = if ($noon.chanceofrain) { [int]$noon.chanceofrain } else { 0 }
    $days += Build-DayRecord -Date $date -TempMin $tmin -TempMax $tmax -WmoCode $wmo -PrecipPct $prec
  }
  return $days
}

# ── FETCH WITH FALLBACK CHAIN ─────────────────────────────────────────────────
function Get-WeatherDays {
  param([datetime]$IssueDate)
  try {
    $data = Get-OpenMeteoData -IssueDate $IssueDate
    Write-Host "  Weather source: Open-Meteo"
    return $data
  } catch {
    Write-Warning "  [Weather] Open-Meteo failed: $_"
  }
  try {
    $data = Get-WttrData -IssueDate $IssueDate
    Write-Host "  Weather source: wttr.in (fallback)"
    return $data
  } catch {
    Write-Warning "  [Weather] wttr.in failed: $_"
  }
  throw "All weather sources failed for $($IssueDate.ToString('yyyy-MM-dd'))."
}

# ── HTML WRITER ────────────────────────────────────────────────────────────────
#    Replaces content inside any tag that has the given id= attribute.
function Replace-WeatherField {
  param([string]$Html, [string]$Id, [string]$Value)
  $p = '(<[^>]+\bid="' + $Id + '"[^>]*>)([\s\S]*?)(</div>)'
  return ([regex]::new($p)).Replace($Html, { param($m) $m.Groups[1].Value + $Value + $m.Groups[3].Value }, 1)
}

function Set-WeatherSnapshot {
  param([string]$Html, [datetime]$IssueDate)
  $days = Get-WeatherDays -IssueDate $IssueDate

  # $days[0] = today (issue date), $days[1]..$days[5] = forecast
  $today = $days[0]
  $Html = Replace-WeatherField -Html $Html -Id 'wval-today-temp' -Value $today.TempStr
  $Html = Replace-WeatherField -Html $Html -Id 'wval-today-cond' -Value $today.CondStr

  for ($d = 1; $d -le 5; $d++) {
    if ($d -ge $days.Count) { break }
    $day = $days[$d]
    $Html = Replace-WeatherField -Html $Html -Id "wval-d${d}-icon" -Value $day.Emoji
    $Html = Replace-WeatherField -Html $Html -Id "wval-d${d}-name" -Value $day.Abbrev
    $Html = Replace-WeatherField -Html $Html -Id "wval-d${d}-temp" -Value $day.TempStr
    $Html = Replace-WeatherField -Html $Html -Id "wval-d${d}-rain" -Value $day.PrecipStr
  }
  return $Html
}

# ── MAIN ───────────────────────────────────────────────────────────────────────
$resolvedPaths = @()
foreach ($entry in $Path) {
  $resolvedPaths += Get-ChildItem -Path $entry -File | Select-Object -ExpandProperty FullName
}
$resolvedPaths = $resolvedPaths | Sort-Object -Unique

if (-not $resolvedPaths -or $resolvedPaths.Count -eq 0) {
  throw 'No issue files matched the provided path.'
}

foreach ($issuePath in $resolvedPaths) {
  $html = [System.IO.File]::ReadAllText($issuePath, [System.Text.Encoding]::UTF8)

  # Only process files that have weather ID hooks
  if ($html -notmatch 'wval-today-temp' -or $html -notmatch 'wval-d1-temp') {
    Write-Host "Skipping $issuePath (no weather IDs found)"
    continue
  }

  $issueDate = Parse-IssueDate $html
  Write-Host "Processing $issuePath  (issue date: $($issueDate.ToString('yyyy-MM-dd')))"

  $updated = Set-WeatherSnapshot -Html $html -IssueDate $issueDate
  [System.IO.File]::WriteAllText($issuePath, $updated, $Utf8NoBom)
  Write-Host "  OK: Done"
}
