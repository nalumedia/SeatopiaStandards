# Seatopia Nutrition Platform — Cowork Team Guide

**How to use Cowork to work on the Seatopia Nutrition Intelligence Platform**

---

## What Is This?

We built a Nutrition Intelligence Platform that makes all of Seatopia's third-party lab data public and transparent — omega-3, protein, selenium, mercury, microplastics, and more across 22 products. The entire platform is self-contained HTML files with no backend, no build step, and no dependencies.

An AI assistant (Cowork / Claude) built this with Ryan. All the project knowledge has been captured in a context file so anyone on the team can pick up where we left off.

---

## Folder Structure

This folder contains everything you need. Here's what's inside:

```
Seatopia_Nutrition_Platform/
│
├── 📄 SEATOPIA_PROJECT_CONTEXT.md          ← THE KEY FILE — feed this to Cowork
│
├── ─── Platform Files (the actual product) ───
├── 🌐 omega-map-v3.html                    ← Main dashboard (10-tab Nutrition Intelligence Platform)
├── 🌐 seatopia-product-tiles.html          ← Product catalog with Omega Meter tiles
├── 🌐 seatopia-omega-system.html           ← Packaging badge generator (internal)
├── 📊 seatopia_omega_value.xlsx            ← $/Omega-3 value analysis spreadsheet
│
├── ─── Source Data ───
├── 📋 LightLabsTestingData.csv             ← Raw Light Labs test results (all assays, all products)
├── 📁 COAs/                                ← Certificate of Analysis PDFs from Light Labs
│
├── ─── Documentation ───
├── 📄 Seatopia_Cowork_Team_Guide.md        ← You are here
├── 📄 Seatopia_Nutrition_Platform_Project.md ← Project delivery doc (what was built, how it works)
└── 📄 Seatopia_Shopify_Deployment_Guide.md  ← How to deploy to Shopify (Liquid templates included)
```

---

## Setup: Google Drive

This folder lives in a shared Google Drive. To work with it:

1. Make sure **Google Drive for Desktop** is installed and synced on your Mac
2. The folder syncs to your local filesystem at something like: `~/Google Drive/My Drive/Seatopia_Nutrition_Platform/` (or wherever the shared drive mounts)
3. You can open any `.html` file directly in your browser by double-clicking it — they work completely offline
4. When Cowork edits files, the changes sync back to Google Drive automatically

If you don't have Google Drive for Desktop, you can also download the folder to your computer and work locally. Just upload the edited files back to Drive when you're done.

---

## Quick Start: Getting Cowork Up to Speed

### Step 1: Open Cowork

Open the Claude desktop app and switch to **Cowork mode** (the toggle at the top of the sidebar).

### Step 2: Select the Folder

Click the **folder icon** in Cowork and navigate to the `Seatopia_Nutrition_Platform` folder (either on Google Drive or wherever you downloaded it). This gives Cowork read/write access to all the project files.

### Step 3: Feed It the Context

Copy and paste this as your first message:

```
Read the file SEATOPIA_PROJECT_CONTEXT.md in my folder. This is the
knowledge base for the Seatopia Nutrition Intelligence Platform.
Familiarize yourself with the entire project — all the files, data
structures, code patterns, and pending work. Then tell me what you
understand and ask if I need help with anything.
```

That's it. Cowork will read the context file and immediately understand the entire project: every file, every data structure, every product, the conversion formulas, the mercury correction story, the three-file sync requirement, and all pending tasks.

### Step 4: Start Working

Now you can ask Cowork to do things like:

- *"Add a new product called Pacific Halibut with these lab values..."*
- *"Update the mercury value for Branzino to 95 ppb from the latest Light Labs test"*
- *"Sync the Hg corrections from omega-map-v3 to product-tiles and omega-system"*
- *"Add microplastics test results for Regal King Salmon — test ID 25001, all ND"*
- *"Export the product data as a CSV"*
- *"Help me deploy this to Shopify"*
- *"Open omega-map-v3.html and walk me through how the bar chart works"*

Cowork will know exactly which files to edit, which data structures to update, and the three-file sync requirement.

---

## Important: Starting a New Session

Every time you start a **new** Cowork session (or if the conversation gets long and resets), you need to re-feed the context file. Cowork doesn't remember between sessions. Just paste the same first message from Step 3 above.

