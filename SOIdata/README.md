# SOIdata Project

IRS Statistics of Income (SOI) Corporation Income Tax Returns analysis for advertising ratio research.

## Session Log

### 2026-01-21, 14:00-18:00

**Task:** Download IRS SOI Table 5.1 data (2014-2022), construct panel dataset, compute advertising ratios, and create initial visualizations.

**Phases Completed:**

1. **Data Acquisition** - Downloaded 9 Excel files from IRS (2014-2022)
   - URL pattern: `https://www.irs.gov/pub/irs-soi/{YY}co51ccr.xlsx`
   - Files saved to `irs_soi_data/`

2. **Structure Discovery** - Examined Excel file structure
   - Data is transposed: industries as columns, variables as rows
   - Header row positions differ between 2014 (row 4) and 2015-2022 (row 5)
   - 19 sector-level totals + 221 subsector-level industries = 240 total (plus "All Industries")

3. **Panel Construction** - Parsed all files into long-format panel
   - Created `parse_soi.R` script
   - Output: 126,429 observations (241 industries × 67 variables × 9 years)
   - Saved to `irs_soi_data/soi_panel_long.rds` and `.csv`

4. **Ratio Computation**
   - Computed `ad_revenue_ratio = advertising / business_receipts`
   - Computed `ad_gross_profit_ratio = advertising / gross_profit`
   - Detected 8 infinite values (open-end investment funds with $0 receipts) → converted to NA
   - No negative gross profit cases found
   - Saved to `irs_soi_data/soi_ratios.rds` and `.csv`

5. **Missingness Investigation**
   - Advertising: 0.95% missing (18 industries, each missing 1 year)
   - Business receipts: 0% missing
   - Cost of goods sold: 5.09% missing
   - Sector-level missing: Educational services (2018), Utilities (2018)

6. **Visualizations** - Created sector-level time series plots
   - `ad_revenue_ratio_by_sector.png`
   - `ad_gross_profit_ratio_by_sector.png`

**Key Findings:**
- Median ad/revenue ratio: 0.93% (lower than SAI Books 2.83% figure)
- Highest ad/revenue sectors (2022): Management of companies (7.3%), Educational services (5.2%), Information (4.1%)
- Lowest: Mining (0.05%), Utilities (0.18%), Agriculture (0.29%)

**Verification:**
- All 9 Excel files downloaded successfully (148-202 KB each)
- Parser extracted 67 variables across 9 years
- Visualizations render correctly with expected missing data points

**Next Steps:**
- Analyze and improve visualizations
- Consider subsector-level analysis
- Potential NAICS code mapping for downstream research

---

### 2026-01-22, ~17:30-18:30

**Task:** Establish visualization style guide and create aggregate time series graphics for all key variables.

**Phases Completed:**

1. **Style Guide Development**
   - Font: Tinos (Times New Roman metric-compatible replacement)
   - Y-axis: Start from 0 for dollar values; trillions if min > $1T, else billions
   - X-axis: 2014-2022, all years labeled, slight padding to prevent point cropping
   - Theme: `theme_minimal()`, no minor gridlines, bold titles
   - Caption: "Source: IRS Statistics of Income, Table 5.1"

2. **Title Refinement**
   - Researched IRS SOI sample definition
   - Table 5.1 includes all "Active Corporations" (C corps, S corps, REITs, RICs, foreign corps with U.S. business)
   - Excludes: inactive corporations, foreign corps without U.S. trade/business
   - Final title format: "[Variable], Active U.S. Corporations"

3. **Pre-2014 Data Investigation**
   - Pre-2014 files exist (e.g., `13co05ccr.xls`) but have fundamentally different structure
   - Organized by size of business receipts (14 columns) vs. industry detail (240+ columns)
   - Not feasible to add without separate parsing logic; sticking with 2014-2022

4. **Graphics Created**
   - Created `graphics/` subdirectory
   - Generated 15-page PDF (`soi_selected_time_series.pdf`) with:
     - 13 level variables (Number of Returns, Revenue, COGS, Total Deductions, Salaries & Wages, Officer Compensation, Advertising, Depreciation, Interest Paid, Net Income, Income Tax, Total Assets, Total Liabilities)
     - 2 ratio graphs (Gross Profit Margin; Advertising Ratios combined)

