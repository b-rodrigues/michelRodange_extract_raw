library(tidyverse)
library(tesseract)
library(pdftools)
library(magick)


#pdf_convert("data-raw/rodange_grow sigfrid.pdf", dpi = 200)

path <- dir(path = "data-raw/sigfrid", pattern = "^rodange", full.names = TRUE)

images <- map(path, image_read)

prep <- function(image, path){
    image <- image %>%
        image_convert(type = "Grayscale") %>%
        image_modulate(brightness = 150) %>%
        image_convolve('DoG:0,0,2', scaling = '1000, 100%') %>%
        image_despeckle(times = 50)


        #image_write(image, path)
}

new_path <- str_replace_all(path, "rodange", "edited")

images <- map2(images, new_path, ~prep(.x, .y))

#images <- images %>%
#    map(prep)

first_half <- map(images, ~image_crop(., geometry_area(width = 750, height = 1120, x_off = 182, y_off = 195)))

second_half <- map(images, ~image_crop(., geometry_area(width = 750, height = 1120, x_off = 1038, y_off = 184)))

merged_list <- prepend(first_half, NA) %>%
    reduce2(second_half, c) %>%
    discard(is.na)

text_list <- map(merged_list, ~ocr(., engine = "nld"))

text_list <- text_list %>%
    map(., ~str_split(., "\n"))

sigfrid <- text_list %>%
    unlist

writeLines(sigfrid, "data-raw/sigfrid.txt")

saveRDS(sigfrid, "data-raw/sigfrid.rds")
