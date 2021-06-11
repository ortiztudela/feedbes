%% FeedBES PPI Analysis - Script 00 - Extract signal from a mask using fslmeants
%
% Authors: Javier Ortiz-Tudela feat. Isabelle Ehrlich
% Lifespan Cognitive and Brain Development (LISCO) Lab
% Goethe University Frankfurt am Main
%
%% Description
%
% This script is just a wrapper to loop over participants and runs to
% extract the signal for the preferred ROI. In our case it is the EVC and
% the LOC. 

%% GO!

% set FSL environment
setenv('FSLDIR','/home/ehrlich/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be

% Get the path to the main folder
if strcmpi(getenv('USERNAME'),'ehrlich') %strcmpi(S1,S2) compares S1 and S2 and returns either 1 (true) or 0 (false)  
    main_folder= '/home/ehrlich/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USERNAME'),'ortiz')
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
end


% Which participants do you want to run?
which_sub = [1:5,7:30];


% Which ROI?
ROI= 'v1_periph'; %'LOC_neurosynth';


% Make folders for the mask files for every participant in order to prevent a mess in the Results folder.   
if ROI == 'v1_periph'
    for cSub = which_sub
        [sufs,sub_code]=feedBES_getdir(main_folder, cSub); %Get folder structure
        if ~exist([sufs.outputs, 'PPI_results/V1_timecourse/'])
            mkdir([sufs.outputs, 'PPI_results/V1_timecourse/']); %create new folder 
        end
    end
elseif ROI == 'LOC_neurosynth'  
    for cSub = which_sub
        [sufs,sub_code]=feedBES_getdir(main_folder, cSub); %Get folder structure
        if ~exist([sufs.outputs, 'PPI_results/LOC_timecourse/'])
            mkdir([sufs.outputs, 'PPI_results/LOC_timecourse/']); %create new folder 
        end
    end
end



% Check whether there is a Nifti file of the mask. This file might result in an error. So, if there is one, remove it.
%for cSub = which_sub
%    if exist([sufs.mask, sub_code, '_LOC_neurosynth_correg.nii.gz'])
%       system(['rm ' sufs.mask, sub_code, '_LOC_neurosynth_correg.nii']);
%    end
%end


% Loop through participants
for cSub = which_sub
    
    ['Starting sub number ', num2str(cSub)]
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    % First we need the mask name
    mask_file=[sufs.mask, sub_code, '_', ROI, '_correg'];
    
    for cRun=1:4
        ['Starting run number ', num2str(cRun)]
        % Then we need the functional images
        if cRun<3
            functional_file=[sufs.brain, 'ses-01/func/',sub_code, '_ses-01_task-feedBES_run-',num2str(cRun), '_space-T1w_desc-preproc_bold.nii.gz'];
        else
            functional_file=[sufs.brain, 'ses-02/func/',sub_code, '_ses-02_task-feedBES_run-',num2str(cRun), '_space-T1w_desc-preproc_bold.nii.gz'];
        end
        
        if ROI == 'v1_periph'
            % Now we need the output name
            output_file=[sufs.outputs, 'PPI_results/V1_timecourse/', sub_code, '_', ROI, '_run', num2str(cRun), '_ts.txt'];
        elseif ROI == 'LOC_neurosynth'
            output_file=[sufs.outputs, 'PPI_results/LOC_timecourse/', sub_code, '_', ROI, '_run', num2str(cRun), '_ts.txt'];
        end
        % Now run the exraction by means of fslmeants
        cmd=['fslmeants -i ',  functional_file, ' -o ', output_file, ' -m ', mask_file];
        %     cmd=['sh extract_timecourse.sh ', functional_file, ' ', output_file, ' ', mask_file]
        system(cmd)
        
    end
    
end