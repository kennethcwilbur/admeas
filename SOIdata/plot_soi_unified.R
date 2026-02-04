################################################################################
# Unified SOI Graphics Script
# Generates soi_unified.pdf with sector, group, and subsector visualizations
# All plots include "All Companies Combined" dark gray reference line
################################################################################

library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(purrr)
library(stringr)
library(showtext)

################################################################################
# Configuration
################################################################################

input_file <- "irs_soi_data/soi_panel_long.rds"
output_file <- "wilbur_2026_irs_soi_data_visualizations.pdf"

source("sector_groupings.R")

# CPI adjustment factors (to 2022 dollars)
cpi <- tibble(
  year = 2014:2022,
  cpi_u = c(236.736, 237.017, 240.007, 245.120, 251.107,
            255.657, 258.811, 270.970, 292.655)
) |> mutate(deflator = cpi_u[year == 2022] / cpi_u)

# "All Companies Combined" styling
all_companies_color <- "#4D4D4D"
all_companies_shape <- 8  # asterisk
all_companies_linewidth <- 1.2
all_companies_label <- "All Companies Combined"

################################################################################
# Font setup
################################################################################

font_add_google("Tinos", "Tinos")
font_add_google("Fira Mono", "FiraMono")
showtext_auto()

################################################################################
# Load and prepare data
################################################################################

panel <- readRDS(input_file)

# All industries aggregate data
all_industries_long <- panel |>
  filter(sector == "all industries") |>
  left_join(cpi, by = "year") |>
  mutate(value_real = value * deflator)

# Sector-level data (19 sectors, exclude "all industries")
sector_data <- panel |>
  filter(is_sector_level, sector != "all industries") |>
  left_join(cpi, by = "year") |>
  mutate(value_real = value * deflator) |>
  left_join(sector_group_definitions, by = "sector") |>
  mutate(
    sector_label = factor(sector_label, levels = sector_label_levels),
    sector_group = factor(sector_group, levels = group_levels)
  )

# Subsector-level data
subsector_data <- panel |>
  filter(!is_sector_level, !is.na(subsector)) |>
  left_join(cpi, by = "year") |>
  mutate(value_real = value * deflator) |>
  left_join(sector_group_definitions, by = "sector") |>
  mutate(sector_group = factor(sector_group, levels = group_levels))

################################################################################
# Compute ratios - Sector level
################################################################################

sector_wide <- sector_data |>
  select(year, sector, sector_label, sector_group, variable, value, value_real) |>
  pivot_wider(names_from = variable, values_from = c(value, value_real))

sector_wide <- sector_wide |>
  mutate(
    gross_profit = value_business_receipts - value_cost_goods_sold,
    gross_profit_margin = gross_profit / value_business_receipts,
    ad_revenue_ratio = value_advertising / value_business_receipts,
    ad_gross_profit_ratio = value_advertising / gross_profit,
    ad_net_income_ratio = value_advertising / value_net_income,
    net_income_gross_profit_ratio = value_net_income / gross_profit
  )

sector_ratios <- sector_wide |>
  select(year, sector, sector_label, sector_group,
         gross_profit_margin, ad_revenue_ratio, ad_gross_profit_ratio,
         ad_net_income_ratio, net_income_gross_profit_ratio) |>
  pivot_longer(cols = c(gross_profit_margin, ad_revenue_ratio, ad_gross_profit_ratio,
                        ad_net_income_ratio, net_income_gross_profit_ratio),
               names_to = "variable", values_to = "value")

################################################################################
# Compute ratios - All industries
################################################################################

all_ind_wide <- all_industries_long |>
  select(year, variable, value, value_real) |>
  pivot_wider(names_from = variable, values_from = c(value, value_real))

all_ind_wide <- all_ind_wide |>
  mutate(
    gross_profit = value_business_receipts - value_cost_goods_sold,
    gross_profit_margin = gross_profit / value_business_receipts,
    ad_revenue_ratio = value_advertising / value_business_receipts,
    ad_gross_profit_ratio = value_advertising / gross_profit,
    ad_net_income_ratio = value_advertising / value_net_income,
    net_income_gross_profit_ratio = value_net_income / gross_profit
  )

all_ind_ratios <- all_ind_wide |>
  select(year, gross_profit_margin, ad_revenue_ratio, ad_gross_profit_ratio,
         ad_net_income_ratio, net_income_gross_profit_ratio) |>
  pivot_longer(cols = -year, names_to = "variable", values_to = "value")

################################################################################
# Harmonize subsector names (IRS renamed many in 2022)
################################################################################

