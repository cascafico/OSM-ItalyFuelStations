# LPG and CNG integration for Italy fuel stations

# aggiunge tag source=MiseGas
add_source = False
source = 'Mise'

# do not add unique reference IDs to OSM?

# aggiunge tag ref:<dataset_id>=<id del MISE>
# True -> relying only on geometric matching every time
no_dataset_id = True
dataset_id = 'mise'

duplicate_distance = 20

# Overpass query to use when searching OSM for data
#overpass_timeout = 120 default
overpass_timeout = 300
#query = [('amenity', 'fuel'),('waterway', 'fuel')] both conditions
#query = [('amenity', 'fuel')],[('waterway', 'fuel')]  or condition
#query = [('amenity', 'fuel'),('disused:amenity','fuel')]  namespace disused and abandoned are implicit
#query = [('amenity', 'fuel'),('ref:mise','.*')] 
#query = [('amenity', 'fuel')] 
query = [('amenity', 'fuel')],[('waterway', 'fuel')]

# parameter --osm will use indipendently generated queries, ie:
# http://overpass-turbo.eu/s/FOX
# use wget -O manual-query.osm <http_addr obtained exporting compact query>
# alternatively, run query and export raw data (export.osm)

# attenzione, coord errate possono rendere enorme il bbox
# use openrefine for lat lon ranges
# vantaggio: fa richieste multiple ad overpass
bbox = True


# tags to replace on matched OSM objects
master_tags = ('name', 'ref:mise', 'operator', 'fuel:diesel', 'fuel:octane_95', 'fuel:octane_98', 'fuel:octane_100', 'fuel:octane_101', 'fuel:lpg', 'fuel:cng','brand')

delete_unmatched = False
tag_unmatched = { 'fixme':'This object might have been dismantled, please check' }


# max distance to search for a match in meters
max_distance = 50
