function [mask_mat]=prepare_func_for_eyemovements(which_sub)
%%
% This script prepares the functional data from BIDS structure (i.e.,
% compressed nifti -.nii.gz- 4D files) so that sb_eyemovements can read
% them (i.e., uncompressed nifti -.nii- 3D files). It uses fslsplit.

%% Set FSL environment
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end


for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    if ~exist([sufs.eyemov,'run1']);mkdir([sufs.eyemov,'run1']);end
    if ~exist([sufs.eyemov,'run2']);mkdir([sufs.eyemov,'run2']);end
    if ~exist([sufs.eyemov,'run3']);mkdir([sufs.eyemov,'run3']);end
    if ~exist([sufs.eyemov,'run4']);mkdir([sufs.eyemov,'run4']);end
    
    if cSub==6
        space='MNI152NLin2009cAsym';
    else
        space='T1w';
    end
    
    '******************************************'
    ['Starting ', sub_code]
    
    %% First make a copy of the nifti to keep the original directory clean
    compr_nifti4D = [sub_code, '_ses-01_task-feedBES_run-1_space-',space,'_desc-preproc_bold.nii.gz'];
    if ~exist([sufs.eyemov,'run1/', compr_nifti4D])
        cmd = sprintf('cp %s%s %s%s', [sufs.brain,'ses-01/func/'], compr_nifti4D, [sufs.eyemov,'run1/'],compr_nifti4D);
        ['Making copies...'];system(cmd);
    end
    compr_nifti4D = [sub_code, '_ses-01_task-feedBES_run-2_space-',space,'_desc-preproc_bold.nii.gz'];
    if ~exist([sufs.eyemov,'run2/', compr_nifti4D])
        cmd = sprintf('cp %s%s %s%s', [sufs.brain,'ses-01/func/'], compr_nifti4D, [sufs.eyemov,'run2/'],compr_nifti4D);
        system(cmd);
    end
    compr_nifti4D = [sub_code, '_ses-02_task-feedBES_run-3_space-',space,'_desc-preproc_bold.nii.gz'];
    if ~exist([sufs.eyemov,'run3/', compr_nifti4D])
        cmd = sprintf('cp %s%s %s%s', [sufs.brain,'ses-02/func/'], compr_nifti4D, [sufs.eyemov,'run3/'],compr_nifti4D);
        system(cmd);
    end
    compr_nifti4D = [sub_code, '_ses-02_task-feedBES_run-4_space-',space,'_desc-preproc_bold.nii.gz'];
    if ~exist([sufs.eyemov,'run4/', compr_nifti4D])
        cmd = sprintf('cp %s%s %s%s', [sufs.brain,'ses-02/func/'], compr_nifti4D, [sufs.eyemov,'run4/'],compr_nifti4D);
        system(cmd);
    end
    
    %% Split the 4D files into 3D files
    ['Splitting 4D...'];
    cd([sufs.eyemov,'run1/'])
    compr_nifti4D = [sub_code, '_ses-01_task-feedBES_run-1_space-',space,'_desc-preproc_bold.nii.gz'];
    cmd = sprintf('/usr/local/fsl/bin/fslsplit %s', compr_nifti4D);
    system(cmd);
    cd([sufs.eyemov,'run2/'])
    compr_nifti4D = [sub_code, '_ses-01_task-feedBES_run-2_space-',space,'_desc-preproc_bold.nii.gz'];
    cmd = sprintf('/usr/local/fsl/bin/fslsplit %s', compr_nifti4D);
    system(cmd);
    cd([sufs.eyemov,'run3/'])
    compr_nifti4D = [sub_code, '_ses-02_task-feedBES_run-3_space-',space,'_desc-preproc_bold.nii.gz'];
    cmd = sprintf('/usr/local/fsl/bin/fslsplit %s', compr_nifti4D);
    system(cmd);
    cd([sufs.eyemov,'run4/'])
    compr_nifti4D = [sub_code, '_ses-02_task-feedBES_run-4_space-',space,'_desc-preproc_bold.nii.gz'];
    cmd = sprintf('/usr/local/fsl/bin/fslsplit %s', compr_nifti4D);
    system(cmd);
    
    %% Now uncompress them
    ['Unzipping...']
    cmd = sprintf('gunzip %s', [sufs.eyemov,'run1/','vol*']);
    system(cmd);
    cmd = sprintf('gunzip %s', [sufs.eyemov,'run2/','vol*']);
    system(cmd);
    cmd = sprintf('gunzip %s', [sufs.eyemov,'run3/','vol*']);
    system(cmd);
    cmd = sprintf('gunzip %s', [sufs.eyemov,'run4/','vol*']);
    system(cmd);
    
    cd([main_folder '/analysis_scripts'])
end
