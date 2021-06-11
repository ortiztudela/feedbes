#!/bin/bash

## FeedBES PPI Analysis - Script 05 - Combine the 4 runs 
#
# Author: Isabelle Ehrlich
# Lifespan Cognitive and Brain Development (LISCO) Lab
# Goethe University Frankfurt am Main
#
## Description
#
# This script creates a "reg" folder and puts all the necessary .mat files into it, i.e.
# a 4x4 identity matrices. Also, a symbolic link is created between mean and standard nifti files.  
# It accesses the manually created template for the 2nd level, exchanges the placeholder
# "CHANGESUBJECT" with the correct subject ID and copies the file with a better fitting 
# filename to the PPI_results folder. 
#
## GO!

# Define paths to project and analysis scripts:
project_path=/home/ehrlich/DATA/2_Analysis_Folder/PIVOTAL/FeedBES
analysis_scripts=$project_path/analysis_scripts/clean/PPI/FSL

# Loop over participant ID and runs
for id in $(seq -w 01 30)
do
    subj="sub-$id" #you might have to put a 0 in front of the $ sign for single-digit IDs --> "sub-0$id"
    echo
    echo "===> Combining runs for $subj "


    cd "$project_path"/outputs/$subj/PPI_results/
 

    # Create reg-folders and put the necessary .mat files in it: 
    for run in 1 2 3 4 ; do 
        cd run$run/episem_hlr.feat/
        mkdir reg # create the reg folder
        cd reg
        echo "the reg folder was successfully created"
        cp "$analysis_scripts"/PPI_EVC_allregs/ident_ie.mat example_func2standard.mat
        cp "$analysis_scripts"/PPI_EVC_allregs/ident_ie.mat standard2example_func.mat
        ln -s ../mean_func.nii.gz standard.nii.gz
        cd ../../..
    done
    echo "===> reg folder part is completed"

    # Access 2nd level template and create and copy fsf-File:
    cp "$analysis_scripts"/PPI_EVC_allregs/template_2ndlevel_episem.fsf episem_combined_runs_$subj.fsf

    # Replace placeholder with correct subject ID:
    sed -i "s|CHANGESUBJECT|$subj|g" episem_combined_runs_$subj.fsf

    echo "Completed."
    echo

done

 
