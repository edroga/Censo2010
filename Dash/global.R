library(shiny)
library(leaflet)
library(rgdal)

# Global
#CensoPol2<-readRDS("Censo2010.rds")

#CensoPol2<-readOGR(dsn = "/home/ubuntu/GobLabDatosDash",
#                    layer = "censo_simplified",
#                    encoding = "UFT-8",
#                    stringsAsFactors=FALSE)
CensoPol2<-readRDS("MPOB.rds")
Entidades<-unique(CensoPol2$NOM_ENT)
Entidades2<-unique(CensoPol2$NOM_ENT)

Vars<-names(CensoPol2)[c(4:27)]
Vars2<-names(CensoPol2)[c(4:27)]
Vars3<-names(CensoPol2)[c(4:27)]

EIN_VAR<-c("Población total.", "Población de 15 años y más.","Población de 65 años y más.","Población femenina.","Población femenina de 0 a 14 años.",
           "Población femenina de 15 años y más.","Población femenina de 65 años y más.","Población masculina.","Población masculina de 0 a 14 años.",
           "Población masculina de 15 años y más.","Población de 0 a 14 años.","Población masculina de 65 años y más.")

CENSO_VAR<-c("Población total","Población de 0 a 14 años","Población de 65 años y más","Población femenina","Población femenina de 0 a 14 años",
             "Población femenina de 15 años y más","Población femenina de 65 años y más","Población masculina","Población masculina de 0 a 14 años",
             "Población masculina de 15 años y más","Población masculina de 65 años y más","Población de 15 años y más")
