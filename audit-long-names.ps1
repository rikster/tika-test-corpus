# Audit script to find remaining long filenames

$corpusPath = ".\\_tika_corpus"
$allFiles = Get-ChildItem -Path $corpusPath -Recurse -File

# Group files by name length
$lengthGroups = @{
    VeryLong = @()    # > 80 characters
    Long = @()        # 51-80 characters
    Medium = @()      # 31-50 characters
    Short = @()       # <= 30 characters
}

foreach ($file in $allFiles) {
    $length = $file.Name.Length
    
    if ($length -gt 80) {
        $lengthGroups.VeryLong += $file
    } elseif ($length -gt 50) {
        $lengthGroups.Long += $file
    } elseif ($length -gt 30) {
        $lengthGroups.Medium += $file
    } else {
        $lengthGroups.Short += $file
    }
}

# Display statistics
Write-Host "=== FILENAME LENGTH AUDIT ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total files: $($allFiles.Count)" -ForegroundColor White
Write-Host ""
Write-Host "Distribution by length:" -ForegroundColor Yellow
Write-Host "  Very Long (>80 chars):  $($lengthGroups.VeryLong.Count)" -ForegroundColor $(if ($lengthGroups.VeryLong.Count -gt 0) { "Red" } else { "Green" })
Write-Host "  Long (51-80 chars):     $($lengthGroups.Long.Count)" -ForegroundColor $(if ($lengthGroups.Long.Count -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Medium (31-50 chars):   $($lengthGroups.Medium.Count)" -ForegroundColor Green
Write-Host "  Short (<=30 chars):     $($lengthGroups.Short.Count)" -ForegroundColor Green
Write-Host ""

# Show very long files if any
if ($lengthGroups.VeryLong.Count -gt 0) {
    Write-Host "=== VERY LONG FILENAMES (>80 chars) ===" -ForegroundColor Red
    $lengthGroups.VeryLong | Sort-Object -Property {$_.Name.Length} -Descending | ForEach-Object {
        $relPath = $_.DirectoryName -replace [regex]::Escape($PWD.Path), '.'
        Write-Host "$($_.Name.Length) chars: " -ForegroundColor Red -NoNewline
        Write-Host "$relPath\\" -ForegroundColor DarkGray -NoNewline
        Write-Host "$($_.Name)" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Show long files (top 30)
if ($lengthGroups.Long.Count -gt 0) {
    Write-Host "=== LONG FILENAMES (51-80 chars) - Top 30 ===" -ForegroundColor Yellow
    $lengthGroups.Long | Sort-Object -Property {$_.Name.Length} -Descending | Select-Object -First 30 | ForEach-Object {
        $relPath = $_.DirectoryName -replace [regex]::Escape($PWD.Path), '.'
        Write-Host "$($_.Name.Length) chars: " -ForegroundColor Yellow -NoNewline
        Write-Host "$relPath\\" -ForegroundColor DarkGray -NoNewline
        Write-Host "$($_.Name)" -ForegroundColor White
    }
    if ($lengthGroups.Long.Count -gt 30) {
        Write-Host "... and $($lengthGroups.Long.Count - 30) more" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# Show statistics by file type
Write-Host "=== LONG FILES BY TYPE ===" -ForegroundColor Cyan
$longFiles = $lengthGroups.VeryLong + $lengthGroups.Long
$byExtension = $longFiles | Group-Object -Property Extension | Sort-Object -Property Count -Descending

foreach ($group in $byExtension) {
    $ext = if ($group.Name) { $group.Name } else { "(no extension)" }
    Write-Host "  $ext : $($group.Count) files" -ForegroundColor White
}
Write-Host ""

# Average filename length
$avgLength = ($allFiles | Measure-Object -Property {$_.Name.Length} -Average).Average
Write-Host "Average filename length: $([math]::Round($avgLength, 1)) characters" -ForegroundColor Cyan
Write-Host ""

