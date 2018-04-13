# value for OSM tag source
source = 'Mise'

# do not add unique reference IDs to OSM?

no_dataset_id = True
dataset_id = 'mise'

# Overpass query to use when searching OSM for data
query = [('amenity', 'fuel', 'waterway', 'fuel')]
bbox = [35.28,6.62,47.1,18.79]

# tags to replace on matched OSM objects
master_tags = ('operator', 'brand', 'description', 'addr:postcode', 'addr:city', 'source:date')

delete_unmatched = False
#tag_unmatched = { 
#'fixme':'non presente nel dataset MISE' 
#'amenity':None,
#'disused:amenity':'fuel'
#}


# max distance to search for a match in meters
max_distance = 80
