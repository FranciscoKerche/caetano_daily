# Simple caetano app

pacman::p_load(dplyr, purrr, telegram.bot, glue, rio, usethis)

caetano_simples <- rio::import("caetano_songs.csv", setclass = "tibble")

usethis::ui_done("Data was imported!")

carinho <- c("Te amo, carinho",
             "Aproveita seu diaaa",
             "Pensa em mim enquanto escuta",
             "Espero que o Caetano alegre seu dia!",
             "Você ta linda hoje, sabia?",
             "Piun, piun, pininiun piun, é a musiquinha de guitarra, não sei se reparou",
             "Já to com saudade (pode ser que eu esteja do seu lado agora, mas não deixa de ser verdade)",
             "Você é meu amor",
             "Sou todo seu",
             "Quero você sempre comigo",
             "Adoro acordar do seu lado",
             "Amo a gente",
             "Me sinto tão leve perto de você",
             "Deixei esse espaço pra anunciantes, vamos ver o que rola
             ...
             Brincadeira, aqui é só pra gente!",
             "Fiz esse robozinho com todo meu amor",
             "Espero que essa seja uma que você gosta",
             "Aproveita sua manhã!",
             "Datezinho?",
             "Gostosa demais, só digo isso")


# update bot -------------------------------------------------------

get_random_song <- function(.x, carinho){
  weighted_list <- .x |>
    mutate(cumulative_pop = cumsum(popularity))

  random_num <- sample(1:max(weighted_list$cumulative_pop), 1)
  
  chosen_song <- weighted_list |>
    filter(cumulative_pop >= random_num) |>
    slice(1) |>
    pull(id)
  
  track_info <- .x |>
    filter(id == chosen_song)
  
  final_message <- glue::glue("Bom dia, meu amor, 🌞
           🎶 Aqui está sua música do Caetano do dia! 🎶
           
           Hoje a música é: 
           [{track_info$name}]({track_info$external_urls.spotify})
           
           do álbum *{track_info$album_name}*, com *{track_info$artists}*
           
           {carinho[round(runif(1, min = 1, max = length(carinho)))]} 🧡")
  return(final_message)
}

song_message <- get_random_song(caetano_simples, carinho)

usethis::ui_info("I selected a file")

bt <- telegram.bot::bot_token('CAETANO')

bot <- Bot(token = bt)
updates <- bot$getUpdates()

try_send <- purrr::possibly(bot$sendMessage, otherwise = NULL)
all_ids <- map(updates, ~.$from_chat_id()) |>
  keep(~!is.null(.)) |>
  unlist() |>
  unique()

all_ids = unique(c(Sys.getenv('LOVE_TELEGRAM'), all_ids))
walk(all_ids, ~try_send(., song_message,
                        parse_mode = 'Markdown'))

usethis::ui_done("Bot sended the message!")

