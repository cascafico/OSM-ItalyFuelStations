# OSM-ItalyFuelStations
Procedure to generate osm-changes maps and osm-ready files for importing fuel stations in Italy. Please refer to import wiki page: https://wiki.openstreetmap.org/wiki/Import/Catalogue/ItalyFuelStations

## download and adapt source csv file
run.sh

## convert to json for conflator
openrefine
### operations to be performed
file: openrefine_operations.json
### export template
file: openrefine_export.template
housekeeping: sed -i -e '/\"fuel:cng\" : null/d'  -e '/\"fuel:lpg\" : null/d' -e '/\"brand\" : \"\",/d' <json to be conflated>

## conflate profile
file: profile-mise.py used by... 
conflate -i <input json file>  -v --changes osmchanges/changes.json -o osm/result.osm -c preview/preview.json profile-mise.py

## Audit
file to be uploaded: preview/preview.json 


## audited adjustments
- source:date should be removed from nodes (JOSM) (added later in changeset upload)
- new POIs don't have amenity=fuel tag (fix profile?), added by JOSM to the following selection:
   amenity="" and waterway=""
- remove any reference to brand:en=Independent or brand=Pompe Bianche (JOSM)