**Verification:**
- All 15 plots render correctly with consistent style
- Y-axis scales use trillions for large aggregates (Revenue, COGS, Deductions, Assets, Liabilities)
- Ratios start from 0% as expected

**Code executed:** R scripts using ggplot2, showtext (for Tinos font), tidyverse

---

### 2026-01-27, ~09:50

**Task:** Improve color scheme in sector-level graphics (replace default ggplot2 hue palette with Tableau 20).

**Phases Completed:**

1. **Problem Diagnosis**
   - Default ggplot2 hue palette creates 5+ similar greens, multiple overlapping blues/pinks
   - With 19 sectors, many lines are indistinguishable
   - No semantic meaning in color assignment

2. **Solution Selection**
   - Evaluated 4 options: Highlight+Gray, Faceted Small Multiples, Tableau 20, Semantic Grouping
   - Selected Tableau 20 palette (via `ggthemes::scale_color_tableau()`) for maximum discriminability across all 19 sectors

3. **Implementation**
   - Installed `ggthemes` package
   - Created `plot_sector_time_series.R` script for reproducible graphics generation
   - Regenerated `graphics/soi_real_by_sector.pdf` (14 pages) with new palette

**Key Changes:**
- Greens now distinct: Construction (grass), Educational (lime), Health Care (teal-green)
- Blues separated: Accommodation (steel), Information (teal), Other Services (charcoal)
- Reds/Pinks spread: Manufacturing (coral), Mining (salmon), Retail (pink), Real Estate (mauve)
- Browns/Golds added: Finance (olive-gold), Wholesale (brown), Agriculture (orange)

**Verification:**
- All 14 pages render correctly
- Sector colors now visually distinguishable in legend and plot
- Script saved for reproducibility

**Files Created/Modified:**
- `plot_sector_time_series.R` (new) - Reproducible plotting script with Tableau 20
- `graphics/soi_real_by_sector.pdf` (updated) - New color scheme applied

---

### 2026-01-27, ~10:15

**Task:** Implement semantic 5-group color scheme and add group-specific advertising ratio pages.

**Phases Completed:**

1. **Defined 5 Semantic Groups**
   - Goods-Producing (4): Agriculture, Mining, Construction, Manufacturing
   - Distribution & Utilities (4): Utilities, Wholesale Trade, Retail Trade, Transportation
   - Finance & Real Estate (2): Finance & Insurance, Real Estate
   - Business Services (4): Information, Professional Services, Management of Companies, Administrative Services
   - Consumer Services (5): Educational, Health Care, Arts & Entertainment, Accommodation & Food, Other Services

2. **Created Reusable Groupings File**
   - `sector_groupings.R` defines groups, colors, and factor levels
   - Color scheme: Blues (Goods), Oranges/Browns (Distribution), Greens (FIRE), Purples (Business), Reds/Pinks (Consumer)
   - Lightness varies within each hue family for sector discrimination

3. **Updated PDF (20 pages)**
   - Pages 1-15: Original variables with new semantic group colors
   - Pages 16-20: Ad/Gross Profit ratios by group (one page per group)

**Key Observations from Group-Specific Plots:**
- Goods-Producing: Manufacturing dominates (~4%), others <1.5%
- Distribution: Retail Trade highest (~5%), Wholesale ~4%
- Finance & Real Estate: Both ~2-3%, Finance trending up
- Business Services: Management of Companies highest (~7%), high volatility
- Consumer Services: Educational Services highest but volatile (5-8%)

**Files Created/Modified:**
- `sector_groupings.R` (new) - Reusable sector group definitions and colors
- `plot_sector_time_series.R` (updated) - Uses grouped colors, adds 5 group pages
- `graphics/soi_real_by_sector.pdf` (updated) - Now 20 pages

---

### 2026-01-29, ~16:15

**Task:** Add advertising-to-net income ratio graphs to soi_real_by_sector.pdf.

**Phases Completed:**

1. **Ratio Computation**
   - Added `ad_net_income_ratio = advertising / net_income` at both sector and subsector levels
   - Net income can be negative (losses), so ratio allows negative values
   - 138 infinite ratios (zero net income) filtered out
   - 89 negative ratios retained (subsectors with net losses)

