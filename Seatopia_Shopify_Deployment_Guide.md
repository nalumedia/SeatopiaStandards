# Seatopia Nutrition Platform — Shopify Deployment Guide

**Purpose:** Step-by-step guide to making the Seatopia Nutrition Intelligence Platform public on your Shopify storefront.

---

## Overview: What We Built

The platform consists of three standalone HTML files — no server, no build step, no dependencies beyond two Google Fonts. Each file is completely self-contained: all CSS, JavaScript, and product data live inside a single `.html` file.

| File | What It Does | Where It Goes on Shopify |
|---|---|---|
| `omega-map-v3.html` | Full Nutrition Intelligence Platform (10-tab dashboard) | Standalone page — e.g. `/pages/nutrition` |
| `seatopia-product-tiles.html` | Product catalog with Omega Meter tiles | Embed on collection page or standalone page |
| `seatopia-omega-system.html` | Packaging badge generator (internal tool) | Not public-facing — used to generate assets |

---

## Architecture: Why Self-Contained HTML Works

Each file follows the same pattern:

```
┌─────────────────────────────────────────┐
│  <style>  ... all CSS ...               │
│  <html>   ... minimal markup ...        │
│  <script> ... PRODUCTS data + renderer  │
└─────────────────────────────────────────┘
```

There are no external API calls, no databases, and no build tools. The product data (NUTRITION, TEST_DATA, COA_MAP, SKUS arrays) is embedded directly in each file. This means:

- Zero load-time latency for data fetching
- Works in any environment that renders HTML (Shopify, static hosting, email, etc.)
- No CORS issues, no API keys, no auth
- The trade-off: data updates require editing the HTML files directly

---

## Option A: Shopify Custom Page (Recommended)

This is the simplest path. Shopify lets you create pages with raw HTML content.

### Step 1: Create a Custom Page Template

In your Shopify theme (Online Store → Themes → Edit Code), create a new template:

**File:** `templates/page.nutrition.liquid`

```liquid
{% comment %}
  Seatopia Nutrition Intelligence Platform
  Template: page.nutrition.liquid
  Usage: Assign this template to a page in Shopify Admin → Pages
{% endcomment %}

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ page.title }} — {{ shop.name }}</title>

  {%- comment -%} Keep Shopify's standard head content for SEO & analytics {%- endcomment -%}
  {{ content_for_header }}

  {%- comment -%} Google Fonts used by the platform {%- endcomment -%}
  <link href="https://fonts.googleapis.com/css2?family=EB+Garamond:wght@400;700&family=Karla:wght@400;500;600;700&display=swap" rel="stylesheet">

  <style>
    /* Reset the Shopify theme wrapper so the platform fills the page */
    .shopify-section { max-width: 100%; padding: 0; }
    .page-width { max-width: 100%; padding: 0; }
    #shopify-section-template--page { padding: 0; }
  </style>
</head>
<body>
  {%- comment -%}
    Option 1: Inline the full HTML content directly (paste everything
    between <style>...</style> and <script>...</script> from omega-map-v3.html)

    Option 2: Use an iframe pointing to a hosted version of the file
  {%- endcomment -%}

  {{ page.content }}

</body>
</html>
```

### Step 2: Create the Page in Shopify Admin

1. Go to **Online Store → Pages → Add page**
2. Title: `Nutrition Intelligence Platform`
3. Set the URL handle to `nutrition`
4. In the **Theme template** dropdown (right sidebar), select `page.nutrition`
5. Switch the content editor to **HTML mode** (click `<>` icon)
6. Paste the entire contents of `omega-map-v3.html`
7. Save

Your platform is now live at `https://seatopia.fish/pages/nutrition`.

### Step 3: Add Navigation

Go to **Online Store → Navigation** and add a link to your main menu or footer:

- **Name:** Nutrition Data
- **Link:** `/pages/nutrition`

---

## Option B: Hosted File + Iframe Embed

If Shopify's content editor strips your JavaScript (common with some themes), host the file externally and embed via iframe.

