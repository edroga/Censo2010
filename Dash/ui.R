library(shiny)
library(leaflet)
library(leaflet.minicharts)
library(plotly)

shinyUI(
  bootstrapPage(
    
    tags$style(type = "text/css", "html, body {width:100%;height:100%} h4 {color: white;}"),
    
    leafletOutput("map", width = "100%", height = "100%"),
    
    absolutePanel(top = 10, right = 10,
                  
                  selectInput("Ent", 
                              h4("Entidades"),
                              #choices = c(Entidades, "Nacional") ,
                              choices = Entidades ,
                              selected= "Distrito Federal" ,
                              multiple = TRUE
                  ),
                  
                  selectInput("Variable", 
                              h4("Información demográfica"), 
                              list("Censo 2010" = CENSO_VAR,
                                   "EI 2015" = EIN_VAR)
                  ),
                  
                  selectInput("Variable2", 
                              h4("Chart"),
                              Vars2,
                              selected= "Población total",
                              multiple = TRUE)
    ),
    
    absolutePanel(top  = 200, 
                  left = 10,
                  width = 250,
                  #height= 20,
                  draggable = TRUE,
                  plotlyOutput("histCentile", height = 350)
    )
    
  )
)
