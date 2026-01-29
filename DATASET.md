# Dataset Card: Tika Test Corpus (Good vs Gnarly)

## Dataset Summary
A curated test corpus derived from Apache Tika test resources, split into:
- **good/**: well-formed, representative documents suitable for “happy path” ingestion/indexing/preview tests
- **gnarly/**: intentionally problematic documents (corrupt/malformed/encrypted/truncated/edge-case/stress-test) for robustness testing

This dataset is designed for file-handling pipelines: type detection, parsing, text extraction, metadata extraction, preview generation, search indexing, and AI/RAG ingestion.

## Source / Provenance
Files were collected from Apache Tika’s test resources across multiple modules, including paths like:
- `*/src/test/resources/test-documents`
- `tika-app/src/test/resources/test-data`

The included `manifest.csv` records per-file provenance (original repo-relative path), SHA-256, classification, category, and classification reason.

## Structure

```
_tika_corpus/
├── manifest.csv          # Complete file inventory with SHA-256, provenance, and metadata
├── good/                 # Well-formed test files (927 files)
│   ├── archive/          # Archive formats (zip, tar, bz2, etc.)
│   ├── email/            # Email formats (eml, pst, mbox, etc.)
│   ├── image/            # Image formats (jpg, png, tiff, webp, etc.)
│   ├── media/            # Audio/video formats (mp3, mp4, etc.)
│   ├── office/           # Office documents (docx, xlsx, pptx, odt, etc.)
│   ├── other/            # Specialized formats (cad, scientific, etc.)
│   ├── pdf/              # PDF documents
│   └── text/             # Text-based formats (html, xml, rtf, etc.)
└── gnarly/               # Problematic test files (90 files)
    ├── archive/
    ├── email/
    ├── image/
    ├── media/
    ├── office/
    ├── other/
    ├── pdf/
    └── text/
```

## File Statistics

- **Total files:** 1,017
- **Good files:** 927 (91%)
- **Gnarly files:** 90 (9%)

### Filename Simplification

All filenames have been simplified for usability:
- Removed redundant Tika source path prefixes
- Removed "test" prefix from filenames
- Converted to lowercase
- Simplified version patterns (e.g., `Version.10.x` → `v10`)
- **91% of files** have names ≤30 characters
- **Only 8 files** have names >50 characters (scientific data files with descriptive names)

### Examples of Simplified Names

| Original | Simplified |
|----------|------------|
| `tika-parsers__tika-parsers-standard__tika-parsers-standard-modules__tika-parser-__testJPEG.jpg` | `jpeg.jpg` |
| `tika-parsers__tika-parsers-standard__tika-parsers-standard-modules__tika-parser-__testPDF_Version.10.x.pdf` | `pdf_v10.pdf` |
| `tika-app__src__test__resources__test-data__testEXCEL_custom_props.xlsx` | `excel_custom_props.xlsx` |

## File Categories

### Archive Formats
Zip, tar, gzip, bzip2, 7z, rar, and other compression/archive formats

### Email Formats
EML, PST, MBOX, MSG, and other email container formats

### Image Formats
JPEG, PNG, TIFF, GIF, WebP, HEIF, BMP, and specialized image formats

### Media Formats
MP3, MP4, WAV, and other audio/video formats

### Office Documents
Microsoft Office (DOC, DOCX, XLS, XLSX, PPT, PPTX)
OpenDocument (ODT, ODS, ODP)
Apple iWork (Pages, Numbers, Keynote)

### PDF Documents
Various PDF versions, encrypted PDFs, PDF/A, PDF/X, and edge cases

### Text Formats
HTML, XML, RTF, plain text, source code, and markup formats

### Other Specialized Formats
CAD files (DWG, DXF), scientific data formats (HDF, NetCDF, GRIB), database files, and more

## Gnarly File Classification

Files in the `gnarly/` directory are tagged with reasons in `manifest.csv`:
- **token:bad** - Malformed/corrupt content
- **token:encrypted** - Password-protected or encrypted
- **token:empty** - Empty or zero-byte files
- **token:recursive** - Recursive embedding (stress test)
- **size:tiny** - Unusually small files that may cause edge cases
- **size:huge** - Large files for performance testing

## Usage

### Basic File Listing
```bash
# List all good PDF files
ls _tika_corpus/good/pdf/

# List all gnarly office documents
ls _tika_corpus/gnarly/office/
```

### Using the Manifest
```python
import pandas as pd

# Load manifest
manifest = pd.read_csv('_tika_corpus/manifest.csv')

# Find all encrypted files
encrypted = manifest[manifest['reason'].str.contains('encrypted', na=False)]

# Get all PDFs
pdfs = manifest[manifest['category'] == 'pdf']

# Find files by original source path
tika_app_files = manifest[manifest['source_rel'].str.contains('tika-app')]
```

### Verification
All files can be verified using SHA-256 hashes in the manifest:
```bash
# Verify a file's integrity
sha256sum _tika_corpus/good/pdf/pdf_v10.pdf
# Compare with manifest.csv entry
```

## License
Files are derived from Apache Tika test resources, which are part of the Apache Tika project licensed under Apache License 2.0.

## Maintenance Notes

### Renaming History
- **Pass 1:** Removed "test" prefix, converted to lowercase, simplified version patterns (1,014 files)
- **Pass 2:** Removed remaining path prefixes (421 files)
- **Total transformations:** 1,435 renames

### Scripts
- `rename-files.ps1` - First pass renaming script
- `rename-files-pass2.ps1` - Second pass renaming script
- `audit-long-names.ps1` - Audit script for filename length analysis
- `update-manifest.ps1` - Updates manifest.csv with current filenames

## Contact / Issues
For issues or questions about this dataset, please refer to the Apache Tika project.
