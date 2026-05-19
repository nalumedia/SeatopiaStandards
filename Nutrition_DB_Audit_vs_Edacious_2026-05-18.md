# Nutrition Database Audit vs. Edacious Source Data

**Audit date:** May 18, 2026
**Source of truth:** 17 Edacious sample CSV exports validated today
**Target under audit:** `nutrition-data/product_nutrition.csv` (22 SKUs, 489 rows) and `nutrition-data/products.csv` (22 SKUs)
**Detail file:** `Edacious_Audit_Detail_2026-05-18.tsv` (one row per analyte/SKU comparison, normalized to mg/100g)

## Headline finding

**The nutrition database is NOT 100% accurate against Edacious.** 345 SKU/analyte values were compared (after normalizing every value to mg/100g for apples-to-apples). Only **122 of 345 (35%) match Edacious within ±5%**. The remaining 223 fall into a small number of well-defined buckets.

| Category | Rows | % | What's happening |
|---|---:|---:|---|
| Match (≤5% delta) | 122 | 35% | DB and Edacious agree |
| Off by ≈ -11.5% (DB is 1.13× too high) | 74 | 21% | Legacy per-113g bug — DB was loaded with Edacious **per-113g (single-serving)** values mislabeled as per-100g |
| Other drift / data errors | 149 | 43% | Real value drift, stale Light Labs values, ARA upload errors, mineral panel out-of-date |
| (No comparable Edacious value) | — | — | Excluded |

The per-113g bug is already documented in `Audit_McFarland_2026-05-13.md`. McFarland Rainbow Trout was fixed on 2026-05-13 and Esteros Sea Bream on 2025-11-06. **Those two SKUs are clean today (96% match).** The other 18 Edacious-linked SKUs still carry the bug plus other drift.

## Match rate by SKU

| SKU | Product | Match rate | Status |
|---|---|---:|---|
| SF-MCF-RBT-BLK-001 | McFarland Springs Rainbow Trout | 26/27 (96%) | Re-synced 2026-05-13 — clean |
| SF-EST-BRE-SHP-001 | Esteros Lubimar Sea Bream | 24/25 (96%) | Re-synced 2025-11-06 — clean |
| SF-EST-BRZ-SHP-001 | Esteros Lubimar Branzino | 6/18 (33%) | Stale — needs re-sync |
| SF-OKS-KGS-SHP-001 | Ora King Salmon | 5/16 (31%) | Stale (also `edacious_status=pending` despite export existing) |
| SF-MAR-OST-BLK-001 | Marshallberg Osetra Caviar | 5/16 (31%) | Stale (also `edacious_url` blank in products.csv) |
| SF-BAK-ATS-SHP-002 | Bakkafrost Atlantic Salmon | 5/16 (31%) | Stale — needs re-sync |
| SF-AUS-BRM-SHP-001/005/009 | Australis Barramundi (3 SKUs) | 5/16 (31%) each | Stale — needs re-sync |
| SF-KFC-YLT-SHP-001 | Yellowtail Sashimi Loin | 4/15 (27%) | Stale — needs re-sync |
| SF-BGB-KGS-SHP-001 | Big Glory Bay King Salmon | 4/16 (25%) | Stale — needs re-sync |
| SF-SEC-SCL-SHP-001/009 | Half Shell Scallops (2 SKUs) | 4/17 (24%) each | Stale — needs re-sync |
| SF-YRV-SLC-BLK-001 | Yarra Valley Salmon Roe | 3/15 (20%) | Stale — needs re-sync |
| SF-TAR-BTS-SHP-001 | Mangrove Black Tiger Shrimp | 3/16 (19%) | Stale — needs re-sync |
| SF-MCA-KGS-SHP-001 | Mt Cook King Salmon | 3/16 (19%) | Stale — needs re-sync |
| SF-CLB-STT-SHP-001/002/009 | Caleta Bay Steelhead (3 SKUs) | 3/17 (18%) each | Stale — needs re-sync |
| SF-HVF-STT-SHP-001 | Hudson Valley Steelhead | 2/16 (12%) | Stale — also has a major omega-6 data error (see below) |
| SF-SIC-RBT-BLK-001/006 | Smoke in Chimneys (2 SKUs) | n/a | No Edacious source available |

## Systematic issues

The 18 stale SKUs share the same fingerprint. Across EPA, DHA, ALA, Total Omega-3, Selenium, and Vitamin D, every one of them sits at almost exactly **-11.5% delta** vs Edacious. 1/1.13 = 0.885, i.e. DB = Edacious × 1.13. This is the per-113g → per-100g labelling bug. Multiplying these analytes by 1/1.13 across the 18 stale SKUs would resolve 74 of the 223 mismatches in one pass.

