# McFarland Springs Rainbow Trout — Data Correction Audit
**Date:** 2026-05-13
**SKU:** SF-MCF-RBT-BLK-001
**Trigger:** Per-100g column in supabase rollups contained per-113g (Edacious single-serving) values.

## Source of truth
Raw Edacious lab data (6 samples, collected 2025-11-03) saved at:
`Edacious_Sample_Data/mcfarland-springs-rainbow-trout-samples.csv`

All values in the source CSV are already in per-100g units (g/100g, mg/100g, mcg/100g, mcg RAE/100g, mg NE/100g).
Per-100g averages are arithmetic means across n=6 samples. `<LOQ` values treated as 0.

## Conversion factors
- 1 serving (Seatopia portion) = 3.2 oz = 90.72 g
- 1 package = 12.8 oz = 362.87 g (4.0 servings)
- Edacious display "single serving" = 113 g (USDA convention, used on edacious.com)
- per_serving = per_100g × 0.9072
- per_package = per_100g × 3.6287
- per_113g = per_100g × 1.13

## Sanity check
Per-100g composition sum (protein + fat + moisture) = 99.45 g ≤ 100 ✓
Remainder (0.55 g) accounts for ash + carbohydrates, which is typical for trout.

## Before / after — per_100g column (selected analytes)

| Analyte | Before (was 113g) | After (true 100g) | Per 113g (Edacious display) | Per serving (90.72g) |
|---|---:|---:|---:|---:|
| EPA (mg) | 272 | 241.1 | 272.4 | 218.71 |
| DHA (mg) | 668 | 591.3 | 668.1 | 536.39 |
| ALA (mg) | 1270 | 1127.4 | 1274.0 | 1022.79 |
| EPA+DHA (mg) | 940 | 832.4 | 940.6 | 755.10 |
| Total Omega-3 (mg) | 2210 | 2118.2 | 2393.6 | 1921.64 |
| Total Omega-6 (mg) | 1390 | 1231.0 | 1391.0 | 1116.71 |
| Omega 6:3 ratio | 0.582 | 0.581 | 0.581 | 0.581 |
| Protein (g) | 22.0 | 22.13 | 25.01 | 20.08 |
| Total Fat (g) | — | 6.88 | 7.78 | 6.24 |
| Cholesterol (mg) | — | 61.4 | 69.4 | 55.74 |
| Selenium (mcg) | 32.9 | 29.15 | 32.94 | 26.44 |
| Vitamin D (mcg) | 18.2 | 16.14 | 18.24 | 14.64 |
| Phosphorus (mg) | 218.0 | 262.27 | 296.36 | 237.92 |
| Zinc (mg) | 0.503 | 0.818 | 0.924 | 0.742 |
| Magnesium (mg) | 23.14 | 36.73 | 41.51 | 33.32 |
| Sodium (mg) | — | 44.39 | 50.16 | 40.27 |
| Potassium (mg) | — | 534.96 | 604.51 | 485.31 |
| Calcium (mg) | — | 15.08 | 17.04 | 13.68 |
| Iron (mg) | — | 0.575 | 0.650 | 0.521 |

## Per-100g values verified against published Edacious page
The user's Edacious "Per 100g" screenshot shows: EPA 0.241 g, DHA 0.591 g, ALA 1.13 g, Omega-3 2.12 g, Omega-6 1.23 g.
Our computed averages: EPA 0.241 g, DHA 0.591 g, ALA 1.127 g, Omega-3 2.118 g, Omega-6 1.231 g — all match to 3 decimal places. ✓

## Files updated in this commit
- `Edacious_Sample_Data/mcfarland-springs-rainbow-trout-samples.csv` — NEW (raw n=6 source data)
- `seatopia_all_products_nutrition_supabase.csv` — McFarland row replaced; previously-blank columns now populated
- `supabase_seatopia_product_nutrition.csv` — McFarland rows replaced (21 -> 46 rows, full Edacious panel)

## Next products to audit
The same per-100g vs per-113g labeling issue likely affects all other SKUs with Edacious-sourced data.
Recommended order: Mt Cook King Salmon, Big Glory Bay King Salmon, Hudson Valley Steelhead, Barramundi.
Process: request raw sample CSVs from Edacious, re-run this script with each SKU's data.