### Step 1: Host the HTML File

Upload `omega-map-v3.html` to any static hosting:

- **Shopify Files:** Settings → Files → Upload (gives you a `cdn.shopify.com/s/files/...` URL)
- **GitHub Pages:** Push to a repo, enable Pages (free, version-controlled)
- **Netlify / Vercel:** Drag-and-drop deploy (free tier)
- **S3 / Cloudflare Pages:** For production-grade CDN hosting

### Step 2: Create the Iframe Template

**File:** `templates/page.nutrition-iframe.liquid`

```liquid
{% comment %}
  Seatopia Nutrition Platform — Iframe Embed
  Hosts the platform via iframe for themes that strip inline JS
{% endcomment %}

{%- layout none -%}

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ page.title }} — {{ shop.name }}</title>
  {{ content_for_header }}
  <style>
    body { margin: 0; padding: 0; overflow: hidden; }
    iframe {
      width: 100%;
      height: 100vh;
      border: none;
      display: block;
    }
  </style>
</head>
<body>
  <iframe
    src="YOUR_HOSTED_URL_HERE/omega-map-v3.html"
    title="Seatopia Nutrition Intelligence Platform"
    loading="lazy"
    allow="clipboard-write"
  ></iframe>
</body>
</html>
```

Replace `YOUR_HOSTED_URL_HERE` with the actual URL.

### Step 3: Assign Template to Page

Same as Option A Step 2, but select the `page.nutrition-iframe` template.

---

## Option C: Shopify Section (For Theme Integration)

If you want the nutrition data to appear as a section within your existing theme layout (with your normal header, footer, and nav), create a Shopify section.

**File:** `sections/nutrition-platform.liquid`

```liquid
{% comment %}
  Seatopia Nutrition Platform Section
  Add this section to any page via the Theme Customizer
{% endcomment %}

<div id="seatopia-nutrition-platform" style="width:100%;min-height:100vh;">
  <style>
    /* ═══ Paste all CSS from omega-map-v3.html here ═══ */
    /* Everything between the <style> tags */
  </style>

  <!-- ═══ Paste all HTML body content here ═══ -->
  <!-- Everything between <body> and the <script> tag -->

  <script>
    // ═══ Paste all JavaScript here ═══
    // Everything between the <script> tags
  </script>
</div>

{% schema %}
{
  "name": "Nutrition Platform",
  "tag": "section",
  "class": "nutrition-platform-section",
  "settings": [
    {
      "type": "text",
      "id": "heading",
      "label": "Section Heading",
      "default": "Nutrition Intelligence"
    }
  ],
  "presets": [
    {
      "name": "Nutrition Platform",
      "category": "Custom"
    }
  ]
}
{% endschema %}
```

Then in the Theme Customizer, add the "Nutrition Platform" section to any page template.

---

## Product Tiles on Product Pages

To show the Omega Meter tile on individual Shopify product pages, you'll extract the relevant tile for each product using the Shopify product handle.

### Snippet: `snippets/omega-tile.liquid`

