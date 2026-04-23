param(
  [string]$IssuesFile = ".\issues.js",
  [string]$ArchiveRoot = ".\archiv"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $IssuesFile)) {
  throw "Issues file not found: $IssuesFile"
}

$issuesText = Get-Content -LiteralPath $IssuesFile -Raw -Encoding UTF8
$matches = [regex]::Matches(
  $issuesText,
  '(?s)\{\s*number:\s*(\d+),\s*title:\s*"((?:[^"\\]|\\.)*)",.*?date:\s*"(\d{4}-\d{2}-\d{2})",'
)

if ($matches.Count -eq 0) {
  throw "No issues found in $IssuesFile"
}

$issues = foreach ($match in $matches) {
  [pscustomobject]@{
    Number = [int]$match.Groups[1].Value
    Title  = ($match.Groups[2].Value -replace '\\"', '"')
    Date   = $match.Groups[3].Value
  }
}

$groupedByDate = $issues | Group-Object Date

foreach ($group in $groupedByDate) {
  $date = $group.Name
  $parts = $date.Split('-')
  $year = $parts[0]
  $month = $parts[1]
  $day = $parts[2]

  $dir = Join-Path $ArchiveRoot (Join-Path $day (Join-Path $month $year))
  New-Item -ItemType Directory -Force -Path $dir | Out-Null

  $displayPath = "/archiv/$day/$month/$year/"
  $outFile = Join-Path $dir "index.html"
  $items = @($group.Group | Sort-Object Number -Descending)

  if ($items.Count -eq 1) {
    $number = $items[0].Number
    $targetUrl = "https://rannasprava.sk/vydania/$number/"
    $html = @"
<!DOCTYPE html>
<html lang="sk">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Rann&aacute; Spr&aacute;va &mdash; Arch&iacute;v $displayPath</title>
<meta name="description" content="Rann&aacute; Spr&aacute;va, vydanie z d&aacute;tumu $date &mdash; slovensk&yacute; denn&yacute; newsletter. Slovensko a svet za 5 min&uacute;t.">
<meta http-equiv="refresh" content="0; url=$targetUrl">
<link rel="canonical" href="$targetUrl">
<style>
  body {
    margin: 0;
    padding: 32px 20px;
    background: #F5F0E8;
    color: #1A1208;
    font-family: Georgia, serif;
    line-height: 1.6;
  }
  .wrap {
    max-width: 680px;
    margin: 0 auto;
    background: #FAFAF7;
    border: 1px solid #1A1208;
    padding: 28px 24px;
  }
  h1 {
    margin: 0 0 12px;
    font-size: 28px;
  }
  p {
    margin: 0 0 12px;
    font-size: 16px;
  }
  a {
    color: #1A1208;
  }
</style>
<script>
  window.location.replace("$targetUrl");
</script>
</head>
<body>
  <div class="wrap">
    <h1>Presmerovanie na vydanie Rannej Spr&aacute;vy</h1>
    <p>T&aacute;to archive URL je verejn&yacute; d&aacute;tumov&yacute; alias pre vydanie z d&aacute;tumu $date.</p>
    <p>Ak sa str&aacute;nka nepresmeruje automaticky, otvor ju tu:
      <a href="$targetUrl">$targetUrl</a>
    </p>
  </div>
</body>
</html>
"@
  }
  else {
    $linksHtml = ($items | ForEach-Object {
      $issueUrl = "https://rannasprava.sk/vydania/$($_.Number)/"
      ('<li><a href="{0}" data-issue-number="{1}">Vydanie #{1}</a> &mdash; {2}</li>' -f $issueUrl, $_.Number, $_.Title)
    }) -join [Environment]::NewLine

    $issueMapLines = ($items | ForEach-Object {
      ('    "{0}": "https://rannasprava.sk/vydania/{0}/"' -f $_.Number)
    }) -join ",`n"

    $html = @"
<!DOCTYPE html>
<html lang="sk">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Rann&aacute; Spr&aacute;va &mdash; Arch&iacute;v $displayPath</title>
<meta name="description" content="Rann&aacute; Spr&aacute;va, vydania z d&aacute;tumu $date &mdash; slovensk&yacute; denn&yacute; newsletter. Slovensko a svet za 5 min&uacute;t.">
<link rel="canonical" href="https://rannasprava.sk$displayPath">
<style>
  body {
    margin: 0;
    padding: 32px 20px;
    background: #F5F0E8;
    color: #1A1208;
    font-family: Georgia, serif;
    line-height: 1.6;
  }
  .wrap {
    max-width: 760px;
    margin: 0 auto;
    background: #FAFAF7;
    border: 1px solid #1A1208;
    padding: 28px 24px;
  }
  h1 {
    margin: 0 0 12px;
    font-size: 28px;
  }
  p {
    margin: 0 0 12px;
    font-size: 16px;
  }
  ul {
    margin: 16px 0 0 18px;
    padding: 0;
  }
  li {
    margin: 0 0 10px;
  }
  a {
    color: #1A1208;
  }
</style>
<script>
  (function () {
    var map = {
$issueMapLines
    };
    var hash = window.location.hash || '';
    var match = hash.match(/^#issue-(\d+)$/);
    if (match && map[match[1]]) {
      window.location.replace(map[match[1]]);
    }
  })();
</script>
</head>
<body>
  <div class="wrap">
    <h1>Viac vydan&iacute; na rovnak&yacute; d&aacute;tum</h1>
    <p>D&aacute;tumov&aacute; archive URL <strong>$displayPath</strong> m&aacute; viac ako jedno vydanie. Vyber si spr&aacute;vne &ccaron;&iacute;slo issue ni&zcaron;&scaron;ie.</p>
    <ul>
$linksHtml
    </ul>
  </div>
</body>
</html>
"@
  }

  Set-Content -LiteralPath $outFile -Value $html -Encoding UTF8
}

Write-Host "Generated $($groupedByDate.Count) archive date alias pages under $ArchiveRoot"
