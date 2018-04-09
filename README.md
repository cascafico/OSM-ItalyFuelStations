# OSM-ItalyFuelStations
Procedure to generate osm-changes maps and osm-ready files for importing fuel stations in Italy

## download and adapt source csv file
fvgfuel.sh (regional test)

## convert to json for conflator
csv2json.py

## conflate profile
File profile-fuelfvg.py will be used by 
conflate -i <input json file>  -v --changes changes.json -o result.osm -c preview.json profile-fuelfvg.py

