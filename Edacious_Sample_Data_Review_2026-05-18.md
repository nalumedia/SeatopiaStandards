# Edacious Sample Data Review

**Export validated:** Monday, May 18, 2026
**Source:** Edacious sample exports (CSV)
**Products reviewed:** 17
**Total samples:** 77

All 17 product CSV exports were pulled from Edacious and validated against the Seatopia Nutrition Platform on **May 18, 2026**. Each product file follows the standard Edacious sample schema (`code`, `name`, `external_id`, `owner__name`, `collection_date`, `results_completed_at`, followed by the nutrient panel). The `collection_date (SAMPLE_COLLECTION.EDA:1149)` field is blank across every record in this export — Edacious is reporting lab `results_completed_at` only. The "Last Edacious sync" column below reflects the date this file was re-pulled and validated; the "Latest lab result" column reflects the most recent `results_completed_at` returned by Edacious for that product.

## Per-product summary

| # | Product | File | Samples | Earliest lab result | Latest lab result | Schema (cols) | Last Edacious sync |
|---|---|---|---:|---|---|---:|---|
| 1 | Bakkafrost Atlantic Salmon Fillet | `bakkafrost-atlantic-salmon-fillet-samples.csv` | 7 | 2025-11-03 | 2025-11-06 | 276 | 2026-05-18 |
| 2 | Barramundi | `barramundi-samples.csv` | 3 | 2026-03-26 | 2026-03-26 | 232 | 2026-05-18 |
| 3 | Big Glory Bay King Salmon | `big-glory-bay-king-salmon-samples.csv` | 3 | 2025-11-03 | 2025-11-06 | 276 | 2026-05-18 |
| 4 | Caleta Bay Steelhead Trout Loin | `caleta-bay-steelhead-trout-loin-samples.csv` | 4 | 2025-11-03 | 2025-11-06 | 276 | 2026-05-18 |
| 5 | Esteros Lubimar Branzino Fillet | `esteros-lubimar-branzino-fillet-samples.csv` | 7 | 2025-11-03 | 2025-11-06 | 276 | 2026-05-18 |
| 6 | Esteros Lubimar Sea Bream Fillet | `esteros-lubimar-sea-bream-fillet-samples.csv` | 7 | 2025-11-03 | 2025-11-06 | 276 | 2026-05-18 |
| 7 | Half Shell Scallops | `half-shell-scallops-samples.csv` | 3 | 2026-03-26 | 2026-03-26 | 232 | 2026-05-18 |
| 8 | Hudson Valley Steelhead Trout Fillet | `hudson-valley-steelhead-trout-fillet-samples.csv` | 4 | 2025-11-03 | 2025-11-06 | 276 | 2026-05-18 |
| 9 | Mangrove Black Tiger Shrimp | `mangrove-black-tiger-shrimp-samples.csv` | 3 | 2026-03-26 | 2026-03-26 | 232 | 2026-05-18 |
| 10 | Marshallberg Classic Osetra Caviar | `marshallberg-classic-osetra-caviar-samples.csv` | 3 | 2026-04-02 | 2026-04-02 | 232 | 2026-05-18 |
| 11 | McFarland Springs Rainbow Trout | `mcfarland-springs-rainbow-trout-samples.csv` | 6 | 2025-11-03 | 2025-11-03 | 232 | 2026-05-18 |
| 12 | McFarland Springs Trout Dogs | `mcfarland-springs-trout-dogs-samples.csv` | 3 | 2026-03-26 | 2026-03-26 | 232 | 2026-05-18 |
| 13 | Mt Cook King Salmon | `mt-cook-king-salmon-samples.csv` | 3 | 2025-11-03 | 2025-11-06 | 276 | 2026-05-18 |
| 14 | Ora King Salmon | `ora-king-salmon-samples.csv` | 3 | 2025-11-03 | 2025-11-06 | 276 | 2026-05-18 |
| 15 | Salmon Roe Caviar | `salmon-roe-caviar-samples.csv` | 3 | 2026-04-02 | 2026-04-02 | 232 | 2026-05-18 |
| 16 | Superior Fresh Atlantic Salmon | `superior-fresh-atlantic-salmon-samples.csv` | 12 | 2025-07-31 | 2025-10-24 | 246 | 2026-05-18 |
| 17 | Yellowtail Sashimi Loin | `yellowtail-sashimi-loin-samples.csv` | 3 | 2026-03-26 | 2026-03-26 | 232 | 2026-05-18 |

## Observations

The exports cluster into three schemas. The 276-column schema covers the eight farmed finfish fillets/loins (Bakkafrost, BGB King, Caleta Bay Steelhead, Esteros Lubimar Branzino and Sea Bream, Hudson Valley Steelhead, Mt Cook, Ora King). The 232-column schema covers the shellfish, roe, and prepared/non-fillet items (Barramundi, Half Shell Scallops, Mangrove Black Tiger Shrimp, Marshallberg Osetra, McFarland Springs Rainbow Trout and Trout Dogs, Salmon Roe, Yellowtail). Superior Fresh sits on its own 246-column variant. All three variants share the same six leading metadata fields and diverge only in the nutrient panel — most of the column-count difference is amino-acid coverage, which is only present on the fillets that have an "Amino Acid Composite" companion sample.

Lab-result dates fall into three campaigns. The November 2025 campaign (results dated 2025-11-03 / 2025-11-06) covers the eight finfish fillet products plus McFarland Springs Rainbow Trout — the 11-06 dates correspond specifically to the "Amino Acid Composite" companion sample on each fillet product. The March/April 2026 campaign (2026-03-26 / 2026-04-02) covers the shellfish, prepared, and caviar SKUs. Superior Fresh has its own three-window cadence (2025-07-31, 2025-09-25, 2025-10-24) reflecting their independent sampling program.

The `collection_date` field is empty across every sample. If we need pre-lab collection timestamps populated in Edacious going forward, that is the one obvious data-quality gap to raise. Owner is consistently `Seatopia` for all 16 internally-owned products; Superior Fresh's 12 samples are owned by `Superior Fresh` in Edacious, which is the expected pattern for that supplier-managed dataset.

Sources: local CSV exports in this project folder.
