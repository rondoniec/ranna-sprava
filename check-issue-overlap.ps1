param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
  throw "Issue file not found: $Path"
}

$html = Get-Content -LiteralPath $Path -Raw -Encoding UTF8

function Get-PlainText {
  param([string]$Value)

  if (-not $Value) {
    return ''
  }

  $decoded = [System.Net.WebUtility]::HtmlDecode($Value)
  $stripped = [regex]::Replace($decoded, '<[^>]+>', ' ')
  $collapsed = [regex]::Replace($stripped, '\s+', ' ')
  return $collapsed.Trim()
}

function Get-Stem {
  param([string]$Token)

  if (-not $Token) {
    return ''
  }

  $normalized = $Token.Normalize([Text.NormalizationForm]::FormD)
  $builder = New-Object System.Text.StringBuilder

  foreach ($char in $normalized.ToCharArray()) {
    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($char) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$builder.Append($char)
    }
  }

  $ascii = $builder.ToString().ToLowerInvariant()
  if ($ascii.Length -gt 6) {
    return $ascii.Substring(0, 6)
  }

  return $ascii
}

$stopwords = @(
  'a', 'aj', 'ako', 'ale', 'ani', 'asi', 'bez', 'bola', 'boli', 'bolo', 'bol',
  'budu', 'by', 'co', 'do', 'dna', 'dnes', 'ho', 'ich', 'ina', 'ine', 'iny',
  'je', 'jej', 'jeho', 'ju', 'kde', 'ked', 'ktora', 'ktore', 'ktori', 'ktory',
  'len', 'ma', 'maju', 'medzi', 'mi', 'na', 'nad', 'nam', 'nas', 'ne', 'nez',
  'nie', 'no', 'od', 'po', 'pod', 'podla', 'pre', 'pri', 'sa', 'si', 'so',
  'su', 'ten', 'tento', 'tej', 'to', 'toho', 'tu', 'tym', 'u', 'uz', 'v', 'vo', 'z',
  'za', 'ze', 'eu', 'unia', 'summi', 'issue', 'vydan', 'cislo', 'den', 'tyzde',
  'sprav', 'tema', 'tema', 'tema', 'today', 'this', 'that', 'with', 'from',
  'into', 'after', 'before', 'will', 'have', 'more', 'than', 'also', 'only',
  'bola', 'bude', 'bolo', 'slovak', 'sloven', 'slovak', 'world', 'europ', 'rada',
  'domov', 'vychod', 'konfli', 'medzit', 'miliar', 'polici', 'zapali', 'bezpec',
  'premie', 'pripad', 'pozorn', 'podpor', 'jeden', 'najma', 'projek', 'poisto',
  'social', 'pocas', 'este'
)

$genericStems = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($word in $stopwords) {
  [void]$genericStems.Add((Get-Stem $word))
}

function Get-TopicSignature {
  param([string]$Text)

  $plain = Get-PlainText $Text
  $matches = [regex]::Matches($plain, '[\p{L}\p{N}]{4,}')
  $stems = New-Object System.Collections.Generic.List[string]
  $numbers = New-Object System.Collections.Generic.List[string]

  foreach ($match in $matches) {
    $token = $match.Value
    if ($token -match '^\d+$') {
      if ($token.Length -ge 2 -and $token -notin @('2026', '2025', '2024', '2023', '2022', '2021')) {
        $numbers.Add($token)
      }
      continue
    }

    $stem = Get-Stem $token
    if ($stem.Length -lt 4) {
      continue
    }

    if ($genericStems.Contains($stem)) {
      continue
    }

    $stems.Add($stem)
  }

  [pscustomobject]@{
    PlainText = $plain
    Stems = $stems
    Numbers = $numbers
  }
}

$blocks = New-Object System.Collections.Generic.List[object]

$mainMatch = [regex]::Match($html, '<!--\s*HLAVN[\s\S]*?-->(?<body>[\s\S]*?)<!--\s*PREHLIADKA', 'IgnoreCase')
if ($mainMatch.Success) {
  $blocks.Add([pscustomobject]@{
      Label = 'Hlavna tema'
      Kind = 'main'
      Text = Get-PlainText $mainMatch.Groups['body'].Value
    })
}

$tourSectionMatch = [regex]::Match($html, '<!--\s*PREHLIADKA[\s\S]*?-->(?<body>[\s\S]*?)<!--\s*..SLO', 'IgnoreCase')
if ($tourSectionMatch.Success) {
  $tourMatches = [regex]::Matches($tourSectionMatch.Groups['body'].Value, '<div class="tour-item">\s*<div class="tour-hed">(?<hed>[\s\S]*?)</div>\s*<p>(?<body>[\s\S]*?)</p>\s*</div>', 'IgnoreCase')
  $index = 1
  foreach ($match in $tourMatches) {
    $blocks.Add([pscustomobject]@{
        Label = "Prehliadka $index"
        Kind = 'tour'
        Text = ((Get-PlainText $match.Groups['hed'].Value) + ' ' + (Get-PlainText $match.Groups['body'].Value)).Trim()
      })
    $index++
  }
}