subsector_name_map <- c(
  # Retail trade renames (stores -> retailers)
  "beer, wine, and liquor retailers" = "beer, wine, and liquor stores",
  "clothing and clothing accessories retailers" = "clothing and clothing accessories stores",
  "electronics and appliance retailers (including computers)" = "electronics and appliance stores",
  "food and beverage retailers" = "food and beverage stores",
  "furniture and home furnishings retailers" = "furniture and home furnishings stores",
  "gasoline stations and fuel dealers" = "gasoline stations",
  "general merchandise retailers" = "general merchandise stores",
  "hardware retailers" = "hardware stores",
  "health and personal care retailers" = "health and personal care stores",
  "home centers; paint and wallpaper retailers" = "home centers; paint and wallpaper stores",
  "lawn and garden equipment and supplies retailers" = "lawn and garden equipment and supplies stores",
  "sporting goods, hobby, book, music and miscellaneous retailers" = "sporting goods, hobby, book, and music stores",
  # Finance renames
  "commodity contracts intermediation" = "commodity contracts dealing and brokerage",
  "investment banking and securities intermediation" = "investment banking and securities dealing",
  "savings institutions and other depository credit intermediation" = "savings institutions, credit unions, and other depository credit intermediation",
  "life insurance (form 1120l)" = "life insurance",
  "life insurance (form 1120-l)" = "life insurance",
  "property and casualty insurance (form 1120pc)" = "property and casualty insurance",
  "property and casualty insurance (form 1120-pc)" = "property and casualty insurance",
  "other financial vehicles mortgage real estate investment trust (reits)" = "other financial vehicles (including mortgage reits)",
  "other insurance related activities (including third-party administrator of insurance, and pension funds)" = "other insurance related activities (third-party administrator of insurance, etc.)",
  "activities related to credit intermediation (including loan brokers)" = "activities related to credit intermediation (loan brokers, check clearing, etc.)",
  # Information renames
  "computing infrastructure providers, data processing, web hosting and related services" = "data processing, hosting, and related services",
  "sounds recording industries" = "sound recording industries",
  "telecommunications (including wired, wireless, satellite, cable and other program distribution, resellers, agents, other telecommunications, and internet service providers)" = "telecommunications (paging, cellular, cable, satellite, & internet service providers)",
  "telecommunications (paging, cellular, cable, satellite, & internet service providers" = "telecommunications (paging, cellular, cable, satellite, & internet service providers)",
  "web search portals, libraries, archives, and other info. services" = "other information services",
  "boradcasting & content providers (including movies, tv, radio, music and book publishers)" = "broadcasting (except internet)",
  # Manufacturing renames
  "cutlery, hardware, spring and wire, machine shops; screw, nut, and bolt" = "cutlery, hardware, spring and wire: machine shops, screw, nut, and bolt",
  "other food (including coffee, tea, flavorings, and seasonings)" = "other food",
  "apparel accessories and other apparel manufacturing" = "apparel accessories and other apparel",
  # Wholesale renames
  "wholesale trade agents and brokers" = "wholesale electronic markets and agents and brokers"
)

subsector_data <- subsector_data |>
  mutate(subsector = if_else(subsector %in% names(subsector_name_map),
                              subsector_name_map[subsector],
                              subsector))

################################################################################
# Compute ratios - Subsector level
################################################################################

subsector_wide <- subsector_data |>
  filter(variable %in% c("advertising", "business_receipts",
                         "cost_goods_sold", "net_income")) |>
  select(year, sector, subsector, sector_group, variable, value) |>
  pivot_wider(names_from = variable, values_from = value)

subsector_wide <- subsector_wide |>
  mutate(
    gross_profit = business_receipts - cost_goods_sold,
    ad_revenue_ratio = advertising / business_receipts,
    ad_gross_profit_ratio = advertising / gross_profit,
    ad_net_income_ratio = advertising / net_income
  )

################################################################################
# Theme and helper functions
################################################################################

theme_soi <- function() {
  theme_minimal(base_family = "Tinos", base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      axis.title = element_text(size = 11),
      legend.position = "bottom",
      legend.title = element_text(size = 10),
      legend.text = element_text(size = 8),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray40")
    )
}

get_scale_info <- function(values) {
  max_val <- max(values, na.rm = TRUE)
  if (max_val >= 1e12) {
    list(scale = 1e-12, suffix = "T", label = "$ Trillions")
  } else if (max_val >= 1e9) {
    list(scale = 1e-9, suffix = "B", label = "$ Billions")
  } else if (max_val >= 1e6) {
    list(scale = 1e-6, suffix = "M", label = "$ Millions")
  } else if (max_val >= 1e3) {
    list(scale = 1e-3, suffix = "K", label = "$ Thousands")
  } else {
    list(scale = 1, suffix = "", label = "$")
  }
}

################################################################################
# Extend color/shape palettes to include "All Companies Combined"
################################################################################

sector_colors_extended <- c(sector_colors,
                            setNames(all_companies_color, all_companies_label))
sector_shapes_extended <- c(sector_shapes,
                            setNames(all_companies_shape, all_companies_label))
sector_label_levels_extended <- c(sector_label_levels, all_companies_label)

################################################################################
# Plot function: Sector plot with All Companies reference line
################################################################################

