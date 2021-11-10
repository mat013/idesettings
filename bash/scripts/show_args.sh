#!/bin/bash

#for i; do
#   echo "$i"
#done

#for i in "${@:2}"; do echo "$i"; done

#for i in "${!foo[@]}"; do 
#  printf "%s\t%s\n" "$i" "${foo[$i]}"
#done

args=$#
for (( i=1; i<=$args; i++ )); do
    echo "Argument $i: ${!i}"
done