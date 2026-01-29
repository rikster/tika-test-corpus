# Tika Test Corpus (Good vs Gnarly)

This repository contains a curated corpus derived from the Apache Tika test resources.

## Structure

_tika_corpus/
  ├── good/      # Well-formed, representative files
  ├── gnarly/    # Corrupt, malformed, edge-case, stress-test files
  └── manifest.csv

## Stats

- Good files: 924
- Gnarly files: 92

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
