% Creates SPM.mat and computes GLM
% Author: González-García (Ghent Uni)
% Modified: Ortiz-Tudela (Goethe Uni)

function glm_tarmap_SPM(which_sub)

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
    %     main_folder= '/home/javier/Documents/home_office/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
% Clear in case an older version of SPM was added to the path
% rmpath(genpath('spm8/'))
% addpath(genpath('spm12/'))

%% start looping over subjects
for cSub = which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    if ~exist([sufs.spm, 'tarmap_spm/']);mkdir([sufs.spm, 'tarmap_spm/']);end
    
    % Create condition files
    create_condFile_tarmap_SPM_LSU(cSub)
    
    if cSub~=6
        space = 'T1w';
    else
        space = 'MNI152NLin2009cAsym';
    end
    
    % Gunzip nifti
    if ~exist([sufs.brain, 'ses-01/func/', sub_code, '_ses-01_task-tarmap_space-',space,'_desc-preproc_bold.nii'])
        gunzip([sufs.brain, 'ses-01/func/', sub_code, '_ses-01_task-tarmap_space-',space,'_desc-preproc_bold.nii.gz']);
    end
    %% Fun beggins
    matlabbatch{1}.spm.stats.fmri_spec.dir = {[sufs.spm, 'tarmap_spm/']}; % Output folder
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.8; % TR
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 72; % n slices
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 36; % reference slice for slicetime correction
    
    %% first run
    filter = ['^', sub_code, '_ses-01_task-tarmap_space-',space,'_desc-preproc_bold.nii$'] ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(spm_select('FPList',[sufs.brain, 'ses-01/func/'],filter));
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {[sufs.beh, '/spm_LSU_tarmap.mat']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
    %%  model spec
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    %% model estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
    
    gzip([sufs.brain, 'ses-01/func/', sub_code, '_ses-01_task-tarmap_space-',space,'_desc-preproc_bold.nii']);
    
end
end