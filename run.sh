#!/bin/bash

PROVINCIE=$*
FILTERED=`echo $PROVINCIE | tr [:space:] '_'`
echo "province scelte $PROVINCIE"

# script lanciato periodicamente per aggiornare i dataset anagrafica e tipi di carburante    
# argomento sigla provincia maiuscolo (p.es "UD") per filtrare

PREZZI=prezzi-`date +"%Y-%m-%d"`
ANAGRAFICA=anagrafica-`date +"%Y-%m-%d"`

mkdir -p tmp
cd tmp

#wget -nc -O $PREZZI.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"
wget --no-check-certificate -nc -O $PREZZI.csv "https://sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"
cp $PREZZI.csv prezzo_alle_8.csv
sed -i -e '/^Estrazione/d' prezzo_alle_8.csv

#wget -nc -O $ANAGRAFICA.csv "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"
wget --no-check-certificate -nc -O $ANAGRAFICA.csv "https://sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"

# ANAGRAFICA
# replacing headers, removing quotes, extracting useful columns, reducing coordinate floats, filter province(s)
sed -i -e '/^Estrazione/d' -e '/^idImpianto/d' $ANAGRAFICA.csv
sed -i -e 's/"//g' $ANAGRAFICA.csv
awk -F ";" '{ printf("%s;%s;%s;%s;%2.5f;%2.5f\n",$1,$2,$3,$8,$9,$10) }' $ANAGRAFICA.csv  > short_$ANAGRAFICA.csv
if  [ $# -ge 1  ] 
   then 
     awk -v argomenti="$PROVINCIE" -F ";"  '{ if ( argomenti~$4 )  print $0 }' short_$ANAGRAFICA.csv  > short_$FILTERED.csv
fi
sed -i '1 i\ref:mise;operator;brand;prov;lat;lon' short_$ANAGRAFICA.csv
sed -i '1 i\ref:mise;operator;brand;prov;lat;lon' short_$FILTERED.csv     

### sample output:   
#ref:mise;operator;brand;prov;lat;lon
#7720;A.NUARA E FIGLI SRL;Pompe Bianche;AG;37.31493;13.57139
#3778;ALFONSO DI BENEDETTO CARBURANTI LUBRIFICANTI SRL;Pompe Bianche;AG;37.31239;13.58591


echo "preprocessing finished"
echo "Openrefine: please, apply prezzi operation, then choose a last update timespan (ie 1 month), then apply anagrafica operations"
echo ""
echo "optionally, clean null values in resuting json before conflation:"
echo "sed -i '/: null/d' infile.json"
echo " sed -i '/"brand" : \"\"/d' infile.json"
echo ""
echo "optionally, check with jsonlint"
echo ""
echo "example conflation: $ conflate -i <exported from openrefine>.json -v -c <preview to be loaded in audit>.json profile-mise.py"

