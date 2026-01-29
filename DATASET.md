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



clear
