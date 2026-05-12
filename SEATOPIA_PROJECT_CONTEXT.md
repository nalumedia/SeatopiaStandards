# Seatopia Nutrition Intelligence Platform — Project Context

> **What this file is:** Drop this into a Cowork session (or paste it as context for any AI assistant) to get fully up to speed on the Seatopia Nutrition Intelligence Platform. It covers every file, every data structure, every code pattern, and every decision made during the build. If you need to update data, add a product, fix a bug, or extend the platform — this file has what you need.

---

## Project Overview

**Owner:** Ryan Dranginis (ryan.dranginis@gmail.com)
**Last Updated:** April 3, 2026
**Status:** v1.0 — Live, lab-verified data

Seatopia sells regenerative, ocean-raised seafood. This platform makes their third-party lab test data (omega-3, protein, selenium, mercury, microplastics, vitamin D) public, transparent, and comparable across 22 products and 14 species. Every number traces back to a Certificate of Analysis (COA) from Light Labs or Edacious.

---

## Files & What They Do

| File | Lines | Role | Public? |
|---|---|---|---|
| `omega-map-v3.html` | ~3,120 | **Primary dashboard** — 10-tab Nutrition Intelligence Platform | Yes |
| `seatopia-product-tiles.html` | ~1,170 | **Product catalog** — Shopify-ready tiles with Omega Meter | Yes |
| `seatopia-omega-system.html` | ~946 | **Packaging badges** — generates Omega Meter for print/packaging | Internal |
| `seatopia_omega_value.xlsx` | — | **Value analysis** — $/gram EPA+DHA across all 24 SKUs | Internal |
| `SeatopiaTestingData_AllLabs.csv` | ~1,463 | **Unified source data** — Light Labs + Edacious, normalized to mg/100g with mg/serving | No |
| `Seatopia_Nutrition_Platform_Project.md` | ~194 | **Project delivery doc** — Notion page for team sharing | Internal |
| `Seatopia_Shopify_Deployment_Guide.md` | ~581 | **Shopify deployment guide** — Liquid templates, embed options | Internal |

### Critical Rule: Three-File Synchronization

The product data lives in three HTML files that **must stay in sync**:

1. `omega-map-v3.html` → `PRODUCTS` array
2. `seatopia-product-tiles.html` → `NUTRITION` object + `TEST_DATA` + `COA_MAP` + `SKUS` array
3. `seatopia-omega-system.html` → `PRODUCTS` array

**Any time you update a product's data, you must update all three files.** The data structures are slightly different between them (see below), but the canonical per-100g values must match.

---

## The Seatopia Omega Standard (Core Data Model)

All omega-3 data is stored as **mg per 100g of edible portion** — the lab-reported canonical form. Per-serving values are **never stored**; they're always computed at render time.

### Why the math is correct

Both lab sources report on the **same basis**:

- **Light Labs** — Fatty Acid Profile reports in `g/100g` of the whole edible sample (not % of extracted lipids). Conversion: multiply by 1,000 to get mg/100g.
- **Edacious** — Multi-sample averages already reported in mg/100g of edible portion.

This means the values reflect **what you actually eat**, not a lipid-fraction percentage. There is no moisture/fat correction needed because the labs test the whole fish as purchased.

**Known data quality issue:** Light Labs test #3962 (Bakkafrost) has DHA and EPA labeled with unit `mg` instead of `g/100g`. The values (0.843, 0.324) are clearly g/100g based on all other analytes in the same test. This is flagged in `SeatopiaTestingData_AllLabs.csv` with `UNIT_MISMATCH`.

### Unified CSV: `SeatopiaTestingData_AllLabs.csv`

All testing data from both labs is consolidated in one CSV with these added columns:

| Column | Description |
|---|---|
| `Lab_Source` | `Light Labs` or `Edacious` |
| `mg_per_100g` | Every analyte normalized to mg/100g (the canonical unit) |
| `Serving_oz` | Product-specific serving size in oz |
| `mg_per_serving` | `mg_per_100g × (Serving_oz × 28.3495) / 100` |
| `Edacious_URL` | Link to Edacious dashboard for that product (if applicable) |
| `Data_Quality_Flag` | Any unit mismatches or data issues |

### The Conversion Formula

```javascript
const OZ_TO_G = 28.3495;

// Per-serving = per-100g × (serving_oz × 28.3495) / 100
function getServingData(product) {
  const servOz = getServingOz(product);
  const factor = (servOz * OZ_TO_G) / 100;
  const p = product.per100g;
  return {
    epa: Math.round(p.epa * factor),
    dha: Math.round(p.dha * factor),
    ala: Math.round(p.ala * factor),
    epa_dha: epa + dha,
    total: epa + dha + ala
  };
}
```

