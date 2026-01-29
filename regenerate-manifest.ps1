# Script to regenerate manifest.csv with current filenames
# This script scans all files, calculates their SHA256, and updates the manifest

$manifestPath = ".\_tika_corpus\manifest.csv"
$corpusPath = ".\_tika_corpus"

Write-Host "Reading existing manifest..." -ForegroundColor Cyan
$oldManifest = Import-Csv -Path $manifestPath

# Create a lookup by SHA256
$manifestBySha = @{}
foreach ($entry in $oldManifest) {
    $manifestBySha[$entry.sha256] = $entry
}

Write-Host "Scanning current files and calculating SHA256..." -ForegroundColor Cyan
$currentFiles = Get-ChildItem -Path $corpusPath -Recurse -File | Where-Object { $_.Name -ne "manifest.csv" }

$newManifest = @()
$processed = 0
$found = 0
$notFound = 0

foreach ($file in $currentFiles) {
    $processed++
    if ($processed % 50 -eq 0) {
        Write-Host "  Processed $processed / $($currentFiles.Count) files..." -ForegroundColor Gray
    }
    
    # Calculate SHA256
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToLower()
    
    # Get relative path from corpus root
    $relPath = $file.FullName -replace [regex]::Escape((Resolve-Path $corpusPath).Path + "\"), ""
    $relPath = $relPath -replace "\\", "/"
    
    # Look up in old manifest
    if ($manifestBySha.ContainsKey($hash)) {
        $oldEntry = $manifestBySha[$hash]
        
        # Create new entry with updated dest_rel
        $newEntry = [PSCustomObject]@{
            sha256 = $hash
            kind = $oldEntry.kind
            category = $oldEntry.category
            size_bytes = $oldEntry.size_bytes
            source_rel = $oldEntry.source_rel
            dest_rel = $relPath
            reason = $oldEntry.reason
        }
        
        $newManifest += $newEntry
        $found++
    } else {
        Write-Host "Warning: File not in manifest: $relPath (SHA256: $hash)" -ForegroundColor Yellow
        $notFound++
    }
}

Write-Host ""
Write-Host "=== RESULTS ===" -ForegroundColor Green
Write-Host "Files processed: $processed"
Write-Host "Files matched: $found"
Write-Host "Files not in manifest: $notFound"
Write-Host ""

# Write new manifest
Write-Host "Writing updated manifest..." -ForegroundColor Cyan
$newManifest | Export-Csv -Path $manifestPath -NoTypeInformation

Write-Host "Done! Manifest regenerated at: $manifestPath" -ForegroundColor Green

