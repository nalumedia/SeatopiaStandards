# Edacious Sample Data

Raw lab-result CSV exports pulled directly from Edacious. This folder is the **single source of truth** that the `nutrition-data/` database (`nalumedia/seatopia-nutrition-data`) is derived from.

Last full sync from Edacious: **2026-05-18** (17 products, 77 samples).

## What lives here

One CSV per Edacious product, named `<product-slug>-samples.csv`, where the slug matches the Edacious URL path (e.g. `bakkafrost-atlantic-salmon-fillet` from `https://eat.edacious.com/brand/seatopia/bakkafrost-atlantic-salmon-fillet`).

Each file contains every sample Edacious has for that product, with the standard sample schema: `code`, `name`, `external_id`, `owner__name`, `collection_date`, `results_completed_at`, followed by the full nutrient panel. Values are reported in their native Edacious units (`g/100g`, `mg/100g`, `mcg/100g`, `mg/kg`, etc.) — **per 100g, not per 113g**. The legacy database bug where per-113g values were stored as per-100g is documented in `../Audit_McFarland_2026-05-13.md`; do not reintroduce it.

Rows tagged `Amino Acid Composite` in the `external_id` column are companion composites and should be excluded from per-100g averages when deriving the nutrient panel (they are separate analyses, not duplicate samples).

## How to add a new export

When you re-pull a product from Edacious — either because new lab results landed, or to refresh stale data — export the full sample CSV from Edacious and drop it in this folder with the same `<product-slug>-samples.csv` name. **Overwrite the existing file**; git history is the audit trail. Then:

1. Re-run the per-100g averaging script (same logic as `Audit_McFarland_2026-05-13.md` — arithmetic mean across non-composite samples, `<LOQ` treated as 0).
2. Update the corresponding rows in `nutrition-data/product_nutrition.csv` and check the `data_source` and `edacious_status` fields in `nutrition-data/products.csv`.
3. Update the "last sync" line at the top of this README and the per-product table in `../Edacious_Sample_Data_Review_2026-05-18.md` (or create a new dated review).
4. Commit both repos.

## Current inventory (as of 2026-05-18)

| Edacious product | Samples | Latest lab result | DB SKU(s) | Match rate vs DB |
|---|---:|---|---|---:|
| `bakkafrost-atlantic-salmon-fillet` | 7 | 2025-11-06 | SF-BAK-ATS-SHP-002 | 31% — stale |
| `barramundi` | 3 | 2026-03-26 | SF-AUS-BRM-SHP-001/005/009 | 31% — stale |
| `big-glory-bay-king-salmon` | 3 | 2025-11-06 | SF-BGB-KGS-SHP-001 | 25% — stale |
| `caleta-bay-steelhead-trout-loin` | 4 | 2025-11-06 | SF-CLB-STT-SHP-001/002/009 | 18% — stale |
| `esteros-lubimar-branzino-fillet` | 7 | 2025-11-06 | SF-EST-BRZ-SHP-001 | 33% — stale |
| `esteros-lubimar-sea-bream-fillet` | 7 | 2025-11-06 | SF-EST-BRE-SHP-001 | **96% — clean** (re-synced 2025-11-06) |
| `half-shell-scallops` | 3 | 2026-03-26 | SF-SEC-SCL-SHP-001/009 | 24% — stale |
| `hudson-valley-steelhead-trout-fillet` | 4 | 2025-11-06 | SF-HVF-STT-SHP-001 | 12% — stale + known omega-6 data error |
| `mangrove-black-tiger-shrimp` | 3 | 2026-03-26 | SF-TAR-BTS-SHP-001 | 19% — stale |
| `marshallberg-classic-osetra-caviar` | 3 | 2026-04-02 | SF-MAR-OST-BLK-001 | 31% — stale (URL/status blank in products.csv) |
| `mcfarland-springs-rainbow-trout` | 6 | 2025-11-03 | SF-MCF-RBT-BLK-001 | **96% — clean** (re-synced 2026-05-13) |
| `mcfarland-springs-trout-dogs` | 3 | 2026-03-26 | (none — mapping issue, see audit) | n/a |
| `mt-cook-king-salmon` | 3 | 2025-11-06 | SF-MCA-KGS-SHP-001 | 19% — stale |
| `ora-king-salmon` | 3 | 2025-11-06 | SF-OKS-KGS-SHP-001 | 31% — stale (URL/status blank in products.csv) |
| `salmon-roe-caviar` | 3 | 2026-04-02 | SF-YRV-SLC-BLK-001 | 20% — stale |
| `superior-fresh-atlantic-salmon` | 12 | 2025-10-24 | (none — missing SKU, see audit) | n/a |
| `yellowtail-sashimi-loin` | 3 | 2026-03-26 | SF-KFC-YLT-SHP-001 | 27% — stale |

## Related documents

- `../Edacious_Sample_Data_Review_2026-05-18.md` — full review of all 17 exports
- `../Nutrition_DB_Audit_vs_Edacious_2026-05-18.md` — DB-vs-Edacious accuracy audit and remediation plan
- `../Edacious_Audit_Detail_2026-05-18.tsv` — per-analyte-per-SKU delta table
- `../Audit_McFarland_2026-05-13.md` — the per-113g bug fix template; reuse for each stale SKU
- `../Bream_Update_2025-11-06_Summary.md` — second example of a clean per-product re-sync