```liquid
{% comment %}
  Renders the Omega Meter tile for a given product.
  Usage: {% render 'omega-tile', product_handle: product.handle %}

  This snippet contains the per-product nutrition data inline.
  When lab data changes, update the NUTRITION object below.
{% endcomment %}

{%- assign handle = product_handle | default: product.handle -%}

<div class="omega-tile" id="omega-tile-{{ handle }}">
  <style>
    .omega-tile {
      font-family: 'Karla', sans-serif;
      background: #fff;
      border-radius: 14px;
      padding: 20px;
      box-shadow: 0 2px 12px rgba(51,85,102,0.07);
      max-width: 400px;
      margin: 16px 0;
    }
    .omega-tile .ot-label {
      font-size: 10px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: #4B7991;
      margin-bottom: 6px;
    }
    .omega-tile .ot-value {
      font-family: 'EB Garamond', serif;
      font-size: 28px;
      font-weight: 700;
      color: #1a1a1a;
      line-height: 1.1;
    }
    .omega-tile .ot-sub {
      font-size: 12px;
      color: #666;
      margin-top: 2px;
    }
    .omega-tile .ot-pills {
      display: flex;
      gap: 6px;
      margin-top: 10px;
    }
    .omega-tile .ot-pill {
      font-size: 11px;
      padding: 3px 10px;
      border-radius: 10px;
      font-weight: 600;
    }
    .omega-tile .ot-epa { background: rgba(51,85,102,0.08); color: #335566; }
    .omega-tile .ot-dha { background: rgba(75,121,145,0.08); color: #4B7991; }
    .omega-tile .ot-verified {
      display: flex;
      align-items: center;
      gap: 4px;
      font-size: 10px;
      font-weight: 600;
      color: #2e8b57;
      margin-top: 10px;
    }
  </style>

  <script>
    (function() {
      // Seatopia Omega Standard — per 100g canonical values
      const NUTRITION = {
        "caleta-bay-steelhead": { epa: 262, dha: 589 },
        "ora-king-king-salmon": { epa: 536, dha: 1070 },
        "hudson-valley-steelhead": { epa: 376, dha: 1040 },
        "big-glory-bay-king-salmon": { epa: 546, dha: 885 },
        "mt-cook-king-salmon": { epa: 457, dha: 862 },
        "bakkafrost-atlantic-salmon": { epa: 471, dha: 833 },
        "superior-fresh-atlantic-salmon": { epa: 530, dha: 1020 },
        "mcfarland-springs-rainbow-trout": { epa: 272, dha: 668 },
        "smoke-in-chimneys-rainbow-trout": { epa: 86, dha: 404 },
        "esteros-lubimar-branzino": { epa: 304, dha: 598 },
        "esteros-lubimar-sea-bream": { epa: 221, dha: 567 },
        "kingfish-yellowtail": { epa: 187, dha: 546 },
        "australis-barramundi": { epa: 31, dha: 92 },
        "desert-springs-barramundi": { epa: 20, dha: 20 },
        "tarakan-black-tiger-shrimp": { epa: 15, dha: 17 },
        "taprobane-shrimp": { epa: 69.6, dha: 81.9 },
        "ecuador-shrimp": { epa: 48.9, dha: 53 },
        "santa-priscila-shrimp": { epa: 23.1, dha: 24.5 },
        "seacorp-peruvian-scallops": { epa: 51, dha: 35 },
        "marshallberg-osetra": { epa: 497.8, dha: 1250.7 },
        "yarra-valley-salmon-roe": { epa: 513.8, dha: 2292.4 },
        "regal-king-salmon": { epa: 275.8, dha: 750.1 }
      };

      // Serving sizes by handle (oz)
      const SERVING_OZ = {
        "caleta-bay-steelhead": 6, "ora-king-king-salmon": 8.5,
        "hudson-valley-steelhead": 6, "big-glory-bay-king-salmon": 8,
        "mt-cook-king-salmon": 7, "bakkafrost-atlantic-salmon": 6,
        "superior-fresh-atlantic-salmon": 6, "mcfarland-springs-rainbow-trout": 3.2,
        "smoke-in-chimneys-rainbow-trout": 6, "esteros-lubimar-branzino": 6,
        "esteros-lubimar-sea-bream": 6, "kingfish-yellowtail": 6,
        "australis-barramundi": 6, "desert-springs-barramundi": 6,
        "tarakan-black-tiger-shrimp": 4, "taprobane-shrimp": 4,
        "ecuador-shrimp": 4, "santa-priscila-shrimp": 4,
        "seacorp-peruvian-scallops": 4, "marshallberg-osetra": 0.2,
        "yarra-valley-salmon-roe": 0.2, "regal-king-salmon": 6.7
      };

      const handle = "{{ handle }}";
      const data = NUTRITION[handle];
      const container = document.getElementById("omega-tile-" + handle);

      if (!data || !container) return;

      const oz = SERVING_OZ[handle] || 6;
      const factor = (oz * 28.3495) / 100;
      const epa = Math.round(data.epa * factor);
      const dha = Math.round(data.dha * factor);
      const marine = epa + dha;

      container.innerHTML += `
        <div class="ot-label">Marine Omega Dose</div>
        <div class="ot-value">${marine.toLocaleString()} mg EPA + DHA</div>
        <div class="ot-sub">per ${oz} oz serving · lab verified</div>
        <div class="ot-pills">
          <span class="ot-pill ot-epa">EPA ${epa.toLocaleString()}</span>
          <span class="ot-pill ot-dha">DHA ${dha.toLocaleString()}</span>
        </div>
        <div class="ot-verified">
          <svg style="width:12px;height:12px" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
          3rd Party Lab Verified · <a href="/pages/nutrition" style="color:#4B7991;text-decoration:underline">View Full Report</a>
        </div>
      `;
    })();
  </script>
</div>
```

