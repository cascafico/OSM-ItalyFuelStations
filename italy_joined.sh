#!/bin/bash

# script lanciato periodicamente per aggiornare il dataset tipi di carburante    

cd tmp
PREZZI=prezzi-`date +"%Y-%m-%d"`
ANAGRAFICA=anagrafica-`date +"%Y-%m-%d"`

wget -nc -O $PREZZI.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"

wget -nc -O $ANAGRAFICA.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"

# extracting useful columns, reducing coordinate floats
sed -i -e '/^Estrazione/d' -e '/^idImpianto/d' $ANAGRAFICA.csv
awk -F ";" '{ printf("%s;%s;%s;%2.5f;%2.5f\n",$1,$2,$3,$9,$10) }' $ANAGRAFICA.csv > short_$ANAGRAFICA.csv

# rimuovo prime due linee (data estrazione e header originali)
# idImpianto;Gestore;Bandiera;Tipo Impianto;Nome Impianto;Indirizzo;Comune;Provincia;Latitudine;Longitudine
sed -i -e '/^Estrazione/d' -e '/^idImpianto/d' $PREZZI.csv


### esempio ottenuto:
# 3464;Benzina;1.834;0;27/04/2018 21:00:09
# 3464;Benzina;1.624;1;27/04/2018 21:00:09
# 3464;Gasolio;1.704;0;27/04/2018 21:00:09
# 3464;Gasolio;1.494;1;27/04/2018 21:00:09
# 3464;Metano;1.008;0;27/04/2018 21:00:09
# 3464;GPL;0.799;0;27/04/2018 21:00:09
# 3464;Excellium Diesel;1.574;1;27/04/2018 21:00:09


echo "metto tutto minuscolo "
tr '[:upper:]' '[:lower:]' < $PREZZI.csv > $PREZZI.csv.tmp
mv -f $PREZZI.csv.tmp $PREZZI.csv

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

awk -F ";" '{ if (match($2, "benzina") > 0 ) { print $1";yes" } }' $PREZZI.csv | sort -n -u -t";" -k1,1 > benzina.csv
awk -F ";" '{ if ( (match($2, "diesel") > 0) || (match($2, "gasolio")) > 0)  { print $1";yes" } }' $PREZZI.csv | sort -n -u -t";" -k1,1  > diesel.csv
awk -F ";" '{ if (match($2, "metano") > 0 ) { print $1";yes" } }' $PREZZI.csv | sort -n -u -t";" -k1,1 > cng.csv
awk -F ";" '{ if (match($2, "gpl") > 0 ) { print $1";yes" } }' $PREZZI.csv | sort -n -u -t";" -k1,1 > lpg.csv


# SELF SERVICE
# verificare causa 0/1 su ogni tipo di carburante awk -F ";" '{print $1";"$4}' $PREZZI.csv | grep 0 | sort -u -t";" -k1,1 > self.csv
# basta uno con isSelf:
awk -F ";" '{ if ($4 == 1) { print $1";yes" } }' $PREZZI.csv | sort -u -t";" -k1,1 > self.csv

# forse meglio cercare quelli che non hanno neanche un isSelf
# awk -F ";" '{print $1";"$4}' prezzi-2018-05-03.csv   | sort -u -t";" -k1,4


# i file <tipocarburante>.csv sono pronti per essere joined in openrefine con:
# Create new column fuel:cng based on column ref:mise by filling yyy rows with grel:cell.cross("cng", "ref:mise").cells["fuel:cng"].value[0]
# Create new column fuel:lpg based on column ref:mise by filling xxx rows with grel:cell.cross("lpg", "ref:mise").cells["fuel:lpg"].value[0]

