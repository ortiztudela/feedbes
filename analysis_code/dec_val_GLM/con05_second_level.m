%% FeedBES. FeedBack signals from Episodic and Semantic memories"
% author: "Javier Ortiz-Tudela" (Goethe Uni)
% ---
% *Contact: ortiztudela@psych.uni-frankfurt.de*

% Second level analysis
which_sub=[1:5,7:30];
% Which classification?
% Which classification?
cAnal=5;
if cAnal==2; class_label='scn';elseif cAnal==3; class_label='obj';
elseif cAnal==5; class_label='XC';end
ROI_label='LOC_neurosynth';

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath('/home/javier/pepe/2_Analysis_Folder/_common_software/spm12')

% Contrasts labels
cont_labels={'dec_episodic';'dec_semantic';'dec_episem'};

%% loop over contrasts
for cContrast = 1:length(cont_labels)
    
    % Get contrast name
    cont_label= cont_labels{cContrast};
    
    % Output folder
    output_folder=[main_folder, '/outputs/group_level/connect/GLM_', class_label, '_',ROI_label,'/', cont_label];
    
    
    %% start looping over subjects
    c=1;
    for cSub = which_sub
        
        % Get folder structure
        [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
        
        % Get contrast 1st level files
        file_names{c,1}=[sufs.connect, 'GLM_', class_label, '_',ROI_label,'/con_000', num2str(cContrast), '.nii'];
        c=c+1;
    end
    
    %% Fun begins
    % Nothing needs to be changed from here on
    matlabbatch{1}.spm.stats.factorial_design.dir = {output_folder};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = file_names;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = cont_label;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
end