
# Fallstudie für die Datenbankfunktionalitäten

## Ziel
In der Fallstudie werden Funktionalitäten und Daten der ZeitreihenDB, RasterDB, ProjektDB und VAT verwendet um einen Workflow zu modellieren , der die Bestandstemperatur auf Grundlage vom Blattflächenindex (LAI) und Klimastationsdaten schätzt. Die verwendete Transferfunktion  wird auf die gesamte Fläche des MOF angewendet um die Bestandstemperatur räumlich zu modellieren. Das Ergebnis soll als Rasterdatenebene  sowie für ausgewählte Waldstrukturplots visualisiert werden. 

## Nutzerverwaltung
* Einloggen und Verwalten eines Nutzers mit spezifischer Rolle ( Scientist, Student, Citizen)
* Speichern, Laden und Manipulieren (Klonen) des Workflows inkl. Metadaten in die ProjektDB/VAT 
      
## Datensätze und benutzerdefinierte Funktionen
* Zeitreihen der zwei Klimastationen  (TubeDB)
* Lidar Daten inkl. abgeleiteter Rasterdatensätze (RasterDB)
* Tabelle mit Waldstrukturplots (ProjektDB)
* R-Funktion “ forestT” (Github)

## Workflow
Datenprozessierung und Modellierung:
* Flächendeckende Berechnung des LAI aus den Lidar-Daten in 2 m x 2 m räumlicher Auflösung für den MOF.
* Bereitstellung der Montasmitteltemperatur im Juni und Juli 2018 von den  zwei Klimastationen.
* Extraktion des LAI für die Lage der Klimastationen.
* Anwendung der R-Funktion “forestT ”, die ein lineares Modell aufstellt, welches flächendeckend aus dem LAI die Monatsmitteltemperatur schätzt. Eingangsparameter sind die gemessenen Temperaturen und der LAI an den Klimastationen sowie das LAI Raster. Die Funktion gibt ein Raster der modellierten Bestandstemperaturen zurück.
* Extraktion der modellierten Bestandstemperaturen für die Waldstrukturplots mit einem 10 m x 10 m Puffer.
* Berechnung deskriptive Statistik und Visualisierung der Waldstrukturplots.

Datenvisualisierung:
* Verfügbarkeit des Workflows für berechtigte Nutzer/Rollen zur automatischen Ausführung und weiteren Bearbeitung.
* Visualisierung des modellierten Temperaturrasters in der Projektion ETRS89 UTM mit der “viridis” Farbpalette
* Visualisierung der extrahierten Bestandstemperaturen der Waldstrukturplots.

# Technische Umsetzung Benutzerverwaltung

Da ProjektDB allgemeine Informationen zu Natur 4.0 enthält, sollte hier der zentrale Login für die Benutzer ausgeführt werden.
Alternativ könnte VAT (vorübergehend) das zentrale Login übernehmen, falls dadurch der Usecase besser zeitnah umgesetzt werden kann (falls dort eine entsprechende Benutzerverwaltung existiert).

VAT ist die zentrale Instanz für Workflows.

## Problemstellung "Single Sign-on"

ProjektDB --> TubeDB (weitgehend fertiggestellt, mit reverse Proxy in ProjektDB)

ProjektDB --> RasterDB (weitgehend fertiggestellt, mit reverse Proxy in ProjektDB)

ProjektDB --> VAT (eine reverse Proxy Lösung ist hier vermutlich nicht einfach umsetzbar, gibt es eine Umsetzung / Erfahrung mit "echtem" Single Sign-on?)


VAT --> TubeDB (nur API Zugriff notwendig, einfache HTTP-Authentifizierung über einen VAT-Account in TubeDB)

VAT --> RasterDB (nur API Zugriff notwendig, einfache HTTP-Authentifizierung über einen VAT-Account in RasterDB)


## Technische Umsetzung Workflow

* Flächendeckende Berechnung des LAI: Vorberechnung und Speicherung in RasterDB, Raster-Abfrage (VAT --> RasterDB)
* Bereitstellung der Montasmitteltemperatur: CSV-Abfrage (VAT --> TubeDB)
* Extraktion des LAI für die Lage der Klimastationen: drei Möglichkeiten:
  *  eingrenzende Abfrage auf dem vorberechneten Raster in RasterDB
  *  eingrenzende Abfrage in VAT auf dem in VAT zwischengespeicherten flächendeckenden Raster aus der Abfrage von RasterDB
  * on-demand Berechnung in RasterDB des LAI an den Positionen der Klimastationen
* weitere Berechnungen werden von VAT ausgeführt
* eventuell werden Rasterergebnisse in RasterDB gespeichert (Visualisierung, Export für Benutzer) (VAT --> RasterDB)

  
## API Details
*(Fokussiert auf Aspekte zur Umsetzung der Fallstudie)*

### TubeDB
*(Server URL in der initialen Email)*

**Authentifizierung**
* HTTP digest authentication *(Account in der initialen Email)*
* oder IP based authentication *(Freischaltung der IP des VAT-Servers)*

**Montasmitteltemperatur (CSV)**

`[SERVER]/tsdb/query_csv?plot=CaldernWald&sensor=Ta_200&aggregation=month&interpolated=false&quality=empirical&year=2017&month=8`


### RasterDB
*(Server URL in der initialen Email)*

**Authentifizierung:**
* HTTP digest authentication *(Account in der initialen Email)*
* oder IP based authentication *(Freischaltung der IP des VAT-Servers)*

**Auflistung aller Raster-Layer (JSON):**

[SERVER]/rasterdbs.json

**Metadaten eines Raster-Layers (extent, projection, u.a. JSON):**

[SERVER]/rasterdb/[LAYER_NAME]/meta.json

Metadaten des natur40_lai Layers:

[SERVER]/rasterdb/natur40_lai/meta.json

**Rasterausschnitt eines Raster-Layers (GeoTIFF):** 

[SERVER]/rasterdb/natur40_lai/raster.tiff?ext=[XMIN]%20[YMIN]%20[XMAX]%20[YMAX]

Gesamtes Raster des natur40_lai Layers (extent aus meta.json, *meta.ref.extent*): 

[SERVER]/rasterdb/[LAYER_NAME]/raster.tiff?ext=476164%205631376%20478226%205632752
