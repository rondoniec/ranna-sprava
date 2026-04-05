param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Path = @('vydania/*/index.html')
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Slovakia-wide weather is built from several representative locations.
$ForecastPoints = @(
  @{ Name = 'Bratislava';       QueryName = 'Bratislava';       Lat = 48.1486; Lon = 17.1077 },
  @{ Name = 'Zilina';           QueryName = 'Zilina';           Lat = 49.2232; Lon = 18.7394 },
  @{ Name = 'Banska Bystrica';  QueryName = 'Banska Bystrica';  Lat = 48.7363; Lon = 19.1462 },
  @{ Name = 'Poprad';           QueryName = 'Poprad';           Lat = 49.0584; Lon = 20.2979 },
  @{ Name = 'Kosice';           QueryName = 'Kosice';           Lat = 48.7164; Lon = 21.2611 }
)

# No literal non-ASCII chars in script source because Windows PowerShell 5 may
# misread them depending on file encoding.
$deg   = [char]0x00B0
$ndash = [char]0x2013
$mid   = [char]0x00B7

$cSH = [char]0x0160
$cA  = [char]0x00E1
$cC  = [char]0x010D
$cD  = [char]0x010F
$cE  = [char]0x00E9
$cI  = [char]0x00ED
$cU  = [char]0x00FA
$cY  = [char]0x00FD
$cZ  = [char]0x017E

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

function Get-WeatherEmoji {
  param([int]$Code)
  $sunny   = [System.Char]::ConvertFromUtf32(0x2600)  + [char]0xFE0F
  $pcloudy = [System.Char]::ConvertFromUtf32(0x1F324) + [char]0xFE0F
  $cloudy  = [System.Char]::ConvertFromUtf32(0x2601)  + [char]0xFE0F
  $fog     = [System.Char]::ConvertFromUtf32(0x1F32B) + [char]0xFE0F
  $drizzle = [System.Char]::ConvertFromUtf32(0x1F326) + [char]0xFE0F
  $rain    = [System.Char]::ConvertFromUtf32(0x1F327) + [char]0xFE0F
  $snow    = [System.Char]::ConvertFromUtf32(0x2744)  + [char]0xFE0F
  $hsnow   = [System.Char]::ConvertFromUtf32(0x1F328) + [char]0xFE0F
  $storm   = [System.Char]::ConvertFromUtf32(0x26C8)  + [char]0xFE0F

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
  if ($Code -eq 0)                     { return 'Jasno'                                            }
  if ($Code -eq 1)                     { return 'Preva' + $cZ + 'ne jasno'                         }
  if ($Code -eq 2)                     { return 'Polojasno'                                        }
  if ($Code -eq 3)                     { return 'Zamra' + $cC + 'ene'                              }
  if ($Code -in @(45, 48))             { return 'Hmla'                                             }
  if ($Code -in @(51, 53, 55))         { return 'Mrholenie'                                        }
  if ($Code -in @(56, 57))             { return 'Mrzn' + $cU + 'ce mrholenie'                      }
  if ($Code -in @(61, 63))             { return 'Da' + $cZ + $cD + 'ovo'                           }
  if ($Code -eq 65)                    { return 'Siln' + $cY + ' da' + $cZ + $cD                   }
  if ($Code -in @(66, 67))             { return 'Mrzn' + $cU + 'ci da' + $cZ + $cD                 }
  if ($Code -in @(71, 73))             { return 'Sne' + $cZ + 'enie'                               }
  if ($Code -eq 75)                    { return 'Siln' + $cE + ' sne' + $cZ + 'enie'               }
  if ($Code -eq 77)                    { return 'Snehov' + $cE + ' zrn' + $cA                      }
  if ($Code -in @(80, 81, 82))         { return 'Preh' + $cA + 'nky'                               }
  if ($Code -in @(85, 86))             { return 'Snehov' + $cE + ' preh' + $cA + 'nky'             }
  if ($Code -eq 95)                    { return 'B' + $cU + 'rka'                                  }
  if ($Code -in @(96, 99))             { return 'B' + $cU + 'rka s kr' + $cU + 'pobit' + $cI + 'm' }
  return 'Polojasno'
}

function Get-DayAbbrev {
  param([int]$DotNetDayOfWeek)
  $days = @('Ne', 'Po', 'Ut', 'St', ($cSH + 't'), 'Pi', 'So')
  return $days[$DotNetDayOfWeek]
}

