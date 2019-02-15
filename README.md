# OSM-ItalyFuelStations
Procedure to generate osm-changes maps and osm-ready files for importing/maintaining fuel stations in Italy. Please refer to import wiki page: https://wiki.openstreetmap.org/wiki/Import/Catalogue/ItalyFuelStations
## Requires
openrefine http://openrefine.org/download.html

## optional
jsonlint tool (optional, to check json syntax)

## Steps
### download and manage source csv files
./run.sh <province abbreviation(s) space separated, ie: UD GO PN TS>
two files will be written: anagrafica (operator, addres, coordinates etc) and prezzi (prices, survey date, fuel types)

### openrefine
#### create projects prezzi and anagrafica
#### apply operations 
since anagrafica reads prezzi, follow the sequence:
apply operations in file: prezzi.operations
apply operations in file: anagrafica.operations
#### convert to json for conflator
export template
file: anagrafica.export          

### conflate & profile
file: profile-mise.py used by...    
conflate -i <input json file>  -v -c preview.json profile-mise.py   
note: conflator approximate AOI with big squares: better use overpass-turbo manually, export data and run conflator with --osm option

### Audit
upload preview.json to http://audit.osmz.ru/ 
wait for community checks...

### post-audited adjustments
- source:date should be removed from nodes (JOSM) (added later in changeset upload)
- remove any reference to brand:en=Independent or brand=Pompe Bianche (JOSM)


## example maintenance
./run.sh UD TS PN GO
openrefine load prezzi_alle_8.csv             
  transform todate 
  facet timeline
  remove old fuel stations (either via slide timeline facet and customizing epochs in prezzi.operationa)
openrefine load anagrafica and apply operations
  several replaces 
  facet and remove rows by noupdate=true
sed -i -e '/\"fuel:diesel\" : null/d'  -e '/\"fuel:octane_95\" : null/d' -e '/\"fuel:octane_98\" : null/d' -e '/\"fuel:octane_100\" : null/d' -e '/\"fuel:octane_101\" : null/d' short_UD_TS_PN_GO.txt.json
check result json: 
  jsonlint short_UD_TS_PN_GO.txt.json
conflate -i short_UD_TS_PN_GO.txt.json -v -c preview_UD_TS_PN_GO.json profile-mise.py

