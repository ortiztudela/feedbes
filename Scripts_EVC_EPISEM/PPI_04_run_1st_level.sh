#!/bin/bash

## FeedBES PPI Analysis - Script 04 - Run the 1st level
#
# Author: Isabelle Ehrlich
# Lifespan Cognitive and Brain Development (LISCO) Lab
# Goethe University Frankfurt am Main
#
## Description
#
# This little script runs the previously created design files for the first level.
# The results are saved in the folder that is specified in the according design file.
#
## GO!


# Define the path:
project_path=/home/ehrlich/DATA/2_Analysis_Folder/PIVOTAL/FeedBES

# Loop over the participants and runs:
for id in $ 01 #$(seq -w 24 27 )
do
    subj="sub-$id"
    echo
    echo "===> Starting first level for $subj "

    # Specify output folder/directory:
    cd "$project_path"/outputs/$subj/PPI_results/
 

    #Run the design files for each run:
    for run in 1 2 3 4 ; do 
        cd run$run/
        feat $subj""_design-file.fsf
        cd ..
    done
    echo "===> First level finished"

done