plot_sector_with_all <- function(sector_df, all_df, var_name, title, y_label,
                                  definition, is_ratio = FALSE, is_count = FALSE,
                                  allow_negative = FALSE) {

  # Prepare sector data
  plot_data <- sector_df |> filter(variable == var_name)

  # Prepare all-companies data
  all_data <- all_df |>
    filter(variable == var_name) |>
    mutate(sector_label = all_companies_label)

  # Combine
  if (is_ratio) {
    combined <- bind_rows(
      plot_data |> select(year, sector_label, value),
      all_data |> select(year, sector_label, value)
    )
  } else {
    combined <- bind_rows(
      plot_data |> select(year, sector_label, value_real),
      all_data |> select(year, sector_label, value_real)
    )
  }

  combined <- combined |>
    mutate(sector_label = factor(sector_label, levels = sector_label_levels_extended))

  # Build plot
  if (is_ratio) {
    y_limits <- if (allow_negative) c(NA, NA) else c(0, NA)
    y_expand <- if (allow_negative) expansion(mult = 0.05) else expansion(mult = c(0, 0.05))

    p <- ggplot(combined, aes(x = year, y = value, color = sector_label,
                               shape = sector_label)) +
      geom_line(aes(linewidth = sector_label == all_companies_label)) +
      geom_point(size = 2) +
      scale_linewidth_manual(values = c("FALSE" = 0.8, "TRUE" = all_companies_linewidth),
                             guide = "none") +
      scale_y_continuous(labels = scales::label_percent(), limits = y_limits,
                         expand = y_expand) +
      labs(y = y_label)
  } else if (is_count) {
    scale_info <- get_scale_info(combined$value_real)
    p <- ggplot(combined, aes(x = year, y = value_real, color = sector_label,
                               shape = sector_label)) +
      geom_line(aes(linewidth = sector_label == all_companies_label)) +
      geom_point(size = 2) +
      scale_linewidth_manual(values = c("FALSE" = 0.8, "TRUE" = all_companies_linewidth),
                             guide = "none") +
      scale_y_continuous(labels = scales::label_comma(scale = scale_info$scale,
                                                       suffix = scale_info$suffix),
                         limits = c(0, NA),
                         expand = expansion(mult = c(0, 0.05))) +
      labs(y = y_label)
  } else {
    scale_info <- get_scale_info(combined$value_real)
    p <- ggplot(combined, aes(x = year, y = value_real, color = sector_label,
                               shape = sector_label)) +
      geom_line(aes(linewidth = sector_label == all_companies_label)) +
      geom_point(size = 2) +
      scale_linewidth_manual(values = c("FALSE" = 0.8, "TRUE" = all_companies_linewidth),
                             guide = "none") +
      scale_y_continuous(labels = function(x) paste0("$", x * scale_info$scale,
                                                      scale_info$suffix),
                         limits = c(0, NA),
                         expand = expansion(mult = c(0, 0.05))) +
      labs(y = paste0(y_label, " (Real 2022 $)"))
  }

  caption_text <- if (is_ratio) {
    paste0("Source: IRS Statistics of Income, Table 5.1\nRatio: ", definition)
  } else {
    paste0("Source: IRS Statistics of Income, Table 5.1 (Real 2022 dollars)\nDefinition: ", definition)
  }

  p +
    scale_x_continuous(breaks = 2014:2022, expand = expansion(add = 0.3)) +
    scale_color_manual(values = sector_colors_extended, drop = FALSE) +
    scale_shape_manual(values = sector_shapes_extended, drop = FALSE) +
    labs(
      title = title,
      x = "Year",
      color = "Sector",
      shape = "Sector",
      caption = caption_text
    ) +
    theme_soi() +
    guides(color = guide_legend(ncol = 5, byrow = FALSE),
           shape = guide_legend(ncol = 5, byrow = FALSE))
}

################################################################################
# Plot function: Combined Ad Ratios (Ad/Rev + Ad/GP on same plot)
################################################################################

plot_combined_ad_ratios <- function(sector_df, all_df, title) {

  # Prepare sector data for both ratios
  sector_long <- sector_df |>
    filter(variable %in% c("ad_revenue_ratio", "ad_gross_profit_ratio")) |>
    mutate(ratio_type = case_when(
      variable == "ad_revenue_ratio" ~ "Ad / Revenue",
      variable == "ad_gross_profit_ratio" ~ "Ad / Gross Profit"
    ))

  # Prepare all-companies data
  all_long <- all_df |>
    filter(variable %in% c("ad_revenue_ratio", "ad_gross_profit_ratio")) |>
    mutate(
      sector_label = all_companies_label,
      ratio_type = case_when(
        variable == "ad_revenue_ratio" ~ "Ad / Revenue",
        variable == "ad_gross_profit_ratio" ~ "Ad / Gross Profit"
      )
    )

  combined <- bind_rows(
    sector_long |> select(year, sector_label, value, ratio_type),
    all_long |> select(year, sector_label, value, ratio_type)
  ) |>
    mutate(sector_label = factor(sector_label, levels = sector_label_levels_extended))

  p <- ggplot(combined, aes(x = year, y = value, color = sector_label,
                             shape = sector_label)) +
    geom_line(aes(linewidth = sector_label == all_companies_label)) +
    geom_point(size = 1.5) +
    scale_linewidth_manual(values = c("FALSE" = 0.6, "TRUE" = all_companies_linewidth),
                           guide = "none") +
    scale_y_continuous(labels = scales::label_percent(),
                       limits = c(0, NA),
                       expand = expansion(mult = c(0, 0.05))) +
    scale_x_continuous(breaks = 2014:2022, expand = expansion(add = 0.3)) +
    scale_color_manual(values = sector_colors_extended, drop = FALSE) +
    scale_shape_manual(values = sector_shapes_extended, drop = FALSE) +
    facet_wrap(~ratio_type, ncol = 2) +
    labs(
      title = title,
      x = "Year",
      y = "Advertising Ratio",
      color = "Sector",
      shape = "Sector",
      caption = "Source: IRS Statistics of Income, Table 5.1"
    ) +
    theme_soi() +
    guides(color = guide_legend(ncol = 5, byrow = FALSE),
           shape = guide_legend(ncol = 5, byrow = FALSE))

  return(p)
}

