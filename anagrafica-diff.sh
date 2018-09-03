#!/bin/bash

# script lanciato periodicamente per aggiornare il layer Anagrafica distributori

if [ ! -f $1 ] || (( $# == 0 )); then
    echo "provide previous anagrafica carburanti filename as argument"
    exit
fi

OLDANA=$1
NEWANA=`date +"%Y-%m-%d"`.csv

wget -O $NEWANA "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"


SOURCEDATE=`head -1 $NEWANA | awk ' {print $3 }'`
echo "data del dataset: " $SOURCEDATE


# rimuovo prime due linee (data estrazione e header originali)
# idImpianto;Gestore;Bandiera;Tipo Impianto;Nome Impianto;Indirizzo;Comune;Provincia;Latitudine;Longitudine
sed -i -e '/^idImpianto/ d' $NEWANA
sed -i -e '/^Estrazione del/ d' $NEWANA

# eventualmente anche dal vecchio:
sed -i -e '/^idImpianto/ d' $OLDANA
sed -i -e '/^Estrazione del/ d' $OLDANA

awk -F ";" '{print $1";"$2";"$3";"$9";"$10}' $NEWANA > short_$NEWANA
awk -F ";" '{print $1";"$2";"$3";"$9";"$10}' $OLDANA > short_$OLDANA


