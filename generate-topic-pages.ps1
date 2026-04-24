# generate-topic-pages.ps1
# Generates /temy/[topic]/index.html pages by keyword-classifying issues.
# Run from repo root: powershell -ExecutionPolicy Bypass -File .\generate-topic-pages.ps1
#
# ENCODING NOTE: All static strings in this file are ASCII-safe (HTML entities / char codes).
# Do NOT add raw Slovak diacritics as string literals here -- PowerShell 5.1 reads scripts
# as Windows-1252 without BOM, garbling UTF-8 byte sequences.

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
} | Where-Object { $_.number -lt 200 } | Where-Object { Test-Path (Join-Path $root "vydania\$($_.number)\index.html") } | Sort-Object date -Descending

# Normalize Slovak diacritics to ASCII for keyword matching.
# Uses [char] codes to avoid encoding issues in this script file.
function NormalizeSK($s) {
    $s = $s.ToLower()
    $s = $s -replace [char]225, 'a'   # a-acute  (a)
    $s = $s -replace [char]228, 'a'   # a-umlaut (a)
    $s = $s -replace [char]269, 'c'   # c-caron  (c)
    $s = $s -replace [char]271, 'd'   # d-caron  (d)
    $s = $s -replace [char]233, 'e'   # e-acute  (e)
    $s = $s -replace [char]237, 'i'   # i-acute  (i)
    $s = $s -replace [char]318, 'l'   # l-caron  (l)
    $s = $s -replace [char]314, 'l'   # l-acute  (l)
    $s = $s -replace [char]328, 'n'   # n-caron  (n)
    $s = $s -replace [char]243, 'o'   # o-acute  (o)
    $s = $s -replace [char]244, 'o'   # o-circumflex (o)
    $s = $s -replace [char]341, 'r'   # r-acute  (r)
    $s = $s -replace [char]353, 's'   # s-caron  (s)
    $s = $s -replace [char]357, 't'   # t-caron  (t)
    $s = $s -replace [char]250, 'u'   # u-acute  (u)
    $s = $s -replace [char]253, 'y'   # y-acute  (y)
    $s = $s -replace [char]382, 'z'   # z-caron  (z)
    return $s
}

