# Application avec facet_wrap

library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(ggplot2)
library(shinyWidgets)
library(qs)
library(tidyr)

# Modifications principales :
# ✅ Lecture unique de data/all_periodes.qs (déjà fusionné)
# ✅ Retrait de st_make_valid() dans l’application (pré-traitement en amont)

# ------------------------
# CHARGEMENT DES LIBRAIRIES
# ------------------------
library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(ggplot2)
library(shinyWidgets)
library(qs)
library(tidyr)

# ------------------------
# PARAMÈTRES GLOBAUX
# ------------------------
base_url <- "https://raw.githubusercontent.com/hgesdrn/InterFor_shiny/main/data/"
periodes <- c("1960-1969", "1970-1979", "1980-1989", "1990-1999", "2000-2009",
              "2010-2019", "2020-2029")
terr_choix <- c("02371", "02471", "02571", "02751")

classes_coupe <- c("CP", "CR", "EPC", "PL", "CT-CPR")
classes_nom <- c("CP" = "Coupe partielle",
                 "CR" = "Coupe de récupération",
                 "EPC" = "Éclaircie précommerciale",
                 "PL" = "Plantation",
                 "CT-CPR" = "Coupe protection régèn./totale")
classe_labels <- setNames(names(classes_nom), paste(names(classes_nom), "-", classes_nom))
palette_classes <- c("CP" = "#377eb8", "CR" = "#4daf4a", "EPC" = "#984ea3",
                     "PL" = "#e41a1c", "CT-CPR" = "#ff7f00")

# ------------------------
# IMPORTATION DES DONNÉES
# ------------------------
# Lecture unique du fichier fusionné .qs
all_data <- lire_qs_github(paste0(base_url, "all_periodes.qs"))

# Lecture de la couche UA simplifiée (sans st_make_valid)
uasag_sf <- lire_qs_github(paste0(base_url, "UASag_s.qs")) %>%
  st_transform(4326)

# Centroides pour labels
centroïdes_ua <- uasag_sf %>%
  st_drop_geometry() %>%
  select(TERRITOIRE, X, Y) %>%
  st_as_sf(coords = c("X", "Y"), crs = 4326)

# ------------------------
# TRANSFORMATION POUR INDEXATION RAPIDE
# ------------------------
# data_par_periode devient une liste indexée par période
# On présumera que chaque élément de all_data contient la colonne "Periode"
data_par_periode <- split(all_data, all_data$Periode)



