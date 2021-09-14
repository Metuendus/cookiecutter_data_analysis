# 1.  LOAD REQUIRED PACKAGES AND FUNCTIONS ---------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  googlesheets4,
  keyring,
  lubridate,
  RAdwords,
  rfacebookstat,
  tidyverse,
  rjson
)
source("R/functions.R")

# 2.  GA API EXTRACT SETTINGS ---------------------------------------------
## Authenticate
ga_auth(email = "example@email")

## Set Dates
# Sys.Date() - 1
start_date <- as.Date("2021-07-26")
end_date <- as.Date("2021-08-15")

## Set view ids
account <- "test" # Regex to search in GA accounts
(ga_acounts <- ga_account_list() %>%
  select(
    accountName,
    webPropertyName,
    viewName,
    viewId,
    starred
  ) %>%
  filter(
    grepl(account,
      accountName,
      ignore.case = TRUE
    ),
    starred == TRUE
  ))

view_ids <- ga_acounts %>%
  select(
    webPropertyName,
    viewId
  )

## Search for UA metrics and dimensions
ua <- "gender"
meta %>%
  filter(
    status != "DEPRECATED",
    grepl(ua,
      uiName,
      ignore.case = TRUE
    )
  ) %>%
  select(
    name,
    uiName,
    type,
    group
  ) %>%
  mutate(name = str_remove(
    name,
    "ga:"
  ))

# 3. GA API EXTRACTS ---------------------------------------------------------
## Devices
dims <- c(
  "deviceCategory",
  "productListName",
  "productBrand",
  "dimension1",
  "dimension2",
  "dimension3"
)
mets <- c(
  "productListViews",
  "productListClicks"
)

ga_devices <- ga_extract(
  view_ids = view_ids,
  start_date = start_date,
  end_date = end_date,
  dims = dims,
  mets = mets
)

## Products
dims = c(
  "ga:date",
  "productCategoryHierarchy",
  "productBrand",
  "productName",
  "productListName",
  "dimension1",
  "dimension2",
  "dimension3",
  "productListPosition"
)
mets <- c(
  "productListViews",
  "productListClicks"
)

ga_products <- ga_extract(
  view_ids = view_ids,
  start_date = start_date,
  end_date = end_date,
  dims = dims,
  mets = mets
)

# 4. SAVE RAW DATA --------------------------------------------------------
save(ga_devices,
     ga_products
     file = "data/raw/ga_raw_data.RData"
)
