# publish.ps1
# Master regeneration script. Run after committing a new issue's core files
# (vydania/N/index.html, issues.js). Regenerates all derived site assets.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\publish.ps1 -Issue 87
#
# Called automatically by the rannaspravaposts skill (Step 6).
# Do NOT call ping-indexnow here — that runs after git push, handled by skill.

param([int]$Issue = 0)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# Pick PowerShell executable: prefer pwsh (cross-platform), fallback to Windows powershell
$psExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }

if ($Issue -eq 0) {
    # Auto-detect latest issue from issues.js
    $js   = Get-Content issues.js -Raw -Encoding UTF8
    $m    = [regex]::Match($js, 'number:\s*(\d+)')
    $Issue = [int]$m.Groups[1].Value
    Write-Host "Auto-detected latest issue: #$Issue"
}

Write-Host ""
Write-Host "=== publish.ps1 — issue #$Issue ==="
Write-Host ""

Write-Host "[1/7] NewsArticle JSON-LD + meta/OG/canonical for issue #$Issue..."
& $psExe -ExecutionPolicy Bypass -File ./generate-issue-schema.ps1 -Apply -Issue $Issue

Write-Host "[2/7] Archive date alias pages..."
& $psExe -ExecutionPolicy Bypass -File ./generate-archive-date-pages.ps1

Write-Host "[3/7] Static archive links in index.html..."
& $psExe -ExecutionPolicy Bypass -File ./generate-static-archive.ps1

Write-Host "[4/7] sitemap.xml..."
& $psExe -ExecutionPolicy Bypass -File ./generate-sitemap.ps1

Write-Host "[5/7] feed.xml (RSS)..."
& $psExe -ExecutionPolicy Bypass -File ./generate-feed.ps1

Write-Host "[6/7] llms.txt + llms-full.txt..."
& $psExe -ExecutionPolicy Bypass -File ./generate-llms.ps1

Write-Host "[7/7] Topic pages (temy/)..."
& $psExe -ExecutionPolicy Bypass -File ./generate-topic-pages.ps1

Write-Host ""
Write-Host "=== Done. All assets regenerated for issue #$Issue. ==="
Write-Host "Next: git add, git commit, git push, then ping-indexnow.ps1 -Issue $Issue"
Write-Host ""