# ---------------------
# UI
# ---------------------
ui <- fluidPage(
  tags$style(HTML("
    .header-title {
      background-color: #2C3E50;
      color: white;
      padding: 20px;
      font-size: 22px;
      font-weight: bold;
      text-align: left;
      text-transform: uppercase;
      margin-bottom: 20px;
      box-shadow: 2px 2px 8px rgba(0,0,0,0.2);
    }

    .box-style {
      background-color: #f9f9f9;
      border: 1px solid #ccc;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 2px 2px 8px rgba(0,0,0,0.1);
      height: 700px;
      overflow-y: auto;
    }

    .irs--shiny .irs-line,
    .irs--shiny .irs-bar,
    .irs--shiny .irs-bar-edge,
    .irs--shiny .irs-single {
      background-color: #ddd !important;
      border-color: #ddd !important;
      color: black !important;
    }

    .irs--shiny .irs-handle {
      border-color: #999 !important;
      background-color: #999 !important;
    }
  ")),
  
  div("INTERVENTIONS FORESTIÈRES DANS LES UNITÉS D'AMÉNAGEMENTS DU SAGUENAY DE 1960 À 2022", 
      class = "header-title"),
  
  fluidRow(
    column(6,
           div(class = "box-style",
               sliderTextInput(
                 "periode", "Choisir une période :", 
                 choices = periodes, selected = periodes[1], grid = TRUE,
                 animate = animationOptions(interval = 1500, loop = FALSE), 
                 width = "100%"
               ),
               selectInput("classe", "Type d'intervention :", choices = classe_labels, selected = "CP"),
               plotOutput("barplot", height = "400px")
           )
    ),
    column(6,
           div(class = "box-style",
               leafletOutput("carte", height = "640px")
           )
    )
  )
)

# ---------------------
# SERVER
# ---------------------
server <- function(input, output, session) {
  
  # Données pour la carte
  donnees_filtrees <- reactive({
    df <- data_par_periode[[input$periode]]
    if (is.null(df)) return(NULL)
    df %>% filter(CLASS == input$classe, TERRITOIRE %in% terr_choix)
  })
  
  # Données pour le graphique
  donnees_aggregées <- reactive({
    lapply(names(data_par_periode), function(p) {
      df <- data_par_periode[[p]]
      if (is.null(df)) return(NULL)
      df <- df %>%
        st_drop_geometry() %>%  # 🔧 Empêche les problèmes de géométrie
        filter(CLASS == input$classe, TERRITOIRE %in% terr_choix) %>%
        group_by(TERRITOIRE) %>%
        summarise(Surface = sum(SUP_HA, na.rm = TRUE), .groups = "drop") %>%
        mutate(Periode = p)
      return(df)
    }) %>% bind_rows()
  })
  
  
  # Carte initiale
  output$carte <- renderLeaflet({
    leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
      addProviderTiles("CartoDB.Positron", group = "Gris/Contour") %>%
      addRectangles(lng1 = -180, lat1 = -90, lng2 = 180, lat2 = 90,
                    fillColor = "white", fillOpacity = 0.3, stroke = FALSE,
                    group = "Eclaircir") %>%
      addPolygons(data = uasag_sf, group = "UA", color = "black",
                  fillColor = "gray80", fillOpacity = 0.4, weight = 1,
                  label = ~TERRITOIRE) %>%
      addLabelOnlyMarkers(
        data = centroïdes_ua,
        label = ~TERRITOIRE,
        labelOptions = labelOptions(
          noHide = TRUE, direction = "center", textOnly = TRUE,
          style = list(
            "font-weight" = "bold", "font-size" = "14px",
            "color" = "black", "text-shadow" = "1px 1px 2px #ffffff"
          )
        )
      ) %>%
      addLayersControl(
        baseGroups = c("Satellite", "Gris/Contour"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  # Zoom sur les 4 territoires
  observe({
    bbox <- st_bbox(uasag_sf)
    leafletProxy("carte") %>%
      clearGroup("Highlight") %>%
      fitBounds(bbox[["xmin"]], bbox[["ymin"]], bbox[["xmax"]], bbox[["ymax"]])
  })
  
  # Ajout des polygones filtrés
  observe({
    df <- donnees_filtrees()
    leafletProxy("carte") %>%
      clearGroup("IntFor") %>%
      {
        if (!is.null(df) && nrow(df) > 0)
          addPolygons(
            ., data = df, group = "IntFor",
            fillColor = palette_classes[[input$classe]],
            fillOpacity = 1, color = "black", weight = 1
          )
        else .
      }
  })
  
  # Graphique (facet_wrap par territoire)
  output$barplot <- renderPlot({
    df <- donnees_aggregées() %>% mutate(Selection = Periode == input$periode)
    
    ggplot(df, aes(x = Periode, y = Surface)) +
      geom_col(fill = palette_classes[input$classe]) +
      geom_text(data = df %>% filter(Selection),
                aes(label = scales::comma(Surface, accuracy = 1)),
                vjust = -0.5, color = "black", size = 4) +
      facet_wrap(~ TERRITOIRE, ncol = 2) +
      scale_y_continuous(labels = scales::comma_format()) +
      labs(title = "Superficie (ha) par type d'intervention",
           y = "Superficie (ha)", x = "Période") +
      scale_x_discrete(limits = c("1960-1969", "1970-1979", "1980-1989",
                                  "1990-1999", "2000-2009", "2010-2019", "2020-2029")) +
      theme_minimal(base_size = 14) +
      theme(
        strip.background = element_rect(fill = "#D4D4D4", color = "grey40"),
        strip.text = element_text(color = "black", face = "bold", size = 14),
        axis.text.y = element_text(face = "bold", size = 10),
        axis.text.x = element_text(angle = 25, hjust = 1),
        axis.title.x = element_text(face = "bold", size = 14, margin = margin(t = 15)),
        axis.title.y = element_text(face = "bold", size = 14, margin = margin(r = 10)),
        plot.title = element_text(size = 14, face = "bold")
      )
  })
  
}

# Run app
shinyApp(ui, server)