function Get-ConditionBucket {
  param([int]$Code)
  if ($Code -eq 0)                     { return 'clear' }
  if ($Code -in @(1, 2, 3))            { return 'cloud' }
  if ($Code -in @(45, 48))             { return 'fog' }
  if ($Code -in @(51, 53, 55, 56, 57)) { return 'drizzle' }
  if ($Code -in @(61, 63, 65, 66, 67, 80, 81, 82)) { return 'rain' }
  if ($Code -in @(71, 73, 75, 77, 85, 86))         { return 'snow' }
  if ($Code -in @(95, 96, 99))         { return 'storm' }
  return 'cloud'
}

function Get-BucketSeverity {
  param([string]$Bucket)
  switch ($Bucket) {
    'storm'   { return 6 }
    'snow'    { return 5 }
    'rain'    { return 4 }
    'drizzle' { return 3 }
    'fog'     { return 2 }
    'cloud'   { return 1 }
    default   { return 0 }
  }
}

function Test-EmergencyWeatherSplit {
  param([object[]]$Records)

  $maxSpread = [int](($Records | Measure-Object Max -Maximum).Maximum - ($Records | Measure-Object Max -Minimum).Minimum)
  $minSpread = [int](($Records | Measure-Object Min -Maximum).Maximum - ($Records | Measure-Object Min -Minimum).Minimum)

  $hasSnowOrStorm = @($Records | Where-Object { $_.Bucket -in @('snow', 'storm') }).Count -gt 0
  $hasClearOrCloud = @($Records | Where-Object { $_.Bucket -in @('clear', 'cloud') }).Count -gt 0
  $hasFreeze = @($Records | Where-Object { $_.Max -le 1 -or $_.Min -le -5 }).Count -gt 0
  $hasWarm = @($Records | Where-Object { $_.Max -ge 13 }).Count -gt 0

  if (($maxSpread -ge 14) -or ($minSpread -ge 14)) { return $true }
  if (@($Records | Where-Object { $_.Bucket -eq 'storm' }).Count -gt 0 -and $hasClearOrCloud -and ($maxSpread -ge 8 -or $minSpread -ge 8)) { return $true }
  if (@($Records | Where-Object { $_.Bucket -eq 'snow' }).Count -gt 0 -and @($Records | Where-Object { $_.Bucket -eq 'clear' }).Count -gt 0 -and ($maxSpread -ge 10 -or $minSpread -ge 10)) { return $true }
  if ($hasFreeze -and $hasWarm) { return $true }

  return $false
}

function Build-DayRecord {
  param([datetime]$Date, [int]$TempMin, [int]$TempMax, [int]$WmoCode, [int]$PrecipPct)
  $emoji  = Get-WeatherEmoji -Code $WmoCode
  $desc   = Get-WeatherDesc  -Code $WmoCode
  $abbrev = Get-DayAbbrev    -DotNetDayOfWeek ([int]$Date.DayOfWeek)
  return [pscustomobject]@{
    Date      = $Date
    Min       = $TempMin
    Max       = $TempMax
    WmoCode   = $WmoCode
    PrecipPct = $PrecipPct
    Bucket    = Get-ConditionBucket -Code $WmoCode
    Abbrev    = $abbrev
    TempStr   = "$TempMin$deg $ndash $TempMax$deg"
    Emoji     = $emoji
    CondStr   = "$emoji $abbrev $mid $desc"
    PrecipStr = "$PrecipPct%"
  }
}

