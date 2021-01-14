#!/bin/pwsh
$ErrorActionPreference = "Stop"

# Create zip archive containing replays
$useZip = $false
if (Get-Command "zip" -ErrorAction SilentlyContinue)
{
    # Use zip if possible as it handles permissions better on unix
    $useZip = $true
    Write-Host "Using zip instead of Compress-Archive"
}

Write-Host -ForegroundColor Cyan "Re-creating artifacts directory..."
Remove-Item -Force -Recurse artifacts -ErrorAction SilentlyContinue
New-Item -Force -ItemType Directory artifacts | Out-Null

Write-Host -ForegroundColor Cyan "Copying replays..."
Push-Location replays
    Copy-Item -Recurse ../replays ../artifacts/
Pop-Location

Write-Host -ForegroundColor Cyan "Creating final archive..."
if ($useZip)
{
    Push-Location "artifacts/replays"
        zip -r9 "../replays.zip" (Get-ChildItem).Name
        if ($LASTEXITCODE -ne 0)
        {
            throw "zip failed with $LASTEXITCODE"
        }
    Pop-Location
}
else
{
    Compress-Archive -Force "artifacts/replays/*" -DestinationPath "artifacts/replays.zip" -CompressionLevel Optimal
}
Remove-Item -Force -Recurse artifacts/replays
$fileHash = Get-FileHash "artifacts/replays.zip" -Algorithm SHA1 | Select-Object Hash
Write-Host -ForegroundColor Cyan "SHA1:" $fileHash.Hash