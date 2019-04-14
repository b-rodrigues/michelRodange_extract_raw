# this scripts gets the text from the "Renert" and puts it into a nice data frame

library("tidyverse")
library("tidytext")
library("janitor")

renert_link <- "https://wikisource.org/wiki/Renert"

renert_raw <- renert_link %>%
    xml2::read_html() %>%
    rvest::html_nodes(".mw-parser-output") %>%
    rvest::html_text() %>%
    str_split("\n", simplify = TRUE) %>%
    .[1, -c(1:21)]

write_lines(renert_raw, "data-raw/renert_raw.txt")


(indices <- grepl("Gesank", renert_raw) %>% which(isTRUE(.)))

(indices2 <- c(indices[-1] - 1, length(renert_raw)))

song_lines <- map2(indices, indices2,  ~seq(.x,.y))

renert_songs <- map(song_lines, ~`[`(renert_raw, .))

is_empty_character <- function(char){
    if(char == "") TRUE else FALSE
}

renert <- renert_songs %>%
    map(., ~discard(., is_empty_character)) %>%
    map(., ~str_remove_all(., "\\[edit\\]")) %>%
    map(tibble) %>%
    map(., ~rename(., sentence = `<chr>`)) %>%
    map(., ~mutate(., gesank = pull(.[1, 1]))) %>%
    map(., ~mutate(., gesank = str_remove_all(gesank, " Gesank."))) %>%
    map(., ~mutate(., gesank = tolower(gesank))) %>%
    bind_rows()

renert %>%
    group_by(gesank) %>%
    summarise(total_lines = n())