function Get-OpenMeteoLocationDays {
  param([hashtable]$Point, [datetime]$IssueDate)

  $issueStart = $IssueDate.Date
  $issueEnd   = $IssueDate.Date.AddDays(5)
  $today      = (Get-Date).Date
  $baseParams = ('?latitude=' + $Point.Lat +
                 '&longitude=' + $Point.Lon +
                 '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode' +
                 '&timezone=Europe%2FBratislava')

  if ($issueEnd -lt $today) {
    $url = ('https://archive-api.open-meteo.com/v1/archive' +
            $baseParams +
            '&start_date=' + $issueStart.ToString('yyyy-MM-dd') +
            '&end_date=' + $issueEnd.ToString('yyyy-MM-dd'))
  } elseif ($issueStart -ge $today) {
    $url = ('https://api.open-meteo.com/v1/forecast' +
            $baseParams +
            '&start_date=' + $issueStart.ToString('yyyy-MM-dd') +
            '&end_date=' + $issueEnd.ToString('yyyy-MM-dd'))
  } else {
    $pastDays = [math]::Max(0, ($today - $issueStart).Days)
    $forecastDays = [math]::Max(1, ($issueEnd - $today).Days + 1)
    $url = ('https://api.open-meteo.com/v1/forecast' +
            $baseParams +
            '&past_days=' + $pastDays +
            '&forecast_days=' + $forecastDays)
  }

  $r     = Invoke-RestMethod -Uri $url
  $daily = $r.daily
  if (-not $daily -or -not $daily.time) {
    throw ("Open-Meteo returned no daily block for " + $Point.Name)
  }
  $tStr  = $IssueDate.ToString('yyyy-MM-dd')

  $idx = -1
  for ($i = 0; $i -lt $daily.time.Count; $i++) {
    if ($daily.time[$i] -eq $tStr) { $idx = $i; break }
  }
  if ($idx -lt 0) {
    throw ("Open-Meteo: date $tStr not found for " + $Point.Name)
  }

  $days = @()
  for ($d = 0; $d -le 5; $d++) {
    $i = $idx + $d
    if ($i -ge $daily.time.Count) { break }
    $date = [datetime]::ParseExact($daily.time[$i], 'yyyy-MM-dd', $null)
    $tmax = [int][math]::Round([double]$daily.temperature_2m_max[$i])
    $tmin = [int][math]::Round([double]$daily.temperature_2m_min[$i])
    $wmo  = [int]$daily.weathercode[$i]
    $prec = if ($null -ne $daily.precipitation_probability_max[$i]) {
      [int]$daily.precipitation_probability_max[$i]
    } else {
      0
    }
    $days += Build-DayRecord -Date $date -TempMin $tmin -TempMax $tmax -WmoCode $wmo -PrecipPct $prec
  }

  return [pscustomobject]@{
    Location = $Point.Name
    Days = $days
  }
}

function Get-WttrLocationDays {
  param([hashtable]$Point, [datetime]$IssueDate)

  $query   = [uri]::EscapeDataString($Point.QueryName)
  $url     = "https://wttr.in/$query?format=j1"
  $headers = @{ 'User-Agent' = 'Mozilla/5.0 (compatible; ranna-sprava/1.0)' }
  $r       = Invoke-RestMethod -Uri $url -Headers $headers
  if (-not $r.weather) {
    throw ("wttr.in returned no weather array for " + $Point.Name)
  }
  $tStr    = $IssueDate.ToString('yyyy-MM-dd')

  $idx = -1
  for ($i = 0; $i -lt $r.weather.Count; $i++) {
    if ($r.weather[$i].date -eq $tStr) { $idx = $i; break }
  }
  if ($idx -lt 0) { $idx = 0 }

  $days = @()
  for ($d = 0; $d -le 5; $d++) {
    $i = $idx + $d
    if ($i -ge $r.weather.Count) { break }
    $w    = $r.weather[$i]
    $date = [datetime]::ParseExact($w.date, 'yyyy-MM-dd', $null)
    $tmax = [int]$w.maxtempC
    $tmin = [int]$w.mintempC
    $slot = $w.hourly | Where-Object { $_.time -eq '1200' } | Select-Object -First 1
    if (-not $slot -and $w.hourly) { $slot = $w.hourly[0] }
    $wmo  = if ($slot.weatherCode) { [int]$slot.weatherCode } else { 2 }
    $prec = if ($slot.chanceofrain) { [int]$slot.chanceofrain } else { 0 }
    $days += Build-DayRecord -Date $date -TempMin $tmin -TempMax $tmax -WmoCode $wmo -PrecipPct $prec
  }

  return [pscustomobject]@{
    Location = $Point.Name
    Days = $days
  }
}

