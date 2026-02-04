# SOIdata Project

## Purpose
Construct advertising ratio data from IRS Statistics of Income (SOI) Corporation Income Tax Returns (Table 5.1) for:
1. Teaching slide visualization (MGTA 451, replacing SAI Books graphic)
2. Downstream research on advertising intensity variation across industries and time

## Data Source
- IRS SOI Table 5.1: Returns of Active Corporations by Minor Industry
- Years available: 2014-2022 (current Excel format)
- URL pattern: `https://www.irs.gov/pub/irs-soi/{YY}co51ccr.xlsx`
- Official IRS publication page: https://www.irs.gov/statistics/soi-tax-stats-corporation-income-tax-returns-complete-report-publication-16

## Ratios Computed
- `ad_revenue_ratio` = Advertising / Business Receipts
- `ad_gross_profit_ratio` = Advertising / (Revenue - Cost of Goods Sold)
- `ad_net_income_ratio` = Advertising / Net Income
- `net_income_gross_profit_ratio` = Net Income / (Revenue - Cost of Goods Sold)
- `gross_profit_margin` = (Revenue - Cost of Goods Sold) / Revenue

## Workflow (3 Scripts)
Run in this order:
1. `parse_soi.R` - Download Excel files from IRS and parse into long-format panel
2. `sector_groupings.R` - Define 5 sector groups, colors, and shapes (sourced by plot script)
3. `plot_soi_unified.R` - Generate 87-page PDF with all visualizations

## Visualization Style Guide
- Font: Tinos (Times New Roman equivalent on Chrome OS)
- Theme: `theme_minimal()` with no minor gridlines
- X-axis: Years 2014-2022, all labeled, with `expansion(add = 0.3)` to prevent point cropping
- Y-axis for dollar values: Start from $0; use trillions ($T) if minimum > $1T, else billions ($B)
- Y-axis for ratios: Start from 0%, format as percentages
- Titles: Bold, format "[Variable], Active U.S. Corporations"
- Caption: "Source: IRS Statistics of Income, Table 5.1"
- Sector encoding: Color by group + shape by sector within group
- "All Companies Combined" reference line: Dark gray (#4D4D4D), thicker line

## Outlier Handling
Certain time series are excluded from specific plots to maintain readable scales:
- **Ad/Net Income by Sector (Page 18):** Excludes Educational Services, Utilities, Accommodation & Food (ratios >80% or <-20%)
- **Net Income/Gross Profit by Sector (Page 19):** Excludes Finance & Insurance, Management of Companies, Mining (ratios >60% or <-10%)
- **Ad/Net Income by Subsector (Pages 45-48):** Excludes subsectors with ratios >50% or <-20%

## 2022 Subsector Name Harmonization
IRS renamed many subsectors in 2022 (e.g., "stores" → "retailers"). The script includes a mapping of 29 name changes to ensure continuous time series. See `subsector_name_map` in `plot_soi_unified.R`.

## PDF Appendix Requirement
**IMPORTANT:** When generating the visualization PDF, ALWAYS include ALL R scripts as appendices at the end of the PDF, in execution order:
1. `parse_soi.R` - Download and parse data
2. `sector_groupings.R` - Define sector groups and colors
3. `plot_soi_unified.R` - Generate visualizations

This ensures full reproducibility by including the exact code used to generate the visualizations within the document itself.

## Output Files
- `irs_soi_data/` - Downloaded Excel files (14co51ccr.xlsx through 22co51ccr.xlsx)
- `irs_soi_data/soi_panel_long.rds/.csv` - Long-format panel (241 industries × 67 variables × 9 years)
- `irs_soi_data/soi_ratios.rds/.csv` - Computed advertising ratios
- `wilbur_2026_irs_soi_data_visualizations.pdf` - 87-page output (2 title + 64 visualizations + 21 appendix)

## Technical Notes
- R with tidyverse conventions
- Use base pipe `|>`
- Verify code runs without error before reporting completion
- CPI adjustment to 2022 dollars using CPI-U values
