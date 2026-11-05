# Generate the image and PDF manifest for Rocky Singh Hub.
# Save this script in the repository root, beside index.html.
# Run it whenever you add or remove images/PDFs.

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$imagesFolder = Join-Path $root "images"
$pdfFolder = Join-Path $root "PDF"
$outputFile = Join-Path $root "site-content.json"

if (-not (Test-Path -LiteralPath $imagesFolder -PathType Container)) {
    throw "The images folder was not found: $imagesFolder"
}

if (-not (Test-Path -LiteralPath $pdfFolder -PathType Container)) {
    throw "The PDF folder was not found: $pdfFolder"
}

$imageExtensions = @(".jpg", ".jpeg", ".png", ".webp", ".gif")

$backgroundImages = @(
    Get-ChildItem -LiteralPath $imagesFolder -File |
    Where-Object { $imageExtensions -contains $_.Extension.ToLowerInvariant() } |
    Sort-Object Name |
    ForEach-Object {
        "./images/" + [System.Uri]::EscapeDataString($_.Name)
    }
)

$pdfs = @(
    Get-ChildItem -LiteralPath $pdfFolder -File |
    Where-Object { $_.Extension -ieq ".pdf" } |
    Sort-Object Name |
    ForEach-Object {
        [ordered]@{
            title    = $_.BaseName
            fileName = $_.Name
            url      = "./PDF/" + [System.Uri]::EscapeDataString($_.Name)
        }
    }
)

$manifest = [ordered]@{
    backgroundImages = $backgroundImages
    pdfs             = $pdfs
}

$json = $manifest | ConvertTo-Json -Depth 5
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outputFile, $json, $utf8NoBom)

Write-Host ""
Write-Host "Rocky Singh Hub manifest created successfully." -ForegroundColor Green
Write-Host ("Background images found: " + $backgroundImages.Count)
Write-Host ("PDF files found: " + $pdfs.Count)
Write-Host ("Output: " + $outputFile)
Write-Host ""
