# value for OSM tag source
source = 'Mise'
#add_source = True

# do not add unique reference IDs to OSM?

#no_dataset_id = True
no_dataset_id = False
dataset_id = 'mise'

# Overpass query to use when searching OSM for data
#query = [('amenity', 'fuel'),('waterway', 'fuel')] questa chiede entrambe le condizioni
query = [('amenity', 'fuel')]

# attenzione, coord errate possono rendere enorme il bbox
# vantaggio: fa richieste multiple ad overpass
bbox = True

# italia
#bbox = [35.28,6.62,47.1,18.79]

# tags to replace on matched OSM objects
master_tags = ('operator', 'brand', 'source:date')

delete_unmatched = False
#tag_unmatched = { 
#'fixme':'non presente nel dataset MISE' 
#'amenity':None,
#'disused:amenity':'fuel'
#}


# max distance to search for a match in meters
max_distance = 80