2. **Plot Function Updates**
   - Modified `plot_group_series()` to accept `allow_negative` parameter
   - Modified `plot_subsector_series()` to accept ratio variable and `allow_negative` parameters
   - Y-axis now allows negative values when `allow_negative = TRUE`
   - Added caption note explaining negative values

3. **PDF Extended (62 pages)**
   - Pages 1-15: Original sector-level variables (unchanged)
   - Page 16: Ad/Net Income ratio, all sectors (NEW)
   - Pages 17-21: Ad/Revenue ratio by group (5 pages)
   - Pages 22-39: Ad/Revenue ratio by subsector (18 pages)
   - Pages 40-44: Ad/Net Income ratio by group (5 pages, NEW)
   - Pages 45-62: Ad/Net Income ratio by subsector (18 pages, NEW)

**Verification:**
- Script executes without error
- PDF generated with 62 pages (up from 38)
- Negative ratios visible in plots where sectors have net losses

**Files Modified:**
- `plot_sector_time_series.R` - Added ad_net_income_ratio computation and plots
- `graphics/soi_real_by_sector.pdf` - Now 62 pages

---

### 2026-01-30, ~10:30

**Task:** Add net income / gross profit ratio visualization to soi_selected_time_series.pdf; move SOIdata folder to new location.

**Phases Completed:**

1. **Folder Relocation**
   - Moved entire `SOIdata/` directory from `/aaaCURRENT/SOIdata/` to `/aaaCURRENT/mgta451mktg/AdMeas/SOIdata/`
   - All R scripts use relative paths, so no code changes required

2. **New Visualization Added**
   - Computed Net Income / Gross Profit ratio for all industries combined (2014-2022)
   - Ratio = Net Income / (Business Receipts - Cost of Goods Sold)
   - Created page 16 using consistent style (Tinos font, theme_minimal, IRS source caption)
   - Merged with existing PDF using `pdfunite`

**Key Data Points (Net Income / Gross Profit, All Industries):**
- 2014: 21.0%
- 2017: 15.0% (low point, pre-TCJA)
- 2018: 29.1% (jump after Tax Cuts and Jobs Act)
- 2022: 31.2% (highest in series)

**Verification:**
- PDF page count confirmed: 16 pages (up from 15)
- Plot renders correctly with y-axis starting at 0%

**Files Modified:**
- `graphics/soi_selected_time_series.pdf` - Now 16 pages (added Net Income / Gross Profit ratio)

---

### 2026-01-30, ~11:00-12:20

**Task:** Create unified SOI graphics PDF combining aggregate and sector-level visualizations.

**Phases Completed:**

1. **Planning**
   - Created detailed implementation plan (`PLAN_unified_graphics.md`)
   - Design decisions: one script, one PDF; "All Companies Combined" as dark gray reference line on all plots; subsector breakouts by 5 groups (not 18 sectors); color + shape encoding for sectors

2. **Script Development**
   - Created `plot_soi_unified.R` - single script generating all visualizations
   - Sources `sector_groupings.R` for consistent color/shape palettes
   - Uses CPI adjustment to 2022 dollars
   - Computes 5 ratios: gross_profit_margin, ad_revenue_ratio, ad_gross_profit_ratio, ad_net_income_ratio, net_income_gross_profit_ratio

3. **Visual Structure (47 pages)**
   - Section A (pp 1-13): Level variables by sector (19 sectors + All Companies reference)
   - Section B (pp 14-17): Ratio variables by sector (Gross Profit Margin, Combined Ad Ratios, Ad/Net Income, Net Income/Gross Profit)
   - Section C (pp 18-32): Group-sector breakouts (5 groups × 3 ratios = 15 pages)
   - Section D (pp 33-47): Group-subsector breakouts (5 groups × 3 ratios = 15 pages)

4. **Outlier Handling**
   - Visual review identified extreme values in Ad/Net Income subsector plots (e.g., 22,198%, -4,419%)
   - Implemented outlier filtering: remove subsector lines where |ratio| > 500%
   - 8 subsectors removed: Audio/video equipment mfg, Apparel accessories mfg, Nonstore retailers, Book publishers, Data processing/hosting, Computer systems design, Newspaper publishers, Food services/drinking places

