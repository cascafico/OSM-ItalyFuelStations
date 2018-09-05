#!/bin/bash

# script for generating mapillary layer from coords read from file
# extraction query http://overpass-turbo.eu/s/BEW
# sample output:
# 1528;10.5229253;45.4560895
#39376;10.7984679;45.4990070
#10404;9.9344513;45.8843891
#11955;10.8200000;45.4433333
#30726;9.9363600;45.8874740


wget -n -O fixme.lst "http://overpass-api.de/api/interpreter?data=%5Bout%3Acsv%28%22ref%3Amise%22%2C%3A%3Alon%2C%3A%3Alat%3Bfalse%3B%22%3B%22%29%5D%5Btimeout%3A25%5D%3Barea%283600365331%29%2D%3E%2EsearchArea%3B%28node%5B%22amenity%22%3D%22fuel%22%5D%5B%22fixme%22%7E%22name%22%5D%28area%2EsearchArea%29%3Bway%5B%22amenity%22%3D%22fuel%22%5D%5B%22fixme%22%7E%22name%22%5D%28area%2EsearchArea%29%3Brelation%5B%22amenity%22%3D%22fuel%22%5D%5B%22fixme%22%7E%22name%22%5D%28area%2EsearchArea%29%3B%29%3Bout%20center%3B%0A"

awk -F ";" '{ print "https://a.mapillary.com/v3/images?client_id=cjN3UkdxZktRcTlSbzFlenB5ZmZCdzo3ZmI1YWUyNTMzZmI0Mzhh&closeto="$2","$3 }' fixme.lst  > url.lst

wget -i url.lst -O mpl.geojson