################################################################################
# Plot function: Group breakout (sectors within group)
################################################################################

plot_group_sectors <- function(sector_df, all_df, group_name, var_name,
                                title, y_label, definition,
                                is_ratio = TRUE, allow_negative = FALSE) {

  # Filter to group
  plot_data <- sector_df |>
    filter(variable == var_name, sector_group == group_name)

  # Get all-companies data
  all_data <- all_df |>
    filter(variable == var_name) |>
    mutate(sector_label = all_companies_label)

  combined <- bind_rows(
    plot_data |> select(year, sector_label, value),
    all_data |> select(year, sector_label, value)
  )

  # Get group-specific colors and shapes
  group_sectors <- sector_group_definitions |>
    filter(sector_group == group_name) |>
    pull(sector_label)
  group_colors <- sector_colors[group_sectors]
  group_shapes <- sector_shapes[group_sectors]

  # Add All Companies
  group_colors <- c(group_colors, setNames(all_companies_color, all_companies_label))
  group_shapes <- c(group_shapes, setNames(all_companies_shape, all_companies_label))

  combined <- combined |>
    mutate(sector_label = factor(sector_label,
                                  levels = c(group_sectors, all_companies_label)))

  y_limits <- if (allow_negative) c(NA, NA) else c(0, NA)
  y_expand <- if (allow_negative) expansion(mult = 0.05) else expansion(mult = c(0, 0.05))

  p <- ggplot(combined, aes(x = year, y = value, color = sector_label,
                             shape = sector_label)) +
    geom_line(aes(linewidth = sector_label == all_companies_label)) +
    geom_point(size = 2.5) +
    scale_linewidth_manual(values = c("FALSE" = 1.0, "TRUE" = all_companies_linewidth),
                           guide = "none") +
    scale_y_continuous(labels = scales::label_percent(), limits = y_limits,
                       expand = y_expand) +
    scale_x_continuous(breaks = 2014:2022, expand = expansion(add = 0.3)) +
    scale_color_manual(values = group_colors) +
    scale_shape_manual(values = group_shapes) +
    labs(
      title = title,
      subtitle = paste0("Sector Group: ", group_name),
      x = "Year",
      y = y_label,
      color = "Sector",
      shape = "Sector",
      caption = paste0("Source: IRS Statistics of Income, Table 5.1\nRatio: ", definition)
    ) +
    theme_soi() +
    guides(color = guide_legend(nrow = 2, byrow = TRUE),
           shape = guide_legend(nrow = 2, byrow = TRUE))

  return(p)
}

################################################################################
# Plot function: Group breakout (subsectors within group)
################################################################################

