#!/bin/bash

#Change this if your environment needs that
ImportDir=/home/$(whoami)/Documents

#Loop through all of the .ova files in $ImportDir
for ova in $ImportDir/*.ova; do
    #Import one of the .ova files
    vboxmanage import $ova
#End the ova for loop
done