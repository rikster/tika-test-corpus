param(
    [switch]$Execute = $false
)

function Further-Simplify-Filename {
    param([string]$filename)
    
    # Get extension
    $ext = [System.IO.Path]::GetExtension($filename)
    $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($filename)
    
    # Remove common path prefixes - these are the remnants from the first pass
    # Pattern: remove everything up to and including common path markers
    $pathMarkers = @(
        'tika-parsers-standard_tika-parsers-standard-modules_tika-parser-_',
        'tika-parsers-standard_tika-parsers-standard-package_src_test_r_',
        'tika-parsers-ml_tika-transcribe-aws_src_test_resources_test-d_',
        'tika-parsers-extended_tika-parser-scientific-module_src_test_r_',
        'tika-server-standard_src_test_resources_test-documents_',
        'tika-server-core_src_test_resources_test-documents_',
        'tika-app_src_test_resources_test-data_',
        'tika-core_src_test_resources_test-documents_',
        'src_test_resources_test-documents_',
        'src_test_resources_test-data_',
        'src_test_r_',
        'test-documents_',
        'test-data_'
    )
    
    # Try to remove the longest matching prefix first
    $simplified = $nameWithoutExt
    foreach ($marker in $pathMarkers | Sort-Object -Property Length -Descending) {
        if ($simplified -match "^$([regex]::Escape($marker))(.+)$") {
            $simplified = $matches[1]
            break
        }
    }
    
    # Also handle patterns like: bz2_test-file-1.csv.bz2 -> test-file-1.csv
    # (where the directory name got prepended)
    if ($simplified -match '^[^_]+_(.+)$' -and $simplified.StartsWith(($ext -replace '\.', '') + '_')) {
        $simplified = $matches[1]
    }
    
    # Remove duplicate file extensions in the name (e.g., file.csv.bz2_file.csv -> file.csv)
    if ($simplified -match '(.+)\.\w+_\1$') {
        $simplified = $matches[1]
    }
    
    return $simplified + $ext
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

Write-Host "Analyzing files for second pass simplification..." -ForegroundColor Cyan
Write-Host ""

foreach ($file in $allFiles) {
    $stats.Total++
    
    $oldName = $file.Name
    $newName = Further-Simplify-Filename -filename $oldName
    
    if ($oldName -eq $newName) {
        $stats.NoChange++
        continue
    }
    
    $stats.ToRename++
    
    # Check for conflicts
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

# Display sample renames (first 30)
Write-Host "=== SAMPLE RENAMES (first 30) ===" -ForegroundColor Cyan
foreach ($item in $renameMap.GetEnumerator() | Select-Object -First 30) {
    $info = $item.Value
    $relDir = $info.Directory -replace [regex]::Escape($PWD.Path), '.'
    Write-Host "$relDir\" -ForegroundColor DarkGray -NoNewline
    Write-Host "$($info.OldName)" -ForegroundColor Red -NoNewline
    Write-Host " → " -NoNewline
    Write-Host "$($info.NewName)" -ForegroundColor Green
}

if ($renameMap.Count -gt 30) {
    Write-Host "... and $($renameMap.Count - 30) more files" -ForegroundColor DarkGray
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
            if ($renamed % 50 -eq 0) {
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
    Write-Host "To execute the renames, run: .\rename-files-pass2.ps1 -Execute"
    Write-Host ""
}

