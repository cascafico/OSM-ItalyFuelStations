#!/bin/bash

# script lanciato periodicamente per aggiornare il layer Anagrafica distributori

ADESSO=`date +"%Y-%m-%d"`
echo "prefisso file: " $ADESSO
cd tmp

#wget -O $ADESSO.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"

SOURCEDATE=`head -1 $ADESSO.csv | awk ' {print $3 }'`
echo "data dei dataset: " $SOURCEDATE

# adattare al seguente csv:
# {,id,lat,lon,tags{,operator,brand,description,addr:postcode,addr:city,source:date,},}
# ,100,45.6,13,,pippo,ip,blav lkaj da blababa,33100,Udine,2018-12-03,,

echo "filtro per provincie"
awk -v source_date="$SOURCEDATE" -F ";" '{ if (($8 == "GO")||($8 == "UD")||($8 == "TS")||($8 == "PN")) {print ";"$1";"$9";"$10";;"$2";"$3";"$6";"substr($6,length($6)-4,5)";"$7";" source_date ";;"} }' $ADESSO.csv > FVG$ADESSO.csv

echo "metto iniziali maiuscole"
sed -i -e 's/.*/\L&/' -e 's/[a-z]*/\u&/g' FVG$ADESSO.csv

# echo "aggiugo ultimo campo source:date" $SOURCEDATE
# sed -i -e "s/$/;$SOURCEDATE/" FVG$ADESSO.csv


echo "aggiungo header per csv2json"
sed -i '1 i\{;id;lat;lon;tags{;operator;brand;description;addr:postcode;addr:city;source:date;};}' FVG$ADESSO.csv
echo "tolgo virgole e sostituisco puntoevirgola originle con virgola"
sed -i -e 's/,/ /g' FVG$ADESSO.csv                     
sed -i -e 's/;/,/g' FVG$ADESSO.csv                     
sed -i -e 's/"//g' FVG$ADESSO.csv

# a questo punto il file pronto per 
# http://www.convertcsv.com/csv-to-json.htm

# python CSVtoNestedJSON.py FVG$ADESSO.csv come passarlo al comando?

echo "copio FVG$ADESSO.csv in http://bpi.uk.to/osm/latest-FVG.csv"
scp -P 2204 FVG$ADESSO.csv pi@lampone.zapto.org:/var/www/osm/latest-FVG.csv
echo ""
echo "andare a http://www.convertcsv.com/csv-to-json.htm "
echo "ed inserire load from URL http://bpi.uk.to/osm/latest-FVG.csv"
echo ""
echo "una volta generato e scaricato eseguire git"
echo ""
