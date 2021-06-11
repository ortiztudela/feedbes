#!/bin/bash

## FeedBES PPI Analysis - Script 08 - Run the 3rd level
#
# Author: Isabelle Ehrlich
# Lifespan Cognitive and Brain Development (LISCO) Lab
# Goethe University Frankfurt am Main
#
## Description
#
# This little script runs the disgn file for the 3rd level that you created manually beforehand.
# It gives you the connectivity results between ROI and rest of the brain across all participants/ sessions/ runs.
# The results are saved in the folder that is specified in the design file.
#
## GO!

project_path=/home/ehrlich/DATA/2_Analysis_Folder/PIVOTAL/FeedBES

echo "===> Starting 3rd level "

# Go to the path where you stored the 3rd level design file and run it: 
cd "$project_path"/analysis_scripts/clean/PPI/FSL/PPI_EVC_allregs/

feat Design_file_3rdlevel_episem_allregs.fsf

cd ..

echo "===> 3rd level finished"