Mineral and trace-metal columns show different patterns. Magnesium, manganese, zinc, copper, arsenic, cholesterol, and phosphorus are systematically **higher in Edacious than in DB**, often by 30-150%. These cannot be explained by the 1.13 factor — they are legacy Light Labs values that pre-date the Edacious panel and need to be replaced wholesale. The McFarland audit memo flagged that the previously-blank columns were populated from Edacious in that re-sync, which is exactly the same fix the other 18 SKUs need.

ARA (arachidonic acid) shows large per-product swings (-67% to +600%). Spot-checking suggests the DB column was populated inconsistently — some SKUs have raw mg, some have an apparently scaled value, and Hudson Valley has 0.0 in DB vs 92.8 mg in Edacious. This column should be re-derived from the Edacious export, not adjusted in place.

## Specific data errors worth fixing immediately

The Hudson Valley Steelhead `omega6` value in DB is **852 mg/100g** versus Edacious **2,499 mg/100g** — almost 3× off. The DB `omega6_3_ratio` for that SKU (0.416) is also half the Edacious ratio (0.833). These two values are internally consistent with each other but inconsistent with the underlying EPA/DHA/ALA — strong sign of a manual data-entry error rather than a unit issue.

The Esteros Branzino `mercury` value in DB is **100 ppb** versus Edacious 0.0233 mg/kg (= 23.3 ppb, but Edacious actually reports it at the LOQ across all 6 samples, so the true value is below LOQ). The 100 ppb in DB looks like a placeholder/round number rather than a measured result.

Hudson Valley Steelhead `vitamin_d` in DB is 3.98 mcg/100g but Edacious reports 0.0 across all 3 samples (below LOQ). This needs reconciliation with the lab — either DB has a stale value from a different lab, or Edacious is reporting below detection.

## Product mapping issues (products.csv)

**Superior Fresh Atlantic Salmon is missing from the database entirely.** The Edacious export today contains 12 samples for `superior-fresh-atlantic-salmon` (collected Jul/Sep/Oct 2025, owner = Superior Fresh), but `products.csv` contains no Superior Fresh SKU. Either we onboard a new SKU (recommended SKU stub: `SF-SUF-ATS-SHP-001`) or document why this Edacious dataset is excluded.

**McFarland Trout Dogs vs. McFarland Rainbow Trout fillet are conflated.** The single McFarland SKU in DB (`SF-MCF-RBT-BLK-001`) has `sku_label = "McFarland Springs Trout Dogs"`, `serving_oz = 3.2`, `package_oz = 12.8`, `servings_per_package = 4.0` — all consistent with the prepared hot-dog product. But its `edacious_url` and the nutrition values come from `mcfarland-springs-rainbow-trout-samples.csv` (the raw fillet). Edacious has a separate `mcfarland-springs-trout-dogs-samples.csv` (3 samples, collected 2026-03-26). Either the trout-dogs nutrition needs to be pulled from the correct Edacious product, or a second SKU for the plain fillet needs to be added.

**Two SKUs have blank `edacious_url`/`edacious_status` despite an Edacious export existing.** `SF-MAR-OST-BLK-001` (Marshallberg Osetra) and `SF-OKS-KGS-SHP-001` (Ora King) have empty fields in products.csv but live exports were validated today. Update both to verified URLs.

**Smoke in Chimneys** (`SF-SIC-RBT-BLK-001`, `SF-SIC-RBT-BLK-006`) has no Edacious URL and no upload. These two SKUs currently rely on Light Labs only — needs to either be brought into Edacious testing or explicitly flagged as Light-Labs-only in `data_source`.

## Recommended remediation (in priority order)

The highest-leverage fix is a full re-sync of all 18 stale SKUs from the Edacious exports we validated today, following exactly the process documented in `Audit_McFarland_2026-05-13.md`. That single pass will resolve the per-113g bug for 74 rows and bring the mineral/vitamin panels current for the other 149. The next-most-urgent items are the Hudson Valley omega-6 correction, the Branzino mercury cleanup, and onboarding Superior Fresh as a new SKU. The McFarland Trout Dogs mapping should be fixed at the same time — either retarget the Edacious URL or add a separate fillet SKU. Once those passes complete, re-run this audit (`Edacious_Audit_Detail_2026-05-18.tsv` is the format) to confirm the match rate goes from 35% to >95% across all SKUs.

## Files referenced

- Live exports: `/Users/ryan/.../uploads/*.csv` (17 files, validated 2026-05-18)
- Database under audit: `nutrition-data/product_nutrition.csv`, `nutrition-data/products.csv`
- Prior remediation memo: `Audit_McFarland_2026-05-13.md`
- Prior remediation memo: `Bream_Update_2025-11-06_Summary.md`
- Audit detail (per-row): `Edacious_Audit_Detail_2026-05-18.tsv`

Sources: local CSV exports and database files in this project folder.
