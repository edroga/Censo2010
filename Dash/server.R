# server.R
library(shiny)
library(leaflet)
library(RColorBrewer)
library(htmltools)
library(leaflet.minicharts)
library(plotly)

# Server
shinyServer(     
  function(input, output){  
    
    output$map <-renderLeaflet({
      
      # entidades<-reactive{( input$Ent )}
      
      #CensoPol2<- ifelse("Nacional" %in% entidades() ,
      #                  CensoPol2,
      #                 subset(CensoPol2, NOM_ENT %in% entidades() ))
      
      x <- reactive({
        if ( "Nacional" %in% input$Ent ){
          unlist(Entidades2)
        } else { 
          input$Ent  
        }
      }) 
      
      
      CensoPol2<-subset(CensoPol2, NOM_ENT %in% x() )
      
      pal <- colorNumeric(palette = "Blues",
                          domain = CensoPol2@data[ ,input$Variable] ) 
      
      factpal <- colorFactor(c("white",
                               "red4",
                               "gold1",
                               "orange2",
                               "yellow3",
                               "chartreuse4",
                               "turquoise3",
                               "royalblue4",
                               "khaki",
                               "royalblue",
                               "red3",
                               "white",
                               "red3",
                               "red3",
                               "red3",
                               "khaki",
                               "lightsalmon4",
                               "chartreuse4",
                               "mediumorchid3",
                               "khaki",
                               "violetred3",
                               "royalblue"),
                             domain=sort(unique(CensoPol2$Ganador)) )
      
      labels <- sprintf(
        "<strong>%s</strong><br/>%s Municipio<br/> <strong>%s</strong> ",
        CensoPol2$NOM_ENT , CensoPol2$NOM_MUN , paste(CensoPol2@data[ ,input$Variable])
      ) %>% lapply(htmltools::HTML)
      
      labels2<- sprintf(
        "<strong>%s</strong><br/>%s Municipio<br/> <strong>%s</strong> ",
        CensoPol2$NOM_ENT , CensoPol2$NOM_MUN , paste(CensoPol2$Ganador )
      ) %>% lapply(htmltools::HTML)
      
      leaflet() %>%
        addProviderTiles("CartoDB.DarkMatter", options= providerTileOptions(opacity = 0.99)) %>%
        addPolygons( 
          data = CensoPol2,
          fillColor = factpal(CensoPol2$Ganador ),
          fillOpacity = 0.8,
          weight = 1,
          opacity = 1,
          color = "white",
          dashArray = ".5",
          group="Partidos",
          highlight = highlightOptions(
            weight = 2,
            color = "white",
            dashArray = "",
            fillOpacity = 0.8,
            bringToFront = TRUE),
          label = labels2,
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto")
        ) %>%
        addPolygons(
          data = CensoPol2,
          fillColor = pal( CensoPol2@data[ ,input$Variable] ),
          fillOpacity = 0.8,
          weight = 1,
          opacity = 1,
          color = "white",
          dashArray = ".5",
          group="Chropleth",
          highlight = highlightOptions(
            weight = 2,
            color = "white",
            dashArray = "",
            fillOpacity = 0.8,
            bringToFront = TRUE),
          label = labels,
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto")
        ) %>%
        addLegend("bottomright", pal = pal, values = CensoPol2@data[ ,input$Variable],
                  title = input$Variable) %>%
        addMinicharts(
          CensoPol2$LON_DEC, CensoPol2$LAT_DEC,
          chartdata = CensoPol2@data[ ,input$Variable2],
          showLabels = TRUE,
          type = "polar-area",
          width = 70,
          height=70,
          opacity = .6,
          #layerId = "Chart",
          legendPosition= 'bottomleft') %>%
        addLayersControl(
          position='topleft',
          #baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
          overlayGroups  = c("Chropleth","Partidos"),
          options = layersControlOptions(collapsed = FALSE)
        )
      
    })
    
    output$histCentile <- renderPlotly({
      
      plot_ly(x=CensoPol2@data[ ,input$Variable], y=CensoPol2@data[ ,input$Variable2], color=CensoPol2$POB55_x, size=CensoPol2$POB8_x  )
      
    })
    
  }
) 
