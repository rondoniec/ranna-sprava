# generate-archive-date-pages.ps1 (v3)
# Generates FULL-CONTENT indexable /archiv/DD/MM/YYYY/ pages.
# No redirects. Each page: title, preview, cold-open, prev/next nav,
# NewsArticle schema, self-canonical, per-issue OG image.
#
# ENCODING: All static strings use HTML entities / [char] codes.
# Do NOT add raw Slovak diacritics as string literals.

param(
  [string]$IssuesFile = ".\issues.js",
  [string]$ArchiveRoot = ".\archiv"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$base = "https://rannasprava.sk"

# --- Helper functions ---

function Get-Month-SK-HTML($iso) {
    $m = [int]$iso.Substring(5,2)
    $months = @("",
        "janu&aacute;ra", "febru&aacute;ra", "marca", "apr&iacute;la",
        "m&aacute;ja", "j&uacute;na", "j&uacute;la", "augusta",
        "septembra", "okt&oacute;bra", "novembra", "decembra"
    )
    $d = [int]$iso.Substring(8,2)
    $y = $iso.Substring(0,4)
    return "$d. " + $months[$m] + " $y"
}

function Get-Month-SK-JSON($iso) {
    # JSON-safe month name using \u escapes — no HTML entities
    $m = [int]$iso.Substring(5,2)
    $months = @("",
        "janu\u00e1ra", "febru\u00e1ra", "marca", "apr\u00edla",
        "m\u00e1ja", "j\u00fana", "j\u00fala", "augusta",
        "septembra", "okt\u00f3bra", "novembra", "decembra"
    )
    $d = [int]$iso.Substring(8,2)
    $y = $iso.Substring(0,4)
    return "$d. " + $months[$m] + " $y"
}

function Get-Day-SK-HTML($iso) {
    # Slovak weekday name as HTML-safe string
    $dt = [datetime]::ParseExact($iso, 'yyyy-MM-dd', $null)
    $days = @(
        'Nede&#318;a',   # Sunday
        'Pondelok',       # Monday
        'Utorok',         # Tuesday
        'Streda',         # Wednesday
        '&Scaron;tvrtok', # Thursday
        'Piatok',         # Friday
        'Sobota'          # Saturday
    )
    return $days[[int]$dt.DayOfWeek]
}

function Escape-Html($s) {
    return $s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;'
}

function Escape-Json($s) {
    return $s -replace '\\', '\\\\' -replace '"', '\"'
}

# --- Parse issues.js ---

if (-not (Test-Path -LiteralPath $IssuesFile)) {
    throw "Issues file not found: $IssuesFile"
}

$issuesText = Get-Content -LiteralPath $IssuesFile -Raw -Encoding UTF8
$rx = [System.Text.RegularExpressions.Regex]::new(
    '(?s)\{\s*number:\s*(\d+),\s*title:\s*"((?:[^"\\]|\\.)*)",.*?date:\s*"(\d{4}-\d{2}-\d{2})".*?preview:\s*"((?:[^"\\]|\\.)*)"',
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)

$issues = $rx.Matches($issuesText) | ForEach-Object {
    [pscustomobject]@{
        Number  = [int]$_.Groups[1].Value
        Title   = $_.Groups[2].Value -replace '\\"', '"'
        Date    = $_.Groups[3].Value
        Preview = $_.Groups[4].Value -replace '\\"', '"'
    }
} | Where-Object { $_.Number -lt 200 } |
    Where-Object { Test-Path "vydania\$($_.Number)\index.html" } |
    Sort-Object Date

if ($issues.Count -eq 0) {
    throw "No valid issues found in $IssuesFile"
}

# Build prev/next map keyed by issue number
$navMap = @{}
for ($i = 0; $i -lt $issues.Count; $i++) {
    $navMap[$issues[$i].Number] = @{
        Prev = if ($i -gt 0)                    { $issues[$i - 1] } else { $null }
        Next = if ($i -lt $issues.Count - 1)    { $issues[$i + 1] } else { $null }
    }
}

# Group by date (rare multi-issue dates handled separately)
$groupedByDate = $issues | Group-Object Date

# --- CSS (shared) ---
$css = @'
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
:root { --cream: #F5F0E8; --ink: #1A1208; --gold: #C8962A; --paper: #EDE7D9; --muted: #7A6E5F; --border: rgba(26,18,8,0.12); }
body { background: var(--cream); color: var(--ink); font-family: "DM Sans", sans-serif; min-height: 100vh; }
nav { display: flex; justify-content: space-between; align-items: center; padding: 18px 48px; border-bottom: 1.5px solid var(--ink); background: var(--cream); position: sticky; top: 0; z-index: 100; }
.nav-logo { font-family: "Playfair Display", serif; font-size: 20px; font-weight: 900; color: var(--ink); text-decoration: none; }
.nav-logo span { color: var(--gold); }
.nav-right { display: flex; gap: 16px; align-items: center; }
.nav-link { font-size: 13px; color: var(--muted); text-decoration: none; font-weight: 500; transition: color 0.2s; }
.nav-link:hover { color: var(--ink); }
.nav-btn { background: var(--ink); color: var(--cream); padding: 9px 20px; border-radius: 2px; font-size: 13px; font-weight: 500; border: none; cursor: pointer; font-family: "DM Sans", sans-serif; text-decoration: none; }
.nav-btn:hover { background: var(--gold); color: var(--ink); }
.page-header { padding: 64px 64px 48px; border-bottom: 1.5px solid var(--ink); }
.page-eyebrow { font-size: 11px; letter-spacing: 0.15em; text-transform: uppercase; color: var(--gold); font-weight: 500; margin-bottom: 14px; display: flex; align-items: center; gap: 10px; }
.page-eyebrow::before { content: ""; display: inline-block; width: 28px; height: 1.5px; background: var(--gold); }
.issue-badge { font-size: 11px; letter-spacing: 0.1em; font-weight: 700; color: var(--muted); text-transform: uppercase; margin-bottom: 14px; display: block; }
.page-h1 { font-family: "Playfair Display", serif; font-size: clamp(26px, 3vw, 44px); font-weight: 900; letter-spacing: -0.8px; line-height: 1.12; margin-bottom: 18px; max-width: 760px; }
.page-sub { font-size: 17px; color: var(--muted); max-width: 640px; line-height: 1.7; font-weight: 300; }
.cold-open { padding: 40px 64px; border-bottom: 1px solid var(--border); max-width: 100%; }
.cold-open p { font-size: 17px; line-height: 1.8; color: var(--ink); font-weight: 300; font-style: italic; max-width: 680px; }
.archiv-cta { padding: 40px 64px; border-bottom: 1.5px solid var(--ink); }
.archiv-btn { display: inline-block; background: var(--ink); color: var(--cream); padding: 14px 28px; font-size: 14px; font-weight: 500; text-decoration: none; border-radius: 2px; transition: background 0.2s; }
.archiv-btn:hover { background: var(--gold); color: var(--ink); }
.day-nav { padding: 28px 64px; display: flex; justify-content: space-between; border-bottom: 1.5px solid var(--ink); gap: 16px; }
.day-nav a { font-size: 13px; color: var(--muted); text-decoration: none; font-weight: 500; transition: color 0.15s; }
.day-nav a:hover { color: var(--ink); }
.day-nav-spacer { flex: 1; }
footer { background: var(--ink); color: var(--cream); padding: 36px 64px; }
.footer-inner { display: flex; justify-content: space-between; align-items: center; }
.footer-logo { font-family: "Playfair Display", serif; font-size: 18px; font-weight: 900; color: var(--cream); text-decoration: none; }
.footer-logo span { color: var(--gold); }
.footer-links a { font-size: 12px; color: rgba(245,240,232,0.4); text-decoration: none; margin-left: 16px; }
.footer-links a:hover { color: var(--cream); }
@media (max-width: 640px) { nav { padding: 14px 20px; } .nav-link { display: none; } .page-header { padding: 40px 20px 32px; } .cold-open { padding: 28px 20px; } .archiv-cta { padding: 28px 20px; } .day-nav { padding: 20px; flex-direction: column; } footer { padding: 28px 20px; } .footer-inner { flex-direction: column; gap: 14px; } }
'@

# Shared nav + footer (HTML-entity encoded)
$navHtml = "<nav>`n  <a class=`"nav-logo`" href=`"/`">Rann&aacute;<span>Spr&aacute;va</span></a>`n  <div class=`"nav-right`">`n    <a class=`"nav-link`" href=`"/archiv/`">Arch&iacute;v</a>`n    <a class=`"nav-link`" href=`"/o-nas/`">O n&aacute;s</a>`n    <a class=`"nav-btn`" href=`"/`">Prihl&aacute;si&#357; sa zadarmo</a>`n  </div>`n</nav>"
$footerHtml = "<footer>`n  <div class=`"footer-inner`">`n    <a class=`"footer-logo`" href=`"/`">Rann&aacute;<span>Spr&aacute;va</span></a>`n    <div class=`"footer-links`"><a href=`"/archiv/`">Arch&iacute;v</a><a href=`"/o-nas/`">O n&aacute;s</a></div>`n  </div>`n</footer>"

$generated = 0

foreach ($group in $groupedByDate) {
    $date  = $group.Name
    $parts = $date.Split('-')
    $year  = $parts[0]; $month = $parts[1]; $day = $parts[2]

    $dir        = Join-Path $ArchiveRoot (Join-Path $day (Join-Path $month $year))
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $outFile    = Join-Path $dir "index.html"
    $archivUrl  = "$base/archiv/$day/$month/$year/"
    $items      = @($group.Group | Sort-Object Number -Descending)

    if ($items.Count -eq 1) {
        # --- SINGLE ISSUE: full content page ---
        $issue   = $items[0]
        $number  = $issue.Number
        $title   = $issue.Title
        $preview = $issue.Preview

        $titleHtml   = Escape-Html $title
        $previewHtml = Escape-Html $preview
        $titleJSON   = Escape-Json $title
        $previewJSON = Escape-Json $preview

        $dateDisplay     = Get-Month-SK-HTML $date        # "20. apr&iacute;la 2026"
        $dateDisplayJSON = Get-Month-SK-JSON $date        # "20. apr\u00edla 2026"
        $dayName         = Get-Day-SK-HTML $date          # "Pondelok" / "&Scaron;tvrtok"

        $vydaniaUrl  = "$base/vydania/$number/"
        $encodedTitle = [Uri]::EscapeDataString($title)
        $ogImageUrl  = "https://og.rannasprava.sk/?n=$number&amp;t=$encodedTitle&amp;d=$date"

        # Cold-open extraction
        $coldOpenBlock = ""
        $vydaniaHtml = Join-Path "vydania" "$number\index.html"
        if (Test-Path $vydaniaHtml) {
            $issueContent = Get-Content $vydaniaHtml -Raw -Encoding UTF8
            if ($issueContent -match '(?s)<div class="cold-open">(.*?)</div>') {
                $raw = $Matches[1] -replace '<[^>]+>', '' -replace '&amp;', '&' -replace '&nbsp;', ' ' -replace '&lt;', '<' -replace '&gt;', '>'
                $raw = $raw.Trim() -replace '\s+', ' '
                if ($raw.Length -gt 20) {
                    $escapedCO = Escape-Html $raw
                    $coldOpenBlock = "<div class=`"cold-open`"><p>$escapedCO</p></div>`n"
                }
            }
        }

        # Prev/next navigation
        $nav = $navMap[$number]
        $prevHtml = ""
        $nextHtml = ""
        if ($nav.Prev) {
            $pp = $nav.Prev.Date.Split('-')
            $prevUrl = "$base/archiv/$($pp[2])/$($pp[1])/$($pp[0])/"
            $prevDate = Get-Month-SK-HTML $nav.Prev.Date
            $prevHtml = "<a href=`"$prevUrl`">&#8592; $prevDate</a>"
        }
        if ($nav.Next) {
            $np = $nav.Next.Date.Split('-')
            $nextUrl = "$base/archiv/$($np[2])/$($np[1])/$($np[0])/"
            $nextDate = Get-Month-SK-HTML $nav.Next.Date
            $nextHtml = "<a href=`"$nextUrl`">$nextDate &#8594;</a>"
        }
        $spacer = if ($prevHtml -and $nextHtml) { "<span class=`"day-nav-spacer`"></span>" } else { "" }
        $dayNavHtml = "<nav class=`"day-nav`">$prevHtml$spacer$nextHtml</nav>`n"

        # Meta description
        $metaDesc = "Vydanie #$number Rannej Spr&aacute;vy z $dateDisplay. $previewHtml"

        # Schema
        $schema = '<script type="application/ld+json">' + "`n{`n" +
            '  "@context": "https://schema.org",' + "`n" +
            '  "@graph": [' + "`n" +
            '    {' + "`n" +
            '      "@type": "NewsArticle",' + "`n" +
            '      "@id": "' + $archivUrl + '#article",' + "`n" +
            '      "headline": "' + $titleJSON + '",' + "`n" +
            '      "description": "' + $previewJSON + '",' + "`n" +
            '      "datePublished": "' + $date + '",' + "`n" +
            '      "dateModified": "' + $date + '",' + "`n" +
            '      "url": "' + $archivUrl + '",' + "`n" +
            '      "inLanguage": "sk",' + "`n" +
            '      "publisher": { "@id": "' + $base + '/#organization" },' + "`n" +
            '      "author": { "@id": "' + $base + '/o-nas/#adam-hodosi" },' + "`n" +
            '      "isPartOf": { "@id": "' + $base + '/#website" }' + "`n" +
            '    },' + "`n" +
            '    {' + "`n" +
            '      "@type": "BreadcrumbList",' + "`n" +
            '      "itemListElement": [' + "`n" +
            '        { "@type": "ListItem", "position": 1, "name": "Domov", "item": "' + $base + '/" },' + "`n" +
            '        { "@type": "ListItem", "position": 2, "name": "Arch\u00edv", "item": "' + $base + '/archiv/" },' + "`n" +
            '        { "@type": "ListItem", "position": 3, "name": "' + $dateDisplayJSON + '", "item": "' + $archivUrl + '" }' + "`n" +
            '      ]' + "`n" +
            '    }' + "`n" +
            '  ]' + "`n" +
            "}`n</script>"

        $html = @"
<!DOCTYPE html>
<html lang="sk">
<head>
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-WQDSFGYPJ0"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-WQDSFGYPJ0');
</script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="$metaDesc">
<link rel="canonical" href="$archivUrl">
<link rel="alternate" hreflang="sk" href="$archivUrl">
<link rel="icon" href="/favicon.ico" sizes="32x32">
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="icon" type="image/png" sizes="192x192" href="/favicon-192.png">
<link rel="icon" type="image/png" sizes="512x512" href="/favicon-512.png">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<meta property="og:type" content="article">
<meta property="og:site_name" content="Rann&aacute; Spr&aacute;va">
<meta property="og:url" content="$archivUrl">
<meta property="og:title" content="Vydanie #$number &mdash; Rann&aacute; Spr&aacute;va">
<meta property="og:description" content="$previewHtml">
<meta property="og:image" content="$ogImageUrl">
<meta property="og:locale" content="sk_SK">
<meta property="article:published_time" content="${date}T08:00:00+02:00">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Vydanie #$number &mdash; Rann&aacute; Spr&aacute;va">
<meta name="twitter:description" content="$previewHtml">
<meta name="twitter:image" content="$ogImageUrl">
<title>Rann&aacute; Spr&aacute;va &mdash; $dateDisplay | Vydanie #$number</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
$schema
<style>
$css
</style>
</head>
<body>
$navHtml

<div class="page-header">
  <div class="page-eyebrow">$dayName &middot; $dateDisplay</div>
  <span class="issue-badge">Vydanie #$number</span>
  <h1 class="page-h1">$titleHtml</h1>
  <p class="page-sub">$previewHtml</p>
</div>

$coldOpenBlock
<div class="archiv-cta">
  <a class="archiv-btn" href="$vydaniaUrl">Pre&ccaron;&iacute;ta&#357; cel&eacute; vydanie #$number &#8594;</a>
</div>

$dayNavHtml
$footerHtml
</body>
</html>
"@

    }
    else {
        # --- MULTIPLE ISSUES on same date: listing page ---
        $linksHtml = ($items | ForEach-Object {
            $u = "$base/vydania/$($_.Number)/"
            $t = Escape-Html $_.Title
            '<li><a href="{0}">Vydanie #{1} &mdash; {2}</a></li>' -f $u, $_.Number, $t
        }) -join [Environment]::NewLine

        $archivCanonical = "$base$( "/archiv/$day/$month/$year/" )"
        $metaDescMulti = "Rann&aacute; Spr&aacute;va, vydania z d&aacute;tumu $( Get-Month-SK-HTML $date ) &mdash; slovensk&yacute; denn&yacute; newsletter."

        $html = @"
<!DOCTYPE html>
<html lang="sk">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Rann&aacute; Spr&aacute;va &mdash; Arch&iacute;v $( Get-Month-SK-HTML $date )</title>
<meta name="description" content="$metaDescMulti">
<link rel="canonical" href="$archivCanonical">
<style>
  body { margin: 0; padding: 32px 20px; background: #F5F0E8; color: #1A1208; font-family: Georgia, serif; line-height: 1.6; }
  .wrap { max-width: 760px; margin: 0 auto; background: #FAFAF7; border: 1px solid #1A1208; padding: 28px 24px; }
  h1 { margin: 0 0 12px; font-size: 28px; }
  p { margin: 0 0 12px; font-size: 16px; }
  ul { margin: 16px 0 0 18px; padding: 0; }
  li { margin: 0 0 10px; }
  a { color: #1A1208; }
</style>
</head>
<body>
  <div class="wrap">
    <h1>Viac vydan&iacute; na rovnak&yacute; d&aacute;tum</h1>
    <p>D&aacute;tumov&aacute; archive URL <strong>/archiv/$day/$month/$year/</strong> m&aacute; viac ako jedno vydanie.</p>
    <ul>
$linksHtml
    </ul>
  </div>
</body>
</html>
"@
    }

    Set-Content -LiteralPath $outFile -Value $html -Encoding UTF8
    $generated++
}

Write-Host "Generated $generated archive pages under $ArchiveRoot"
