pacman::p_load(rvest, tidyverse)

albums <- c()
for(page in 1:26){
  list <- rvest::read_html(glue::glue("https://www.listchallenges.com/1001-albums-you-must-hear-before-you-die-2016/list/{page}"))
  current_albums <- list |>
    rvest::html_nodes(".item-name") |>
    rvest::html_text()
  albums <- c(current_albums, albums)
}
full_list <- albums |>
  str_trim()

# import data -------------------------------------------------

full_list <- rio::import('1001_albums.csv', setclass = "tibble", sep = ";")$albums


sample(full_list, 1)

rio::export(tibble("albums" = full_list), "1001_albums.csv")
