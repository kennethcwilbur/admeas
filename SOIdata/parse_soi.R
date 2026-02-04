################################################################################
# IRS SOI Table 5.1 Downloader and Parser
# Downloads Excel files from IRS website and parses into long-format panel data
################################################################################

library(tidyverse)
library(readxl)

# Configuration
input_dir <- "irs_soi_data"
years <- 2014:2022
base_url <- "https://www.irs.gov/pub/irs-soi"

################################################################################
# Step 0: Download Excel files from IRS
################################################################################

download_soi_files <- function(years, input_dir, base_url) {
  if (!dir.exists(input_dir)) {
    dir.create(input_dir, recursive = TRUE)
  }

  for (yr in years) {
    yr_short <- str_sub(as.character(yr), 3, 4)
    filename <- str_glue("{yr_short}co51ccr.xlsx")
    filepath <- file.path(input_dir, filename)

    if (file.exists(filepath)) {
      message(str_glue("  {filename} already exists, skipping"))
      next
    }

    url <- str_glue("{base_url}/{filename}")
    message(str_glue("  Downloading {filename}..."))

    tryCatch({
      download.file(url, filepath, mode = "wb", quiet = TRUE)
      message(str_glue("    Downloaded successfully"))
    }, error = function(e) {
      message(str_glue("    ERROR: {e$message}"))
    })
  }
}

message("=== Downloading IRS SOI Table 5.1 Files ===\n")
download_soi_files(years, input_dir, base_url)

################################################################################
# Step 1: Detect header row positions
################################################################################

detect_header_rows <- function(raw) {
  item_row <- which(as.character(raw[[1]]) == "Item")[1]
  if (item_row == 4) {
    list(sector_row = 4, subsector_row = 5)
  } else {
    list(sector_row = 5, subsector_row = 6)
  }
}

################################################################################
# Step 2: Build column map (industry metadata)
################################################################################

build_column_map <- function(raw, header_rows) {
  r_sector <- as.character(raw[header_rows$sector_row, ])
  r_subsector <- as.character(raw[header_rows$subsector_row, ])

  tibble(
    col_idx = seq_along(r_sector),
    sector_raw = r_sector,
    subsector_raw = r_subsector
  ) |>
    filter(col_idx > 1) |>
    fill(sector_raw, .direction = "down") |>
    mutate(
      sector = sector_raw |>
        str_replace_all("[\r\n]+", " ") |>
        str_squish() |>
        str_to_lower(),
      subsector = subsector_raw |>
        str_replace_all("[\r\n]+", " ") |>
        str_squish() |>
        str_to_lower(),
      is_sector_level = (subsector == "total" | is.na(subsector_raw)),
      industry_name = if_else(is_sector_level, sector, subsector),
      industry_id = paste(sector, if_else(is_sector_level, "_total", subsector), sep = "|") |>
        str_replace_all("[^a-z0-9|_]", "_") |>
        str_replace_all("_+", "_")
    )
}

################################################################################
# Step 3: Detect data row positions by regex matching
################################################################################

