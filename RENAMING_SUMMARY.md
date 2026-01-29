# File Renaming Summary

## Overview
The renaming script will simplify **1,016 out of 1,017** files in the corpus.

## Simplification Rules Applied

1. **Extract actual filename** - Takes only the meaningful part after the last `__`
2. **Remove "test" prefix** - `testJPEG.jpg` → `jpeg.jpg`
3. **Convert to lowercase** - `EXCEL.xlsx` → `excel.xlsx`
4. **Simplify version patterns** - `Version.10.x` → `v10`
5. **Clean special characters** - Parentheses become underscores
6. **Remove duplicate underscores** - `test__file.txt` → `file.txt`

## Examples of Successful Simplifications

### Great Examples ✓
```
testOneNote3.one → onenote3.one
testMP3id3v1.mp3 → mp3id3v1.mp3
testTIFF.tif → tiff.tif
testRotated-10.png → rotated-10.png
testHEIF.heic → heif.heic
testPages.pages → pages.pages
```

### Files with Long Paths (Still Simplified)
Some files don't follow the `__filename.ext` pattern, so they keep more path info:
```
tika-parsers__...__testWORD_bold_character_runs2.docx 
→ tika-parsers-standard_tika-parsers-standard-modules_tika-parser-_word_bold_character_runs2.docx

tika-parsers__...__en-GB_(A_Little_Bottle_Of_Water).mp3
→ tika-parsers-ml_tika-transcribe-aws_src_test_resources_test-d_en-gb_a_little_bottle_of_water.mp3
```

## Conflicts Detected (2)

The script found 2 naming conflicts that need manual resolution:

### Conflict 1: example.xml
- `tika-core__src__test__resources__test-documents__example.xml__example.xml` (already exists)
- `tika-parsers__tika-parsers-standard__tika-parsers-standard-package__src__test__r__example.xml` (would conflict)

**Suggested resolution:** Rename one to `example_core.xml` and the other to `example_parsers.xml`

### Conflict 2: html.html  
- `tika-java7__src__test__resources__test-documents__test.html__test.html` (already exists as `test.html`)
- `tika-server__tika-server-standard__src__test__resources__test-documents__testHTM__testHTML.html` (would become `html.html`)

**Suggested resolution:** Keep first as `test.html`, rename second to `html_server.html`

## Statistics

- **Total files:** 1,017
- **Files to rename:** 1,016
- **Files unchanged:** 1
- **Conflicts:** 2

## Next Steps

1. **Review conflicts** - Manually rename the 2 conflicting files first
2. **Run preview** - `.\rename-files.ps1` (already done)
3. **Execute rename** - `.\rename-files.ps1 -Execute` (after resolving conflicts)

## Manual Conflict Resolution

Before running the script with `-Execute`, manually rename these files:

```powershell
# Resolve conflict 1
Rename-Item "_tika_corpus\good\text\tika-parsers__tika-parsers-standard__tika-parsers-standard-package__src__test__r__example.xml" -NewName "example_parsers.xml"

# Resolve conflict 2  
Rename-Item "_tika_corpus\good\text\tika-server__tika-server-standard__src__test__resources__test-documents__testHTM__testHTML.html" -NewName "html_server.html"
```

Then run: `.\rename-files.ps1 -Execute`