plot_group_subsectors <- function(subsector_df, group_name, ratio_var,
                                   ratio_label, title,
                                   outlier_upper = 0.5, outlier_lower = -0.2) {  # 50%, -20%

  # Get sectors in this group
  group_sectors <- sector_group_definitions |>
    filter(sector_group == group_name) |>
    pull(sector)

  # Filter subsectors
  plot_data <- subsector_df |>
    filter(sector %in% group_sectors, is.finite(.data[[ratio_var]]))

  # For ad_net_income_ratio: remove entire subsector lines with extreme outliers
  if (grepl("net_income", ratio_var)) {
    outlier_subsectors <- plot_data |>
      filter(.data[[ratio_var]] > outlier_upper | .data[[ratio_var]] < outlier_lower) |>
      pull(subsector) |>
      unique()
    if (length(outlier_subsectors) > 0) {
      plot_data <- plot_data |>
        filter(!subsector %in% outlier_subsectors)
      message("  Removed ", length(outlier_subsectors), " subsectors with ratio > ",
              outlier_upper * 100, "% or < ", outlier_lower * 100, "% in ", group_name)
    }
  }

  if (nrow(plot_data) == 0) {
    return(NULL)
  }

  n_subsectors <- n_distinct(plot_data$subsector)

  # Dynamic color palette
  if (n_subsectors <= 12) {
    subsector_colors <- scales::hue_pal()(n_subsectors)
  } else if (n_subsectors <= 24) {
    subsector_colors <- c(scales::hue_pal()(12),
                          scales::hue_pal(h = c(0, 360) + 15)(n_subsectors - 12))
  } else {
    subsector_colors <- colorRampPalette(
      c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
        "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf")
    )(n_subsectors)
  }

  # Dynamic shape palette (cycle)
  base_shapes <- c(16, 17, 15, 18, 4, 8, 3, 7, 9, 10, 11, 12, 13, 14)
  subsector_shapes <- rep(base_shapes, length.out = n_subsectors)

  # Order by most recent available value and truncate names
  # Use mean ratio as fallback for subsectors missing the max year
  subsector_order <- plot_data |>
    group_by(subsector) |>
    summarise(order_val = mean(.data[[ratio_var]], na.rm = TRUE), .groups = "drop") |>
    arrange(desc(order_val)) |>
    pull(subsector)

  plot_data <- plot_data |>
    mutate(
      subsector_short = str_trunc(subsector, 40),
      subsector_short = factor(subsector_short,
                                levels = unique(str_trunc(subsector_order, 40)))
    )

  names(subsector_colors) <- levels(plot_data$subsector_short)
  names(subsector_shapes) <- levels(plot_data$subsector_short)

  # Legend layout
  if (n_subsectors <= 8) {
    legend_ncol <- 2
  } else if (n_subsectors <= 16) {
    legend_ncol <- 3
  } else if (n_subsectors <= 30) {
    legend_ncol <- 4
  } else {
    legend_ncol <- 5
  }

  # Allow negative for ad/net income
  allow_neg <- grepl("net_income", ratio_var)
  y_limits <- if (allow_neg) c(NA, NA) else c(0, NA)
  y_expand <- if (allow_neg) expansion(mult = 0.05) else expansion(mult = c(0, 0.05))

  p <- ggplot(plot_data, aes(x = year, y = .data[[ratio_var]],
                              color = subsector_short, shape = subsector_short)) +
    geom_line(linewidth = 0.6) +
    geom_point(size = 1.5) +
    scale_y_continuous(labels = scales::label_percent(), limits = y_limits,
                       expand = y_expand) +
    scale_x_continuous(breaks = 2014:2022, expand = expansion(add = 0.3)) +
    scale_color_manual(values = subsector_colors) +
    scale_shape_manual(values = subsector_shapes) +
    labs(
      title = title,
      subtitle = paste0("Sector Group: ", group_name, " (", n_subsectors, " subsectors)"),
      x = "Year",
      y = ratio_label,
      color = "Subsector",
      shape = "Subsector",
      caption = paste0("Source: IRS Statistics of Income, Table 5.1\nRatio: ", ratio_label,
                       "\nOrdered by 2022 value")
    ) +
    theme_soi() +
    theme(legend.text = element_text(size = 6)) +
    guides(color = guide_legend(ncol = legend_ncol),
           shape = guide_legend(ncol = legend_ncol))

  return(p)
}

################################################################################
# Generate Title Pages (Pages 1-2)
################################################################################

message("Generating title pages...")

# Page 1: Title and basic info
title_text_p1 <- paste0(
"Author: Kenneth C. Wilbur, UC San Diego
Date: February 2026

DATA SOURCE
- IRS Statistics of Income, Corporation Income Tax Returns
- Table 5.1: Returns of Active Corporations by Minor Industry
- Years: 2014-2022 (9 years)

SAMPLE
- Active U.S. Corporations (C corps, S corps, REITs, RICs)
- 19 sector-level industries
- 187 subsector-level industries

RATIOS COMPUTED
- Advertising / Revenue = Advertising Deductions / Business Receipts
- Advertising / Gross Profit = Advertising / (Revenue - Cost of Goods Sold)
- Advertising / Net Income = Advertising / Net Income (less credits)
- Net Income / Gross Profit = Net Income / (Revenue - Cost of Goods Sold)
- Gross Profit Margin = (Revenue - Cost of Goods Sold) / Revenue

ADJUSTMENTS
- Dollar values adjusted to real 2022 dollars using CPI-U
- CPI-U values: 236.7 (2014) to 292.7 (2022)"
)

p_title_1 <- ggplot() +
  annotate("text", x = 0.5, y = 0.95, label = "IRS Statistics of Income Data Visualizations",
           size = 7, fontface = "bold", family = "Tinos", hjust = 0.5, vjust = 1) +
  annotate("text", x = 0.05, y = 0.82, label = title_text_p1,
           size = 3.5, family = "Tinos", hjust = 0, vjust = 1, lineheight = 1.2) +
  xlim(0, 1) + ylim(0, 1) +
  theme_void() +
  theme(plot.margin = margin(20, 20, 20, 20))

