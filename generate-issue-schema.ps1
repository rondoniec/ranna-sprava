# generate-issue-schema.ps1
# Backfills canonical, OG meta, og:image, Twitter meta, and NewsArticle JSON-LD
# into vydania/[N]/index.html pages that are missing them.
# Safe to re-run -- skips any page that already has application/ld+json.
#
# Usage:
#   .\generate-issue-schema.ps1               # dry-run (shows what would change)
#   .\generate-issue-schema.ps1 -Apply        # writes files
#   .\generate-issue-schema.ps1 -Issue 80     # single issue (add -Apply to write)

param(
    [switch]$Apply,
    [int]$Issue = 0
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# ── Parse issues.js ──────────────────────────────────────────────────────────

$issuesJs = Get-Content "$root\issues.js" -Raw -Encoding UTF8
$issues = @{}

$pattern = '(?s)\{\s*number:\s*(\d+),.*?title:\s*"((?:[^"\\]|\\.)*?)".*?date:\s*"(\d{4}-\d{2}-\d{2})".*?dateLabel:\s*"((?:[^"\\]|\\.)*?)".*?preview:\s*"((?:[^"\\]|\\.)*?)".*?\}'
foreach ($m in [regex]::Matches($issuesJs, $pattern)) {
    $n   = [int]$m.Groups[1].Value
    $issues[$n] = @{
        number    = $n
        title     = $m.Groups[2].Value -replace '\\"', '"'
        date      = $m.Groups[3].Value
        dateLabel = $m.Groups[4].Value -replace '\\"', '"'
        preview   = $m.Groups[5].Value -replace '\\"', '"'
    }
}

Write-Host "Parsed $($issues.Count) issues from issues.js"

# ── Helpers ───────────────────────────────────────────────────────────────────

function UrlEncode($s) {
    [System.Uri]::EscapeDataString($s)
}

function EscapeHtml($s) {
    $s -replace '&','&amp;' -replace '"','&quot;' -replace '<','&lt;' -replace '>','&gt;'
}

function FormatOgDate($iss) {
    # Use dateLabel from issues.js (already UTF-8 decoded) + year from date
    # dateLabel is like "Sobota, 18. apríla" -- strip weekday, append year
    $label = $iss.dateLabel -replace '^[^,]+,\s*', ''
    $year  = $iss.date.Split('-')[0]
    return "$label $year"
}

function BuildMetaBlock($iss) {
    $n       = $iss.number
    $title   = $iss.title
    $date    = $iss.date
    $preview = $iss.preview
    $url     = "https://rannasprava.sk/vydania/$n/"

    $titleH  = EscapeHtml $title
    $prevH   = EscapeHtml $preview

    $ogTitle  = $title -replace '\.$',''
    $ogDate   = FormatOgDate $iss
    $ogImg    = "https://og.rannasprava.sk/?n=$n&amp;t=$(UrlEncode $ogTitle)&amp;d=$(UrlEncode $ogDate)"
    $pubTime  = "${date}T08:00:00+02:00"

    return @"
<link rel="canonical" href="$url">
<link rel="alternate" hreflang="sk" href="$url">
<meta name="description" content="$prevH">
<meta property="og:type" content="article">
<meta property="og:title" content="$titleH">
<meta property="og:description" content="$prevH">
<meta property="og:url" content="$url">
<meta property="og:site_name" content="Ranná Správa">
<meta property="og:image" content="$ogImg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="article:published_time" content="$pubTime">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="$titleH">
<meta name="twitter:description" content="$prevH">
"@
}

function BuildInsertBlock($iss) {
    $n       = $iss.number
    $title   = $iss.title
    $date    = $iss.date
    $preview = $iss.preview
    $url     = "https://rannasprava.sk/vydania/$n/"
    $id      = "https://rannasprava.sk/vydania/$n/#article"

    $titleJ   = $title  -replace '"','\"'
    $prevJ    = $preview -replace '"','\"'

    return (BuildMetaBlock $iss) + @"
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "NewsArticle",
      "@id": "$id",
      "headline": "$titleJ",
      "name": "Ranná Správa — Vydanie #$n",
      "description": "$prevJ",
      "url": "$url",
      "datePublished": "$date",
      "dateModified": "$date",
      "inLanguage": "sk",
      "isPartOf": { "@id": "https://rannasprava.sk/#website" },
      "publisher": { "@id": "https://rannasprava.sk/#organization" },
      "author": { "@id": "https://rannasprava.sk/o-nas/#adam-hodosi" }
    },
    {
      "@type": "Organization",
      "@id": "https://rannasprava.sk/#organization",
      "name": "Ranná Správa",
      "url": "https://rannasprava.sk"
    },
    {
      "@type": "Person",
      "@id": "https://rannasprava.sk/o-nas/#adam-hodosi",
      "name": "Adam Hodoši",
      "jobTitle": "Zakladateľ a šéfredaktor",
      "url": "https://rannasprava.sk/o-nas/"
    },
    {
      "@type": "WebSite",
      "@id": "https://rannasprava.sk/#website",
      "url": "https://rannasprava.sk",
      "name": "Ranná Správa"
    },
    {
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Domov", "item": "https://rannasprava.sk/" },
        { "@type": "ListItem", "position": 2, "name": "Archív", "item": "https://rannasprava.sk/#archiv" },
        { "@type": "ListItem", "position": 3, "name": "Vydanie #$n", "item": "$url" }
      ]
    }
  ]
}
</script>
"@
}