### Serving Basis Toggle

The dashboard supports two comparison modes:

```javascript
const STANDARD_SERVING_OZ = 6;
let currentServingBasis = 'standard'; // default

function getServingOz(product) {
  return currentServingBasis === 'standard'
    ? STANDARD_SERVING_OZ      // 6 oz — apples-to-apples
    : product.portion_oz;       // actual (caviar = 0.2 oz, shrimp = 4 oz, etc.)
}
```

### Why This Matters

You only ever update the **per-100g** values. Everything downstream recomputes. This prevents data drift between "per serving" and "per 100g" numbers.

---

## Data Structures by File

### omega-map-v3.html — `PRODUCTS` Array

This is the most complete data structure. Each product is an object in the `PRODUCTS` array:

```javascript
{
  handle: 'caleta-bay-steelhead',         // URL slug / unique ID
  name: 'Caleta Bay Steelhead',           // Display name
  species: 'Steelhead Trout',             // Species
  farm: 'Caleta Bay',                     // Farm/brand
  category: 'trout',                      // Category for filtering
  portion_oz: 6,                          // Actual serving size in oz

  // ─── Canonical per-100g values (SOURCE OF TRUTH) ───
  per100g: {
    epa: 262.0,    // mg EPA per 100g
    dha: 589.0,    // mg DHA per 100g
    ala: 1330.0    // mg ALA per 100g
  },

  // ─── Additional nutrition ───
  protein_g: 20.8,           // grams protein per 100g
  se_mcg_per100g: 22.1,     // micrograms selenium per 100g
  hg_ppb: 0,                // mercury in parts per billion
  hg_loq: true,             // true = below limit of quantification
  hg_source: 'Light Labs',  // which lab provided the Hg value
  hg_test: '4078',          // Light Labs test ID for Hg
  vitd_mcg: 9.01,           // vitamin D (D2+D3) mcg per 100g
  omega6_3: 1.03,           // omega-6 to omega-3 ratio

  // ─── Microplastics ───
  mp_tested: true,           // whether EMSL microplastics test was done
  mp_test: '21522',          // Light Labs/EMSL test ID
  mp_result: 'ND',           // 'ND' = Not Detected

  // ─── Lab references ───
  n_tests: 4,               // number of independent tests
  source: 'Edacious',       // primary data source
  primary_test: 'E-CLB',    // test code used for public-facing values

  // ─── Test data (individual lab results) ───
  tests: [
    { code: 'E-CLB', lab: 'Edacious', epa: 262.0, dha: 589.0, ala: 1330.0, primary: true },
    { code: '21156', lab: 'Light Labs', epa: 295.0, dha: 660.0, ala: 1230.0 },
    { code: '21164', lab: 'Light Labs', epa: 289.0, dha: 659.0, ala: 1219.5 }
  ]
}
```

### seatopia-product-tiles.html — Separate Objects

This file uses four separate data structures instead of one big array:

```javascript
// 1. NUTRITION — per-100g canonical values, keyed by handle
const NUTRITION = {
  "caleta-bay-steelhead": {
    epa: 262.0, dha: 589.0, ala: 1330.0,
    protein_g: 20.8, se_mcg: 22.1, hg_ppb: 0,
    vitd_mcg: 9.01, n_tests: 4, source: "Edacious", omega6_3: 1.03
  },
  // ... 21 more products
};

// 2. TEST_DATA — lab results per handle
const TEST_DATA = {
  "caleta-bay-steelhead": [
    { code: "E-CLB", lab: "Edacious", assay: "Full Panel", epa: 262.0, dha: 589.0, ala: 1330.0 },
    { code: "21156", lab: "Light Labs", assay: "Fatty Acids", epa: 295.0, dha: 660.0, ala: 1230.0 }
  ],
  // ...
};

// 3. COA_MAP — test code → COA document reference
const COA_MAP = {
  'E-CLB': { type: 'url', url: 'https://eat.edacious.com/...', source: 'Edacious', assay: 'Full Panel' },
  '21156': { type: 'pdf', coa: 'Caleta Bay - Lot X - Fatty Acids COA.pdf', lot: 'X', assay: 'Fatty Acids' },
  // ...
};

// 4. SKUS — individual SKUs with serving/portion/package model
const SKUS = [
  {
    sku: "SF-CLB-STT-SHP-002",
    title: "Caleta Bay, A&I Steelhead Loin",
    category: "trout",
    handle: "caleta-bay-steelhead",
    serving_oz: 6,      // one eating occasion
    portion_oz: 12,     // individual piece/cut
    package_oz: 12,     // total weight customer buys
    package_label: "1 × 12oz loin",
    portions_per_pkg: 1
  },
  // ... 23 more SKUs (24 total across 22 products)
];
```

