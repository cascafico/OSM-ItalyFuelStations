# -*- coding: utf-8 -*-
print 'CSV to nested JSON converter'
print 'Twitter: @jase_thomas | Github: https://github.com/JasonThomasData'

import csv
import numbers
import sys

bigArray = []                  
spacesNumber = 1            

#filename = raw_input('\nWhat is filename, minus .csv:  ')
filename = ( str(sys.argv[1]))    
#reader = csv.reader(open(filename + '.csv'), delimiter=',')  #Data from here
reader = csv.reader(open(filename), delimiter=',')  #Data from here
f = open(filename + '.json', 'w')                             #Data goes here


# CSV READ LOOP

for row in reader:
    littleArray = []    
    for a in range(0, len(row)):      
        string = ''.join(row[a])
        if row[a] == True or row[a] == 'TRUE' or row[a] == False or row[a] == 'FALSE' or row[a] == 'Null' or row[a] == 'NULL':
            row[a] = string.lower()
        else:
            row[a] = string.replace('”','\'').replace('“','\'').replace('"','\'').replace('„','\'')   #Replaces " with '. You need the backslash to exit the ''.
        littleArray.append(row[a])
    bigArray.append(littleArray)   # Becomes bigArray[[littleArray],[littleArray],[littleArray]]


# BEHAVIOUR LOOP - each column can have up to two behaviours.

header = bigArray[0]   # The top row of the CSV file. This contains all column names and all behaviours
behaviour = []     # This is where the behaviours are kept once when we extract them from the header
littleBehaviour = []
childCount = 0
for t in range(0, len(header)):
    if header[t][len(header[t])-1] == '{':
        string = ''.join(header[t])
        header[t] = string[:len(header[t])-1]  #Header[t] becomes everything before its last letter, which is the behaviour.
        childCount = childCount + 1
        littleBehaviour.append('objectChild')
        if len(littleBehaviour) > 0:
            behaviour.append(['objectOpen', littleBehaviour[-1]])
        else:
            behaviour.append(['objectOpen', 'null'])
    elif header[t] == '}':
        childCount = childCount - 1
        if littleBehaviour[-1] == 'objectChild':
            littleBehaviour.pop()
        if len(littleBehaviour) > 0:
            behaviour.append(['objectEnd', littleBehaviour[-1]])
        else:
            behaviour.append(['objectEnd', 'null'])
    elif header[t][len(header[t])-1] == '[':
        string = ''.join(header[t])
        header[t] = string[:len(header[t])-1]  #Header[t] becomes everything before its last letter, which is the behaviour.
        childCount = childCount + 1
        littleBehaviour.append('arrayChild')
        if len(littleBehaviour) > 0:
            behaviour.append(['arrayOpen', littleBehaviour[-1]])
        else:
            behaviour.append(['arrayOpen', 'null'])
    elif header[t] == ']':
        childCount = childCount - 1
        if littleBehaviour[-1] == 'arrayChild':
            littleBehaviour.pop()
        if len(littleBehaviour) > 0:
            behaviour.append(['arrayEnd', littleBehaviour[-1]])
        else:
            behaviour.append(['arrayEnd', 'null'])
    else:
        if len(littleBehaviour) > 0:
            behaviour.append(['null', littleBehaviour[-1]])
        else:
            behaviour.append(['null', 'null'])
            
print behaviour

# PRINTING LOOP, formatting JSON

spaces = '    ' # muliplied according to function's arguments

def addLine(x, i, indentedNumber, comma, speechMarks):      #This function adds a line of JSON, with the key and relevant value
    if header[i] != '':
        print >>f, spaces * indentedNumber + '"' + header[i] + '" : ' + speechMarks + bigArray[x][i] + speechMarks + comma

def boundaries(bracket, indentedNumber, comma):          #This function adds { or } around every object
    print >>f, spaces * indentedNumber + bracket + comma

print >>f, '['      #Print to file 'f' declared above

for x in range(1, len(bigArray)):      #Loops through the rows in bigArray
    indentNumber = 0
    for i in range(0, len(header)):     #Loops through the cells in each row of bigArray

        try:
            check = int(bigArray[x][i])
        except ValueError:
            try:
                check = float(bigArray[x][i])
            except ValueError:
                check = str(bigArray[x][i])
        if isinstance(check, numbers.Number) or bigArray[x][i] == 'true' or bigArray[x][i] == 'false' or bigArray[x][i] == 'null':
            speechMarks = '' 
        else:
            speechMarks = '"'

        if i == len(header) - 1 and x + 1 != len(bigArray): 
            comma = ','
        elif i < len(header) - 1:
            if behaviour[i+1][0] == 'null' or behaviour[i+1][0] == 'objectOpen':
                comma = ','
            elif behaviour[i+1][0] == 'objectEnd':
                comma = ''
                
        if behaviour[i][0] == 'objectOpen':
            addLine(x, i, indentNumber + 1, '', '')
            indentNumber = indentNumber + 1
            boundaries('{', indentNumber, '')
        elif behaviour[i][0] == 'objectEnd':
            boundaries('}', indentNumber, comma)
            indentNumber = indentNumber - 1
        else:
            addLine(x, i, indentNumber + 1, comma, speechMarks)
    
print >>f, ']'

if childCount > 0:
    raw_input('\n Error, you have open nests that are not closed.')
    sys.exit()
elif childCount < 0:
    raw_input('\n Error, you have closed nests that are not open.')
    sys.exit()
    
f.close()

raw_input("\n Done. \n\n Hit enter to go on with conflation")