# Topic definitions: slug, label, keywords (ALL ASCII -- matched against normalized haystack)
$topics = @(
  [PSCustomObject]@{
    slug    = "slovensko"
    label   = "Slovensko"
    desc    = "Dom&aacute;ce spr&aacute;vy, politika, ekonomika a spolo&#269;nos&#357; na Slovensku."
    intro   = "Rann&aacute; Spr&aacute;va ka&zcaron;d&yacute; pracovn&yacute; de&#328; sleduje najd&ocirc;le&zcaron;itej&scaron;ie udalosti zo Slovenska &mdash; od parlamentu a vl&aacute;dy cez ekonomiku a&zcaron; po spolo&#269;nos&#357; a regi&oacute;ny. Ka&zcaron;d&eacute; vyd&aacute;nie prin&aacute;&scaron;a jedno hlavn&eacute; t&eacute;mu s kontextom, ktor&yacute; skr&aacute;ten&eacute; spr&aacute;vy nedaj&uacute;. P&iacute;&scaron;eme pre &#318;ud&iacute;, ktor&iacute; chc&uacute; by&#357; informovan&iacute; bez clickbaitu a ideologick&eacute;ho &scaron;umu."
    keywords = @("fico","vlada","koalicia","parlament","slovensko","bratislava","pellegrini","smer","ps ","republika","referendum","volby","danko","blana","minister","zakon","stat","ustava")
  },
  [PSCustomObject]@{
    slug    = "biznis"
    label   = "Biznis a ekonomika"
    desc    = "Ekonomika, trhy, firmy, finan&#269;n&iacute;ctvo a podnikanie na Slovensku a vo svete."
    intro   = "Slovensk&aacute; ekonomika je mal&aacute;, otvoren&aacute; a z&aacute;visl&aacute; od exportu &mdash; ka&zcaron;d&yacute; pohyb v glob&aacute;lnych trhoch, menovej politike ECB alebo eur&oacute;pskych fondoch sa prejav&iacute; aj u n&aacute;s. Rann&aacute; Spr&aacute;va sleduje firmy, akciov&eacute; trhy, infl&aacute;ciu, rozpo&#269;et a pracovn&yacute; trh ka&zcaron;d&yacute; pracovn&yacute; de&#328;."
    keywords = @("ekonomik","inflaci","dlh","rozpocet","bank","euro ","firmy","firma","export","hdp","mzd","priemysel","investici","trh","burz","akci","financi","podnikat","hospodarst")
  },
  [PSCustomObject]@{
    slug    = "tech"
    label   = "Tech a startupy"
    desc    = "Technol&oacute;gie, umel&aacute; inteligencia, startupy a digitaliz&aacute;cia na Slovensku."
    intro   = "Umel&aacute; inteligencia, digitaliz&aacute;cia verejn&yacute;ch slu&zcaron;ieb a slovensk&yacute; startupov&yacute; ekosyst&eacute;m s&uacute; t&eacute;mami, ktor&eacute; &#269;oraz viac formuj&uacute; ekonomiku aj ka&zcaron;dodenn&yacute; &zcaron;ivot. Rann&aacute; Spr&aacute;va prin&aacute;&scaron;a technologick&eacute; spr&aacute;vy v kontexte relevantn&iacute; pre slovensk&eacute;ho &#269;itate&#318;a."
    keywords = @("tech","ai ","umela inteligencia","startup","digital","aplikaci","internet","softver","hardware","cybersec","platforma","innovaci","digitalizaci")
  },
  [PSCustomObject]@{
    slug    = "svet"
    label   = "Svet"
    desc    = "Zahrani&#269;n&eacute; spr&aacute;vy, Eur&oacute;pska &uacute;nia, geopolitika a svetov&eacute; ekonomiky."
    intro   = "Slovensko je mal&aacute; otvoren&aacute; krajina v strede Eur&oacute;py &mdash; dianie v Bruseli, Berl&iacute;ne, Washingtone aj Kyjeve n&aacute;s priamo ovplyv&#328;uje. Rann&aacute; Spr&aacute;va sleduje zahrani&#269;n&eacute; spr&aacute;vy s d&ocirc;razom na eur&oacute;psku politiku, geopolitiku a glob&aacute;lne ekonomick&eacute; trendy."
    keywords = @("europ","eu ","usa","trump","madar","orban","ukraj","rusko","brit","nemeck","francuz","cina","nato","summit","brusel","geopolit","zahrani")
  },
  [PSCustomObject]@{
    slug    = "sport"
    label   = "&Scaron;port"
    desc    = "Slovensk&yacute; a medzin&aacute;rodn&yacute; &scaron;port: hokej, futbal, atletika a v&scaron;etko, &#269;o sa deje na &scaron;portovej mape."
    intro   = "Od hokeja a futbalu po atletiku a tenis &mdash; slovensk&yacute; &scaron;port m&aacute; bohat&uacute; trad&iacute;ciu a siln&eacute; osobnosti na svetovej sc&eacute;ne. Rann&aacute; Spr&aacute;va prin&aacute;&scaron;a preh&#318;ad najd&ocirc;le&zcaron;itej&scaron;&iacute;ch v&yacute;sledkov a udalost&iacute; zo slovensk&eacute;ho aj medzin&aacute;rodn&eacute;ho &scaron;portu."
    keywords = @("futbal","hokej","sport","slovan","ligou","liga ","ms ","olymp","tenis","atletik","zbrojar")
  },
  [PSCustomObject]@{
    slug    = "zdravie"
    label   = "Zdravie a veda"
    desc    = "Zdravotn&iacute;ctvo, veda, medic&iacute;na a verejn&aacute; politika na Slovensku."
    intro   = "Slovensk&eacute; zdravotn&iacute;ctvo &#269;el&iacute; dlhodob&yacute;m v&yacute;zvam: nedostatok person&aacute;lu, pre&#357;a&zcaron;en&eacute; nemocnice a reforma syst&eacute;mu. Rann&aacute; Spr&aacute;va sleduje zdravotn&uacute; politiku, vedecko-technologick&eacute; objavy a medic&iacute;nske spr&aacute;vy, ktor&eacute; formuj&uacute; verejn&uacute; diskusiu."
    keywords = @("nemocnic","zdravotnictv","sestry","lekar","liek","zdravie","rakovina","pandem","ockovani","sestra","sanitk","ordinaci","pacient")
  }
)

# Month names as HTML entities (safe in ASCII script file)
function Get-Month-SK($iso) {
    $m = [int]$iso.Substring(5,2)
    $months = @("",
        "janu&aacute;ra",
        "febru&aacute;ra",
        "marca",
        "apr&iacute;la",
        "m&aacute;ja",
        "j&uacute;na",
        "j&uacute;la",
        "augusta",
        "septembra",
        "okt&oacute;bra",
        "novembra",
        "decembra"
    )
    $d = [int]$iso.Substring(8,2)
    $y = $iso.Substring(0,4)
    return "$d. " + $months[$m] + " $y"
}

function Escape-Html($s) {
    return $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;'
}

