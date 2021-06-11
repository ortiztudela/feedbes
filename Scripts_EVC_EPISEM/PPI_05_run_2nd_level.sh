#!/bin/bash

## FeedBES PPI Analysis - Script 05 - Run the 2nd level
#
# Authors: Javier Ortiz-Tudela feat. Isabelle Ehrlich
# Lifespan Cognitive and Brain Development (LISCO) Lab
# Goethe University Frankfurt am Main
#
## Description
#
# This little script runs the previously created design files for the 2nd level.
# The results are saved in the folder that is specified in the according design file.
#
## GO!

project_path=/home/ehrlich/DATA/2_Analysis_Folder/PIVOTAL/FeedBES

# Loop over participants:
for id in $(seq -w 01 30 )
do
    subj="sub-$id" 
    echo
    echo "===> Starting 2nd level for $subj "


    cd "$project_path"/outputs/$subj/PPI_results/
    
    # Call the design file that contains the 2st levels results of all runs and run it:  
    feat episem_combined_runs_$subj.fsf
    cd ..
    
    echo "===> 2nd level finished"

done