**Verification:**
- PDF generated with 47 pages at 17.2 MB
- All 19 sectors + "All Companies Combined" appear on sector plots
- Y-axis ranges now reasonable for Ad/Net Income subsector plots (-257% to +459%)
- Script runs end-to-end without manual intervention

**Files Created/Modified:**
- `plot_soi_unified.R` (new) - Unified plotting script
- `PLAN_unified_graphics.md` (new) - Implementation plan
- `graphics/soi_unified.pdf` (new) - 47-page unified output
- `graphics/soi_selected_time_series.pdf` (deprecated)
- `graphics/soi_real_by_sector.pdf` (deprecated)

---

### 2026-01-30, ~12:30-14:30

**Task:** Finalize unified PDF with improvements, cleanup, and full reproducibility.

**Phases Completed:**

1. **Structural Changes**
   - Separated Ad/Revenue and Ad/Gross Profit into distinct pages (previously combined)
   - Removed group-level Ad/Net Income breakouts (pages 30-49 from earlier version)
   - Added subsector breakouts by individual sector (18 sectors × 2 ratios = 36 pages)
   - Renamed output to `wilbur_2026_irs_soi_data_visualizations.pdf`

2. **Outlier Handling Refinements**
   - Page 18 (Ad/Net Income by Sector): Excluded Educational Services, Utilities, Accommodation & Food (ratios >80% or <-20%)
   - Page 19 (Net Income/Gross Profit by Sector): Excluded Finance & Insurance, Management of Companies, Mining (ratios >60% or <-10%)
   - Subsector Ad/Net Income plots: Excluded subsectors with ratios >50% or <-20%

3. **2022 Subsector Name Harmonization**
   - IRS renamed many subsectors in 2022 (e.g., "stores" → "retailers")
   - Created mapping to unify names across years (29 mappings)
   - Fixed ordering to use mean values instead of 2022-only (prevents NA in legends)

4. **Title Pages**
   - Page 1: Author, date, data source, sample, ratios computed, adjustments
   - Page 2: Omitted time series (with quantified thresholds), sector groupings, structure

5. **Appendix**
   - All R scripts included as appendix (21 pages total):
     - parse_soi.R (4 pages) - now includes download logic
     - sector_groupings.R (3 pages)
     - plot_soi_unified.R (14 pages)

6. **Directory Cleanup**
   - Removed deprecated files and intermediate outputs
   - Moved PDF to main directory (removed graphics/ subdirectory)
   - Updated CLAUDE.md with appendix requirement

**Final Output:**
- 87-page PDF: 2 title + 64 visualizations + 21 appendix
- Fully reproducible from 3 R scripts

**Verification:**
- No NA values in any plots
- All subsector time series continuous (no vertical line artifacts)
- Script runs end-to-end without manual intervention

**Files Modified:**
- `parse_soi.R` - Added download logic for IRS Excel files
- `plot_soi_unified.R` - Complete rewrite with all improvements
- `CLAUDE.md` - Added appendix requirement
- Deleted: `PLAN_unified_graphics.md`, `plot_sector_time_series.R`, `irs_soi_panel.R`, all files in `graphics/`

---

## File Structure

```
SOIdata/
├── CLAUDE.md                                        # Project instructions & style guide
├── README.md                                        # This file (session log)
├── parse_soi.R                                      # Download and parse IRS Excel files
├── sector_groupings.R                               # Sector group definitions, colors, shapes
├── plot_soi_unified.R                               # Main visualization script
├── wilbur_2026_irs_soi_data_visualizations.pdf      # 87-page output (main deliverable)
└── irs_soi_data/
    ├── 14co51ccr.xlsx ... 22co51ccr.xlsx            # Raw IRS Excel files (2014-2022)
    ├── soi_panel_long.rds/.csv                      # Long-format panel (all variables)
    └── soi_ratios.rds/.csv                          # Ratio dataset
```

## Data Sources

- IRS Statistics of Income, Corporation Income Tax Returns
- Table 5.1: Returns of Active Corporations by Minor Industry
- Publication page: https://www.irs.gov/statistics/soi-tax-stats-corporation-income-tax-returns-complete-report-publication-16
