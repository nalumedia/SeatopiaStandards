# Seatopia Nutrition Intelligence Platform

**Objective:** Build trust and provide transparency by making our data public, easy to understand, and easy to use.

---

## References

- [The Seatopia Standard](https://seatopia.com/pages/the-seatopia-standard)
- [Analytes & Units (Analytes_Units tab)](https://docs.google.com/spreadsheets/d/1...)
- [Component SKUs & Portion Sizes](https://docs.google.com/spreadsheets/d/1...)

---

## Todo

- [ ] Get Edacious results public
- [ ] Get Edacious on product pages

---

## 1. Executive Summary

This document describes the Seatopia Nutrition Intelligence Platform delivered against the original product spec. The spec called for a **Phase 1 "Omega-3 Map"** — a comparison tool showing EPA, DHA, and Total Omega-3 per standardized 6 oz serving across the Seatopia catalog. What was delivered significantly exceeds the Phase 1 scope and reaches well into the **Phase 2 "Marine Nutrition Map"** territory outlined in the spec.

The platform currently covers **22 products across 14 species**, backed by **60+ independent lab tests** from two accredited sources (Light Labs and Edacious), with full COA traceability. Every data point links back to a verifiable Certificate of Analysis.

---

## 2. Spec Alignment

### 2.1 Phase 1 Requirements — Omega-3 Map ✅ 100% Complete

| Requirement | Status |
|---|---|
| **Analytes:** Total Omega-3, DHA, EPA in mg | ✅ Delivered. All three analytes are computed from per-100g canonical lab values and displayed in mg per serving. |
| **Standard comparison basis:** Per 6 oz serving | ✅ Delivered. The map defaults to a standardized 6 oz basis so all species can be compared apples-to-apples. A toggle allows switching to "Per Actual Serving" for products with non-6oz portions (caviar 1 oz, shrimp 4 oz, etc.). |
| **Output:** Product pages + Comparison page ("Omega-3 Map") | ✅ Delivered. The platform includes an interactive ranked bar-chart comparison (Tab 1: Omega-3 Map) and individual product detail pages with full nutrition breakdown (Tab 2: Product Pages). |
| **Definition of done:** Auto-pull DHA, EPA, Total Omega-3 from fatty-acid dataset and visualize across catalog | ✅ Delivered. All values are computed programmatically from the PRODUCTS dataset. No hardcoded display values — everything derives from the per-100g canonical data, ensuring consistency as new lab results are added. |

### 2.2 Phase 2 Deliverables — Marine Nutrition Map (Delivered Early)

The original spec noted Phase 2 as a future expansion into a broader "Marine Nutrition Map" with additional analytes. The following Phase 2 features were delivered in this build:

| Analyte / Feature | Details |
|---|---|
| **Omega-6:Omega-3 Ratio** | Computed from Light Labs fatty acid profiles. Displayed per product. Seatopia's catalog averages well below the 1:1 threshold recommended by nutrition science. |
| **Selenium (Se)** | Extracted from trace mineral COAs. Displayed as mcg per serving with a nutrient pill on every bar. |
| **Mercury (Hg)** | Extracted from Heavy Metals COAs (Light Labs) and trace mineral COAs (Edacious). Color-coded (green < 0.5 mcg, yellow 0.5–2, red > 2). Products below LOQ (limit of quantification) are flagged accordingly. Source lab noted inline. |
| **Se:Hg Molar Ratio** | Protective selenium-to-mercury ratio displayed inline. Ratio > 1 indicates selenium surplus — a key differentiator for Seatopia's regenerative products. |
| **Protein** | Grams per serving from protein assay COAs. Shown as a nutrient pill on every bar. |
| **Vitamin D** | Extracted from Vitamin D (D2+D3) COAs where available. |
| **Microplastics Testing** | 16 of 22 products tested via EMSL Analytical (contracted through Light Labs) across 6 polymer types (HDPE, LDPE, PET, Polypropylene, Polystyrene, PVC). 100% Not Detected. Full COA traceability per product. |
| **Raw Data Tab with COA Traceability** | Every test result is grouped by product and SKU, with direct links to the source COA PDF or Edacious dashboard. Primary (public-facing) test rows marked with ★ PUBLIC badge. |
| **$/Omega-3 Value Analysis** | A full spreadsheet (`seatopia_omega_value.xlsx`) computing cost per gram of EPA+DHA for all 24 SKUs using current MSRP. Includes ranking, per-serving and per-package breakdowns, and a Top 5 summary. |

---

## 3. Deliverables

### 3.1 Omega-3 Nutritional Map (`omega-map-v3.html`)

The primary dashboard and the core Phase 1 deliverable. A single-page interactive application with **10 tabs**:

**Tab 1 — Omega-3 Map**
Ranked horizontal bar chart of all 22 products. Sortable by EPA+DHA, Total Omega-3, EPA only, or DHA only. Bars scale proportionally — the #1 product fills 100% width, others are proportional. Segment-aware rendering: EPA+DHA sort shows only EPA and DHA segments; Total sort adds ALA; single-metric sorts show just that metric. Nutrient pills below each bar show protein, selenium (with Se:Hg ratio), and mercury. Serving basis toggle: "Per 6 oz (Standardized)" for apples-to-apples comparison or "Per Actual Serving" for real-world portion context. Includes Seafood vs. Supplements comparison (top 5 vs. fish oil capsules).

**Tab 2 — Product Pages**
Individual cards for each product with full nutrition breakdown: EPA, DHA, ALA, Total Omega-3, Omega-6:3 ratio, selenium, mercury, protein, vitamin D, and % Daily Values. Links to COA source.

**Tab 3 — Analytics**
Cross-catalog analytics including species rankings, daily value analysis, and portfolio-level metrics.

**Tab 4 — Mercury Profile**
Detailed mercury analysis for every product: ppb values, source lab callout (Light Labs or Edacious), Se:Hg molar ratio chart, color-coded risk levels, and per-serving mcg computation.

**Tab 5 — Microplastics**
Results from EMSL Analytical testing across 6 polymer types. 16 of 22 products tested — all Not Detected. Each result links to the source COA with test ID and lot number. 6 untested products flagged as "COA Pending."

**Tab 6 — Raw Data**
Full test-level data grouped by product and SKU. 18-column simplified table with search filter and CSV export. Each row shows test code, lab, EPA, DHA, ALA, Total, and a direct link to the source COA. Primary rows (used for public-facing values) marked with ★ PUBLIC; secondary reference rows marked with REF.

**Tab 7 — Visuals**
Publication-ready visualizations: ranked bar chart, top 5 spotlight, portfolio donut, species comparison, and nutrition scorecard.

### 3.2 Product Tiles (`seatopia-product-tiles.html`)

Standalone product catalog page with Shopify-ready embed structure. Each tile shows the Omega Meter (visual gauge), per-serving omega-3 values, fish oil capsule equivalence, and a link to the product's COA. Includes NUTRITION, TEST_DATA, COA_MAP, and SKUS arrays synchronized with the main omega map.

### 3.3 Omega Meter Packaging System (`seatopia-omega-system.html`)

Generates Omega Meter badges for product packaging and marketing materials. Circular gauge shows EPA+DHA per serving with fish oil capsule equivalence. System data is synchronized with the main omega map to ensure packaging always reflects the latest lab results.

### 3.4 $/Omega-3 Value Spreadsheet (`seatopia_omega_value.xlsx`)

Excel workbook computing the cost efficiency of omega-3 across all 24 Seatopia SKUs. Columns include MSRP, package weight, serving size, EPA+DHA per serving and per package, and the key metric: **$ per 1g EPA+DHA**. All cells use Excel formulas (not hardcoded values) so the sheet stays dynamic as prices or lab data change. Includes a Top 5 Best Value summary using INDEX/MATCH/SMALL formulas.

---

## 4. Data Architecture

### 4.1 Seatopia Omega Standard

All omega-3 data is stored in a canonical **per-100g format** (mg/100g), derived from lab-verified fatty acid profiles. Per-serving values are computed at render time using the formula:

```
value_per_serving = value_per_100g × (serving_oz × 28.3495) / 100
```

This ensures consistency, traceability, and the ability to re-render at any serving size without data duplication.

### 4.2 Three-File Synchronization

Product data lives in three files that must stay synchronized:

| File | Purpose |
|---|---|
| `omega-map-v3.html` | The full Nutrition Intelligence Platform |
| `seatopia-product-tiles.html` | Product catalog (Shopify-ready) |
| `seatopia-omega-system.html` | Packaging badge system |

Every product addition or data update must be applied to all three files to prevent drift.

### 4.3 COA Traceability

Every lab test is linked to its source via a `COA_MAP` structure:

- **Light Labs PDF-based results:** Map stores the COA filename, lot number, and assay type.
- **Edacious dashboard results:** Map stores the dashboard URL.

This enables full audit-trail traceability from any displayed value back to its original lab documentation.

### 4.4 Mercury Data Sourcing

Mercury values are sourced from Light Labs **Heavy Metals** assay where available (separate from the Trace Minerals panel). When Edacious shows `< LOQ` but Light Labs has an actual ppb value, the Light Labs value is used and the source is called out inline. This corrected mercury data for 13 products that previously showed 0 ppb.

---

## 5. Recent Changes & Architecture Notes

### Product Tiles (`seatopia-product-tiles.html`)

- Headline now shows **"X,XXX mg EPA + DHA"** with `"per serving · marine omega dose"` label
- Supporting line shows total omega-3
- Default view flipped from per-package to **per-serving** — no more accidentally showing package numbers as serving
- Lab traceability now shows a strict ladder: **per 100g (truth) → per serving → per portion → per package** for both Marine Omega and Total Omega
- Variability note added: *"Based on third-party lab averages"*
- Sort now ranks by EPA+DHA, not total

### Omega Map Dashboard (`omega-map-v3.html`)

- Bar chart headline flipped to **EPA+DHA** with total as small secondary
- ALA bar segment de-emphasized (opacity: 0.5)
- Sorted by EPA+DHA not total
- Product cards: EPA+DHA as hero number, total as supporting
- Product detail modal: Marine Omega Dose as the primary display
- Subtitle updated to clarify Marine Omega methodology
- *"Based on third-party lab averages"* note throughout
- **Mercury data corrected** from Light Labs Heavy Metals assay (13 products updated)
- **Microplastics tab added** with EMSL testing results and COA links (16 products, all ND)
- **Data Quality tab removed** (not in use)
- **Raw Data tab simplified** from 29 → 18 columns with search filter and CSV export
- Header updated to **v1.0 · Apr 3, 2026 / Lab-verified data**

### Omega System (`seatopia-omega-system.html`)

- Dose card restructured: EPA → DHA → **Marine Omega (EPA+DHA)** as the bold total, then ALA and Total Omega-3 in subdued gray
- Variability note per card
- Back-of-pack shows the strict ladder: Truth Layer (per 100g) → Calculated Layer (per serving) with conversion factor shown

### Math Verification (Caleta Bay Steelhead, 6 oz serving)

| Level | Marine Omega | Total Omega-3 |
|---|---|---|
| Per 100g | 851 mg | 2,181 mg |
| Per serving (6 oz) | 1,448 mg | 3,710 mg |
| Per package (12 oz) | 2,895 mg | 7,420 mg |

All values verified ✓ — package values properly labeled as package, never shown as serving.

---

## 6. File Manifest

| File | Description |
|---|---|
| `omega-map-v3.html` | Nutrition Intelligence Platform — primary dashboard (10 tabs) |
| `seatopia-product-tiles.html` | Product catalog with Omega Meter tiles |
| `seatopia-omega-system.html` | Packaging badge generator |
| `seatopia_omega_value.xlsx` | $/Omega-3 cost efficiency spreadsheet |
| `LightLabsTestingData.csv` | Source data — all Light Labs test results |
| COA PDFs (Light Labs) | Individual Certificates of Analysis per product/assay |
| Edacious Dashboards | Online test result dashboards (linked via COA_MAP) |