# Page 2: Omissions, groupings, and structure
title_text_p2 <- paste0(
"OMITTED TIME SERIES
- Page 18 (Advertising/Net Income by Sector): Excludes Educational Services,
  Utilities, Accommodation & Food (ratios exceeded 80% or fell below -20%)
- Page 19 (Net Income/Gross Profit by Sector): Excludes Finance & Insurance,
  Management of Companies, Mining (ratios exceeded 60% or fell below -10%)

SECTOR GROUPINGS
- Goods-Producing: Agriculture, Mining, Construction, Manufacturing
- Distribution & Utilities: Utilities, Wholesale, Retail, Transportation
- Finance & Real Estate: Finance & Insurance, Real Estate
- Business Services: Information, Professional Services, Management, Administrative
- Consumer Services: Educational, Health Care, Arts, Accommodation & Food, Other

STRUCTURE
- Pages 3-15: Level variables by sector (13 pages)
- Pages 16-20: Ratio variables by sector (5 pages)
- Pages 21-30: Group-sector breakouts (10 pages)
- Pages 31-48: Subsector Ad/Revenue by sector (18 pages)
- Pages 49-66: Subsector Ad/Gross Profit by sector (18 pages)

Prepared quickly using Claude Code. Accuracy is not ensured. R scripts are
included as appendices to enable replication. Please contact the author
in case any error is found."
)

p_title_2 <- ggplot() +
  annotate("text", x = 0.5, y = 0.95, label = "IRS Statistics of Income Data Visualizations (continued)",
           size = 6, fontface = "bold", family = "Tinos", hjust = 0.5, vjust = 1) +
  annotate("text", x = 0.05, y = 0.85, label = title_text_p2,
           size = 3.5, family = "Tinos", hjust = 0, vjust = 1, lineheight = 1.2) +
  xlim(0, 1) + ylim(0, 1) +
  theme_void() +
  theme(plot.margin = margin(20, 20, 20, 20))

################################################################################
# Generate Section A: Level Variables (13 pages)
################################################################################

message("Generating Section A: Level variables...")

level_vars <- list(
  list(var = "n_returns", title = "Number of Tax Returns by Sector",
       y_label = "Number of Returns", def = "Count of corporate tax returns",
       is_count = TRUE),
  list(var = "business_receipts", title = "Total Revenue by Sector",
       y_label = "Revenue", def = "Gross receipts from sales"),
  list(var = "cost_goods_sold", title = "Cost of Goods Sold by Sector",
       y_label = "COGS", def = "Direct costs of producing goods/services"),
  list(var = "total_deductions", title = "Total Deductions by Sector",
       y_label = "Deductions", def = "All expenses claimed against income"),
  list(var = "salaries_wages", title = "Salaries and Wages by Sector",
       y_label = "Salaries & Wages", def = "Compensation to non-officer employees"),
  list(var = "compensation_officers", title = "Compensation of Officers by Sector",
       y_label = "Officer Compensation", def = "Compensation to corporate officers"),
  list(var = "advertising", title = "Advertising Deductions by Sector",
       y_label = "Advertising", def = "Advertising and promotion expenses"),
  list(var = "depreciation", title = "Depreciation by Sector",
       y_label = "Depreciation", def = "Decline in value of tangible assets"),
  list(var = "interest_paid", title = "Interest Paid by Sector",
       y_label = "Interest Paid", def = "Interest expenses on business debt"),
  list(var = "net_income", title = "Net Income by Sector",
       y_label = "Net Income", def = "Receipts minus deductions"),
  list(var = "income_tax_after_credits", title = "Income Tax After Credits by Sector",
       y_label = "Income Tax", def = "Tax liability after credits"),
  list(var = "total_assets", title = "Total Assets by Sector",
       y_label = "Total Assets", def = "Sum of all corporate assets"),
  list(var = "total_liabilities", title = "Total Liabilities by Sector",
       y_label = "Total Liabilities", def = "Sum of all corporate liabilities")
)

section_a_plots <- map(level_vars, function(v) {
  is_count <- isTRUE(v$is_count)
  plot_sector_with_all(
    sector_data, all_industries_long, v$var,
    paste0(v$title, ", Active U.S. Corporations"),
    v$y_label, v$def, is_ratio = FALSE, is_count = is_count
  )
})

################################################################################
# Generate Section B: Ratio Variables (5 pages)
################################################################################

message("Generating Section B: Ratio variables...")

# Page 14: Gross Profit Margin
p_gpm <- plot_sector_with_all(
  sector_ratios, all_ind_ratios, "gross_profit_margin",
  "Gross Profit Margin by Sector, Active U.S. Corporations",
  "Gross Profit Margin", "(Revenue - COGS) / Revenue", is_ratio = TRUE
)

# Page 15: Ad / Revenue
p_ad_rev <- plot_sector_with_all(
  sector_ratios, all_ind_ratios, "ad_revenue_ratio",
  "Advertising / Revenue by Sector, Active U.S. Corporations",
  "Advertising / Revenue", "Advertising / Revenue",
  is_ratio = TRUE
)

