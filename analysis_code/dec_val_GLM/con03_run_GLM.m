%% FeedBES. FeedBack signals from Episodic and Semantic memories"
% author: "Javier Ortiz-Tudela" (Goethe Uni)
% ---
% *Contact: ortiztudela@psych.uni-frankfurt.de*
% *date: Jul 08 2020*

% Creates conditions files (per run) for SPM

which_sub=[1:5,7:30];

% Which classification?
cAnal=5;
if cAnal==2; class_label='scn';elseif cAnal==3; class_label='obj';
elseif cAnal==5; class_label='XC';end

%% Add necessary paths
% Main folder.
if strcmpi(getenv('USERNAME'),'javier')
    samba_folder= '/home/javier/pepe/';
    spm_folder='/home/javier/pepe/2_Analysis_Folder/_common_software/spm12';
    main_folder='/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USER'), 'ortiz')
        samba_folder= '/home/javier/pepe/';
    spm_folder='/home/ortiz/DATA/2_Analysis_Folder/_common_software/spm12';
    main_folder='/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
else % Replace below with the paths for your computer
    samba_folder= 'smb://ntsamba1.server.uni-frankfurt.de/entwicklungspsychologie';
    spm_fodler='/Users/Nina/spm12'; %add path to my spm
    main_folder= [samba_folder, '/2_Student_Analysis/PIVOTAL/FeedBES'];
end

% Add SPM12 to the path
addpath(spm_folder) % error
ROI_label='LOC_neurosynth';
% Loop through subjects
for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    space = 'MNI152NLin2009cAsym';
    ['Starting ', sub_code]
    
    % Gunzip nifti % compressed nii.gz brain data
    for cRun=1:4
        ['Gunzipping run ', num2str(cRun)]
        if cRun<3;ses_nb='01';elseif cRun>2;ses_nb='02';end
        if ~exist([sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-preproc_bold.nii'])
            gunzip([sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-preproc_bold.nii.gz']);
        end
        if ~exist([sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-sm_bold.nii'])
            if  ~exist([sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-sm_bold.nii.gz'])
                spm_smooth([sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-preproc_bold.nii'],...
                    [sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-sm_bold.nii'],...
                    6);
            else
                gunzip([sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-sm_bold.nii.gz'])
            end
        end
    end

    % Load dec values (already convolved)
    load([sufs.connect, 'dec_values_', ROI_label, '_', class_label, '_epi_run1.mat']);epi_run1=coPM;
    load([sufs.connect, 'dec_values_', ROI_label, '_', class_label, '_sem_run1.mat']);sem_run1=coPM;
    load([sufs.connect, 'dec_values_', ROI_label, '_', class_label, '_epi_run2.mat']);epi_run2=coPM;
    load([sufs.connect, 'dec_values_', ROI_label, '_', class_label, '_sem_run2.mat']);sem_run2=coPM;
    load([sufs.connect, 'dec_values_', ROI_label, '_', class_label, '_epi_run3.mat']);epi_run3=coPM;
    load([sufs.connect, 'dec_values_', ROI_label, '_', class_label, '_sem_run3.mat']);sem_run3=coPM;
    load([sufs.connect, 'dec_values_', ROI_label, '_', class_label, '_epi_run4.mat']);epi_run4=coPM;
    load([sufs.connect, 'dec_values_', ROI_label, '_', class_label, '_sem_run4.mat']);sem_run4=coPM;
    
    %% Fun beggins (scanning parameters)
    matlabbatch{1}.spm.stats.fmri_spec.dir = {[sufs.connect, 'GLM_', class_label, '_', ROI_label, '/']}; % Output folder
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.8; % TR
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 72; % n slices
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 36; % reference slice for slicetime correction
    
    %% first run
    filter = ['^', sub_code,  '_ses-01_task-feedBES_run-1_space-',space,'_desc-sm_bold.nii$'] ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(spm_select('FPList',[sufs.brain, 'ses-01/func/'],filter));
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {[sufs.beh, '/spm_episem_run1.mat']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {''}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {[sufs.connect, 'covar_dec_values_', ROI_label, '_', class_label, '_run1.txt']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
    %% second run
    filter = ['^', sub_code,  '_ses-01_task-feedBES_run-2_space-',space,'_desc-sm_bold.nii$'] ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(spm_select('FPList',[sufs.brain, 'ses-01/func/'],filter));
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {[sufs.beh, '/spm_episem_run2.mat']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {''}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {[sufs.connect, 'covar_dec_values_', ROI_label, '_', class_label, '_run2.txt']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;
    %% third run
    filter = ['^', sub_code,  '_ses-02_task-feedBES_run-3_space-',space,'_desc-sm_bold.nii$'] ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).scans = cellstr(spm_select('FPList',[sufs.brain, 'ses-02/func/'],filter));
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi = {[sufs.beh, '/spm_episem_run3.mat']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress = struct('name', {''}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi_reg = {[sufs.connect, 'covar_dec_values_', ROI_label, '_', class_label, '_run3.txt']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).hpf = 128;
    %% fourth run
    filter = ['^', sub_code,  '_ses-02_task-feedBES_run-4_space-',space,'_desc-sm_bold.nii$'] ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).scans = cellstr(spm_select('FPList',[sufs.brain, 'ses-02/func/'],filter));
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).multi = {[sufs.beh, '/spm_episem_run4.mat']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).regress = struct('name', {''}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).multi_reg = {[sufs.connect, 'covar_dec_values_', ROI_label, '_', class_label, '_run4.txt']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).hpf = 128;
    %%  model spec
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {[main_folder, '/masks/tpl-MNI152NLin2009cAsym_res-02_label-GM_bin.nii']};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    %% model estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    spm_jobman('run', matlabbatch); % tell SPM to run
    clear matlabbatch;
end
