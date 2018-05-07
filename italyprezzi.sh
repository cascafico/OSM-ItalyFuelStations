#!/bin/bash

# script lanciato periodicamente per aggiornare il layer Anagrafica distributori

ADESSO=prezzi-`date +"%Y-%m-%d"`
echo "prefisso file: " $ADESSO


wget -O $ADESSO.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"

cp $ADESSO.csv tmp/$ADESSO.csv
cd tmp

SOURCEDATE=`head -1 $ADESSO.csv | awk ' {print $3 }'`
echo "data dei dataset: " $SOURCEDATE


# rimuovo prime due linee (data estrazione e header originali)
# idImpianto;Gestore;Bandiera;Tipo Impianto;Nome Impianto;Indirizzo;Comune;Provincia;Latitudine;Longitudine
sed -i -e '1,2d' $ADESSO.csv

### esempio ottenuto:
# 3464;Benzina;1.834;0;27/04/2018 21:00:09
# 3464;Benzina;1.624;1;27/04/2018 21:00:09
# 3464;Gasolio;1.704;0;27/04/2018 21:00:09
# 3464;Gasolio;1.494;1;27/04/2018 21:00:09
# 3464;Metano;1.008;0;27/04/2018 21:00:09
# 3464;GPL;0.799;0;27/04/2018 21:00:09
# 3464;Excellium Diesel;1.574;1;27/04/2018 21:00:09


echo "metto tutto minuscolo "
tr '[:upper:]' '[:lower:]' < $ADESSO.csv > $ADESSO.csv.tmp
mv -f $ADESSO.csv.tmp $ADESSO.csv

echo "uniq solo sul campo id impianto"
echo "i csv prodotti sono da agganciare con join al layer anagrafica (qgis)"

awk -F ";" '{print $1";"$2}' $ADESSO.csv | grep 'diesel\|gasolio' | sort -u -t";" -k1,1 > diesel.csv
awk -F ";" '{print $1";"$2}' $ADESSO.csv | grep 'benzina' | sort -u -t";" -k1,1 > benzina.csv
awk -F ";" '{print $1";"$2}' $ADESSO.csv | grep 'metano' | sort -u -t";" -k1,1 > metano.csv
awk -F ";" '{print $1";"$2}' $ADESSO.csv | grep 'gpl' | sort -u -t";" -k1,1 > gpl.csv
# verificare causa 0/1 su ogni tipo di carburante awk -F ";" '{print $1";"$4}' $ADESSO.csv | grep 0 | sort -u -t";" -k1,1 > self.csv

