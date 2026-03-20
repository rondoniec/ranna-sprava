param(
  [string[]]$Path = @('vydania/*/index.html'),
  [string]$OutputDir = 'emails'
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
$SiteBase = 'https://rannasprava.sk'
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

function Get-IssueNumber {
  param(
    [string]$FilePath,
    [string]$Html
  )

  $folderName = Split-Path (Split-Path $FilePath -Parent) -Leaf
  if ($folderName -match '^\d+$') {
    return $folderName
  }

  $titleMatch = [regex]::Match($Html, 'Vydanie\s*#\s*(\d+)', 'IgnoreCase')
  if ($titleMatch.Success) {
    return $titleMatch.Groups[1].Value
  }

  throw "Could not determine issue number for $FilePath."
}

function Replace-FirstPattern {
  param(
    [string]$Html,
    [string]$Pattern,
    [string]$Replacement
  )

  return ([regex]::new($Pattern, [Text.RegularExpressions.RegexOptions]::Singleline)).Replace($Html, $Replacement, 1)
}

function Convert-ToBrevoEmailHtml {
  param(
    [string]$FilePath,
    [string]$Html
  )

  $issueNumber = Get-IssueNumber -FilePath $FilePath -Html $Html
  $issueUrl = "$SiteBase/vydania/$issueNumber/"

  $updated = $Html

  # Keep the original mast-top copy and only swap the link target.
  $updated = Replace-FirstPattern `
    -Html $updated `
    -Pattern '(<div class="mast-top">[\s\S]*?<a href=")[^"]*(")' `
    -Replacement ('$1' + $issueUrl + '$2')

  # Brevo handles unsubscribe properly; replace the first footer link only.
  $updated = Replace-FirstPattern `
    -Html $updated `
    -Pattern '(<p class="foot-copy">[\s\S]*?<a href=")[^"]*(">)' `
    -Replacement ('$1{{ unsubscribe }}$2')

  return [pscustomobject]@{
    IssueNumber = $issueNumber
    IssueUrl = $issueUrl
    Html = $updated
  }
}

$resolvedPaths = @()
foreach ($entry in $Path) {
  $resolvedPaths += Get-ChildItem -Path $entry -File | Select-Object -ExpandProperty FullName
}

$resolvedPaths = $resolvedPaths | Sort-Object -Unique
if (-not $resolvedPaths -or $resolvedPaths.Count -eq 0) {
  throw 'No issue files matched the provided path.'
}

$OutputDirPath = if ([System.IO.Path]::IsPathRooted($OutputDir)) {
  $OutputDir
} else {
  Join-Path $ScriptRoot $OutputDir
}

if (-not (Test-Path $OutputDirPath)) {
  New-Item -ItemType Directory -Path $OutputDirPath | Out-Null
}

foreach ($issuePath in $resolvedPaths) {
  $html = [System.IO.File]::ReadAllText($issuePath, [System.Text.Encoding]::UTF8)
  $result = Convert-ToBrevoEmailHtml -FilePath $issuePath -Html $html
  $outputPath = Join-Path $OutputDirPath ($result.IssueNumber + '-brevo.html')
  [System.IO.File]::WriteAllText($outputPath, $result.Html, $Utf8NoBom)
  Write-Host ("Prepared Brevo email HTML: " + $outputPath + " -> " + $result.IssueUrl)
}