### seatopia-omega-system.html — `PRODUCTS` Array

Similar to omega-map-v3 but focused on packaging data. Includes tier classification (hero/core/supporting) and poetic descriptions for packaging copy.

---

## The 22 Products (Current Catalog)

| Handle | Species | Farm | Category |
|---|---|---|---|
| `caleta-bay-steelhead` | Steelhead Trout | Caleta Bay | trout |
| `ora-king-king-salmon` | King Salmon | Ora King | salmon |
| `mt-cook-king-salmon` | King Salmon | Mt Cook | salmon |
| `big-glory-bay-king-salmon` | King Salmon | Big Glory Bay | salmon |
| `bakkafrost-atlantic-salmon` | Atlantic Salmon | Bakkafrost | salmon |
| `superior-fresh-atlantic-salmon` | Atlantic Salmon | Superior Fresh | salmon |
| `hudson-valley-steelhead` | Steelhead Trout | Hudson Valley | trout |
| `mcfarland-springs-rainbow-trout` | Rainbow Trout | McFarland Springs | trout |
| `smoke-in-chimneys-rainbow-trout` | Rainbow Trout | Smoke in Chimneys | trout |
| `regal-king-salmon` | King Salmon | Regal | salmon |
| `esteros-lubimar-branzino` | European Bass | Esteros Lubimar | whitefish |
| `esteros-lubimar-sea-bream` | Sea Bream | Esteros Lubimar | whitefish |
| `kingfish-yellowtail` | Yellowtail Kingfish | The Kingfish Co | whitefish |
| `australis-barramundi` | Barramundi | Australis | whitefish |
| `desert-springs-barramundi` | Barramundi | Desert Springs | whitefish |
| `tarakan-black-tiger-shrimp` | Black Tiger Shrimp | Tarakan | shrimp |
| `taprobane-shrimp` | Whiteleg Shrimp | Taprobane | shrimp |
| `ecuador-shrimp` | Whiteleg Shrimp | Ecuador | shrimp |
| `santa-priscila-shrimp` | Whiteleg Shrimp | Santa Priscila | shrimp |
| `seacorp-peruvian-scallops` | Peruvian Scallops | Seacorp | scallop |
| `marshallberg-osetra` | Osetra Sturgeon | Marshallberg | caviar |
| `yarra-valley-salmon-roe` | Salmon Roe | Yarra Valley | caviar |

---

## Dashboard Tabs (omega-map-v3.html)

The dashboard has **10 tabs**:

1. **Omega-3 Map** — Ranked bar chart, sortable by EPA+DHA / Total / EPA / DHA. Proportional bars, nutrient pills, serving basis toggle, supplements comparison.
2. **Product Pages** — Individual product cards with full nutrition breakdown and % Daily Values.
3. **Analytics** — Cross-catalog metrics: species rankings, DV analysis, portfolio stats.
4. **Mercury Profile** — Hg values in ppb, source lab callouts, Se:Hg molar ratio chart, color-coded risk.
5. **Microplastics** — EMSL testing results: 16/22 products tested, 6 polymers, all ND. COA links.
6. **Se:Hg Ratio** — Selenium-to-mercury protective ratio analysis.
7. **Omega-6:3** — Omega-6 to Omega-3 ratio analysis across catalog.
8. **Raw Data** — 18-column test data table with search filter, CSV export, COA links.
9. **Visuals** — Publication-ready charts and graphics.
10. **About** — Methodology, data sources, definitions.

---

## Mercury Data — Important Notes

Mercury data comes from **two different assays** at Light Labs:

1. **Trace Minerals panel** — includes Se, Zn, etc. Mercury is sometimes reported here but often as `< LOQ`.
2. **Heavy Metals assay** — a separate dedicated test that specifically measures Hg in ppb. This has actual values for almost every product.

**The rule:** If Edacious shows `< LOQ` for mercury but Light Labs Heavy Metals assay has an actual ppb value, **use the Light Labs value** and tag it with `hg_source: 'Light Labs'`.

### Products Corrected from Light Labs Heavy Metals

These 13 products were updated from 0 ppb / < LOQ to actual values:

