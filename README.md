# OSM-ItalyFuelStations
Procedure to generate osm-changes maps and osm-ready files for importing fuel stations in Italy

## download and adapt source csv file
fvgfuel.sh (regional test)

## convert to json for conflator
csv2json.py

## conflate profile
File profile-fuelfvg.py will be used by 
conflate -i <input json file>  -v --changes changes.json -o result.osm -c preview.json profile-fuelfvg.py

# After audit:
## audit applied to new osm:
conflate -i original.csv.json -v -a audit_IFS.json  --changes osmchanges/audit.json -o osm/audit.osm -c osmchanges/audit-preview.json profile-noaddr.py


## audited adjustments
- source:date should be removed from nodes by JOSM (added later in changeset upload)
- new POIs doesn't have amenity=fuel flag, added by JOSM to the followinf selection:
amenity="" and waterway=""

