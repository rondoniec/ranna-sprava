# generate-llms.ps1
# Generates llms.txt and llms-full.txt from issues.js.
# Run from repo root: powershell -ExecutionPolicy Bypass -File .\generate-llms.ps1

$base   = "https://rannasprava.sk"
$root   = $PSScriptRoot
$jsPath = Join-Path $root "issues.js"
$js     = Get-Content $jsPath -Raw -Encoding UTF8

# Parse issue blocks: extract number, title, date, preview
$issues = [System.Collections.Generic.List[hashtable]]::new()
$pattern = 'number:\s*(\d+).*?title:\s*"((?:[^"\\]|\\.)*)".*?date:\s*"(\d{4}-\d{2}-\d{2})".*?preview:\s*"((?:[^"\\]|\\.)*)"'
$rx = [System.Text.RegularExpressions.Regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$found = $rx.Matches($js)
foreach ($m in $found) {
    $t = $m.Groups[2].Value; $t = $t -replace '\\\"', '"'
    $p = $m.Groups[4].Value; $p = $p -replace '\\\"', '"'
    $issues.Add(@{
        number  = [int]$m.Groups[1].Value
        title   = $t
        date    = $m.Groups[3].Value
        preview = $p
    })
}

# Sort descending, skip duplicate/misnamed issue 492
$issues = $issues | Where-Object { $_.number -lt 200 } | Sort-Object { $_.date } -Descending

$recent = $issues | Select-Object -First 10
$today  = (Get-Date).ToString("yyyy-MM-dd")

# --- llms.txt ---
$recentLines = foreach ($i in $recent) {
    "- [Vydanie #$($i.number): $($i.title)]($base/vydania/$($i.number)/) ($($i.date))"
    "  $($i.preview)"
}
$recentBlock = $recentLines -join "`n"

$allLines = foreach ($i in $issues) {
    "- $base/vydania/$($i.number)/ | #$($i.number) | $($i.date) | $($i.title)"
}
$allBlock = $allLines -join "`n"

$llms = "# Ranna Sprava`n`n" +
    "> Slovensky denny newsletter. Slovensko a svet za 5 minut. Kazde pracovne rano.`n`n" +
    "Ranna Sprava je bezplatny denny newsletter v slovenskom jazyku. Od marca 2025, kazdy pracovny den. Kazde vydanie obsahuje hlavnu temu, prehlad sprav, trhove data (Bitcoin, S&P 500, EUR/USD, MSCI World, zlato) a predpoved pocasia.`n`n" +
    "## Redakcna politika`n`n" +
    "- Jazyk: slovencina (Slovak)`n" +
    "- Vydava sa: kazdy pracovny den (pondelok-piatok)`n" +
    "- Pokrytie: Slovenska republika, region strednej a vychodnej Europy, svet`n" +
    "- Kazde tvrdenie je podlozene overitelnym zdrojom; zdroje su archivovane v sources.md pri kazdom vydani`n" +
    "- Bez platobnej brany - vsetok obsah je verejne dostupny na https://rannasprava.sk`n" +
    "- Archiv vsetkych vydani: https://rannasprava.sk/vydania/`n`n" +
    "## Poslednch 10 vydani`n`n" +
    $recentBlock + "`n`n" +
    "## Cely archiv`n`n" +
    $allBlock + "`n`n" +
    "---`nGenerovane: $today`n"

# --- llms-full.txt ---
$fullLines = foreach ($i in $issues) {
    $issueFile = Join-Path $root "vydania\$($i.number)\index.html"
    $coldOpen = ""
    if (Test-Path $issueFile) {
        $html = Get-Content $issueFile -Raw -Encoding UTF8
        if ($html -match '<div class="cold-open">(.*?)</div>') {
            $coldOpen = "`n  Uvod: " + ($matches[1] -replace '<[^>]+>', '')
        }
    }
    "## Vydanie #$($i.number): $($i.title)`n" +
    "  URL: $base/vydania/$($i.number)/`n" +
    "  Datum: $($i.date)`n" +
    "  Perex: $($i.preview)$coldOpen"
}
$fullContent = "# Ranna Sprava - Uplny archiv`n`n" +
    "> Slovensky denny newsletter. Kazde pracovne rano. https://rannasprava.sk`n`n" +
    ($fullLines -join "`n`n") + "`n`n---`nGenerovane: $today`n"

$enc = [System.Text.Encoding]::UTF8
[System.IO.File]::WriteAllText((Join-Path $root "llms.txt"),      $llms,        $enc)
[System.IO.File]::WriteAllText((Join-Path $root "llms-full.txt"), $fullContent, $enc)

Write-Host ("llms.txt + llms-full.txt written - " + $issues.Count + " issues")
