# generate-static-archive.ps1
# Pre-renders latest issues as static <a href> links inside the hero and mobile
# archive divs in index.html. Crawlers without JS see real links; JS overwrites
# on load for normal users so behaviour is unchanged.
# Run from repo root: powershell -ExecutionPolicy Bypass -File .\generate-static-archive.ps1

$root        = $PSScriptRoot
$indexPath   = Join-Path $root "index.html"
$jsPath      = Join-Path $root "issues.js"
$heroCount   = 20
$mobileCount = 6

# Parse issues.js
$js      = Get-Content $jsPath -Raw -Encoding UTF8
$pattern = 'number:\s*(\d+).*?title:\s*"((?:[^"\\]|\\.)*)".*?date:\s*"(\d{4}-\d{2}-\d{2})".*?dateLabel:\s*"((?:[^"\\]|\\.)*)"'
$rx      = [System.Text.RegularExpressions.Regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$found   = $rx.Matches($js)

$issues = $found | ForEach-Object {
    [PSCustomObject]@{
        number    = [int]$_.Groups[1].Value
        title     = $_.Groups[2].Value -replace '\\\"', '"'
        date      = $_.Groups[3].Value
        dateLabel = $_.Groups[4].Value -replace '\\\"', '"'
    }
} | Where-Object { $_.number -lt 200 } | Sort-Object date -Descending

# Build hero HTML (latest $heroCount)
$heroItems = ($issues | Select-Object -First $heroCount | ForEach-Object {
    $url = "https://rannasprava.sk/vydania/$($_.number)/"
    "<a class=`"hero-archive-item`" href=`"$url`">" +
    "<div class=`"hero-archive-num`">#$($_.number)</div>" +
    "<div><div class=`"hero-archive-meta`">$($_.dateLabel)</div>" +
    "<div class=`"hero-archive-hed`">$($_.title)</div></div></a>"
}) -join "`n"

# Build mobile HTML (latest $mobileCount)
$mobileItems = ($issues | Select-Object -First $mobileCount | ForEach-Object {
    $url = "https://rannasprava.sk/vydania/$($_.number)/"
    "<a class=`"mobile-archive-item`" href=`"$url`">" +
    "<div class=`"mobile-archive-num`">#$($_.number)</div>" +
    "<div><div class=`"mobile-archive-meta`">$($_.dateLabel)</div>" +
    "<div class=`"mobile-archive-hed`">$($_.title)</div></div></a>"
}) -join "`n"

# Inject into index.html
$html = Get-Content $indexPath -Raw -Encoding UTF8

$html = $html -replace '(<div class="hero-archive-list" id="hero-archive-list">)[^<]*(</div>)', "`$1`n$heroItems`n`$2"
$html = $html -replace '(<div class="mobile-archive-list" id="mobile-archive-list">)[^<]*(</div>)', "`$1`n$mobileItems`n`$2"

[System.IO.File]::WriteAllText($indexPath, $html, [System.Text.Encoding]::UTF8)
Write-Host ("generate-static-archive: injected " + ($issues | Measure-Object | Select-Object -ExpandProperty Count | ForEach-Object { [Math]::Min($_, $heroCount) }) + " hero + $mobileCount mobile links into index.html")