# ── Main loop ─────────────────────────────────────────────────────────────────

# Skip anomalies (492 = duplicate of #49) and issues already complete (#82+)
$skip = @(492)

$targets = if ($Issue -gt 0) { @($Issue) } else { $issues.Keys | Sort-Object }

$updated = 0; $skipped = 0; $noFile = 0; $noData = 0

foreach ($n in $targets) {
    if ($skip -contains $n) {
        Write-Host "SKIP anomaly  #$n"
        $skipped++
        continue
    }

    $file = "$root\vydania\$n\index.html"
    if (-not (Test-Path $file)) {
        Write-Host "NO FILE       #$n"
        $noFile++
        continue
    }

    if (-not $issues.ContainsKey($n)) {
        Write-Host "NO DATA       #$n  (not in issues.js)"
        $noData++
        continue
    }

    $raw = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

    $hasOg     = $raw -match 'og:title'
    $hasSchema = $raw -match 'application/ld\+json'

    if ($hasOg -and $hasSchema) {
        Write-Host "SKIP complete  #$n"
        $skipped++
        continue
    }

    if ($raw -notmatch '</head>') {
        Write-Host "NO HEAD TAG   #$n -- skipping"
        $skipped++
        continue
    }

    $nl = if ($raw -match "`r`n") { "`r`n" } else { "`n" }

    if ($hasSchema -and -not $hasOg) {
        # Has schema only -- inject meta block before the existing <script type="application/ld+json">
        $metaBlock = (BuildMetaBlock $issues[$n]).Replace("`r`n", $nl).Replace("`n", $nl).TrimEnd() + $nl
        $newRaw = $raw.Replace('<script type="application/ld+json">', ($metaBlock + '<script type="application/ld+json">'))
    } else {
        # Missing both (or meta only) -- inject full block before </head>
        $block = BuildInsertBlock $issues[$n]
        $blockNl = $block.Replace("`r`n", $nl).Replace("`n", $nl).TrimEnd() + $nl
        $newRaw = $raw.Replace('</head>', ($blockNl + '</head>'))
    }

    if ($Apply) {
        [System.IO.File]::WriteAllText($file, $newRaw, [System.Text.Encoding]::UTF8)
        Write-Host "UPDATED       #$n  ($($issues[$n].date))"
    } else {
        Write-Host "DRY-RUN       #$n  ($($issues[$n].date))  [use -Apply to write]"
    }
    $updated++
}

Write-Host ""
Write-Host "Done. updated=$updated  skipped=$skipped  noFile=$noFile  noData=$noData"
if (-not $Apply) { Write-Host "DRY-RUN mode. Re-run with -Apply to write changes." }