Think of `SEATOPIA_PROJECT_CONTEXT.md` as the project's brain — Cowork reads it and instantly knows everything.

---

## Common Tasks You Might Need to Do

### Update Lab Data for a Product

Tell Cowork something like:

> *"We got new Light Labs results for Bakkafrost. Fatty Acid test #28000: EPA 485 mg/100g, DHA 850 mg/100g, ALA 920 mg/100g. COA filename is 'Bakkafrost - Lot PO-00650 - Fatty Acids COA.pdf'. Update all three files."*

Cowork will update the per-100g values in PRODUCTS, add the test to the tests array, add the COA_MAP entry, and sync across all three HTML files.

### Add a Brand New Product

> *"We're adding a new product: Ōra King Salmon Belly. Handle: ora-king-belly. Species: King Salmon, Farm: Ora King, Category: salmon. Serving: 4oz. Per 100g: EPA 620, DHA 1180, ALA 1400. Protein 16.5g, Se 28.3 mcg. Hg: 15.2 ppb from Light Labs test 5001. Add it to all three files."*

### Fix Something on the Dashboard

> *"The bar chart on the Omega-3 Map tab is sorting wrong — can you check the sort logic in omega-map-v3.html?"*

### Deploy to Shopify

> *"Read the Shopify deployment guide and help me set up the nutrition page on our Shopify store."*

### Generate Reports or Exports

> *"Give me a CSV of all 22 products with their per-serving EPA+DHA, mercury, and selenium values."*

### Upload a New COA PDF

Drop the PDF into the `COAs/` folder in Google Drive, then tell Cowork:

> *"I just added a new COA PDF to the COAs folder: 'Bakkafrost - Lot PO-00650 - Fatty Acids COA.pdf'. Add it to the COA_MAP in all three files with test ID 28000."*

---

## Tips for Working with Cowork on This Project

**Always feed the context file first.** Every new session, paste the Step 3 message. Without it, Cowork is starting from zero.

**Be specific about which files to update.** If you only want to update the dashboard, say so. If you want all three files synced, say "update all three files."

**Give lab data in per-100g.** The system stores everything as mg/100g. If your lab report gives per-serving values, tell Cowork the serving size so it can back-calculate.

**Include COA details.** When adding new test data, include the test ID, lot number, assay name, and COA filename. This keeps the traceability chain intact.

**Preview before shipping.** After Cowork makes changes, open the HTML file in your browser to visually verify. The files are self-contained — just double-click to open.

**Don't worry about breaking things.** Google Drive has version history. If something goes wrong, right-click the file in Drive → "Manage versions" → restore a previous version.

---

## What's Already Done

- 22 products across 14 species with full nutrition data
- 60+ independent lab tests from Light Labs and Edacious
- 10-tab interactive dashboard with sorting, filtering, and comparison tools
- Mercury data corrected from Light Labs Heavy Metals assay (13 products)
- Microplastics testing results (16 of 22 products, all Not Detected)
- COA traceability for every data point
- Standardized 6oz comparison toggle
- Raw data table with search filter and CSV export
- $/Omega-3 value analysis spreadsheet
- Shopify deployment guide with Liquid templates
- Product page omega tile snippet

## What Still Needs Doing

- [ ] Sync mercury corrections to `seatopia-product-tiles.html` and `seatopia-omega-system.html`
- [ ] Get Edacious results set to public
- [ ] Get Edacious data on Shopify product pages
- [ ] Host COA PDFs so links in the Raw Data tab resolve
- [ ] Test remaining 6 products for microplastics
- [ ] Deploy to Shopify (see deployment guide)

---

## File Descriptions (What to Open When)

**Want to see the full dashboard?** → Open `omega-map-v3.html` in a browser

**Want to see product tiles?** → Open `seatopia-product-tiles.html` in a browser

**Want to generate packaging badges?** → Open `seatopia-omega-system.html` in a browser

**Want to understand the project?** → Read `Seatopia_Nutrition_Platform_Project.md`

**Want to deploy to Shopify?** → Read `Seatopia_Shopify_Deployment_Guide.md`

**Want an AI to help you work on it?** → Feed `SEATOPIA_PROJECT_CONTEXT.md` to Cowork

---

## Questions?

Reach out to Ryan (ryan.dranginis@gmail.com) — he built this with Claude and knows where all the bodies are buried.
