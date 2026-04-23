# ping-indexnow.ps1
# Notifies Bing (and Yandex) about a newly published or updated URL via IndexNow.
# Run after `git push` for each new issue.
#
# Usage:
#   .\ping-indexnow.ps1 -Issue 87          # ping single issue URL
#   .\ping-indexnow.ps1 -Url "https://rannasprava.sk/co-je-ranna-sprava/"  # arbitrary URL
#   .\ping-indexnow.ps1 -All               # ping all URLs in sitemap.xml

param(
    [int]$Issue = 0,
    [string]$Url = "",
    [switch]$All
)

$key     = "7c1b25348bb644d383257abbe2001986"
$keyLoc  = "https://rannasprava.sk/7c1b25348bb644d383257abbe2001986.txt"
$apiUrl  = "https://api.indexnow.org/indexnow"
$root    = Split-Path -Parent $MyInvocation.MyCommand.Path

function Ping-Url {
    param([string]$TargetUrl)
    $encoded = [uri]::EscapeDataString($TargetUrl)
    $encodedKeyLoc = [uri]::EscapeDataString($keyLoc)
    $get = $apiUrl + "?url=" + $encoded + "&key=" + $key + "&keyLocation=" + $encodedKeyLoc
    try {
        $resp = Invoke-WebRequest -Uri $get -UseBasicParsing -TimeoutSec 10
        Write-Host "[$($resp.StatusCode)] $TargetUrl"
    } catch {
        Write-Host "[ERR] $TargetUrl - $($_.Exception.Message)"
    }
}

if ($Issue -gt 0) {
    Ping-Url "https://rannasprava.sk/vydania/$Issue/"
    # Also ping the sitemap so Bing refreshes the index
    Ping-Url "https://rannasprava.sk/sitemap.xml"
    Write-Host "Done. IndexNow pinged for issue #$Issue."
} elseif ($Url -ne "") {
    Ping-Url $Url
    Write-Host "Done."
} elseif ($All) {
    $sitemapPath = Join-Path $root "sitemap.xml"
    [xml]$sitemap = Get-Content $sitemapPath -Encoding UTF8
    $urls = $sitemap.urlset.url | ForEach-Object { $_.loc }
    Write-Host "Pinging $($urls.Count) URLs..."
    foreach ($u in $urls) { Ping-Url $u }
    Write-Host "Done. All sitemap URLs pinged."
} else {
    Write-Host "Usage: .\ping-indexnow.ps1 -Issue 87  |  -Url <url>  |  -All"
}
