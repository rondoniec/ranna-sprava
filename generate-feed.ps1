# generate-feed.ps1
# Generates /feed.xml (RSS 2.0) from issues.js.
# Run from repo root: powershell -ExecutionPolicy Bypass -File .\generate-feed.ps1

$base   = "https://rannasprava.sk"
$root   = $PSScriptRoot
$jsPath = Join-Path $root "issues.js"
$js     = Get-Content $jsPath -Raw -Encoding UTF8

# Parse issues
$pattern = 'number:\s*(\d+).*?title:\s*"((?:[^"\\]|\\.)*)".*?date:\s*"(\d{4}-\d{2}-\d{2})".*?preview:\s*"((?:[^"\\]|\\.)*)"'
$rx      = [System.Text.RegularExpressions.Regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$issues  = $rx.Matches($js) | ForEach-Object {
    [PSCustomObject]@{
        number  = [int]$_.Groups[1].Value
        title   = $_.Groups[2].Value -replace '\\\"', '"'
        date    = $_.Groups[3].Value
        preview = $_.Groups[4].Value -replace '\\\"', '"'
    }
} | Where-Object { $_.number -lt 200 } | Sort-Object date -Descending | Select-Object -First 30

function To-Rfc822 ($iso) {
    $d = [datetime]::ParseExact($iso, "yyyy-MM-dd", $null)
    # 08:00 Bratislava time (CET/CEST) = UTC+1/+2; use +0200 for simplicity
    return $d.ToString("ddd, dd MMM yyyy", [System.Globalization.CultureInfo]::InvariantCulture) + " 08:00:00 +0200"
}

function Escape-Xml ($s) {
    return $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;' -replace "'","&apos;"
}

$lastBuild = To-Rfc822 ($issues | Select-Object -First 1).date

$items = ($issues | ForEach-Object {
    $url     = "$base/vydania/$($_.number)/"
    $pubDate = To-Rfc822 $_.date
    $title   = Escape-Xml $_.title
    $desc    = Escape-Xml $_.preview
    "    <item>`n" +
    "      <title>$title</title>`n" +
    "      <link>$url</link>`n" +
    "      <guid isPermaLink=`"true`">$url</guid>`n" +
    "      <pubDate>$pubDate</pubDate>`n" +
    "      <description>$desc</description>`n" +
    "    </item>"
}) -join "`n"

$feed = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n" +
"<rss version=`"2.0`" xmlns:atom=`"http://www.w3.org/2005/Atom`">`n" +
"  <channel>`n" +
"    <title>Ranna Sprava</title>`n" +
"    <link>$base</link>`n" +
"    <description>Slovensky denny newsletter. Slovensko a svet za 5 minut.</description>`n" +
"    <language>sk</language>`n" +
"    <lastBuildDate>$lastBuild</lastBuildDate>`n" +
"    <atom:link href=`"$base/feed.xml`" rel=`"self`" type=`"application/rss+xml`"/>`n" +
"    <image>`n" +
"      <url>$base/og-image.svg</url>`n" +
"      <title>Ranna Sprava</title>`n" +
"      <link>$base</link>`n" +
"    </image>`n" +
$items + "`n" +
"  </channel>`n" +
"</rss>`n"

$out = Join-Path $root "feed.xml"
[System.IO.File]::WriteAllText($out, $feed, [System.Text.Encoding]::UTF8)
Write-Host ("feed.xml written - " + ($issues | Measure-Object).Count + " items")