foreach ($topic in $topics) {
    # Classify issues: score each by keyword hits in normalized title+preview
    $matched = $allIssues | ForEach-Object {
        $haystack = NormalizeSK ($_.title + " " + $_.preview)
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

    $intro = $topic.intro
    $html = "<!DOCTYPE html>`n<html lang=`"sk`">`n<head>`n" +
"<!-- Google tag (gtag.js) -->`n" +
"<script async src=`"https://www.googletagmanager.com/gtag/js?id=G-WQDSFGYPJ0`"></script>`n" +
"<script>`n  window.dataLayer = window.dataLayer || [];`n  function gtag(){dataLayer.push(arguments);}`n  gtag('js', new Date());`n  gtag('config', 'G-WQDSFGYPJ0');`n</script>`n" +
"<meta charset=`"UTF-8`">`n" +
"<meta name=`"viewport`" content=`"width=device-width, initial-scale=1.0`">`n" +
"<meta name=`"description`" content=`"$desc`">`n" +
"<link rel=`"canonical`" href=`"$canonical`">`n" +
"<link rel=`"alternate`" hreflang=`"sk`" href=`"$canonical`">`n" +
"<link rel=`"icon`" href=`"/favicon.ico`" sizes=`"32x32`">`n" +
"<link rel=`"icon`" href=`"/favicon.svg`" type=`"image/svg+xml`">`n" +
"<link rel=`"icon`" type=`"image/png`" sizes=`"192x192`" href=`"/favicon-192.png`">`n" +
"<link rel=`"icon`" type=`"image/png`" sizes=`"512x512`" href=`"/favicon-512.png`">`n" +
"<link rel=`"apple-touch-icon`" href=`"/apple-touch-icon.png`">`n" +
"<meta property=`"og:type`" content=`"website`">`n" +
"<meta property=`"og:site_name`" content=`"Rann&aacute; Spr&aacute;va`">`n" +
"<meta property=`"og:url`" content=`"$canonical`">`n" +
"<meta property=`"og:title`" content=`"$label $emdash Rann&aacute; Spr&aacute;va`">`n" +
"<meta property=`"og:description`" content=`"$desc`">`n" +
"<meta property=`"og:image`" content=`"$base/og-image.png`">`n" +
"<meta property=`"og:locale`" content=`"sk_SK`">`n" +
"<title>$label $emdash Rann&aacute; Spr&aacute;va</title>`n" +
"<link rel=`"preconnect`" href=`"https://fonts.googleapis.com`">`n" +
"<link rel=`"preconnect`" href=`"https://fonts.gstatic.com`" crossorigin>`n" +
"<link href=`"https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=DM+Sans:wght@300;400;500&display=swap`" rel=`"stylesheet`">`n" +
'<script type="application/ld+json">' + "`n" +
'{' + "`n" +
'  "@context": "https://schema.org",' + "`n" +
'  "@graph": [' + "`n" +
'    { "@type": "CollectionPage", "@id": "' + $canonical + '#page", "url": "' + $canonical + '", "name": "' + $label + ' \u2014 Rann\u00e1 Spr\u00e1va", "isPartOf": { "@id": "' + $base + '/#website" } },' + "`n" +
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
.topic-intro { padding: 32px 64px 0; max-width: 680px; }
.topic-intro p { font-size: 16px; line-height: 1.75; color: var(--ink); font-weight: 300; }
.issues { padding: 24px 64px 64px; }
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
@media (max-width: 640px) { nav { padding: 14px 20px; } .nav-link { display: none; } .page-header { padding: 40px 20px 28px; } .topic-intro { padding: 24px 20px 0; } .issues { padding: 16px 20px 40px; } footer { padding: 28px 20px; } .footer-inner { flex-direction: column; gap: 14px; } }
' + "`n</style>`n</head>`n<body>`n`n" +
"<nav>`n  <a class=`"nav-logo`" href=`"/`">Rann&aacute;<span>Spr&aacute;va</span></a>`n" +
"  <div class=`"nav-right`">`n" +
"    <a class=`"nav-link`" href=`"/archiv/`">Arch&iacute;v</a>`n" +
"    <a class=`"nav-link`" href=`"/o-nas/`">O n&aacute;s</a>`n" +
"    <a class=`"nav-btn`" href=`"/`">Prihl&aacute;si&#357; sa zadarmo</a>`n" +
"  </div>`n</nav>`n`n" +
"<div class=`"page-header`">`n" +
"  <div class=`"page-eyebrow`">T&eacute;ma</div>`n" +
"  <h1 class=`"page-h1`">$label</h1>`n" +
"  <p class=`"page-sub`">$count vydan&iacute; &middot; $desc</p>`n" +
"</div>`n`n" +
"<div class=`"topic-intro`"><p>$intro</p></div>`n`n" +
"<div class=`"issues`">`n$rows`n</div>`n`n" +
"<footer>`n  <div class=`"footer-inner`">`n" +
"    <a class=`"footer-logo`" href=`"/`">Rann&aacute;<span>Spr&aacute;va</span></a>`n" +
"    <div class=`"footer-links`"><a href=`"/archiv/`">Arch&iacute;v</a><a href=`"/o-nas/`">O n&aacute;s</a></div>`n" +
"  </div>`n</footer>`n`n</body>`n</html>`n"

    $dir = Join-Path $root "temy\$slug"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $outPath = Join-Path $dir "index.html"
    [System.IO.File]::WriteAllText($outPath, $html, [System.Text.Encoding]::UTF8)
    Write-Host ("temy/" + $slug + "/ - " + $count + " issues")
}
