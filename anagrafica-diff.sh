#!/bin/bash

# script for anagrafica distrbutori carburante update

if [ ! -f $1 ] || (( $# == 0 )); then
    echo "provide previous anagrafica carburanti filename as argument"
    exit
fi

OLDANA=$1
NEWANA=`date +"%Y-%m-%d"`.csv

wget -nc -O $NEWANA "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"


#SOURCEDATE=`head -1 $NEWANA | awk ' {print $3 }'`
#echo "data del dataset: " $SOURCEDATE


# unuseful rows (extrection date and header) removed
# idImpianto;Gestore;Bandiera;Tipo Impianto;Nome Impianto;Indirizzo;Comune;Provincia;Latitudine;Longitudine
sed -i -e '/^idImpianto/ d' $NEWANA
sed -i -e '/^Estrazione del/ d' $NEWANA

# same for previous anagrafica file:
sed -i -e '/^idImpianto/ d' $OLDANA
sed -i -e '/^Estrazione del/ d' $OLDANA

# extracting useful columns, reducing coordinate floats
awk -F ";" '{ printf("%s;%s;%s;%2.5f;%2.5f\n",$1,$2,$3,$9,$10) }' $NEWANA > short_$NEWANA
awk -F ";" '{ printf("%s;%s;%s;%2.5f;%2.5f\n",$1,$2,$3,$9,$10) }' $OLDANA > short_$OLDANA

echo "comparing short_$NEWANA short_$OLDANA... "

#grep -v -f short_$NEWANA short_$OLDANA > updates.csva
# using fgrep instead (regexp not needed) to speed up process
fgrep -v -f short_$NEWANA short_$OLDANA > updates_$NEWANA

echo "umap adjustments "
sed -i '1 i\ref:mise;operator;brand;lat;lon' updates_$NEWANA       
sed -i -e 's/,/ /g' -e 's/;/,/g' updates_$NEWANA