function Merge-CountryDays {
  param([object[]]$LocationDaySets)

  $countryDays = @()

  for ($d = 0; $d -le 5; $d++) {
    $records = @()
    foreach ($set in $LocationDaySets) {
      if ($set.Days.Count -le $d) { continue }
      $row = [pscustomobject]@{
        Location  = $set.Location
        Date      = $set.Days[$d].Date
        Min       = $set.Days[$d].Min
        Max       = $set.Days[$d].Max
        WmoCode   = $set.Days[$d].WmoCode
        PrecipPct = $set.Days[$d].PrecipPct
        Bucket    = $set.Days[$d].Bucket
      }
      $records += $row
    }

    if ($records.Count -eq 0) { continue }

    $date       = $records[0].Date
    $minTemp    = [int][math]::Round((($records | Measure-Object Min -Average).Average))
    $maxTemp    = [int][math]::Round((($records | Measure-Object Max -Average).Average))
    $avgPrecip  = [int][math]::Round((($records | Measure-Object PrecipPct -Average).Average))

    $bucketGroups = $records | Group-Object Bucket | ForEach-Object {
      [pscustomobject]@{
        Bucket   = $_.Name
        Count    = $_.Count
        Severity = Get-BucketSeverity -Bucket $_.Name
      }
    }
    $dominantBucket = ($bucketGroups | Sort-Object Count, Severity -Descending | Select-Object -First 1).Bucket
    $bucketRecords  = $records | Where-Object { $_.Bucket -eq $dominantBucket }
    $modeCode       = [int](($bucketRecords | Group-Object WmoCode | Sort-Object Count -Descending | Select-Object -First 1).Name)

    $countryDays += Build-DayRecord -Date $date -TempMin $minTemp -TempMax $maxTemp -WmoCode $modeCode -PrecipPct $avgPrecip

    if (Test-EmergencyWeatherSplit -Records $records) {
      $maxSpread = [int](($records | Measure-Object Max -Maximum).Maximum - ($records | Measure-Object Max -Minimum).Minimum)
      $minSpread = [int](($records | Measure-Object Min -Maximum).Maximum - ($records | Measure-Object Min -Minimum).Minimum)
      $warmest = $records | Sort-Object Max -Descending | Select-Object -First 1
      $coldest = $records | Sort-Object Max            | Select-Object -First 1
      $patterns = (($records | Select-Object -ExpandProperty Bucket -Unique) -join ', ')
      Write-Warning ("  [CONSULT] Slovakia weather emergency split on {0}: {1} max {2}{3}, {4} max {5}{3}, spread max {6}{3}, spread min {7}{3}, patterns {8}. Ask the user before final output." -f `
        $date.ToString('yyyy-MM-dd'),
        $warmest.Location,
        $warmest.Max,
        $deg,
        $coldest.Location,
        $coldest.Max,
        $maxSpread,
        $minSpread,
        $patterns)
    }
  }

  return $countryDays
}

function Get-WeatherDays {
  param([datetime]$IssueDate)

  try {
    $sets = foreach ($point in $ForecastPoints) {
      Get-OpenMeteoLocationDays -Point $point -IssueDate $IssueDate
    }
    if (@($sets).Count -lt 3) { throw 'Open-Meteo returned too few Slovakia points.' }
    Write-Host ('  Weather source: Open-Meteo (Slovakia aggregate from ' + (@($sets).Count) + ' locations)')
    return Merge-CountryDays -LocationDaySets $sets
  } catch {
    Write-Warning "  [Weather] Open-Meteo failed: $_"
  }

  try {
    $sets = foreach ($point in $ForecastPoints) {
      Get-WttrLocationDays -Point $point -IssueDate $IssueDate
    }
    if (@($sets).Count -lt 3) { throw 'wttr.in returned too few Slovakia points.' }
    Write-Host ('  Weather source: wttr.in fallback (Slovakia aggregate from ' + (@($sets).Count) + ' locations)')
    return Merge-CountryDays -LocationDaySets $sets
  } catch {
    Write-Warning "  [Weather] wttr.in failed: $_"
  }

  throw ("All weather sources failed for " + $IssueDate.ToString('yyyy-MM-dd') + '.')
}

function Replace-WeatherField {
  param([string]$Html, [string]$Id, [string]$Value)
  $p = '(<[^>]+\bid="' + $Id + '"[^>]*>)([\s\S]*?)(</div>)'
  return ([regex]::new($p)).Replace($Html, { param($m) $m.Groups[1].Value + $Value + $m.Groups[3].Value }, 1)
}

function Set-WeatherSnapshot {
  param([string]$Html, [datetime]$IssueDate)
  $days = Get-WeatherDays -IssueDate $IssueDate

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

  if ($html -notmatch 'wval-today-temp' -or $html -notmatch 'wval-d1-temp') {
    Write-Host ("Skipping " + $issuePath + " (no weather IDs found)")
    continue
  }

  $issueDate = Parse-IssueDate $html
  Write-Host ("Processing " + $issuePath + "  (issue date: " + $issueDate.ToString('yyyy-MM-dd') + ")")

  $updated = Set-WeatherSnapshot -Html $html -IssueDate $issueDate
  [System.IO.File]::WriteAllText($issuePath, $updated, $Utf8NoBom)
  Write-Host '  OK: Done'
}