| Product | Old | New (ppb) | Test ID |
|---|---|---|---|
| Hudson Valley Steelhead | 0 | 10.57 | 4072 |
| Ora King | 0 | 17.33 | 4074 |
| Mt Cook | 0 | 33.26 | 4073 |
| Big Glory Bay | 0 | 18.74 | 4071 |
| Bakkafrost | 0 | 37.46 | 4077 |
| Branzino | 3.0 | 100 | 21126 |
| Sea Bream | 0 | 60 | 21134 |
| Yellowtail | 0 | 60.26 | 4076 |
| McFarland Springs | 0 | 9.41 | 10845 |
| Australis Barramundi | 0 | 27.89 | 4070 |
| Tarakan Shrimp | 0 | 17.93 | 9760 |
| Seacorp Scallops | 0 | 10 | 21548 |
| Smoke in Chimneys | 9.7 | 9.74 | 4075 |

**Still < LOQ:** Caleta Bay (Light Labs also < LOQ, LOQ=10), Yarra Valley Salmon Roe (< LOQ, LOQ=10).

> **NOTE:** These Hg corrections were applied to `omega-map-v3.html` but **not yet synced** to `seatopia-product-tiles.html` or `seatopia-omega-system.html`. This is a known pending sync task.

---

## Microplastics Testing

**Lab:** EMSL Analytical (contracted through Light Labs)
**Polymers Tested:** HDPE, LDPE, PET, Polypropylene, Polystyrene, PVC
**Result:** 100% Not Detected across all 16 tested products

### Tested Products (16)

Each has `mp_tested: true`, `mp_result: 'ND'`, and a test ID in `mp_test`:

| Product | Test ID |
|---|---|
| Australis Barramundi | 21514 |
| Big Glory Bay | 21515 |
| Bakkafrost | 21516 |
| Branzino | 21517 |
| Sea Bream | 21518 |
| Caleta Bay | 21519 |
| Hudson Valley | 21520 |
| Ora King | 21521 |
| Mt Cook | 21522 |
| Superior Fresh | 21523 |
| McFarland Springs | 21524 |
| Yellowtail | 21525 |
| Smoke in Chimneys | 21526 |
| Tarakan Shrimp | 21527 |
| Seacorp Scallops | 21528 |
| Yarra Valley Salmon Roe | 21529 |

### Untested Products (6)

`mp_tested: false` — flagged as "COA Pending" in the Microplastics tab:

Regal King Salmon, Marshallberg Osetra, Desert Springs Barramundi, Taprobane Shrimp, Ecuador Shrimp, Santa Priscila Shrimp.

---

## COA_MAP Structure

The COA_MAP links test IDs to their source documents. Two types:

```javascript
// Type 1: Light Labs PDF COAs
'22491': {
  type: 'pdf',
  coa: 'Yarra Valley Salmon Roe - Lot PO-00512 - Fatty Acids COA.pdf',
  lot: 'PO-00512',
  assay: 'Fatty Acids'
}

// Type 2: Edacious Dashboard URLs
'E-CLB': {
  type: 'url',
  url: 'https://eat.edacious.com/brand/seatopia/caleta-bay-steelhead-trout-loin',
  source: 'Edacious Certified Lab Analysis',
  assay: 'Full Panel (Fatty Acids, Protein, Vitamins, Minerals, Contaminants)'
}
```

The Edacious codes follow a pattern: `E-` + abbreviation (e.g., `E-CLB` = Caleta Bay, `E-OKS` = Ora King Salmon, `E-BAK` = Bakkafrost).

---

## Key Computed Values

### Se:Hg Molar Ratio

```javascript
// Selenium (mcg/100g) and Mercury (ppb) → molar ratio
// Ratio > 1 = selenium surplus (protective)
const seHgMolar = (se_mcg / 78.96) / ((hg_ppb / 10) / 200.59);
// Note: hg_ppb / 10 converts ppb to mcg/100g
```

Products with `hg_ppb === 0` return Infinity and are filtered out of the ratio chart.

### Mercury Per Serving (mcg)

```javascript
const hgMcgPerServing = (hg_ppb / 10) * (serving_oz * 28.3495) / 100;
// Color coding: green < 0.5 mcg, yellow 0.5–2 mcg, red > 2 mcg
```

### % Daily Value for Omega-3

```javascript
const OMEGA_DV = 2000;  // mg EPA+DHA recommended daily
const dvPct = Math.round((epa_dha_per_serving / OMEGA_DV) * 100);
```

### Fish Oil Capsule Equivalence