### Usage in Product Template

In your product template (`sections/main-product.liquid` or equivalent), add:

```liquid
{% render 'omega-tile', product_handle: product.handle %}
```

This will render the omega tile on any product page where the handle matches a tested product. Products without data simply render nothing.

---

## Data Flow: How to Update When New Lab Results Come In

The data lives directly in the HTML files. When you get new lab results, here's the update workflow:

### 1. Update the Canonical Data

In `omega-map-v3.html`, find the `PRODUCTS` array (around line 170). Each product object looks like:

```javascript
{
  handle: 'caleta-bay-steelhead',
  name: 'Caleta Bay Steelhead',
  species: 'Steelhead Trout',
  per100g: { epa: 262, dha: 589, ala: 1330 },
  protein_g: 20.8,
  se_mcg_per100g: 22.1,
  hg_ppb: 0,
  hg_loq: true,
  portion_oz: 6,
  // ... other fields
}
```

Update the `per100g` values with the new lab results. All per-serving values are computed automatically from per-100g.

### 2. Sync to All Three Files

The same canonical data must exist in all three files. After updating `omega-map-v3.html`, replicate the changes to:

- `seatopia-product-tiles.html` → Update the `NUTRITION` object
- `seatopia-omega-system.html` → Update the `PRODUCTS` array
- `snippets/omega-tile.liquid` → Update the `NUTRITION` object (if using product page tiles)

### 3. Add COA References

If the new results come with a COA, add an entry to the `COA_MAP` object in each file:

```javascript
COA_MAP['TEST_ID'] = {
  type: 'pdf',
  coa: 'Product Name - Lot XXXXX - Assay Name COA.pdf',
  lot: 'XXXXX',
  assay: 'Fatty Acids'
};
```

For Edacious dashboard links:

```javascript
COA_MAP['E-CODE'] = {
  type: 'url',
  url: 'https://eat.edacious.com/brand/seatopia/product-slug',
  source: 'Edacious Certified Lab Analysis',
  assay: 'Full Panel'
};
```

---

## Key Code Patterns to Understand

### The Seatopia Omega Standard (Conversion Formula)

Every omega-3 value in the system starts as **mg per 100g** (the lab-reported canonical form). Per-serving values are never stored — they're always computed:

```javascript
const OZ_TO_G = 28.3495;

function getServingData(product) {
  const servOz = getServingOz(product);  // 6 oz standard or actual portion
  const factor = (servOz * OZ_TO_G) / 100;
  const p = product.per100g;
  return {
    epa: Math.round(p.epa * factor),
    dha: Math.round(p.dha * factor),
    ala: Math.round(p.ala * factor)
  };
}
```

This means you only ever update the per-100g source-of-truth values. Everything else recomputes.

### Serving Basis Toggle

The dashboard supports two comparison modes:

```javascript
const STANDARD_SERVING_OZ = 6;
let currentServingBasis = 'standard';  // default

function getServingOz(product) {
  return currentServingBasis === 'standard'
    ? STANDARD_SERVING_OZ        // 6 oz — apples-to-apples comparison
    : product.portion_oz;         // actual serving size (caviar = 0.2 oz, etc.)
}
```

