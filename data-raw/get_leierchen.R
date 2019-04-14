#"http://www.luxemburgensia.bnl.lu/cgi/getPdf1_2.pl?mode=item&id=7110"

library(tidyverse)
library(tesseract)
library(pdftools)
library(magick)


#pngfile <- pdf_convert("~/Downloads/dleierchen/dleierchen.pdf", dpi = 600)

path <- dir(path = "~/Downloads/dleierchen", pattern = "*.png", full.names = TRUE)

images <- map(path, image_read)

first_half <- map(images, ~image_crop(., geometry = "2307x6462"))

second_half <- map(images, ~image_crop(., geometry = "2307x6462+2307+0"))

merged_list <- prepend(first_half, NA) %>%
    reduce2(second_half, c) %>%
    discard(is.na)

text_list <- map(merged_list, ~ocr(., engine = "nld"))

text_list <- text_list %>%
    map(., ~str_split(., "\n"))

dleierchen <- text_list %>%
    unlist

write_lines(dleierchen, "data-raw/dleierchen.txt")

saveRDS(dleierchen, "data-raw/dleierchen.rds")
