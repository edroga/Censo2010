library(foreign)
library(rgdal)
library(leaflet)
library(RColorBrewer)
library(htmltools)
library(rgeos)
library(dplyr)
library(leaflet.minicharts)


# Descarga de datos
# library(readr)
# install.packages("readr")

##########
setwd("/home/arosas/Dash")
getwd()
list.files()

#system("sudo lshw -class memory")

########## DOWNLOADS
 download.file("https://github.com/edroga/Censo2010/raw/master/Vivienda.rds", destfile="Vivienda.rds")
 download.file("https://github.com/edroga/Censo2010/raw/master/national_municipal.dbf", destfile="Nacional.dbf")
 download.file("https://github.com/edroga/Censo2010/raw/master/municipal.dbf", destfile="CARLOS_MPIOS.dbf")
 download.file("https://raw.githubusercontent.com/edroga/Censo2010/master/main2.csv", destfile="EIN.csv")
 download.file("https://github.com/edroga/Censo2010/raw/master/national_cpv2010_estatal_lengua_indigena.dbf", destfile="LIN.dbf")
 download.file("https://raw.githubusercontent.com/edroga/Censo2010/master/CLAVES_MUNICIPIOS_COORDENADAS.csv", destfile="Coordenadas.csv")

#unlink("Vivienda.dbf")
#unlink("Nacional.rds")

######### CARGA DE DATOS

INE<-read.dbf("CARLOS_MPIOS.dbf", as.is = TRUE) # DATOS ELECTORALES
cvegeo<-INE$CVEGEO
write.csv(INE, "INE2.csv")
INE<-read.csv("INE2.csv", stringsAsFactors=FALSE, fileEncoding = "ISO-8859-1" )
INE$CVEGEO<-cvegeo
rm(cvegeo)

COORS<-read.csv("Coordenadas.csv", stringsAsFactors=FALSE, fileEncoding = "ISO-8859-1") %>%
  mutate(CVE_ENT = ifelse( nchar(CVE_ENT)==1, paste("0",CVE_ENT, sep=""), paste(CVE_ENT)),
         CVE_MUN = ifelse( nchar(CVE_MUN)==1, paste("00",CVE_MUN, sep=""), 
                           ifelse( nchar(CVE_MUN)==2, paste("0",CVE_MUN, sep=""), paste(CVE_MUN))
         )) %>%
  mutate(CVEGEO= paste(CVE_ENT,CVE_MUN,sep="" )) %>%
  select(-CVE_ENT, -CVE_MUN, -NOM_ABR, -NOM_ENT, -NOM_MUN)

EIN<-read.csv("EIN.csv", stringsAsFactors=FALSE, fileEncoding = "ISO-8859-1") %>%
  mutate(estado = ifelse( nchar(estado)==1, paste("0",estado, sep=""), paste(estado)),
         MUN = ifelse( nchar(MUN)==1, paste("00",MUN, sep=""), 
                       ifelse( nchar(MUN)==2, paste("0",MUN, sep=""), paste(MUN))
         )) %>%
  mutate(CVEGEO= paste(estado,MUN,sep="" )) %>%
  select(-X,-estado,-MUN,-INDI1,-INDI2,-INDI3, -viv17, -viv23, -viv35, -viv36, -viv9)

names(EIN)[c(1:12)]<-c("Población total.", "Población de 15 años y más.","Población de 65 años y más.","Población femenina.","Población femenina de 0 a 14 años.",
                       "Población femenina de 15 años y más.","Población femenina de 65 años y más.","Población masculina.","Población masculina de 0 a 14 años.",
                       "Población masculina de 15 años y más.","Población de 0 a 14 años.","Población masculina de 65 años y más.")

#VIV<-readRDS("Vivienda.rds") %>%
#  select (CVEGEO,VIV9,VIV17,VIV23,VIV35,VIV36)

POB<-read.dbf("Nacional.dbf", as.is = TRUE) %>%
  select(CVEGEO, NOM_ENT, NOM_MUN,POB1,POB8,POB20,POB24,POB31,POB38,POB51,POB55,POB57,POB64,POB76,POB80) %>%
  mutate(POB18=POB20) %>%
  select(-POB20)

names(POB)[c(4:15)]<-c("Población total","Población de 0 a 14 años","Población de 65 años y más","Población femenina","Población femenina de 0 a 14 años",
                       "Población femenina de 15 años y más","Población femenina de 65 años y más","Población masculina","Población masculina de 0 a 14 años",
                       "Población masculina de 15 años y más","Población masculina de 65 años y más","Población de 15 años y más")

POB<-select(POB, -NOM_ENT, -NOM_MUN)

CENSO<-merge(POB,EIN,by="CVEGEO") %>%
  left_join(INE, by="CVEGEO") %>%
  left_join(COORS, by="CVEGEO") %>%
  select(-X)

rm(POB,COORS,INE, EIN)

#LIN<-read.dbf("LIN.dbf", as.is = TRUE) %>%
#  select(CVEGEO, INDI1,INDI2,INDI3)

MUNICIPIOS<-readOGR(dsn = "/home/ubuntu/GobLabDatosDash", layer = "municipios", encoding = "UFT-8", stringsAsFactors=FALSE)
MUNICIPIOS$CVEGEO<-paste(MUNICIPIOS$CVE_ENT,MUNICIPIOS$CVE_MUN,sep="")
MUNICIPIOS@data <- MUNICIPIOS@data[, -3]

MUNICIPIOS1 <- gSimplify(MUNICIPIOS, tol=95, topologyPreserve=FALSE)
MUNICIPIOS2 <- SpatialPolygonsDataFrame(MUNICIPIOS1, data=MUNICIPIOS@data)

MPOB<-merge(MUNICIPIOS2, CENSO, by="CVEGEO")
rm(MUNICIPIOS, MUNICIPIOS1, MUNICIPIOS2, CENSO)
MPOB <- spTransform(MPOB, CRS("+init=epsg:4326"))
saveRDS(MPOB, "MPOB.rds")

#writeOGR(MPOB, layer = 'censo_simplified', "/home/ubuntu/GobLabDatosDash", driver="ESRI Shapefile")

#unlink("censo_simplified.dbf")
#unlink("censo_simplified.prj")
#unlink("censo_simplified.shp")
#unlink("censo_simplified.shx")

####################
CensoPol2<-readOGR(dsn = "/home/ubuntu/GobLabDatosDash",
                   layer = "censo_simplified",
                   encoding = "UFT-8",
                   stringsAsFactors=FALSE)
CensoPol2<-readRDS("MPOB.rds")
#CensoPol2 <- spTransform(CensoPol2, CRS("+init=epsg:4326"))
#CensoPol2@data[,c(7:47)]<- sapply(CensoPol2@data[, c(7:47)], as.numeric)