# Page 16: Ad / Gross Profit
p_ad_gp <- plot_sector_with_all(
  sector_ratios, all_ind_ratios, "ad_gross_profit_ratio",
  "Advertising / Gross Profit by Sector, Active U.S. Corporations",
  "Advertising / Gross Profit", "Advertising / Gross Profit",
  is_ratio = TRUE
)

# Save high-resolution PNG for teaching slides
ggsave("../AMimages/ad_gross_profit_by_sector.png", p_ad_gp,
       width = 12, height = 8, dpi = 300, bg = "white")
message("Saved ../AMimages/ad_gross_profit_by_sector.png")

# Page 17: Ad / Net Income (exclude outlier sectors)
ad_ni_excluded_sectors <- c("Educational Services", "Utilities", "Accommodation & Food")
sector_ratios_ad_ni <- sector_ratios |>
  filter(!sector_label %in% ad_ni_excluded_sectors)
p_ad_ni <- plot_sector_with_all(
  sector_ratios_ad_ni, all_ind_ratios, "ad_net_income_ratio",
  "Advertising / Net Income by Sector, Active U.S. Corporations",
  "Advertising / Net Income", "Advertising / Net Income",
  is_ratio = TRUE, allow_negative = TRUE
)

# Page 18: Net Income / Gross Profit (exclude outlier sectors)
ni_gp_excluded_sectors <- c("Finance & Insurance", "Management of Companies", "Mining")
sector_ratios_ni_gp <- sector_ratios |>
  filter(!sector_label %in% ni_gp_excluded_sectors)
p_ni_gp <- plot_sector_with_all(
  sector_ratios_ni_gp, all_ind_ratios, "net_income_gross_profit_ratio",
  "Net Income / Gross Profit by Sector, Active U.S. Corporations",
  "Net Income / Gross Profit", "Net Income / Gross Profit",
  is_ratio = TRUE, allow_negative = TRUE
)

section_b_plots <- list(p_gpm, p_ad_rev, p_ad_gp, p_ad_ni, p_ni_gp)

################################################################################
# Generate Section C: Group Breakouts - Sectors (10 pages)
################################################################################

message("Generating Section C: Group-sector breakouts...")

ratio_configs_c <- list(
  list(var = "ad_revenue_ratio", label = "Advertising / Revenue",
       title_prefix = "Ad/Revenue Ratio", allow_neg = FALSE),
  list(var = "ad_gross_profit_ratio", label = "Advertising / Gross Profit",
       title_prefix = "Ad/Gross Profit Ratio", allow_neg = FALSE)
)

section_c_plots <- list()
for (rc in ratio_configs_c) {
  for (grp in group_levels) {
    p <- plot_group_sectors(
      sector_ratios, all_ind_ratios, grp, rc$var,
      paste0(rc$title_prefix, ": ", grp),
      rc$label, rc$label, allow_negative = rc$allow_neg
    )
    section_c_plots <- c(section_c_plots, list(p))
  }
}

################################################################################
# Plot function: Subsectors within a single sector
################################################################################

plot_sector_subsectors <- function(subsector_df, sector_name, ratio_var,
                                    ratio_label, title) {

  # Filter to subsectors of this sector
  plot_data <- subsector_df |>
    filter(sector == sector_name, is.finite(.data[[ratio_var]]))

  if (nrow(plot_data) == 0) {
    return(NULL)
  }

  n_subsectors <- n_distinct(plot_data$subsector)

  # Dynamic color palette
  if (n_subsectors <= 12) {
    subsector_colors <- scales::hue_pal()(n_subsectors)
  } else if (n_subsectors <= 24) {
    subsector_colors <- c(scales::hue_pal()(12),
                          scales::hue_pal(h = c(0, 360) + 15)(n_subsectors - 12))
  } else {
    subsector_colors <- colorRampPalette(
      c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
        "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf")
    )(n_subsectors)
  }

  # Dynamic shape palette (cycle)
  base_shapes <- c(16, 17, 15, 18, 4, 8, 3, 7, 9, 10, 11, 12, 13, 14)
  subsector_shapes <- rep(base_shapes, length.out = n_subsectors)

  # Order by most recent available value and truncate names
  # Use mean ratio as fallback for subsectors missing the max year
  subsector_order <- plot_data |>
    group_by(subsector) |>
    summarise(order_val = mean(.data[[ratio_var]], na.rm = TRUE), .groups = "drop") |>
    arrange(desc(order_val)) |>
    pull(subsector)

  plot_data <- plot_data |>
    mutate(
      subsector_short = str_trunc(subsector, 40),
      subsector_short = factor(subsector_short,
                                levels = unique(str_trunc(subsector_order, 40)))
    )

  names(subsector_colors) <- levels(plot_data$subsector_short)
  names(subsector_shapes) <- levels(plot_data$subsector_short)

  # Legend layout
  if (n_subsectors <= 8) {
    legend_ncol <- 2
  } else if (n_subsectors <= 16) {
    legend_ncol <- 3
  } else if (n_subsectors <= 30) {
    legend_ncol <- 4
  } else {
    legend_ncol <- 5
  }

  p <- ggplot(plot_data, aes(x = year, y = .data[[ratio_var]],
                              color = subsector_short, shape = subsector_short)) +
    geom_line(linewidth = 0.6) +
    geom_point(size = 1.5) +
    scale_y_continuous(labels = scales::label_percent(),
                       limits = c(0, NA),
                       expand = expansion(mult = c(0, 0.05))) +
    scale_x_continuous(breaks = 2014:2022, expand = expansion(add = 0.3)) +
    scale_color_manual(values = subsector_colors) +
    scale_shape_manual(values = subsector_shapes) +
    labs(
      title = title,
      subtitle = paste0(n_subsectors, " subsectors"),
      x = "Year",
      y = ratio_label,
      color = "Subsector",
      shape = "Subsector",
      caption = paste0("Source: IRS Statistics of Income, Table 5.1\n",
                       "Ordered by 2022 value")
    ) +
    theme_soi() +
    theme(legend.text = element_text(size = 6)) +
    guides(color = guide_legend(ncol = legend_ncol),
           shape = guide_legend(ncol = legend_ncol))

  return(p)
}

