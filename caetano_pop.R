# Update caetano popularity ------------------------------------------

pacman::p_load(tidyverse, telegram.bot, spotifyr)

# find caetano -------------------------------------------------------


access_token <- spotifyr::get_spotify_access_token()


caetano_cd <- spotifyr::get_artist_albums("7HGNYPmbDrMkylWqeFCOIQ")

all_tracks <- map_df(caetano_cd$id, spotifyr::get_album_tracks)

tracks_info <- map(all_tracks$id, spotifyr::get_track)

extract_pop <- function(.x){
  return(tibble(popularity = .x$popularity, id = .x$id, album_name = .x$album$name))
}

all_pop <- map_dfr(tracks_info, extract_pop)

caetano_fim <- all_tracks |>
  left_join(all_pop) |>
  tibble() |>
  select(-available_markets)

artists <- map(caetano_fim$artists, ~.$name) |>
  map(paste0, collapse = " e ") |>
  unlist()

caetano_simples <- bind_cols(tibble(artists = artists), select(caetano_fim, -artists))

rio::export(caetano_simples, "caetano_songs.csv")

