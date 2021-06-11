%% FeedBES mask corregistration
% This script is merely a wrapper to loop over participants to register the
% ROI atlas-based masks used in FeedBES study

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])
output=[];here=cd;

% Where are the masks?
mask_folder=[main_folder, '/masks/'];

% What are the masks' filenames?
mask_names{1}='vmpfc_cortex.nii.gz';
mask_names{2}='LOC_neurosynth.nii.gz';

which_sub=[30];
% which_sub=6;
%% Loop through subjects
for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    % Loop through masks
    for cMask=1:length(mask_names)
        %% Which mask?
        mask_file=[mask_folder, mask_names{cMask}];
        thr_file=[mask_file(1:end-7), '_thr.nii.gz'];
        % Let's threshold the mask
        system(sprintf('fslmaths %s -thr 5 %s', mask_file, thr_file))
        mask_file=thr_file;
        
        %% Which reference?
        ref_im=[sufs.brain, 'ses-01/func/', sub_code, '_ses-01_task-feedBES_run-1_space-T1w_boldref.nii.gz'];
        
        %% Trf from fmriprep
        trf_file=[sufs.brain, 'anat/', sub_code, '_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5'];
        
        %% Name of the output?
        out_image=[sufs.mask, sub_code, '_', mask_names{cMask}(1:end-7), '_correg.nii.gz'];
        
        %% Register
            cd(sufs.funct)
            atlas_mask_correg(mask_file, ref_im, trf_file, out_image)
    end
end
cd(here)