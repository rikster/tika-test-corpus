# Tika Test Corpus (Good vs Gnarly)

This repository contains a curated corpus derived from the Apache Tika test resources.

**Version 2.0** - All filenames have been simplified for improved usability! 91% of files now have names ≤30 characters.

## Structure

_tika_corpus/
  ├── good/      # Well-formed, representative files
  ├── gnarly/    # Corrupt, malformed, edge-case, stress-test files
  └── manifest.csv

## Stats

- Total files: 1,017
- Good files: 927
- Gnarly files: 90
- Files with names ≤30 chars: 927 (91%)

## Provenance

All files originate from Apache Tika test resources:
https://github.com/apache/tika

The `manifest.csv` records:
- SHA-256 hash
- Classification (good / gnarly)
- Category (pdf, office, email, etc.)
- Original source path
- Classification reason

## Intended Use

- Search indexing
- File preview pipelines
- Parser robustness testing
- AI / RAG document ingestion
- Multi-cloud storage testing

This corpus is provided for testing and research purposes.
