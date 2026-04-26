param(
  [string[]]$Path = @('vydania/*/index.html'),
  [string]$OutputDir = ''
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
  $shareUrl = "$SiteBase/share/index.html?issue=$issueNumber"

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
    -Replacement ('$1{unsubscribe}$2')

  # Email should keep a normal share-page link, never a script-driven button.
  $updated = Replace-FirstPattern `
    -Html $updated `
    -Pattern '(<a href=")[^"]*("(?=[^>]*>\s*Zdieľaj\s*</a>))' `
    -Replacement ('$1' + $shareUrl + '$2')

  $updated = $updated.Replace(' class="js-share-link"', '')
  $updated = [regex]::Replace($updated, ' data-share-url="[^"]*"', '')

  # Email HTML must stay script-free.
  $updated = [regex]::Replace($updated, '<script\b[^>]*>[\s\S]*?</script>', '', [Text.RegularExpressions.RegexOptions]::Singleline)

  # Brevo expects body content only — no <!DOCTYPE>, <html>, or <head>.
  # Extract the <style> block from <head> and the inner <body> content, combine them.
  $styleMatch = [regex]::Match($updated, '<style>([\s\S]*?)</style>', [Text.RegularExpressions.RegexOptions]::Singleline)
  $bodyMatch  = [regex]::Match($updated, '<body[^>]*>([\s\S]*?)</body>', [Text.RegularExpressions.RegexOptions]::Singleline)

  if ($styleMatch.Success -and $bodyMatch.Success) {
    $updated = "<style>" + $styleMatch.Groups[1].Value + "</style>" + $bodyMatch.Groups[1].Value
  }

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

$UseIssueDir = (-not $OutputDir)

$OutputDirPath = $null
if (-not $UseIssueDir) {
  $OutputDirPath = if ([System.IO.Path]::IsPathRooted($OutputDir)) {
    $OutputDir
  } else {
    Join-Path $ScriptRoot $OutputDir
  }
  if (-not (Test-Path $OutputDirPath)) {
    New-Item -ItemType Directory -Path $OutputDirPath | Out-Null
  }
}

$InlinerScript = Join-Path $ScriptRoot 'inline-email-css.py'

foreach ($issuePath in $resolvedPaths) {
  $html = [System.IO.File]::ReadAllText($issuePath, [System.Text.Encoding]::UTF8)
  $result = Convert-ToBrevoEmailHtml -FilePath $issuePath -Html $html
  $targetDir = if ($UseIssueDir) { Split-Path $issuePath -Parent } else { $OutputDirPath }
  $outputPath = Join-Path $targetDir ($result.IssueNumber + '-brevo.html')

  # Write intermediate file, then inline CSS via Python so email clients render styles
  [System.IO.File]::WriteAllText($outputPath, $result.Html, $Utf8NoBom)
  $inlineOut = & python3 $InlinerScript $outputPath $outputPath 2>$null
  if ($LASTEXITCODE -ne 0) {
    Write-Warning ("CSS inlining failed for " + $outputPath)
  } else {
    Write-Host ("Prepared Brevo email HTML (CSS inlined): " + $outputPath + " -> " + $result.IssueUrl)
  }

  # Inject noindex + canonical into brevo file so it is never indexed as duplicate content.
  # The canonical points back to the web version of this issue.
  $brevoHtml = [System.IO.File]::ReadAllText($outputPath, [System.Text.UTF8Encoding]::new($false))
  $noindexMeta = "<meta name=`"robots`" content=`"noindex, nofollow`">`n<link rel=`"canonical`" href=`"$($result.IssueUrl)`">"
  $brevoHtml = $brevoHtml -replace '(<head[^>]*>)', "`$1`n$noindexMeta"
  [System.IO.File]::WriteAllText($outputPath, $brevoHtml, [System.Text.UTF8Encoding]::new($false))
}
