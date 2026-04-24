# generate-sitemap.ps1
# Generates sitemap.xml from all vydania/*/index.html files.
# Run from repo root: powershell -ExecutionPolicy Bypass -File .\generate-sitemap.ps1

$base = "https://rannasprava.sk"
$root = $PSScriptRoot

function Get-MonthNumber($word) {
    # Match by ASCII prefix to avoid diacritic encoding issues
    $w = $word.ToLower() -replace '[^a-z]', ''
    switch -Wildcard ($w) {
        'jan*' { return '01' }
        'feb*' { return '02' }
        'mar*' { return '03' }
        'apr*' { return '04' }
        'maj*' { return '05' }
        'jun*' { return '06' }
        'jul*' { return '07' }
        'aug*' { return '08' }
        'sep*' { return '09' }
        'okt*' { return '10' }
        'nov*' { return '11' }
        'dec*' { return '12' }
        default { return $null }
    }
}

function Get-ISODate($html) {
    # Try JSON-LD datePublished first (issues with schema)
    if ($html -match '"datePublished"\s*:\s*"(\d{4}-\d{2}-\d{2})"') {
        return $matches[1]
    }
    # Try title tag: "D. mesiaca YYYY</title>"
    if ($html -match '(\d{1,2})\.\s+(\S+)\s+(\d{4})</title>') {
        $day   = $matches[1].PadLeft(2, '0')
        $month = Get-MonthNumber $matches[2]
        $year  = $matches[3]
        if ($month) { return "$year-$month-$day" }
    }
    # Try mast-date-bar span
    if ($html -match '(\d{1,2})\.\s+(\S+)\s+(\d{4})</span>') {
        $day   = $matches[1].PadLeft(2, '0')
        $month = Get-MonthNumber $matches[2]
        $year  = $matches[3]
        if ($month) { return "$year-$month-$day" }
    }
    return $null
}

$urls = [System.Collections.Generic.List[string]]::new()

# Homepage
$urls.Add(@"
  <url>
    <loc>$base/</loc>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
"@)

# Issues — only numeric folders, skip 492 (misnamed duplicate)
$folders = Get-ChildItem -Path "$root\vydania" -Directory |
    Where-Object { $_.Name -match '^\d+$' -and $_.Name -ne '492' } |
    Sort-Object { [int]$_.Name }

foreach ($folder in $folders) {
    $file = Join-Path $folder.FullName "index.html"
    if (-not (Test-Path $file)) { continue }

    $html     = Get-Content $file -Raw -Encoding UTF8
    $num      = $folder.Name
    $loc      = "$base/vydania/$num/"
    $isoDate  = Get-ISODate $html
    $lastmod  = if ($isoDate) { "`n    <lastmod>$isoDate</lastmod>" } else { "" }

    $urls.Add(@"
  <url>
    <loc>$loc</loc>$lastmod
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
"@)
}

# Archiv date pages — scan archiv/DD/MM/YYYY/index.html
$archivPages = Get-ChildItem -Path "$root\archiv" -Recurse -Filter "index.html" |
    Sort-Object FullName

foreach ($aFile in $archivPages) {
    # Path: archiv\DD\MM\YYYY\index.html
    $parts = $aFile.DirectoryName -split [regex]::Escape([IO.Path]::DirectorySeparatorChar)
    # Last 3 parts = YYYY, MM, DD (reversed from path DD/MM/YYYY)
    if ($parts.Count -lt 3) { continue }
    $dd   = $parts[-3]
    $mm   = $parts[-2]
    $yyyy = $parts[-1]
    if ($yyyy -notmatch '^\d{4}$') { continue }
    $isoDate = "$yyyy-$mm-$dd"
    $loc     = "$base/archiv/$dd/$mm/$yyyy/"
    $urls.Add(@"
  <url>
    <loc>$loc</loc>
    <lastmod>$isoDate</lastmod>
    <changefreq>never</changefreq>
    <priority>0.6</priority>
  </url>
"@)
}

$xml = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
$($urls -join "`n")
</urlset>
"@

$out = Join-Path $root "sitemap.xml"
[System.IO.File]::WriteAllText($out, $xml, [System.Text.Encoding]::UTF8)
$total = $urls.Count
Write-Host ("sitemap.xml written - $total URLs ($($folders.Count) vydania + $($archivPages.Count) archiv)")
