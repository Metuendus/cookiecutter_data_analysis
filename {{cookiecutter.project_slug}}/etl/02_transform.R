# 1.  LOAD REQUIRED PACKAGES AND FUNCTIONS --------------------------------

if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  googlesheets4,
  lubridate,
  tidyverse,
  reshape2
)
source("R/functions.R")


# 2.  LOAD RAW DATA -------------------------------------------------------

load("data/raw/ga_raw_data.RData")

hj_data <- read_csv("data/raw/hotjar_data.csv",
  col_types = cols(
    Date = col_date(format = "%d-%m-%Y"),
    Percent = col_double(),
    Sessions = col_integer()
  )
)

ga_age <- read_csv("data/raw/ga_age_20210726-20210815.csv",
  skip = 5
) %>%
  mutate(viewId = "225393445") %>%
  relocate(viewId)

ga_gender <- read_csv("data/raw/ga_gender_20210726-20210815.csv",
  skip = 5
) %>%
  mutate(viewId = "225393445") %>%
  relocate(viewId)

str(ga_age)
str(ga_custom_dims)
str(ga_devices)
str(ga_gender)

# 3.  CLEAN DATASETS ------------------------------------------------------

## Products
clean_products <- ga_products %>%
  rename(
    patrocinio = dimension1,
    seccionComercial = dimension2,
    tipoCreativo = dimension3
  ) %>%
  separate(productCategoryHierarchy,
    into = c(
      "productCategory1",
      "productCategory2"
    ),
    sep = "/",
    fill = "right"
  ) %>%
  mutate_if(
    is.character,
    function(col) iconv(col, to = "ASCII//TRANSLIT")
  ) %>%
  mutate(
    across(where(is.character), str_trim),
    across(where(is.character), tolower),
    patrocinio = str_remove_all(
      patrocinio,
      "(\\[)|(\\])"
    ),
    nivelPatrocinio = case_when(
      grepl("diamante",
        patrocinio,
        ignore.case = TRUE
      ) ~ "diamante",
      grepl("platino",
        patrocinio,
        ignore.case = TRUE
      ) ~ "platino",
      grepl("oro",
        patrocinio,
        ignore.case = TRUE
      ) ~ "oro",
      grepl("plata",
        patrocinio,
        ignore.case = TRUE
      ) ~ "plata",
      grepl("bronce",
        patrocinio,
        ignore.case = TRUE
      ) ~ "bronce",
      grepl("lujo",
        patrocinio,
        ignore.case = TRUE
      ) ~ "lujo",
      TRUE ~ "otros"
    ),
    cleanSection = case_when(
      grepl("home",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "home",
      grepl("landing.*categor.as",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "landing categorias",
      grepl(".?.ndice",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "indice",
      grepl("favoritos",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "favoritos",
      grepl("mega.*ofertas",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "mega ofertas",
      grepl("ofertas.*hot",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "ofertas hot",
      grepl("ofertas.*flash",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "ofertas flash"
    ),
    productListName = str_replace_all(
      productListName,
      "productos hot",
      cleanSection
    ),
    productListName = str_remove_all(
      productListName,
      "'"
    ),
    productBrand = str_remove_all(
      productBrand,
      "'"
    )
  ) %>%
  mutate(across(
    where(is.factor),
    as.character
  )) %>%
  select(
    -cleanSection
  )

## Devices
clean_devices <- ga_devices %>%
  rename(
    patrocinio = dimension1,
    seccionComercial = dimension2,
    tipoCreativo = dimension3
  ) %>%
  mutate_if(
    is.character,
    function(col) iconv(col, to = "ASCII//TRANSLIT")
  ) %>%
  mutate(
    across(where(is.character), str_trim),
    across(where(is.character), tolower),
    patrocinio = str_remove_all(
      patrocinio,
      "(\\[)|(\\])"
    ),
    nivelPatrocinio = case_when(
      grepl("diamante",
        patrocinio,
        ignore.case = TRUE
      ) ~ "diamante",
      grepl("platino",
        patrocinio,
        ignore.case = TRUE
      ) ~ "platino",
      grepl("oro",
        patrocinio,
        ignore.case = TRUE
      ) ~ "oro",
      grepl("plata",
        patrocinio,
        ignore.case = TRUE
      ) ~ "plata",
      grepl("bronce",
        patrocinio,
        ignore.case = TRUE
      ) ~ "bronce",
      grepl("lujo",
        patrocinio,
        ignore.case = TRUE
      ) ~ "lujo",
      TRUE ~ "otros"
    ),
    cleanSection = case_when(
      grepl("home",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "home",
      grepl("landing.*categor.as",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "landing categorias",
      grepl(".?.ndice",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "indice",
      grepl("favoritos",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "favoritos",
      grepl("mega.*ofertas",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "mega ofertas",
      grepl("ofertas.*hot",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "ofertas hot",
      grepl("ofertas.*flash",
        seccionComercial,
        ignore.case = TRUE
      ) ~ "ofertas flash"
    ),
    productListName = str_replace_all(
      productListName,
      "productos hot",
      cleanSection
    ),
    productListName = str_remove_all(
      productListName,
      "'"
    ),
    productBrand = str_remove_all(
      productBrand,
      "'"
    )
  ) %>%
  mutate(across(
    where(is.factor),
    as.character
  )) %>%
  select(
    -cleanSection
  )


## Age
clean_age <- ga_age %>%
  rename_all(tolower) %>%
  rename(
    productListName = page,
    productListViews = `product list views`,
    productListClicks = `product list clicks`
  ) %>%
  mutate_if(
    is.character,
    function(col) iconv(col, to = "ASCII//TRANSLIT")
  ) %>%
  mutate(
    across(where(is.character), str_trim),
    across(where(is.character), tolower),
    productListName = str_remove_all(productListName, "\\?.*"),
    productListName = case_when(
      grepl("^/$",
        productListName,
        ignore.case = TRUE
      ) ~ "home",
      grepl("indice-de-marcas",
        productListName,
        ignore.case = TRUE
      ) ~ "indice",
      grepl("salud",
        productListName,
        ignore.case = TRUE
      ) ~ "salud y cuidado personal",
      TRUE ~ productListName
    ),
    productListName = str_replace_all(productListName, "-", " "),
    productListName = str_remove_all(productListName, "^/")
  )

## Gender
clean_gender <- ga_gender %>%
  rename_all(tolower) %>%
  rename(
    productListName = page,
    productListViews = `product list views`,
    productListClicks = `product list clicks`
  ) %>%
  mutate_if(
    is.character,
    function(col) iconv(col, to = "ASCII//TRANSLIT")
  ) %>%
  mutate(
    across(where(is.character), str_trim),
    across(where(is.character), tolower),
    productListName = str_remove_all(productListName, "\\?.*"),
    productListName = case_when(
      grepl("^/$",
        productListName,
        ignore.case = TRUE
      ) ~ "home",
      grepl("indice-de-marcas",
        productListName,
        ignore.case = TRUE
      ) ~ "indice",
      grepl("salud",
        productListName,
        ignore.case = TRUE
      ) ~ "salud y cuidado personal",
      TRUE ~ productListName
    ),
    productListName = str_replace_all(productListName, "-", " "),
    productListName = str_remove_all(productListName, "^/")
  )


# 4. SAVE PROCESSED DATA ---------------------------------------------------------------

save(clean_products,
  clean_devices,
  clean_age,
  clean_gender,
  file = "data/processed/processed_data.RData"
)