$statMatch = [regex]::Match($html, '<div class="stat">[\s\S]*?<div class="stat-label">(?<label>[\s\S]*?)</div>\s*<div class="stat-body">(?<body>[\s\S]*?)</div>', 'IgnoreCase')
if ($statMatch.Success) {
  $blocks.Add([pscustomobject]@{
      Label = 'Cislo dna'
      Kind = 'number'
      Text = ((Get-PlainText $statMatch.Groups['label'].Value) + ' ' + (Get-PlainText $statMatch.Groups['body'].Value)).Trim()
    })
}

$calSectionMatch = [regex]::Match($html, '<!--\s*TENTO[\s\S]*?-->(?<body>[\s\S]*?)<!--\s*SLOVO', 'IgnoreCase')
if ($calSectionMatch.Success) {
  $calMatches = [regex]::Matches($calSectionMatch.Groups['body'].Value, '<div class="cal-item">[\s\S]*?<span>(?<body>[\s\S]*?)</span>\s*</div>', 'IgnoreCase')
  $index = 1
  foreach ($match in $calMatches) {
    $blocks.Add([pscustomobject]@{
        Label = "Tento tyzden $index"
        Kind = 'calendar'
        Text = Get-PlainText $match.Groups['body'].Value
      })
    $index++
  }
}

if ($blocks.Count -lt 2) {
  throw "Could not parse enough issue blocks from $Path"
}

$signatures = @{}
$documentFrequency = @{}

foreach ($block in $blocks) {
  $signature = Get-TopicSignature $block.Text
  $signatures[$block.Label] = $signature

  $uniqueStems = $signature.Stems | Sort-Object -Unique
  foreach ($stem in $uniqueStems) {
    if (-not $documentFrequency.ContainsKey($stem)) {
      $documentFrequency[$stem] = 0
    }
    $documentFrequency[$stem]++
  }
}

$findings = New-Object System.Collections.Generic.List[object]

for ($i = 0; $i -lt $blocks.Count; $i++) {
  for ($j = $i + 1; $j -lt $blocks.Count; $j++) {
    $left = $blocks[$i]
    $right = $blocks[$j]
    $leftSig = $signatures[$left.Label]
    $rightSig = $signatures[$right.Label]

    $leftFiltered = $leftSig.Stems | Where-Object { $documentFrequency[$_] -le 2 } | Sort-Object -Unique
    $rightFiltered = $rightSig.Stems | Where-Object { $documentFrequency[$_] -le 2 } | Sort-Object -Unique
    $sharedStems = $leftFiltered | Where-Object { $rightFiltered -contains $_ }
    $sharedNumbers = ($leftSig.Numbers | Sort-Object -Unique) | Where-Object { ($rightSig.Numbers | Sort-Object -Unique) -contains $_ }

    $sharedStemCount = @($sharedStems).Count
    $sharedNumberCount = @($sharedNumbers).Count

    $mustBeUnique = (
      ($left.Kind -in @('number', 'calendar') -or $right.Kind -in @('number', 'calendar')) -or
      ($left.Kind -eq 'tour' -and $right.Kind -eq 'tour')
    )

    $isOverlap = $false
    if ($mustBeUnique -and $sharedStemCount -ge 2) {
      $isOverlap = $true
    }
    elseif ($mustBeUnique -and $sharedStemCount -ge 1 -and $sharedNumberCount -ge 1) {
      $isOverlap = $true
    }
    elseif ($sharedStemCount -ge 3 -and $sharedNumberCount -ge 1) {
      $isOverlap = $true
    }

    if ($isOverlap) {
      $findings.Add([pscustomobject]@{
          Left = $left.Label
          Right = $right.Label
          SharedStems = @($sharedStems)
          SharedNumbers = @($sharedNumbers)
        })
    }
  }
}

if ($findings.Count -gt 0) {
  Write-Host "Duplicate story overlap detected in $Path" -ForegroundColor Red
  foreach ($finding in $findings) {
    $stemText = if ($finding.SharedStems.Count -gt 0) { ($finding.SharedStems -join ', ') } else { '-' }
    $numberText = if ($finding.SharedNumbers.Count -gt 0) { ($finding.SharedNumbers -join ', ') } else { '-' }
    Write-Host ""
    Write-Host " - $($finding.Left) <-> $($finding.Right)" -ForegroundColor Yellow
    Write-Host "   Shared keywords: $stemText"
    Write-Host "   Shared numbers: $numberText"
  }
  exit 1
}

Write-Host "No duplicate story overlap detected in $Path" -ForegroundColor Green
