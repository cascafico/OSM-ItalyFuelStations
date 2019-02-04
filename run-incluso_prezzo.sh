#!/bin/bash

PROVINCIE=$*
FILTERED=`echo $PROVINCIE | tr [:space:] '_'`
echo "provincie scelte $PROVINCIE"

# script lanciato periodicamente per aggiornare i dataset anagrafica e tipi di carburante    
# argomento sigla provincia maiuscolo (p.es "UD") per filtrare

cd tmp
PREZZI=prezzi-`date +"%Y-%m-%d"`
ANAGRAFICA=anagrafica-`date +"%Y-%m-%d"`
#PREZZI=prezzi-2018-10-08
#ANAGRAFICA=anagrafica-2018-10-08


wget -nc -O $PREZZI.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"

wget -nc -O $ANAGRAFICA.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"

# ANAGRAFICA
# replacing headers, removing quotes, extracting useful columns, reducing coordinate floats
sed -i -e '/^Estrazione/d' -e '/^idImpianto/d' $ANAGRAFICA.csv
sed -i -e 's/"//g' $ANAGRAFICA.csv
#awk -F ";" '{ printf("%s;%s;%s;%2.5f;%2.5f\n",$1,$2,$3,$9,$10) }' $ANAGRAFICA.csv > short_$ANAGRAFICA.csv
# add provincia and other provincia filtered file
awk -F ";" '{ printf("%s;%s;%s;%s;%2.5f;%2.5f\n",$1,$2,$3,$8,$9,$10) }' $ANAGRAFICA.csv  > short_$ANAGRAFICA.csv
if  [ $# -ge 1  ] 
   then 
     awk -v argomenti="$PROVINCIE" -F ";"  '{ if ( argomenti~$4 )  print $0 }' short_$ANAGRAFICA.csv  > short_$FILTERED.csv
fi
sed -i '1 i\ref:mise;operator;brand;prov;lat;lon' short_$ANAGRAFICA.csv
sed -i '1 i\ref:mise;operator;brand;prov;lat;lon' short_$FILTERED.csv     

### esempio ottenuto:
#ref:mise;operator;brand;prov;lat;lon
#7720;A.NUARA E FIGLI SRL;Pompe Bianche;AG;37.31493;13.57139
#3778;ALFONSO DI BENEDETTO CARBURANTI LUBRIFICANTI SRL;Pompe Bianche;AG;37.31239;13.58591

# PREZZI
# rimuovo prime due linee (data estrazione e header originali)
# idImpianto;Gestore;Bandiera;Tipo Impianto;Nome Impianto;Indirizzo;Comune;Provincia;Latitudine;Longitudine
sed -i -e '/^Estrazione/d' -e '/^idImpianto/d' $PREZZI.csv
### esempio ottenuto:
# 3464;Benzina;1.834;0;27/04/2018 21:00:09
# 3464;Gasolio;1.704;0;27/04/2018 21:00:09
# 3464;Metano;1.008;0;27/04/2018 21:00:09
# 3464;GPL;0.799;0;27/04/2018 21:00:09
# 3464;Excellium Diesel;1.574;1;27/04/2018 21:00:09


echo "metto carburanti tutto minuscolo "
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

awk -F ";" '{ if (match($2, "benzina") > 0 ) { print $1";yes;"$5";"$3 } }' $PREZZI.csv | sort -n -u -t";" -k1,1 > benzina.csv
awk -F ";" '{ if ( (match($2, "diesel") > 0) || (match($2, "gasolio")) > 0)  { print $1";yes;"$5";"$3 } }' $PREZZI.csv | sort -n -u -t";" -k1,1  > diesel.csv
awk -F ";" '{ if (match($2, "metano") > 0 ) { print $1";yes;"$5";"$3 } }' $PREZZI.csv | sort -n -u -t";" -k1,1 > cng.csv
awk -F ";" '{ if (match($2, "gpl") > 0 ) { print $1";yes;"$5";"$3 } }' $PREZZI.csv | sort -n -u -t";" -k1,1 > lpg.csv

sed -i '1 i\ref:mise;fuel:cng;source:date;price' cng.csv     
sed -i '1 i\ref:mise;fuel:lpg;source:date;price' lpg.csv     
sed -i '1 i\ref:mise;fuel:octane_95;source:date;price' benzina.csv     
sed -i '1 i\ref:mise;fuel:diesel;source:date;price' diesel.csv     

# SELF SERVICE - costo carburante self o meno (lasciamo perdere)
# verificare causa 0/1 su ogni tipo di carburante awk -F ";" '{print $1";"$4}' $PREZZI.csv | grep 0 | sort -u -t";" -k1,1 > self.csv
# basta uno con isSelf:
#awk -F ";" '{ if ($4 == 0) { print $1";no" } }' $PREZZI.csv | sort -u -t";" -k1,1 > self.csv
# forse meglio cercare quelli che non hanno neanche un isSelf
# awk -F ";" '{print $1";"$4}' prezzi-2018-05-03.csv   | sort -u -t";" -k1,4

echo ""
echo "i file cng.csv, lpg.csv,  diesel.csv e benzina.csv sono pronti per essere joined a tmp/short_$ANAGRAFICA.csv con openrefine"
echo ""
echo "... il join e' incluso nel file openrefine_operations.json da applicare a openrefine"

echo ""
echo "usa operefine per esportare in json per la conflation"
echo "per esportare in json applica il operefine_export.template"
echo ""
echo "ricorda di togliere i valori nulli prima della conflation:"
echo "sed -i -e '/\"fuel:cng\" : null/d'  -e '/\"fuel:lpg\" : null/d' -e '/\"brand\" : \"\",/d' <json esportato da openrefine>.json"
#     sed -i -e '/\"fuel:cng\" : null/d'  -e '/\"fuel:lpg\" : null/d' -e '/\"brand\" : \"\",/d' <json esportato da openrefine>         

#conflate -i <json esportato da openrefine> -v --changes changes_mise.json -o result-mise.osm -c preview.json profile-mise.py

