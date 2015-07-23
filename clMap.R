library(leaflet)
library(maps)
library(RColorBrewer)

us <- map('state', fill = TRUE, plot = FALSE) 
leaflet(data = us) %>% addTiles() %>% addPolygons(fillColor = brewer.pal(9, "Greens"), stroke = FALSE)


