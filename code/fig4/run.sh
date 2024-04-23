#!/bin/bash

for i in {6..10}; do
    a=$(bc <<< "0.5 + 0.05 * $i")
    echo ""
    echo $a
    #launch the submission script
    julia fig.jl $a
done
 
