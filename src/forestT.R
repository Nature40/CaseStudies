#' Modellierung der Bestandstemperatur
#' @description  Modellierung der Bestandstemperatur auf Grundlage des Blattflächenindex.
#' Zur Modellierung wird ein lineares Modell aufgestellt zwischen der gemessenen Temperatur 
#' an Klimastationen und den dazugehörigen Blattflächenindex (LAI) Werten.
#' Das Modell wird auf ein Raster des LAI angewendet um eine flächendeckende Modellierung
#' zu ermöglichen.
#' @param LAI Vektor der LAI Werte am Standort der Klimastationen
#' @param Temperatur Vektor der gemessenen Temperaturen am Standort der Klimastationen 
#' und zum Zeitpunkt der LAI Aufnahmen
#' @param LAI_rst Raster der LAI Werte
#' @return Raster der modellierten Bestandstemperaturen
#' @note Dies ist eine Testfunktion für den Use Case der Datenbankfunktionalität
#' und ist wissenschaftlich nicht sinnvoll.
#' @author Hanna Meyer
#' @examples
#' # In diesem Beispiel gibt es 2 Temperaturmessungen und 2 dazugehörige LAI Werte
#' library(raster)
#' LAI <- c(0.2,2.1)
#' Temperatur <- c(20,15)
#' LAI_rst <- raster(matrix(c(1,2,0.5,4,0.2,1,0.1,3,0.02),ncol=3))
#' BestandsTemp <- forestT(LAI,Temperatur,LAI_rst)
#' plot(BestandsTemp)
#' @export forestT
#' @aliases forestT

forestT <- function (LAI,Temperatur,LAI_rst){
  model <- lm (Temperatur~LAI)
  names(LAI_rst) <- "LAI"
  pred <- raster::predict(LAI_rst,model)
  return(pred)
}