```javascript
const CAPSULE_MG = 300;  // standard fish oil capsule = 300mg EPA+DHA
const capsules = Math.round(epa_dha_per_serving / CAPSULE_MG);
```

---

## CSS Design System

The platform uses Seatopia's brand palette:

```css
:root {
  --charcoal-blue: #335566;    /* Primary text/buttons */
  --cerulean: #4B7991;         /* Secondary blue */
  --maya-blue: #7BC3F3;        /* Light accent */
  --linen: #F7EFE6;            /* Background */
  --almond-silk: #FDD4CD;      /* Warm accent */
  --fiery-terracotta: #D45A3C; /* ALA bar segment */
  --moss-green: #7BC950;       /* Verified badges, safe indicators */
  --racing-red: #EE1C25;       /* High mercury warning */
  --pumpkin-spice: #EE7B30;    /* Medium mercury warning */
  --deep-ocean: #1a3344;       /* Dark headers */
}
```

Fonts: `EB Garamond` (serif, for headings/numbers) and `Karla` (sans-serif, for body text). Both loaded from Google Fonts.

---

## How To: Common Tasks

### Add a New Product

1. In `omega-map-v3.html`, add a new object to the `PRODUCTS` array with all fields (handle, name, species, per100g, etc.)
2. In `seatopia-product-tiles.html`, add entries to `NUTRITION`, `TEST_DATA`, and `SKUS`
3. In `seatopia-omega-system.html`, add to the `PRODUCTS` array
4. Add COA references to `COA_MAP` in all three files
5. Test: open the HTML file in a browser and verify the product appears

### Update Lab Results for an Existing Product

1. Find the product by handle in `omega-map-v3.html`
2. Update the `per100g` values (epa, dha, ala)
3. Add the new test to the `tests` array
4. Add the COA to `COA_MAP`
5. Sync the same changes to the other two files

### Update Mercury Data

1. Find the product in `omega-map-v3.html`
2. Update `hg_ppb`, set `hg_loq: false` if there's a real value
3. Set `hg_source: 'Light Labs'` and `hg_test: 'XXXX'`
4. Sync to other files

### Add a New Microplastics Test Result

1. Set `mp_tested: true`, `mp_test: 'XXXXX'`, `mp_result: 'ND'` on the product
2. Add COA_MAP entry: `'XXXXX': { type: 'pdf', coa: 'Product - Lot - Microplastics (EMSL) COA.pdf', lot: 'XXXXX', assay: 'Microplastics (EMSL)' }`

### Deploy to Shopify

See `Seatopia_Shopify_Deployment_Guide.md` for full instructions. TL;DR: create a `page.nutrition.liquid` template, paste the HTML, assign it to a page at `/pages/nutrition`.

---

## Known Pending Work

- [ ] **Sync Hg corrections to product-tiles and omega-system** — The 13 mercury corrections from Light Labs Heavy Metals assay were only applied to `omega-map-v3.html`
- [ ] **Get Edacious results public** — Edacious dashboard links need to be publicly accessible
- [ ] **Get Edacious on product pages** — Connect Edacious data to Shopify product pages
- [ ] **Host COA PDFs** — PDF filenames in COA_MAP need to resolve to actual hosted files
- [ ] **Test 6 remaining products for microplastics** — Regal, Marshallberg, Desert Springs, Taprobane, Ecuador, Santa Priscila

---

## Lab Sources

| Lab | Type | What They Test | How Data is Referenced |
|---|---|---|---|
| **Edacious** | Dashboard (URL) | Full panel: fatty acids, protein, vitamins, minerals, contaminants | `type: 'url'` in COA_MAP, codes like `E-CLB` |
| **Light Labs** | PDF COAs | Fatty acids, protein, selenium, vitamin D, heavy metals, microplastics, iodine, cholesterol, vitamin B12, vitamin E, inorganic arsenic | `type: 'pdf'` in COA_MAP, numeric test codes |
| **EMSL Analytical** | via Light Labs | Microplastics (6 polymer types) | Contracted through Light Labs, referenced by Light Labs test IDs |

---

## Quick Reference: Key Constants

```javascript
const OZ_TO_G = 28.3495;           // ounces to grams
const STANDARD_SERVING_OZ = 6;     // standardized comparison basis
const OMEGA_DV = 2000;             // daily value for omega-3 (mg)
const PROTEIN_DV = 50;             // daily value for protein (g)
const SELENIUM_RDI = 55;           // RDI for selenium (mcg)
const CAPSULE_MG = 300;            // fish oil capsule EPA+DHA (mg)
```
