# Sea Bream Data Update — Nov 6, 2025 Edacious Test

**Date applied:** 2026-05-12
**Source:** Edacious dashboard, `esteros-lubimar-sea-bream-fillet` — 7-sample average (Nov 6, 2025), superseding the prior 6-sample average.
**SKU affected:** `SF-EST-BRE-SHP-001` (Esteros Lubimar Sea Bream Fillet, 6oz)

---

## What changed (per-100g, canonical unit)

| Analyte | Before | After | Δ |
|---|---|---|---|
| EPA (mg) | 221.0 | **195.6** | −11.5% |
| DHA (mg) | 567.0 | **501.8** | −11.5% |
| ALA (mg) | 643.0 | **569.0** | −11.5% |
| EPA + DHA (mg) | 788.0 | **697.4** | −11.5% |
| Total Omega-3 (mg) | 1431 | **1442.5** | +0.8% |
| Total Omega-6 (mg) | 1750 | **1539.8** | −12.0% |
| Omega 6:3 ratio | 1.09 | 1.09 | — |
| Protein (g) | 21.1 | **21.2** | +0.5% |
| Cholesterol (mg) | 67 | **102.7** | +53% |
| Selenium (mcg) | 18.9 | **16.7** | −11.6% |
| Zinc (mcg) | 413.3 | **803.5** | +94% |
| Magnesium (mg) | 14.91 | **32.74** | +119% |
| Phosphorus (mg) | 291.7 | **248.7** | −14.7% |
| Vitamin D (mcg) | 15.0 | **13.3** | −11.3% |
| Vitamin E (mcg) | 2886 | **3743** | +30% |
| Arsenic (mcg) | 128 | **146** | +14% |
| Mercury (ppb) | 60 | 60 | unchanged (Light Labs Heavy Metals #21134) |
| Cadmium / Lead | below LOQ | below LOQ | unchanged |
| Iodine (mcg) | 15.9 | 15.9 | not retested — Light Labs value preserved |
| Vitamin B12 (mcg) | 0.91 | 0.91 | not retested — Light Labs value preserved |
| n_tests | 8 | **9** | one more Edacious sample |
| data_source | Light Labs + Edacious | Light Labs + Edacious (Nov 2025 — 7-sample avg) | annotated |

## New analytes added (not in prior Edacious panel)

Per-100g: Total Fat 12.21 g, Saturated Fat 2.67 g, MUFA 6.90 g, PUFA 2.97 g, Trans Fat 53 mg, Moisture 65.66 g, Vit A 2.48 mcg RAE, Vit B1 0.142 mg, Vit B2 0.096 mg, Vit B3 (NE) 9.73 mg, Vit B5 0.414 mg, Vit B6 0.255 mg, Calcium 27.3 mg, Potassium 480.5 mg, Sodium 57.1 mg, Iron 0.395 mg, Sulfur 198 mg, Cobalt 0.35 mcg, Total AA 21.3 g, Essential AA 9.03 g, CLA 8.85 mg.

Notable %DV at a 6oz (170g) serving: Vit D 113%, Vit B3 NE 103%, Protein 72%, Cholesterol 58%, Selenium 52%, Vit E 42%, Phosphorus 34%, Total Fat 27%, Vit B6 25%, Sat Fat 23%, Vit B1 20%, Iodine 18%, Potassium 17%, Vit B5 14%, Magnesium 13%, Vit B2 13%, Zinc 12%, Vit B12 65%.

## Files updated (10)

**Data:**
1. `seatopia_all_products_nutrition_supabase.csv` — bream row refreshed; **43 new columns** added (per-100g + per-serving + %DV for Vit A/B1/B2/B3/B5/B6, Ca, K, Na, Fe, fats, moisture, sulfur, cobalt; cholesterol & sodium %DV). Other 21 products have blanks in new columns until they're re-tested.
2. `supabase_seatopia_product_nutrition.csv` — 22 existing bream rows refreshed, **22 new analyte rows** added (44 total for bream).
3. `SeatopiaTestingData_AllLabs.csv` — **38 new test rows** appended for Test ID `E-BRE-2025-11-06`, all normalized to mg/100g + mg/serving (170 g).

**HTML / Liquid (synced per project context's "three-file synchronization" rule + marketing):**
4. `omega-map-v3.html` — PRODUCTS array entry updated; E-BRE test refreshed; n_tests 8→9.
5. `seatopia-product-tiles.html` — NUTRITION + TEST_DATA refreshed.
6. `seatopia-omega-system.html` — PRODUCTS array refreshed.
7. `seatopia-vs-industry-omega3.html` — comparison row refreshed.
8. `seatopia-omega-compass.html` — compass row refreshed.
9. `seatopia-marketing-claims-reference.html` — full claims-grade row refreshed (epa/dha/ala/omega6/protein/cholesterol/Se/Zn/Cu/Mg/P/Mn/Vit D/Vit E + role narrative).
10. `Omega_Map_042726.liquid` — Shopify template refreshed.

**Spreadsheet:**
11. `seatopia_omega_value.xlsx` — Row 14 (bream) cells O/P/Q updated; downstream $/g formulas recompute automatically.

## Catalog units audit — what I found while at it

You asked for a full-catalog units audit. The hypothesis I floated (that per-100g columns secretly stored Edacious per-113g values across the catalog) turned out to be **wrong**. Existing bream EPA 221 mg/100g was within 3% of Light Labs' true per-100g reading of 215 mg/100g — pure numerical coincidence with the Edacious dashboard's "0.221 g per 113g" display.

However the audit surfaced **other, unrelated data-quality issues** that deserve a separate cleanup pass:

| Product | Issue |
|---|---|
| Caleta Bay Steelhead (3 SKUs) | Light Labs has two lots with very different fatty-acid values (EPA 605 vs 150 mg/100g); CSV picked neither cleanly. Need to decide canonical lot. |
| Bakkafrost & Ora King Salmon | Their Light Labs fatty-acid rows are identical (EPA 0.324, DHA 0.843, ALA 0.918 g/100g) — likely a lab data-entry collision, not a CSV bug. |
| Hudson Valley Steelhead | All fatty acids show as 0/BLOQ in Light Labs; CSV values (EPA 376, DHA 1040) come from Edacious — can't cross-validate. |
| Yellowtail, McFarland Springs, Black Tiger Shrimp, Barramundi (3 SKUs), Peruvian Scallops (2 SKUs) | Fatty-acid ratios off by 0.3×–2× between CSV and Light Labs. Mix of lot mismatches and source confusion. |

Protein, selenium and Vit D columns are largely correct per-100g across the catalog (within 10–15% of Light Labs). The bream-specific Vit D bug I expected to find catalog-wide isn't there.

**Recommendation:** Treat the audit findings above as a tracked follow-up rather than auto-fixing. Each product needs a per-lot decision (which Light Labs / Edacious panel is canonical) before correction. I haven't touched any non-bream rows.

## Verification done

- Header column count: 107 across all 23 lines of the wide CSV ✓
- EPA per-100g = 195.6 in every file (wide CSV, long-form CSV, all 6 HTML files, Liquid template, xlsx) ✓
- No occurrences of stale `221/567/643` remain in any updated file ✓
- 38 new Edacious test rows present in SeatopiaTestingData_AllLabs.csv ✓
- xlsx formulas recompute downstream — Row 14 O/P/Q changed, J/K/L/M auto-refresh on next open ✓

## Backups

Before/after backups of the three data CSVs were taken to `/tmp/wide.bak`, `/tmp/long.bak`, `/tmp/labs.bak` in the workspace sandbox for the duration of this session.
