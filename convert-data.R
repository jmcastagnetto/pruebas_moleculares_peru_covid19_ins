library(tidyverse)
library(vroom)

fnames <- fs::dir_ls("orig/", glob = "*.csv.gz")

# cambio en separador
sep_bar <- c(
  "orig/pm10Abril2021.csv.gz",
  "orig/pm25Marzo2021.csv.gz"
)

pm_df <- tibble()

for (fn in fnames) {
  fn = fnames[1]
  print(glue::glue("Procesando: {fn}"))
  if (fn %in% sep_bar) {
    sep = "|"
  } else {
    sep = ","
  }
  df <- vroom(
    fn,
    delim = sep,
    na = c("", "NULL", "*", "0001-01-01"),
    col_types = cols(.default = col_character())
  ) %>%
    janitor::clean_names() %>%
    mutate(
      fechatomamuestra = lubridate::ymd(fechatomamuestra),
      edadpaciente_c = str_replace(edadpaciente_c, "años", "")
    ) %>%
    add_column(
      src = str_remove(basename(fn), ".gz")
    ) %>%
    distinct() %>%
    filter(!is.na(resultado))

  pm_df <- bind_rows(pm_df, df)
}

# tmp <- pm_df
ubigeos <- readxl::read_excel(
  "misc/Poblacion Peru 2020 Dpto Prov Dist Final INEI-actualizado.xlsx",
  sheet = "PROVINCIAL",
  range = "A7:D204"
) %>%
  janitor::clean_names() %>%
  filter(
    ubigeo != "0000"
  ) %>%
  mutate(
    ubigeo = paste0(ubigeo, "00")
  ) %>%
  rename(
    pob2020 = total
  )

pm_df <- pm_df %>%
  arrange(fechatomamuestra) %>%
  mutate (
    prov_origen = str_replace_all(
      prov_origen,
      pattern = c(
        "PROV. CONST. DEL CALLAO" = "CALLAO",
        "ANTONIO RAYMONDI" = "ANTONIO RAIMONDI"
      )
    )
  ) %>%
  left_join(
    ubigeos,
    by = c(
      "dep_origen" = "departamento",
      "prov_origen" = "provincia"
    )
  ) %>%
  relocate(
    ubigeo,
    .before = dep_origen
  ) %>%
  distinct()

sin_ubigeo <- pm_df %>% filter(is.na(ubigeo))

saveRDS(
  pm_df,
  file = "proc/pm_covid19_ins_peru.rds"
)

write_csv(
  pm_df,
  file = "proc/pm_covid19_ins_peru.csv.gz"
)

pm_counts_df <- pm_df %>%
  group_by(
    fechatomamuestra,
    tipomuestra,
    resultado,
    edadpaciente_c,
    sexopaciente,
    institucion,
    ubigeo,
    dep_origen,
    prov_origen,
    pob2020
  ) %>%
  tally()

write_csv(
  pm_counts_df,
  file = "proc/pm_covid19_ins_peru_counts.csv.gz"
)

writexl::write_xlsx(
  pm_counts_df,
  path = "proc/pm_covid19_ins_peru_counts.xlsx"
)
