-- ═══════════════════════════════════════════════════════════════
-- Seatopia Nutrition Intelligence — Supabase Schema
-- Generated: 2026-04-09
-- Source: Light Labs COAs + Edacious Full Panels
-- ═══════════════════════════════════════════════════════════════

-- Table 1: Products (identity + context)
-- One row per SKU. Primary key is the SKU code.
CREATE TABLE seatopia_products (
  sku TEXT PRIMARY KEY,
  product_name TEXT NOT NULL,
  farm TEXT NOT NULL,
  category TEXT NOT NULL,            -- roe, salmon, trout, white, shellfish
  sku_label TEXT,
  serving_oz NUMERIC(5,2) NOT NULL,
  package_oz NUMERIC(5,2) NOT NULL,
  servings_per_package NUMERIC(4,1),
  functional_role TEXT,
  functional_stacks TEXT,            -- semicolon-separated: "Brain/Cognitive; Heart"
  edacious_url TEXT,
  edacious_status TEXT,              -- verified, preview, pending, private
  microplastics_tested BOOLEAN DEFAULT FALSE,
  mercury_below_loq BOOLEAN DEFAULT FALSE,
  data_source TEXT DEFAULT 'Light Labs + Edacious',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table 2: Nutrition (one row per SKU × analyte)
-- This is the long/normalized format. Each analyte is a row, not a column.
-- All values are pre-computed for three bases: per 100g, per serving, per package.
CREATE TABLE seatopia_product_nutrition (
  id BIGSERIAL PRIMARY KEY,
  sku TEXT REFERENCES seatopia_products(sku) ON DELETE CASCADE,
  analyte TEXT NOT NULL,              -- slug: epa, dha, selenium, vitamin_d, etc.
  display_name TEXT NOT NULL,         -- human-readable: "EPA (C20:5)", "Selenium"
  category TEXT NOT NULL,             -- omega_3, omega_6, macros, minerals, vitamins, safety
  sort_order INTEGER DEFAULT 0,       -- for consistent display ordering
  value_per_100g NUMERIC(10,2),       -- canonical truth layer (all math derives from this)
  unit_per_100g TEXT,                 -- mg, mcg, g, ppb, ratio
  value_per_serving NUMERIC(10,2),    -- pre-computed: value_per_100g × (serving_oz × 28.3495) / 100
  value_per_package NUMERIC(10,2),    -- pre-computed: value_per_100g × (package_oz × 28.3495) / 100
  unit_scaled TEXT,                   -- unit for serving/package values (mcg for mercury)
  pct_daily_value_per_serving INTEGER,-- % of FDA Daily Value per serving
  daily_value_reference NUMERIC(10,2),-- the DV denominator used
  below_loq BOOLEAN DEFAULT FALSE,    -- true if below limit of quantitation
  UNIQUE(sku, analyte)
);

-- ═══════════════════════════════════════════════════════════════
-- INDEXES
-- ═══════════════════════════════════════════════════════════════
CREATE INDEX idx_nutrition_sku ON seatopia_product_nutrition(sku);
CREATE INDEX idx_nutrition_analyte ON seatopia_product_nutrition(analyte);
CREATE INDEX idx_nutrition_category ON seatopia_product_nutrition(category);
CREATE INDEX idx_products_category ON seatopia_products(category);

-- ═══════════════════════════════════════════════════════════════
-- ROW-LEVEL SECURITY (optional — enable if you want public read)
-- ═══════════════════════════════════════════════════════════════
ALTER TABLE seatopia_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE seatopia_product_nutrition ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Public read products" ON seatopia_products FOR SELECT USING (true);
CREATE POLICY "Public read nutrition" ON seatopia_product_nutrition FOR SELECT USING (true);

-- ═══════════════════════════════════════════════════════════════
-- EXAMPLE QUERIES
-- ═══════════════════════════════════════════════════════════════

-- 1. Full nutrition profile for one product
-- SELECT * FROM seatopia_product_nutrition
-- WHERE sku = 'SF-OKS-KGS-SHP-001'
-- ORDER BY sort_order;

-- 2. Rank all products by DHA per serving
-- SELECT p.product_name, p.farm, n.value_per_serving, n.unit_scaled
-- FROM seatopia_product_nutrition n
-- JOIN seatopia_products p ON n.sku = p.sku
-- WHERE n.analyte = 'dha'
-- ORDER BY n.value_per_serving DESC;

-- 3. Products with > 20% DV selenium per serving
-- SELECT p.product_name, n.value_per_serving, n.pct_daily_value_per_serving
-- FROM seatopia_product_nutrition n
-- JOIN seatopia_products p ON n.sku = p.sku
-- WHERE n.analyte = 'selenium' AND n.pct_daily_value_per_serving >= 20
-- ORDER BY n.pct_daily_value_per_serving DESC;

-- 4. All omega-3 analytes for salmon category
-- SELECT p.product_name, p.farm, n.analyte, n.value_per_serving, n.unit_scaled
-- FROM seatopia_product_nutrition n
-- JOIN seatopia_products p ON n.sku = p.sku
-- WHERE p.category = 'salmon' AND n.category = 'omega_3'
-- ORDER BY p.product_name, n.sort_order;

-- 5. Compare two products side by side
-- SELECT n.display_name, n.category,
--   MAX(CASE WHEN n.sku = 'SF-OKS-KGS-SHP-001' THEN n.value_per_serving END) AS ora_king,
--   MAX(CASE WHEN n.sku = 'SF-YRV-SLC-BLK-001' THEN n.value_per_serving END) AS salmon_roe
-- FROM seatopia_product_nutrition n
-- WHERE n.sku IN ('SF-OKS-KGS-SHP-001', 'SF-YRV-SLC-BLK-001')
-- GROUP BY n.analyte, n.display_name, n.category, n.sort_order
-- ORDER BY n.sort_order;

-- 6. Supabase JS client example:
-- const { data } = await supabase
--   .from('seatopia_product_nutrition')
--   .select('*, seatopia_products!inner(product_name, farm, category)')
--   .eq('analyte', 'epa_dha')
--   .order('value_per_serving', { ascending: false });
