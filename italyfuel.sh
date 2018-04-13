#!/bin/bash

# script lanciato periodicamente per aggiornare il layer Anagrafica distributori

ADESSO=`date +"%Y-%m-%d"`
echo "prefisso file: " $ADESSO

cd tmp

wget -O $ADESSO.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"
cp $ADESSO.csv $ADESSO-orig.csv

SOURCEDATE=`head -1 $ADESSO.csv | awk ' {print $3 }'`
echo "data dei dataset: " $SOURCEDATE

# adattare al seguente csv:
# {,id,lat,lon,tags{,operator,brand,description,addr:postcode,addr:city,source:date,},}
# ,100,45.6,13,,pippo,ip,blav lkaj da blababa,33100,Udine,2018-12-03,,

# rimuovo prime due linee (data estrazione e header originali)
sed -i -e '1,2d' $ADESSO.csv

####### PULIZIE
echo "rimuovo backslash+t e doppi backslash sparsi"
sed -i -e 's/\\t//g' $ADESSO.csv
sed -i -e 's/\\\\/ /g' $ADESSO.csv

echo "rimuovo coordinate non immesse"
sed -i -e '/;NULL;NULL/d' $ADESSO.csv
########

# trim leading spaces from 6th field (indirizzo)
awk 'BEGIN{FS=OFS=";"} {gsub(/^[ \t]+|[ \t]+$/, "", $6)}1' $ADESSO.csv > trim-$ADESSO.csv
                     
# DA FARE: controllo numerico su CAP (causa interruzione conflation)
awk -v source_date="$SOURCEDATE" -F ";" '{print ";"$1";"$9";"$10";;"$2";"$3";"$6";"substr($6,length($6)-4,5)";"$7";" source_date ";;" }' trim-$ADESSO.csv > ITALY$ADESSO.csv


echo "metto iniziali maiuscole"
sed -i -e 's/.*/\L&/' -e 's/[a-z]*/\u&/g' ITALY$ADESSO.csv

echo "aggiungo header per csv2json"
sed -i '1 i\{;id;lat;lon;tags{;operator;brand;description;addr:postcode;addr:city;source:date;};}' ITALY$ADESSO.csv
echo "tolgo virgole e sostituisco puntoevirgola originle con virgola"
sed -i -e 's/,/ /g' ITALY$ADESSO.csv                     
sed -i -e 's/;/,/g' ITALY$ADESSO.csv                     
sed -i -e 's/"//g' ITALY$ADESSO.csv


echo "formatto in json per conflator"
python ../csv2json.py ITALY$ADESSO.csv 

echo "Eseguo conflation"
cd ..
conflate -i tmp/ITALY$ADESSO.csv.json -v --changes osmchanges/ITALY$ADESSO.json -o osm/ITALY$ADESSO.osm -c osmchanges/ITALY$ADESSO-preview.json profile-fuelitaly.py

