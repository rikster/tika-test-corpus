# Script to update manifest.csv with new filenames

$manifestPath = ".\_tika_corpus\manifest.csv"
$corpusPath = ".\_tika_corpus"

Write-Host "Reading existing manifest..." -ForegroundColor Cyan

# Read the existing manifest as raw text to preserve structure
$manifestLines = Get-Content -Path $manifestPath

# Skip header
$header = $manifestLines[0]
$dataLines = $manifestLines[1..($manifestLines.Length - 1)]

# Create a hash map of SHA256 to current file paths
Write-Host "Scanning current files..." -ForegroundColor Cyan
$currentFiles = Get-ChildItem -Path $corpusPath -Recurse -File | Where-Object { $_.Name -ne "manifest.csv" }

Write-Host "Building SHA256 index (this may take a minute)..." -ForegroundColor Cyan
$sha256ToPath = @{}
$processed = 0
foreach ($file in $currentFiles) {
    $processed++
    if ($processed % 100 -eq 0) {
        Write-Host "  Processed $processed files..." -ForegroundColor Gray
    }

    # Calculate SHA256
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToLower()

    # Get relative path from corpus root
    $relPath = $file.FullName -replace [regex]::Escape((Resolve-Path $corpusPath).Path + "\"), ""
    $relPath = $relPath -replace "\\", "/"

    $sha256ToPath[$hash] = $relPath
}

Write-Host "Updating manifest entries..." -ForegroundColor Cyan

# Update the manifest with new paths
$updated = 0
$notFound = 0
$newLines = @($header)

foreach ($line in $dataLines) {
    # Parse CSV line (simple approach - assumes no commas in fields except reason which is last)
    $parts = $line -split ',', 7

    if ($parts.Length -ge 6) {
        $sha = $parts[0]
        $kind = $parts[1]
        $category = $parts[2]
        $size = $parts[3]
        $source = $parts[4]
        $oldDest = $parts[5]
        $reason = if ($parts.Length -gt 6) { $parts[6] } else { "" }

        if ($sha256ToPath.ContainsKey($sha)) {
            $newDest = $sha256ToPath[$sha]

            if ($oldDest -ne $newDest) {
                $updated++
            }

            # Rebuild line with new destination
            $newLine = "$sha,$kind,$category,$size,$source,$newDest,$reason"
            $newLines += $newLine
        } else {
            Write-Host "Warning: File not found for SHA256: $sha (was: $oldDest)" -ForegroundColor Yellow
            $notFound++
            $newLines += $line
        }
    } else {
        # Keep malformed lines as-is
        $newLines += $line
    }
}

Write-Host ""
Write-Host "=== RESULTS ===" -ForegroundColor Green
Write-Host "Total entries: $($dataLines.Length)"
Write-Host "Updated paths: $updated"
Write-Host "Not found: $notFound"
Write-Host ""

# Write updated manifest
Write-Host "Writing updated manifest..." -ForegroundColor Cyan
$newLines | Out-File -FilePath $manifestPath -Encoding UTF8

Write-Host "Done! Manifest updated at: $manifestPath" -ForegroundColor Green