detect_variable_rows <- function(raw) {
  labels <- as.character(raw[[1]])

  # Define patterns for all variables we want to extract
  patterns <- c(
    n_returns = "^number of returns$",
    total_assets = "^total assets$",
    cash = "^cash$",
    trade_receivables = "^trade notes and accounts receivable$",
    allowance_bad_debts = "^less:.*allowance for bad debts$",
    inventories = "^inventories$",
    us_govt_obligations = "^u\\.?s\\.? government obligations$",
    tax_exempt_securities = "^tax-exempt securities$",
    other_current_assets = "^other current assets$",
    loans_to_shareholders = "^loans to shareholders$",
    mortgage_real_estate_loans = "^mortgage and real estate loans$",
    other_investments = "^other investments$",
    depreciable_assets = "^depreciable assets$",
    accum_depreciation = "^less:.*accumulated depreciation$",
    depletable_assets = "^depletable assets$",
    accum_depletion = "^less:.*accumulated depletion$",
    land = "^land$",
    intangible_assets = "^intangible assets",
    accum_amortization = "^less:.*accumulated amortization$",
    other_assets = "^other assets$",
    total_liabilities = "^total liabilities$",
    accounts_payable = "^accounts payable$",
    short_term_debt = "^mortgages.*less than 1 year$",
    other_current_liab = "^other current liabilities$",
    loans_from_shareholders = "^loans from shareholders$",
    long_term_debt = "^mortgages.*1 year or more$",
    other_liabilities = "^other liabilities$",
    net_worth = "^net worth.*total$",
    capital_stock = "^capital stock$",
    paid_in_capital = "^additional paid-in capital$",
    retained_earnings_approp = "^retained earnings.*appropriated$",
    retained_earnings_unapprop = "^retained earnings.*unappropriated$",
    treasury_stock = "^less:.*treasury stock$",
    total_receipts = "^total receipts$",
    business_receipts = "^business receipts$",
    dividends_received = "^dividends$",
    interest_received = "^interest$",
    gross_rents = "^gross rents$",
    gross_royalties = "^gross royalties$",
    net_st_capital_gain = "^net short-term capital gain",
    net_lt_capital_gain = "^net long-term capital gain",
    net_gain_noncapital = "^net gain.*noncapital assets$",
    tax_exempt_interest = "^tax-exempt interest$",
    other_receipts = "^other receipts$",
    total_deductions = "^total deductions",
    cost_goods_sold = "^cost of goods sold",
    compensation_officers = "^compensation of officers$",
    salaries_wages = "^salaries and wages$",
    repairs = "^repairs",
    bad_debts = "^bad debts$",
    rents_paid = "^rents paid$",
    taxes_licenses = "^taxes and licenses$",
    interest_paid = "^interest paid$",
    charitable_contributions = "^charitable contributions$",
    amortization = "^amortization$",
    depreciation = "^depreciation$",
    depletion = "^depletion$",
    advertising = "^advertising$",
    pension_plans = "^pension.*profit.sharing",
    employee_benefits = "^employee benefit programs$",
    net_loss_noncapital = "^net loss.*noncapital assets$",
    other_deductions = "^other deductions$",
    receipts_less_deductions = "^total receipts less total deductions$",
    net_income = "^net income.*less deficit",
    income_subject_to_tax = "^income subject to tax$",
    income_tax_before_credits = "^total income tax before credits$",
    income_tax_after_credits = "^total income tax after credits$"
  )

  # Find row for each pattern
  row_map <- map_int(patterns, function(pat) {
    idx <- str_which(labels, regex(pat, ignore_case = TRUE))
    if (length(idx) == 0) NA_integer_ else idx[1]
  })

  row_map
}

################################################################################
# Step 4: Extract data into long format
################################################################################

extract_data_long <- function(raw, column_map, variable_rows, year) {
  # For each variable and each industry column, extract the value
  map_dfr(names(variable_rows), function(var_name) {
    row_idx <- variable_rows[[var_name]]
    if (is.na(row_idx)) return(tibble())

    map_dfr(seq_len(nrow(column_map)), function(i) {
      col_idx <- column_map$col_idx[i]
      val <- raw[[col_idx]][row_idx]

      tibble(
        year = year,
        sector = column_map$sector[i],
        subsector = column_map$subsector[i],
        is_sector_level = column_map$is_sector_level[i],
        industry_name = column_map$industry_name[i],
        industry_id = column_map$industry_id[i],
        variable = var_name,
        value = as.numeric(val)
      )
    })
  })
}

################################################################################
# Step 5: Parse single file
################################################################################

parse_soi_file <- function(filepath, year) {
  message(str_glue("Parsing {year}..."))

  raw <- read_excel(filepath, col_names = FALSE, .name_repair = "minimal")
  header_rows <- detect_header_rows(raw)
  column_map <- build_column_map(raw, header_rows)
  variable_rows <- detect_variable_rows(raw)

  # Report any missing variables
  missing_vars <- names(variable_rows)[is.na(variable_rows)]
  if (length(missing_vars) > 0) {
    message(str_glue("  Warning: Could not find rows for: {paste(missing_vars, collapse = ', ')}"))
  }

  extract_data_long(raw, column_map, variable_rows, year)
}

################################################################################
# Step 6: Parse all files
################################################################################

parse_all_files <- function(years, input_dir) {
  map_dfr(years, function(yr) {
    yr_short <- str_sub(as.character(yr), 3, 4)
    filepath <- file.path(input_dir, str_glue("{yr_short}co51ccr.xlsx"))

    if (!file.exists(filepath)) {
      message(str_glue("File not found: {filepath}"))
      return(tibble())
    }

    tryCatch(
      parse_soi_file(filepath, yr),
      error = function(e) {
        message(str_glue("Error parsing {yr}: {e$message}"))
        tibble()
      }
    )
  })
}

################################################################################
# Main execution
################################################################################

message("=== Parsing IRS SOI Table 5.1 Files ===\n")

panel_long <- parse_all_files(years, input_dir)

message(str_glue("\n=== Parsing Complete ==="))
message(str_glue("Total observations: {nrow(panel_long)}"))
message(str_glue("Years: {min(panel_long$year)}-{max(panel_long$year)}"))
message(str_glue("Unique industries: {n_distinct(panel_long$industry_id)}"))
message(str_glue("Variables: {n_distinct(panel_long$variable)}"))

# Save output
saveRDS(panel_long, file.path(input_dir, "soi_panel_long.rds"))
write_csv(panel_long, file.path(input_dir, "soi_panel_long.csv"))

message(str_glue("\nSaved to {input_dir}/soi_panel_long.rds and .csv"))