################################################################################
# Generate Section D: Subsector Breakouts by Sector
################################################################################

message("Generating Section D: Subsector breakouts by sector...")

# Get list of sectors that have subsectors
sectors_with_subsectors <- subsector_wide |>
  filter(!is.na(subsector)) |>
  distinct(sector) |>
  pull(sector)

# Generate Ad/Revenue plots for all sectors
section_d_ad_rev <- list()
for (sec in sectors_with_subsectors) {
  sec_label <- sector_group_definitions |>
    filter(sector == sec) |>
    pull(sector_label)
  p <- plot_sector_subsectors(
    subsector_wide, sec, "ad_revenue_ratio",
    "Advertising / Revenue",
    paste0("Ad/Revenue: ", sec_label)
  )
  if (!is.null(p)) {
    section_d_ad_rev <- c(section_d_ad_rev, list(p))
  }
}

# Generate Ad/Gross Profit plots for all sectors
section_d_ad_gp <- list()
for (sec in sectors_with_subsectors) {
  sec_label <- sector_group_definitions |>
    filter(sector == sec) |>
    pull(sector_label)
  p <- plot_sector_subsectors(
    subsector_wide, sec, "ad_gross_profit_ratio",
    "Advertising / Gross Profit",
    paste0("Ad/Gross Profit: ", sec_label)
  )
  if (!is.null(p)) {
    section_d_ad_gp <- c(section_d_ad_gp, list(p))
  }
}

section_d_plots <- c(section_d_ad_rev, section_d_ad_gp)
message("  Generated ", length(section_d_plots), " subsector-by-sector plots")

################################################################################
# Generate Appendix: All R Scripts
################################################################################

message("Generating appendix (all R scripts)...")

# Scripts to include in order of execution
script_files <- c(
  "parse_soi.R",           # 1. Download and parse data
  "sector_groupings.R",    # 2. Define sector groups, colors, shapes
  "plot_soi_unified.R"     # 3. Generate visualizations
)

lines_per_page <- 70  # Approximate lines per page with small font
appendix_plots <- list()
global_page <- 0

for (script_file in script_files) {
  script_lines <- readLines(script_file)
  n_pages <- ceiling(length(script_lines) / lines_per_page)

  for (i in seq_len(n_pages)) {
    global_page <- global_page + 1
    start_line <- (i - 1) * lines_per_page + 1
    end_line <- min(i * lines_per_page, length(script_lines))
    page_lines <- script_lines[start_line:end_line]
    page_text <- paste(page_lines, collapse = "\n")

    p <- ggplot() +
      annotate("text", x = 0, y = 1, label = page_text,
               size = 2, family = "FiraMono", hjust = 0, vjust = 1) +
      xlim(-0.02, 1) + ylim(0, 1.02) +
      labs(title = paste0("Appendix: ", script_file, " (Page ", i, " of ", n_pages, ")")) +
      theme_void() +
      theme(
        plot.title = element_text(size = 10, face = "bold", family = "Tinos"),
        plot.margin = margin(10, 10, 10, 10)
      )

    appendix_plots <- c(appendix_plots, list(p))
  }
  message("  ", script_file, ": ", n_pages, " pages")
}

message("  Total appendix pages: ", length(appendix_plots))

################################################################################
# Combine all plots
################################################################################

all_plots <- c(list(p_title_1, p_title_2), section_a_plots, section_b_plots, section_c_plots, section_d_plots, appendix_plots)
message("Total plots: ", length(all_plots))

################################################################################
# Save to PDF
################################################################################

message("Saving to PDF...")

pdf(output_file, width = 11, height = 8.5)
walk(seq_along(all_plots), function(i) {
  p <- all_plots[[i]]
  if (!is.null(p)) {
    p <- p + labs(caption = paste0(p$labels$caption, "\nPage ", i, " of ", length(all_plots)))
    print(p)
  }
})
dev.off()

message("Saved ", length(all_plots), " pages to ", output_file)
