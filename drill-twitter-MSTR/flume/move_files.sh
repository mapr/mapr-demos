#!/bin/bash

for file in $(find ./ -name *.json)
do  
    newdir=${file:2:13}
    newfile=${file:2}
    mkdir -p ../feed/${newdir}
    mv ${file} ../feed/${newfile}
done

