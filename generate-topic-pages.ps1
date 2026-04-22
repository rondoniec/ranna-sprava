# generate-topic-pages.ps1
# Generates /temy/[topic]/index.html pages by keyword-classifying issues.
# Run from repo root: powershell -ExecutionPolicy Bypass -File .\generate-topic-pages.ps1

$emdash  = [char]0x2014
$base    = "https://rannasprava.sk"
$root    = $PSScriptRoot
$jsPath  = Join-Path $root "issues.js"
$js      = Get-Content $jsPath -Raw -Encoding UTF8

# Parse issues
$pattern = 'number:\s*(\d+).*?title:\s*"((?:[^"\\]|\\.)*)".*?date:\s*"(\d{4}-\d{2}-\d{2})".*?preview:\s*"((?:[^"\\]|\\.)*)"'
$rx      = [System.Text.RegularExpressions.Regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$allIssues = $rx.Matches($js) | ForEach-Object {
    [PSCustomObject]@{
        number  = [int]$_.Groups[1].Value
        title   = $_.Groups[2].Value -replace '\\\"', '"'
        date    = $_.Groups[3].Value
        preview = $_.Groups[4].Value -replace '\\\"', '"'
    }
} | Where-Object { $_.number -lt 200 } | Sort-Object date -Descending

# Topic definitions: slug, label, keywords (matched in title+preview, case-insensitive)
$topics = @(
  [PSCustomObject]@{
    slug    = "slovensko"
    label   = "Slovensko"
    desc    = "Domace spravy, politika, ekonomika a spolocnost na Slovensku."
    keywords = @("fico","vlada","koalicia","parlament","slovensko","bratislava","pellegrini","smer","ps ","republika","referendum","volby","danko","blana","minister","zakon","stat","ustava")
  },
  [PSCustomObject]@{
    slug    = "biznis"
    label   = "Biznis a ekonomika"
    desc    = "Ekonomika, trhy, firmy, financie a podnikanie."
    keywords = @("ekonomik","inflaci","dlh","rozpocet","bank","euro ","firmy","firma","export","hdp","mzd","priemysel","investici","trh","burz","akci","financi","podnikat","hospodarst")
  },
  [PSCustomObject]@{
    slug    = "tech"
    label   = "Tech a startupy"
    desc    = "Technologie, umelá inteligencia, startupy a digitalizacia."
    keywords = @("tech","ai ","umelá inteligencia","startup","digitál","aplikáci","internet","softvér","hardware","cybersec","dát","platforma","innovaci")
  },
  [PSCustomObject]@{
    slug    = "svet"
    label   = "Svet"
    desc    = "Zahranicne spravy, Europska unia, geopolitika."
    keywords = @("európ","eu ","usa","trump","madar","orbán","ukraj","rusko","brit","nemeck","francúz","čína","nato","summit","brusel","geopolit","zahrani")
  },
  [PSCustomObject]@{
    slug    = "sport"
    label   = "Sport"
    desc    = "Slovensky a medzinarodny sport."
    keywords = @("futbal","hokej","sport","šport","slovan","ligou","liga ","ms ","olymp","tenis","atletik","zbrojár")
  },
  [PSCustomObject]@{
    slug    = "zdravie"
    label   = "Zdravie a veda"
    desc    = "Zdravotnictvo, veda, medicina a verejna politika."
    keywords = @("nemocnic","zdravotníctv","sestry","sestry","lekár","liek","zdravie","rakovina","pandém","ockovani","sestra","sanitk","ordinaci","pacient")
  }
)

function Get-Month-SK($iso) {
    $m = [int]$iso.Substring(5,2)
    $months = @("","januára","februára","marca","apríla","mája","júna","júla","augusta","septembra","októbra","novembra","decembra")
    $d = [int]$iso.Substring(8,2)
    $y = $iso.Substring(0,4)
    return "$d. " + $months[$m] + " $y"
}

function Escape-Html($s) {
    return $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;'
}

foreach ($topic in $topics) {
    # Classify issues: score each by keyword hits in title+preview
    $matched = $allIssues | ForEach-Object {
        $haystack = ($_.title + " " + $_.preview).ToLower()
        $score = 0
        foreach ($kw in $topic.keywords) { if ($haystack -like "*$kw*") { $score++ } }
        [PSCustomObject]@{ issue = $_; score = $score }
    } | Where-Object { $_.score -gt 0 } | Sort-Object { $_.issue.date } -Descending | ForEach-Object { $_.issue }

    if ($matched.Count -eq 0) { continue }

    $rows = ($matched | ForEach-Object {
        $url      = "$base/vydania/$($_.number)/"
        $dateStr  = Get-Month-SK $_.date
        $title    = Escape-Html $_.title
        $preview  = Escape-Html $_.preview
        "      <a class=`"issue-row`" href=`"$url`">`n" +
        "        <div class=`"issue-num`">#$($_.number)</div>`n" +
        "        <div class=`"issue-body`">`n" +
        "          <div class=`"issue-date`">$dateStr</div>`n" +
        "          <div class=`"issue-title`">$title</div>`n" +
        "          <div class=`"issue-preview`">$preview</div>`n" +
        "        </div>`n" +
        "      </a>"
    }) -join "`n"

    $count     = $matched.Count
    $slug      = $topic.slug
    $label     = $topic.label
    $desc      = $topic.desc
    $canonical = "$base/temy/$slug/"

    $html = "<!DOCTYPE html>`n<html lang=`"sk`">`n<head>`n" +
"<meta charset=`"UTF-8`">`n" +
"<meta name=`"viewport`" content=`"width=device-width, initial-scale=1.0`">`n" +
"<meta name=`"description`" content=`"$desc`">`n" +
"<link rel=`"canonical`" href=`"$canonical`">`n" +
"<link rel=`"alternate`" hreflang=`"sk`" href=`"$canonical`">`n" +
"<meta property=`"og:type`" content=`"website`">`n" +
"<meta property=`"og:site_name`" content=`"Ranna Sprava`">`n" +
"<meta property=`"og:url`" content=`"$canonical`">`n" +
"<meta property=`"og:title`" content=`"$label $emdash Ranna Sprava`">`n" +
"<meta property=`"og:description`" content=`"$desc`">`n" +
"<meta property=`"og:image`" content=`"$base/og-image.svg`">`n" +
"<meta property=`"og:locale`" content=`"sk_SK`">`n" +
"<title>$label $emdash Ranna Sprava</title>`n" +
"<link rel=`"preconnect`" href=`"https://fonts.googleapis.com`">`n" +
"<link rel=`"preconnect`" href=`"https://fonts.gstatic.com`" crossorigin>`n" +
"<link href=`"https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=DM+Sans:wght@300;400;500&display=swap`" rel=`"stylesheet`">`n" +
'<script type="application/ld+json">' + "`n" +
'{' + "`n" +
'  "@context": "https://schema.org",' + "`n" +
'  "@graph": [' + "`n" +
'    { "@type": "CollectionPage", "@id": "' + $canonical + '#page", "url": "' + $canonical + '", "name": "' + $label + ' — Ranna Sprava", "isPartOf": { "@id": "' + $base + '/#website" } },' + "`n" +
'    { "@type": "BreadcrumbList", "itemListElement": [' + "`n" +
'      { "@type": "ListItem", "position": 1, "name": "Domov", "item": "' + $base + '/" },' + "`n" +
'      { "@type": "ListItem", "position": 2, "name": "' + $label + '", "item": "' + $canonical + '" }' + "`n" +
'    ]}' + "`n" +
'  ]' + "`n" +
'}' + "`n" +
"</script>`n" +
"<style>`n" +
'*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
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
.page-header { padding: 64px 64px 40px; border-bottom: 1.5px solid var(--ink); }
.page-eyebrow { font-size: 11px; letter-spacing: 0.15em; text-transform: uppercase; color: var(--gold); font-weight: 500; margin-bottom: 14px; display: flex; align-items: center; gap: 10px; }
.page-eyebrow::before { content: ""; display: inline-block; width: 28px; height: 1.5px; background: var(--gold); }
.page-h1 { font-family: "Playfair Display", serif; font-size: clamp(36px, 4vw, 56px); font-weight: 900; letter-spacing: -1.5px; margin-bottom: 12px; }
.page-sub { font-size: 15px; color: var(--muted); font-weight: 300; }
.issues { padding: 0 64px 64px; }
.issue-row { display: grid; grid-template-columns: 56px 1fr; gap: 20px; padding: 24px 16px; border-bottom: 1px solid var(--border); text-decoration: none; color: inherit; transition: background 0.15s; margin: 0 -16px; border-radius: 3px; }
.issue-row:hover { background: var(--paper); }
.issue-num { font-family: "Playfair Display", serif; font-size: 24px; font-weight: 900; color: var(--ink); text-align: right; padding-top: 3px; }
.issue-date { font-size: 10px; letter-spacing: 0.1em; text-transform: uppercase; color: var(--gold); font-weight: 700; margin-bottom: 5px; }
.issue-title { font-family: "Playfair Display", serif; font-size: 17px; font-weight: 700; line-height: 1.3; margin-bottom: 5px; }
.issue-preview { font-size: 13px; color: var(--muted); line-height: 1.6; font-weight: 300; }
footer { background: var(--ink); color: var(--cream); padding: 36px 64px; }
.footer-inner { display: flex; justify-content: space-between; align-items: center; }
.footer-logo { font-family: "Playfair Display", serif; font-size: 18px; font-weight: 900; color: var(--cream); text-decoration: none; }
.footer-logo span { color: var(--gold); }
.footer-links a { font-size: 12px; color: rgba(245,240,232,0.4); text-decoration: none; margin-left: 16px; }
.footer-links a:hover { color: var(--cream); }
@media (max-width: 640px) { nav { padding: 14px 20px; } .nav-link { display: none; } .page-header { padding: 40px 20px 28px; } .issues { padding: 0 20px 40px; } footer { padding: 28px 20px; } .footer-inner { flex-direction: column; gap: 14px; } }
' + "`n</style>`n</head>`n<body>`n`n" +
"<nav>`n  <a class=`"nav-logo`" href=`"/`">Ranná<span>Správa</span></a>`n" +
"  <div class=`"nav-right`">`n" +
"    <a class=`"nav-link`" href=`"/archiv/`">Archív</a>`n" +
"    <a class=`"nav-link`" href=`"/o-nas/`">O nás</a>`n" +
"    <a class=`"nav-btn`" href=`"/`">Prihlásiť sa zadarmo</a>`n" +
"  </div>`n</nav>`n`n" +
"<div class=`"page-header`">`n" +
"  <div class=`"page-eyebrow`">Téma</div>`n" +
"  <h1 class=`"page-h1`">$label</h1>`n" +
"  <p class=`"page-sub`">$count vydaní · $desc</p>`n" +
"</div>`n`n" +
"<div class=`"issues`">`n$rows`n</div>`n`n" +
"<footer>`n  <div class=`"footer-inner`">`n" +
"    <a class=`"footer-logo`" href=`"/`">Ranná<span>Správa</span></a>`n" +
"    <div class=`"footer-links`"><a href=`"/archiv/`">Archív</a><a href=`"/o-nas/`">O nás</a></div>`n" +
"  </div>`n</footer>`n`n</body>`n</html>`n"

    $dir = Join-Path $root "temy\$slug"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $outPath = Join-Path $dir "index.html"
    [System.IO.File]::WriteAllText($outPath, $html, [System.Text.Encoding]::UTF8)
    Write-Host ("temy/" + $slug + "/ - " + $count + " issues")
}
