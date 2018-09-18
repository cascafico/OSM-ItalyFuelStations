# aggiunge tag source=MiseGas
add_source = False
source = 'MiseGas'

# do not add unique reference IDs to OSM?

# aggiunge tag ref:<dataset_id>=<id del MISE>
no_dataset_id = True
#dataset_id = 'mise'

# Overpass query to use when searching OSM for data
#overpass_timeout = 120 default
overpass_timeout = 180
#query = [('amenity', 'fuel'),('waterway', 'fuel')] questa chiede entrambe le condizioni
#query = [('amenity', 'fuel'),('disused:amenity','fuel')] i namespace disused ed abandoned sono impliciti
#query = [('amenity', 'fuel')],[('waterway', 'fuel')] 
#query = [('amenity', 'fuel'),('ref:mise')] 
query = [('amenity', 'fuel')] 

# attenzione, coord errate possono rendere enorme il bbox
# vantaggio: fa richieste multiple ad overpass
bbox = True

# italia
#bbox = [35.28,6.62,47.1,18.79]

# tags to replace on matched OSM objects
#master_tags = ('ref:mise', 'operator', 'brand', 'fuel:lpg', 'fuel:cng')
master_tags = ('fuel:lpg', 'fuel:cng')
#master_tags = ('fuel:lpg')

delete_unmatched = False
#tag_unmatched = { 'fixme':'This object might have been dismantled, please check' }


# max distance to search for a match in meters
max_distance = 80
