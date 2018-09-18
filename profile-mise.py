# LPG and CNG integration for Italy fuel stations
# aggiunge tag source=MiseGas
add_source = False
source = 'Mise'

# do not add unique reference IDs to OSM?

# aggiunge tag ref:<dataset_id>=<id del MISE>
no_dataset_id = True
#dataset_id = 'mise'

# Overpass query to use when searching OSM for data
#overpass_timeout = 120 default
overpass_timeout = 180
#query = [('amenity', 'fuel'),('waterway', 'fuel')] both conditions
#query = [('amenity', 'fuel')],[('waterway', 'fuel')]  or condition
#query = [('amenity', 'fuel'),('disused:amenity','fuel')]  namespace disused and abandoned are implicit
#query = [('amenity', 'fuel'),('ref:mise')] 
query = [('amenity', 'fuel')] 

# parameter --osm will use indipendently generated queries, ie:
# http://overpass-turbo.eu/s/BZq
# http://overpass-turbo.eu/s/BZM (amenity=fuel and fuel:cng or fuel:lpg not "yes" 
# use wget -O manual-query.osm <http_addr obtained exporting compact query>

# attenzione, coord errate possono rendere enorme il bbox
# use openrefine for lat lon ranges
# vantaggio: fa richieste multiple ad overpass
bbox = True

# italia
#bbox = [35.28,6.62,47.1,18.79]

# tags to replace on matched OSM objects
master_tags = ('fuel:lpg', 'fuel:cng')

delete_unmatched = False
#tag_unmatched = { 'fixme':'This object might have been dismantled, please check' }


# max distance to search for a match in meters
max_distance = 80
