################################################################################
# Sector Groupings and Color Scheme
# Defines 5 semantic groups for NAICS 2-digit sectors with consistent colors
# Source this file for reuse across scripts
################################################################################

library(tibble)

################################################################################
# 5-Group Semantic Categorization
################################################################################

sector_group_definitions <- tribble(

  ~sector, ~sector_label, ~sector_group, ~group_order,
  # Group 1: Goods-Producing (Blues)
 "agriculture, forestry, fishing, and hunting", "Agriculture", "Goods-Producing", 1,
 "mining", "Mining", "Goods-Producing", 1,
 "construction", "Construction", "Goods-Producing", 1,
 "manufacturing", "Manufacturing", "Goods-Producing", 1,
  # Group 2: Distribution & Utilities (Oranges/Browns)
 "utilities", "Utilities", "Distribution & Utilities", 2,
 "wholesale trade", "Wholesale Trade", "Distribution & Utilities", 2,
 "retail trade", "Retail Trade", "Distribution & Utilities", 2,
 "transportation and warehousing", "Transportation", "Distribution & Utilities", 2,
  # Group 3: Finance & Real Estate (Greens)
 "finance and insurance", "Finance & Insurance", "Finance & Real Estate", 3,
 "real estate and rental and leasing", "Real Estate", "Finance & Real Estate", 3,
  # Group 4: Business Services (Purples)
 "information", "Information", "Business Services", 4,
 "professional, scientific, and technical services", "Professional Services", "Business Services", 4,
 "management of companies (holding companies)", "Management of Companies", "Business Services", 4,
 "administrative and support and waste management and remediation services", "Administrative Services", "Business Services", 4,
  # Group 5: Consumer Services (Reds/Pinks)
 "educational services", "Educational Services", "Consumer Services", 5,
 "health care and social assistance", "Health Care", "Consumer Services", 5,
 "arts, entertainment, and recreation", "Arts & Entertainment", "Consumer Services", 5,
 "accommodation and food services", "Accommodation & Food", "Consumer Services", 5,
 "other services", "Other Services", "Consumer Services", 5
)

################################################################################
# Color Palette by Group (19 colors total)
# Each group uses a hue family with lightness/saturation variation
################################################################################

sector_colors <- c(
  # Goods-Producing: Blues (4 sectors)
  "Agriculture" = "#08519C",
  "Mining" = "#3182BD",
  "Construction" = "#6BAED6",
  "Manufacturing" = "#9ECAE1",
  # Distribution & Utilities: Oranges/Browns (4 sectors)
  "Utilities" = "#8C510A",
  "Wholesale Trade" = "#BF812D",
  "Retail Trade" = "#DFC27D",
  "Transportation" = "#F6E8C3",
  # Finance & Real Estate: Greens (2 sectors)
  "Finance & Insurance" = "#1B7837",
  "Real Estate" = "#7FBC41",
  # Business Services: Purples (4 sectors)
  "Information" = "#6A3D9A",
  "Professional Services" = "#9E7BB5",
  "Management of Companies" = "#CAB2D6",
  "Administrative Services" = "#E7D4E8",
  # Consumer Services: Reds/Pinks (5 sectors)
  "Educational Services" = "#99000D",
  "Health Care" = "#CB181D",
  "Arts & Entertainment" = "#EF3B2C",
  "Accommodation & Food" = "#FB6A4A",
  "Other Services" = "#FCBBA1"
)

################################################################################
# Point Shapes by Sector (varies within each group for distinguishability)
# Shapes: 16=circle, 17=triangle, 15=square, 18=diamond, 4=cross
################################################################################

sector_shapes <- c(
  # Goods-Producing (4 sectors)
  "Agriculture" = 16,
  "Mining" = 17,
  "Construction" = 15,
  "Manufacturing" = 18,
  # Distribution & Utilities (4 sectors)
  "Utilities" = 16,
  "Wholesale Trade" = 17,
  "Retail Trade" = 15,
  "Transportation" = 18,
  # Finance & Real Estate (2 sectors)
  "Finance & Insurance" = 16,
  "Real Estate" = 17,
  # Business Services (4 sectors)
  "Information" = 16,
  "Professional Services" = 17,
  "Management of Companies" = 15,
  "Administrative Services" = 18,
  # Consumer Services (5 sectors)
  "Educational Services" = 16,
  "Health Care" = 17,
  "Arts & Entertainment" = 15,
  "Accommodation & Food" = 18,
  "Other Services" = 4
)

################################################################################
# Group-level colors (for group summary plots)
################################################################################

group_colors <- c(
 "Goods-Producing" = "#3182BD",
 "Distribution & Utilities" = "#BF812D",
  "Finance & Real Estate" = "#1B7837",
  "Business Services" = "#7B68EE",
  "Consumer Services" = "#CB181D"
)

################################################################################
# Ordered factor levels
################################################################################

group_levels <- c(
 "Goods-Producing",
 "Distribution & Utilities",
 "Finance & Real Estate",
  "Business Services",
  "Consumer Services"
)

# Sector labels ordered by group, then within group
sector_label_levels <- c(
  # Goods-Producing
  "Agriculture", "Mining", "Construction", "Manufacturing",
  # Distribution & Utilities
  "Utilities", "Wholesale Trade", "Retail Trade", "Transportation",
  # Finance & Real Estate
  "Finance & Insurance", "Real Estate",
  # Business Services
  "Information", "Professional Services", "Management of Companies", "Administrative Services",
  # Consumer Services
  "Educational Services", "Health Care", "Arts & Entertainment", "Accommodation & Food", "Other Services"
)
