param(
  [Parameter(Mandatory = $true)]
  [string]$Url,

  [string]$Path
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

function Get-LatestIssuePath {
  param([string]$Root)

  $latestDir = Get-ChildItem -Path (Join-Path $Root 'vydania') -Directory |
    Where-Object { $_.Name -match '^\d+$' } |
    Sort-Object { [int]$_.Name } -Descending |
    Select-Object -First 1

  if (-not $latestDir) {
    throw 'Could not find any numeric issue directories under vydania/.'
  }

  $issuePath = Join-Path $latestDir.FullName 'index.html'
  if (-not (Test-Path $issuePath)) {
    throw "Could not find issue HTML at $issuePath."
  }

  return $issuePath
}

function Resolve-IssuePath {
  param(
    [string]$Root,
    [string]$RawPath
  )

  if ([string]::IsNullOrWhiteSpace($RawPath)) {
    return Get-LatestIssuePath -Root $Root
  }

  if ([System.IO.Path]::IsPathRooted($RawPath)) {
    return $RawPath
  }

  return Join-Path $Root $RawPath
}

function Get-SpotifyEmbedTarget {
  param([string]$RawUrl)

  $match = [regex]::Match($RawUrl, 'open\.spotify\.com/(show|episode)/([A-Za-z0-9]+)', 'IgnoreCase')
  if (-not $match.Success) {
    throw 'URL must be a Spotify show or episode link from open.spotify.com.'
  }

  $type = $match.Groups[1].Value.ToLowerInvariant()
  $id = $match.Groups[2].Value
  $canonicalUrl = 'https://open.spotify.com/' + $type + '/' + $id
  $embedUrl = 'https://open.spotify.com/embed/' + $type + '/' + $id + '?utm_source=generator'

  return [pscustomobject]@{
    Type = $type
    CanonicalUrl = $canonicalUrl
    EmbedUrl = $embedUrl
  }
}

$issuePath = Resolve-IssuePath -Root $ScriptRoot -RawPath $Path
if (-not (Test-Path $issuePath)) {
  throw "Issue file not found: $issuePath"
}

$target = Get-SpotifyEmbedTarget -RawUrl $Url
$html = [System.IO.File]::ReadAllText($issuePath, [System.Text.Encoding]::UTF8)

if ($html -notmatch 'class="podcast-embed"') {
  throw "No podcast embed block found in $issuePath"
}

$updated = $html
$updated = [regex]::Replace($updated, '(class="podcast-embed"[\s\S]*?\ssrc=")[^"]*(")', ('$1' + $target.EmbedUrl + '$2'), 1)
$updated = [regex]::Replace($updated, '(class="podcast-embed"[\s\S]*?\sdata-podcast-embed-url=")[^"]*(")', ('$1' + $target.CanonicalUrl + '$2'), 1)
$updated = [regex]::Replace($updated, '(class="podcast-embed"[\s\S]*?\sdata-podcast-embed-type=")[^"]*(")', ('$1' + $target.Type + '$2'), 1)

[System.IO.File]::WriteAllText($issuePath, $updated, $Utf8NoBom)

Write-Host ("Updated podcast embed in " + $issuePath)
Write-Host ("  Type: " + $target.Type)
Write-Host ("  Embed URL: " + $target.EmbedUrl)
