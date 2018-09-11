#!/bin/bash

# script lanciato periodicamente per aggiornare il layer Anagrafica distributori

cd tmp
ADESSO=prezzi-`date +"%Y-%m-%d"`
echo "prefisso file: " $ADESSO

#wget -O $ADESSO.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"


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

# tipi di carburante eventualmente da discriminare:
# benzina
# benzina plus 98
# benzina shell v power
# benzina speciale
# benzina wr 100
# blu diesel alpino
# blue diesel
# blue super
# diesel e+10
# dieselmax
# diesel shell v power
# excellium diesel
# f101
# gasolio
# gasolio alpino
# gasolio artico
# gasolio artico igloo
# gasolio ecoplus
# gasolio gelo
# gasolio oro diesel
# gasolio premium
# gasolio speciale
# gp diesel
# gpl
# hi-q diesel
# hiq perform+
# magic diesel
# metano
# r100
# v-power
# v-power diesel

echo "uniq solo sul campo id impianto"
echo "i csv prodotti sono da agganciare con join al layer anagrafica (qgis)"

awk -F ";" '{ if (match($2, "benzina") > 0 ) { print $1";yes" } }' $ADESSO.csv | sort -n -u -t";" -k1,1 > benzina.csv
awk -F ";" '{ if ( (match($2, "diesel") > 0) || (match($2, "gasolio")) > 0)  { print $1";yes" } }' $ADESSO.csv | sort -n -u -t";" -k1,1  > diesel.csv
awk -F ";" '{ if (match($2, "metano") > 0 ) { print $1";yes" } }' $ADESSO.csv | sort -n -u -t";" -k1,1 > cng.csv
awk -F ";" '{ if (match($2, "gpl") > 0 ) { print $1";yes" } }' $ADESSO.csv | sort -n -u -t";" -k1,1 > lpg.csv


# genero liste di ref:mise con varie tipologie
awk -F ";" '{ if (match($2, "metano") > 0 ) { print $1 } }' $ADESSO.csv | sort -n -u -t";" -k1,1 > ref.metano
awk -F ";" '{ if (match($2, "gpl") > 0 ) { print $1 } }' $ADESSO.csv | sort -n -u -t";" -k1,1 > ref.gpl

# aggiungo colonne tipologie
# vedi https://unix.stackexchange.com/questions/269513/merge-files-based-on-matching-of-first-column

awk -F";" 'FNR==NR{a[$1]=$2 FS $3;next} $1 in a {print $0";yes"}' ref.metano ../2018-09-03.csv > 2018-09-03.csv.2
awk -F";" 'FNR==NR{a[$1]=$2 FS $3;next} $1 in a {print $0";yes"}' ref.gpl 2018-09-03.csv.2 > 2018-09-03.csv.3
awk 'BEGIN {print "ref:mise;operator;fuel:lpg;fuel:cng"}; {print}' 2018-09-03.csv.3 > 2018-09-03.csv.4

echo "aggiungo headers fuel:"
sed -i '1 i\id;fuel:diesel' diesel.csv
sed -i '1 i\id;fuel:lpg' lpg.csv
sed -i '1 i\id;fuel:cng' cng.csv
sed -i '1 i\id;fuel:octane_95' benzina.csv


# SELF SERVICE
# verificare causa 0/1 su ogni tipo di carburante awk -F ";" '{print $1";"$4}' $ADESSO.csv | grep 0 | sort -u -t";" -k1,1 > self.csv
# basta uno con isSelf:
awk -F ";" '{ if ($4 == 1) { print $1";yes" } }' $ADESSO.csv | sort -u -t";" -k1,1 > self.csv
sed -i '1 i\id;automated' self.csv

# forse meglio cercare quelli che non hanno neanche un isSelf
# awk -F ";" '{print $1";"$4}' prezzi-2018-05-03.csv   | sort -u -t";" -k1,4