Users toggle between "Per 6 oz (Standardized)" and "Per Actual Serving" using the buttons at the top of the Omega-3 Map tab.

### Mercury Source Logic

Mercury data comes from two sources with a priority rule:

```
IF Light Labs Heavy Metals assay has a value → use it, tag as "Light Labs"
ELSE IF Edacious has a value → use it, tag as "Edacious"
ELSE → display "< LOQ"
```

The source is displayed inline next to every mercury value so the data is always traceable.

### COA Traceability

The `COA_MAP` maps test IDs to their source documents:

```javascript
// PDF-based (Light Labs)
'22491': {
  type: 'pdf',
  coa: 'Yarra Valley Salmon Roe - Lot PO-00512 - Fatty Acids COA.pdf',
  lot: 'PO-00512',
  assay: 'Fatty Acids'
}

// URL-based (Edacious)
'E-CLB': {
  type: 'url',
  url: 'https://eat.edacious.com/brand/seatopia/caleta-bay-steelhead-trout-loin',
  source: 'Edacious Certified Lab Analysis',
  assay: 'Full Panel'
}
```

The Raw Data tab renders a clickable link to every COA. For PDFs, this links to the filename (you'll need to host these alongside the HTML or link to a shared drive). For Edacious results, it links directly to the public dashboard URL.

---

## Hosting the COA PDFs

The COA filenames in `COA_MAP` need to resolve to actual files. Options:

1. **Shopify Files**: Upload each PDF to Settings → Files. Update the `COA_MAP` entries to use the full `cdn.shopify.com` URL.

2. **Shared Google Drive folder**: Upload all COA PDFs and set sharing to "Anyone with the link." Use the direct download link format: `https://drive.google.com/uc?id=FILE_ID`

3. **Static hosting alongside the HTML**: If hosting on GitHub Pages or Netlify, put COA PDFs in a `/coas/` directory. The Raw Data tab's COA links can point to `/coas/filename.pdf`.

---

## SEO & Meta Tags

For the nutrition page, add structured data to help search engines understand the content. In your `page.nutrition.liquid` template, add inside `<head>`:

```liquid
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "name": "Seatopia Nutrition Intelligence Platform",
  "description": "Lab-verified omega-3, protein, selenium, and mercury data for 22 regenerative seafood products across 14 species. 60+ independent lab tests with full COA traceability.",
  "publisher": {
    "@type": "Organization",
    "name": "Seatopia",
    "url": "https://seatopia.fish"
  }
}
</script>
```

---

## Checklist: Going Live

- [ ] Choose deployment option (A: Custom Page, B: Iframe, or C: Section)
- [ ] Create Liquid template file in your Shopify theme
- [ ] Paste or link the HTML content
- [ ] Upload COA PDFs to accessible hosting
- [ ] Update COA_MAP links to point to hosted PDF URLs
- [ ] Test on mobile (the platform is responsive down to 680px)
- [ ] Add navigation link to main menu or footer
- [ ] Verify all 22 products render correctly on the Omega-3 Map tab
- [ ] Verify Raw Data tab COA links resolve
- [ ] Verify Microplastics tab COA references show test IDs
- [ ] Optional: Add `omega-tile.liquid` snippet to product pages
- [ ] Optional: Set up the product tiles page at `/pages/catalog`

---

## File Manifest

| File | Lines | Purpose |
|---|---|---|
| `omega-map-v3.html` | ~3,120 | Full Nutrition Intelligence Platform |
| `seatopia-product-tiles.html` | ~1,170 | Product catalog with Omega Meter tiles |
| `seatopia-omega-system.html` | ~946 | Packaging badge generator (internal) |
| `templates/page.nutrition.liquid` | ~30 | Shopify page template (create this) |
| `snippets/omega-tile.liquid` | ~100 | Per-product omega tile snippet (create this) |
| `sections/nutrition-platform.liquid` | ~20 | Optional Shopify section wrapper (create this) |
