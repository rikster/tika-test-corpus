param(
    [switch]$Execute = $false
)

function Simplify-Filename {
    param([string]$filename)

    # Extract the actual filename (after last __)
    # Many files have pattern: path__filename__filename, so we want the last part
    if ($filename -match '__([^_\\]+\.[^_\\]+)$') {
        # Matches __filename.ext at the end
        $simplified = $matches[1]
    } elseif ($filename -match '__([^\\]+)$') {
        # Fallback: anything after last __
        $simplified = $matches[1]
    } else {
        $simplified = $filename
    }

    # Get extension
    $ext = [System.IO.Path]::GetExtension($simplified)
    $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($simplified)

    # Remove "test" prefix (case-insensitive) - handle TEST, Test, test
    $nameWithoutExt = $nameWithoutExt -ireplace '^test', ''

    # Simplify version patterns: Version.10.x -> v10, _Version.7.x -> _v7
    $nameWithoutExt = $nameWithoutExt -replace '_?[Vv]ersion\.(\d+)\.x', '_v$1'

    # Clean up parentheses - replace with underscores
    $nameWithoutExt = $nameWithoutExt -replace '[()]', '_'

    # Remove duplicate underscores
    $nameWithoutExt = $nameWithoutExt -replace '__+', '_'

    # Remove leading/trailing underscores
    $nameWithoutExt = $nameWithoutExt.Trim('_')

    # Convert to lowercase
    $nameWithoutExt = $nameWithoutExt.ToLower()

    # Remove duplicate underscores again (after lowercase conversion)
    $nameWithoutExt = $nameWithoutExt -replace '__+', '_'
    $nameWithoutExt = $nameWithoutExt.Trim('_')

    return $nameWithoutExt + $ext.ToLower()
}

# Get all files in the corpus
$corpusPath = ".\_tika_corpus"
$allFiles = Get-ChildItem -Path $corpusPath -Recurse -File

$renameMap = @{}
$conflicts = @{}
$stats = @{
    Total = 0
    ToRename = 0
    NoChange = 0
    Conflicts = 0
}

Write-Host "Analyzing files..." -ForegroundColor Cyan
Write-Host ""

foreach ($file in $allFiles) {
    $stats.Total++
    
    $oldName = $file.Name
    $newName = Simplify-Filename -filename $oldName
    
    if ($oldName -eq $newName) {
        $stats.NoChange++
        continue
    }
    
    $stats.ToRename++
    
    # Check for conflicts (same new name in same directory)
    $dirPath = $file.DirectoryName
    $conflictKey = "$dirPath\$newName"
    
    if ($renameMap.ContainsKey($conflictKey)) {
        $stats.Conflicts++
        if (-not $conflicts.ContainsKey($conflictKey)) {
            $conflicts[$conflictKey] = @()
        }
        $conflicts[$conflictKey] += $oldName
    } else {
        $renameMap[$conflictKey] = @{
            OldPath = $file.FullName
            OldName = $oldName
            NewName = $newName
            Directory = $dirPath
        }
    }
}

# Display statistics
Write-Host "=== STATISTICS ===" -ForegroundColor Yellow
Write-Host "Total files: $($stats.Total)"
Write-Host "Files to rename: $($stats.ToRename)"
Write-Host "Files unchanged: $($stats.NoChange)"
Write-Host "Conflicts detected: $($stats.Conflicts)"
Write-Host ""

# Display conflicts if any
if ($conflicts.Count -gt 0) {
    Write-Host "=== CONFLICTS DETECTED ===" -ForegroundColor Red
    Write-Host "The following files would have the same name after renaming:"
    Write-Host ""
    foreach ($conflict in $conflicts.GetEnumerator()) {
        Write-Host "Target: $($conflict.Key)" -ForegroundColor Red
        foreach ($oldName in $conflict.Value) {
            Write-Host "  - $oldName" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    Write-Host "Please resolve conflicts manually before proceeding." -ForegroundColor Red
    Write-Host ""
}

# Display sample renames (first 20)
Write-Host "=== SAMPLE RENAMES (first 20) ===" -ForegroundColor Cyan
$sampleCount = 0
foreach ($item in $renameMap.GetEnumerator() | Select-Object -First 20) {
    $info = $item.Value
    $relDir = $info.Directory -replace [regex]::Escape($PWD.Path), '.'
    Write-Host "$relDir\" -ForegroundColor DarkGray -NoNewline
    Write-Host "$($info.OldName)" -ForegroundColor Red -NoNewline
    Write-Host " → " -NoNewline
    Write-Host "$($info.NewName)" -ForegroundColor Green
    $sampleCount++
}

if ($renameMap.Count -gt 20) {
    Write-Host "... and $($renameMap.Count - 20) more files" -ForegroundColor DarkGray
}
Write-Host ""

# Execute renames if requested
if ($Execute) {
    if ($conflicts.Count -gt 0) {
        Write-Host "Cannot execute: conflicts detected. Resolve conflicts first." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "=== EXECUTING RENAMES ===" -ForegroundColor Yellow
    $renamed = 0
    $errors = 0
    
    foreach ($item in $renameMap.GetEnumerator()) {
        $info = $item.Value
        try {
            Rename-Item -Path $info.OldPath -NewName $info.NewName -ErrorAction Stop
            $renamed++
            if ($renamed % 100 -eq 0) {
                Write-Host "Renamed $renamed files..." -ForegroundColor Gray
            }
        } catch {
            Write-Host "Error renaming $($info.OldName): $_" -ForegroundColor Red
            $errors++
        }
    }
    
    Write-Host ""
    Write-Host "=== COMPLETE ===" -ForegroundColor Green
    Write-Host "Successfully renamed: $renamed files"
    if ($errors -gt 0) {
        Write-Host "Errors: $errors" -ForegroundColor Red
    }
} else {
    Write-Host "=== PREVIEW MODE ===" -ForegroundColor Yellow
    Write-Host "This is a preview. No files have been renamed."
    Write-Host "To execute the renames, run: .\rename-files.ps1 -Execute"
    Write-Host ""
}

